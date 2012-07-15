/**
 * Flexirails - a plugin for the jQuery JavaScript Library
 * http://jquery.com/
 *
 * Copyright 2010-2012, Raphael Randschau
 * licensed under the MIT license.
 */
(function($, undefined) {
  var firstPageSVG = '<svg version="1.2" baseProfile="tiny" id="Navigation_first" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="16px" height="16px" viewBox="0 0 512 512" overflow="inherit" xml:space="preserve"> <path d="M186.178,256.243l211.583,166.934V89.312L186.178,256.243z M112.352,422.512h66.179V89.975h-66.179V422.512z"/> </svg>';
  var prevPageSVG = '<svg version="1.2" baseProfile="tiny" id="Navigation_left" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="16px" height="16px" viewBox="0 0 512 512" overflow="inherit" xml:space="preserve"> <polygon points="148.584,255.516 360.168,88.583 360.166,422.445 "/> </svg>';
  var lastPageSVG = '<svg version="1.2" baseProfile="tiny" id="Navigation_last" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="16px" height="16px" viewBox="0 0 512 512" overflow="inherit" xml:space="preserve"> <path d="M111.708,424.514l211.581-166.927L111.708,90.654V424.514z M330.935,87.311v332.544h66.173V87.311H330.935z"/> </svg>';
  var nextPageSVG = '<svg version="1.2" baseProfile="tiny" id="Navigation_right" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="16px" height="16px" viewBox="0 0 512 512" overflow="inherit" xml:space="preserve"> <polygon points="360.124,255.513 148.535,422.442 148.537,88.58 "/> </svg>';

  var defaults = {};
  function Flexirails( element, options ) {
    if (options === undefined) {
      options = {};
    }

    this.formatterFunctions = {};
    this.currentView = null;

    this.pagination = {
      last              : 1,
      first             : 1
    };
    
    this.defaults = {
      maxResultsPerQuery    : 50,
      perPage               : 25,
      perPageOptions        : [5, 25, 50, 100, 250]
    };
    

    this.element = element;
    this.$element = $(element);
    this.options = $.extend({}, defaults, options);

    this._defaults = defaults;
    this._name = 'flexirails';

    if (options.hasOwnProperty('locales')) {
      this.locales = options.locales;
    }
    
    this.currentView = options.view;
    this.requestURL = options.url;
    
    this.init();
    return this;
  };

  // Registers an custom cell formatter for a given object-attribute path
  Flexirails.prototype.registerFormatter = function(keyPath, fnc) {
      this.formatterFunctions[keyPath] = fnc;
  };
    
  Flexirails.prototype.updateRow = function(obj) {
      var _tr = this.buildFlexiRow( obj );
      $(".row-"+obj.id, this.flexiTable).replaceWith(_tr);
  };
   
    // Applies all view related settings to the current DOM
  Flexirails.prototype.invalidateView = function() {
    this.dontExecuteQueries = true;
      
    this.setViewOptions();

    if (this.pagination.last == this.pagination.first || this.currentView.totalResults === 0) {
      this.$element.find(".pagination.logic").hide();
    } else {
      this.$element.find(".pagination.logic").show();
    }
      
    this.dontExecuteQueries = false;

    for (var j = 0; j < this.currentView.cols.length; j++) {
      if (!this.formatterFunctions.hasOwnProperty(this.currentView.cols[j].attribute)) {
        this.formatterFunctions[this.currentView.cols[j].attribute] = buildDefaultFlexiCell;
      }
    }

    this.reloadFlexidata();
  }

  Flexirails.prototype.init = function() {
    this.initializingView = true;

    if (!this.currentView.hasOwnProperty('totalResults')) {
      this.currentView.totalResults = 1;
    }
    
    if (this.currentView.hasOwnProperty('current_page')) {
      this.currentView.currentPage = this.currentView.current_page;
      delete this.currentView.current_page;
    }
    this.currentView.currentPage = this.currentView.hasOwnProperty('currentPage') ? parseInt(this.currentView.currentPage, 10) : 1;
    
    if (this.currentView.hasOwnProperty('per_page')) {
      this.currentView.perPage = this.currentView.per_page;
      delete this.currentView.per_page;
    }
    this.currentView.perPage = this.currentView.hasOwnProperty('perPage') ? parseInt(this.currentView.perPage, 10) : this.defaults.perPage;
    
    this.initializingView = false;
    
    this.flexiContainer  = $(document.createElement('div')).addClass('flexirails');
    
    if (this.flexiTable !== undefined) {
      $(this.flexiTable).remove();
    } 

    this.flexiTable      = document.createElement('table');
    this.flexiContainer.append(this.flexiTable);
    
    var topNavigation = $(document.createElement('div'));
    this.createNavigation(topNavigation);
    this.$element.append(topNavigation);
    
    this.flexiContainer.append(this.flexiTable);
    this.$element.append(this.flexiContainer);
    
    var bottomNavigation = $(document.createElement('div'));
    this.createNavigation(bottomNavigation);
    this.$element.append(bottomNavigation);

    this.invalidateView();
  };

  Flexirails.prototype.setLocales = function(d) {
    $.extend(true, fl, d);
  };

  $.fn.flexirails = function(options) {
    return this.each(function () {
      if (!$.data(this, 'plugin_flexirails')) {
        $.data(this, 'plugin_flexirails', new Flexirails(this, options));

        $(this).trigger('initialized');
      }
    });
  };

  function appendFlexiData() {
    if ((this.currentView.perPage * (this.currentView.currentPage - 1) + this.loadedRows) < this.currentView.totalResults) {
      this.appendResults = true;
      
      var limit = this.defaults.maxResultsPerQuery;
      if (this.currentView.perPage > 0) {
        limit = Math.min( this.defaults.maxResultsPerQuery, this.currentView.perPage - this.loadedRows );
      }
      
      $.ajax({
        type: 'GET',
        url: this.requestURL,
        data: buildFlexiOptions({}, {
          limit: limit,
          offset: this.loadedRows
        }),
        success: this.buildFlexiview.bind(this),
        dataType: 'json'
      });
    }
  }

  Function.prototype.bind = function(scope) {
    var _function = this;
  
    return function() {
      return _function.apply(scope, arguments);
    }
  };

  Flexirails.prototype.reloadFlexidata = function() {
    if (this.requestURL === null || this.dontExecuteQueries || this.initializingView || this.loadingData) {
      return;
    }

    this.$element.find(".js-fr-from-page").attr('disabled','disabled');
    $.ajax({
      type: 'GET',
      url: this.requestURL,
      data: this.buildFlexiOptions(),
      success: this.buildFlexiview.bind(this),
      dataType: 'json'
    });

    this.loadingData = true;
    this.appendResults = false;
  }

  Flexirails.prototype.setViewOptions = function() {
    this.$element.find(".total_results").html(this.currentView.totalResults);
    this.$element.find(".js-fr-from-page").val(this.currentView.currentPage);
    this.$element.find(".to").html(this.pagination.last);
    this.$element.find(":input[name=per_page]").val(this.currentView.perPage);
  }

  Flexirails.prototype.setFlexirailsOptions = function(data) {
    if (this.appendResults) {
      return;
    }

    this.pagination.last = Math.ceil(this.currentView.totalResults / (this.currentView.perPage == -1 ? data.total : this.currentView.perPage));
    this.currentView.currentPage = data.currentPage;
    
    this.setViewOptions();
    
    this.dontExecuteQueries = false;

    if (this.currentView.perPage == -1 || this.pagination.last == this.pagination.first) {
      this.$element.find(".pagination.logic").hide();
    } else {
      this.$element.find(".pagination.logic").show();
    }
  }

  function buildDefaultFlexiCell(td, obj, col, val) {
    if (val === undefined || val === null || val.length === 0) {
      val = "-";
      td.className += 'center';
    }
    td.appendChild(document.createTextNode(val));
  }

  Flexirails.prototype.appendClasses = function(td, index, col) {
    className = '';
    if (index === 0) {
      className = 'first ';
    } else if (index == this.currentView.cols.length-1) {
      className = 'last ';
    }
    className += col.attribute;
    td.className = className;
  }

  Flexirails.prototype.buildFlexiview = function(data, textStatus, XMLHttpRequest) {
    this.currentView.totalResults = parseInt(data.total, 10) || 0;
    
    this.setFlexirailsOptions(data);
    
    var fragment = document.createDocumentFragment();

    if (!this.appendResults) {
      while(this.flexiTable.hasChildNodes()) { this.flexiTable.removeChild(this.flexiTable.firstChild); }
      this.loadedRows = 0;

      var header = document.createElement("tr");
      for (var i = 0; i < this.currentView.cols.length; i++) {
        var col = this.currentView.cols[i];
        if (col.onlySearchable) {
          continue;
        }
        var th = document.createElement('th');
        th.className = col.attribute;
        th.appendChild(document.createTextNode(col.title));
        header.appendChild(th);
      }

      fragment.appendChild(header);
    }
    
    var arr = data.rows;
   
    this.loadedRows += arr.length;
    var cur_req = Math.round(this.loadedRows / this.defaults.maxResultsPerQuery);

    if (arr.length === 0) {
      var _tr = document.createElement('tr');
      _tr.className = 'no_results';
      var td = document.createElement('td');
      td.className = 'center';
      td.appendChild(document.createTextNode("Keine Einträge vorhanden"));
      _tr.appendChild(td);
      fragment.appendChild(_tr);
    }

    for (var j = 0; j < arr.length; j++) {
      fragment.appendChild(this.buildFlexiRow(arr[j]));
    }
    this.flexiTable.appendChild(fragment.cloneNode(true));

    this.setupFirstLastColumns();
    
    this.loadingData = false;
    
    if ((this.loadedRows < this.currentView.perPage) && (this.loadedRows < this.currentView.totalResults)) {
      appendFlexiData();
      if (this.currentView.currentPage == this.pagination.last) {
        this.$element.find(".js-fr-from-page").removeAttr('disabled');
      }
    } else {
      this.appendResults = false;
      this.$element.find(".js-fr-from-page").removeAttr('disabled');
      this.$element.find(".flexirails-container").trigger("complete");
    }
  }

  Flexirails.prototype.buildFlexiRow = function(obj) {
    var _tr = document.createElement('tr');
    _tr.className = 'flexirow';
    
    if (obj.hasOwnProperty('id')) {
      _tr.className += (' row-' + obj.id);
    }

    for (var j = 0; j < this.currentView.cols.length; j++) {
      var col = this.currentView.cols[j];
      var td = document.createElement('td');

      this.appendClasses(td, j, col);

      this.formatterFunctions[col.attribute](td, obj, col, $.extractAttribute(obj, col.attribute));
      
      _tr.appendChild(td);
    }

    return _tr;
  }

  Flexirails.prototype.buildFlexiOptions = function(options, override) {
    var opts = {};
    opts.flexirails = "index";

    $.extend(opts,options);
    opts.pagination = {};
    opts.pagination.current_page = this.currentView.currentPage;
    opts.pagination.per_page = this.currentView.perPage;

    opts.limit = this.defaults.maxResultsPerQuery;
    opts.offset = 0;
      
    $.extend(opts, override);
    return opts;
  }

  Flexirails.prototype.createNavigation = function(container) {
    if (!this.hasOwnProperty('navigationTemplate')) {
      this.navigationTemplateSource =
        '<div class="results">'+
          '<span class="total_results">1</span>'+
          ' Ergebnisse,'+
        '</div>'+
        '<div class="label">{{locales/resultsPerPage}}</div>'+
        '<div class="select">'+
          '<select id="per_page" name="per_page">'+
            '{{#resultsPerPage}}'+
              '<option value="{{value}}">{{label}}</option>'+
            '{{/resultsPerPage}}'+
          '</select>'+
        '</div>'+
        '<div class="pagination">'+
          '<a name="toFirstPage"><span class="first">'+firstPageSVG+'</span></a>'+
          '<a name="toPrevPage"><span class="prev">'+prevPageSVG+'</span></a>'+
          '<div class="page">'+
            '<span>{{locales/page}}</span>'+
            '<input class="js-fr-from-page" name="current_page_box" type="text">'+
            '<span>{{locales/of}}</span>'+
            '<span class="to">1</span>'+
          '</div>'+
          '<a name="toNextPage"><span class="next">'+nextPageSVG+'</span></a>'+
          '<a name="toLastPage"><span class="last">'+lastPageSVG+'</span></a>'+
        '</div>';
      this.navigationTemplate = Handlebars.compile(this.navigationTemplateSource);
    }

    var resultsPerPage = [];
    for (var i = 0; i < this.defaults.perPageOptions.length; i++) {
      resultsPerPage.push({
        value : this.defaults.perPageOptions[i],
        label : (this.defaults.perPageOptions[i] == -1 ? $.t('results.loadAll') : this.defaults.perPageOptions[i])
      });
    }
    
    container.addClass('navigation');
    var data = {
      "locales"             : {
        "resultsPerPage"    : $.t('results.perPage', this),
        "page"              : $.t('results.page', this),
        "of"                : $.t('results.of', this)
      },
      "resultsPerPage"      : resultsPerPage
    };
    var navigation = this.navigationTemplate(data);
    
    container.append(navigation);

    $(container).delegate("a[name=toFirstPage]","click", function(fl) { 
      return function() { 
        fl.paginateToFirstPage(this); 
      } 
    }(this) );
    $(container).delegate("a[name=toPrevPage]","click", function(fl) { 
      return function() { 
        fl.paginateToPrevPage(this); 
      }
    }(this) );
    $(container).delegate("a[name=toNextPage]","click", function(fl) { 
      return function() {
        fl.paginateToNextPage(this);
      }
    }(this) );
    $(container).delegate("a[name=toLastPage]","click", function(fl) { 
      return function() {
        fl.paginateToLastPage(this);
      }
    }(this) );
    $(container).delegate(":input[name=current_page_box]", "change", function(fl) { 
      return function() {
        fl.paginateToAnyPage(this);
      }
    }(this) );
    $(container).delegate(":input[name=per_page]", "change", function(fl) { 
      return function() {
        fl.changePerPage(this);
      } 
    }(this) );
  };

  Flexirails.prototype.changePerPage = function(elem) {
    this.updatePerPage($(elem).val());
  }
  Flexirails.prototype.paginateToAnyPage = function(elem) {
    this.paginate($(elem).val());
  }
  Flexirails.prototype.paginateToFirstPage = function(elem){
    this.paginate(this.pagination.first);
    return false;
  }
  Flexirails.prototype.paginateToPrevPage = function(elem) {
    this.paginate(Math.max(parseInt(this.currentView.currentPage, 10) - 1, this.pagination.first));
    return false;
  }
  Flexirails.prototype.paginateToNextPage = function(elem) {
    this.paginate(Math.min(parseInt(this.currentView.currentPage, 10) + 1, this.pagination.last));
    return false;
  }
  Flexirails.prototype.paginateToLastPage = function(elem){
    this.paginate(this.pagination.last);
    return false;
  }

  Flexirails.prototype.paginate = function(to_page) {
    if (to_page > this.pagination.last || to_page < 1) {
      $(".js-fr-from-page").val(this.currentView.currentPage);
    }
    if (this.currentView.currentPage != to_page) {
      this.currentView.currentPage = parseInt(to_page, 10);
      
      this.reloadFlexidata();
    }
  }

  Flexirails.prototype.changePerPageOption = function() {
    this.updatePerPage($(this).val());
  }

  Flexirails.prototype.updatePerPage = function(new_per_page) {
    if (new_per_page == -1) {
      if (!confirm($.t('confirm.loadAll'))) {
        $(":input[name=per_page]").val(this.currentView.perPage);
        return;
      }
    }

    if (new_per_page != this.currentView.perPage) {
      this.currentView.currentPage = 1;
      this.currentView.perPage = new_per_page;

      this.reloadFlexidata();
    }
  }

  Flexirails.prototype.setupFirstLastColumns = function() {
    this.$element.find("td.first,th.first").removeClass("first");
    this.$element.find("td.last,th.last").removeClass("last");

    for (var first = 0; first < this.currentView.cols.length; first++) {
      if (this.currentView.cols[first].visible) {
        this.$element.find("td."+this.currentView.cols[first].cacheName).addClass("first");
        this.$element.find("th."+this.currentView.cols[first].cacheName).addClass("first");
        break;
      }
    }

    for (var last = this.currentView.cols.length - 1; last >= 0; last--) {
      if (this.currentView.cols[last].visible) {
        this.$element.find("td."+this.currentView.cols[last].cacheName).addClass("last");
        this.$element.find("th."+this.currentView.cols[last].cacheName).addClass("last");
        break;
      }
    }
  }

  var fl = $.fl = {
    confirm : {
      loadAll           : 'Wirklich alle Ergebnisse laden?'
    },
    results : {
      perPage           : 'Ergebnisse pro Seite:',
      page              : 'Seite ',
      of                : ' von ',
      total             : ' Ergebnisse',
      loadAll           : 'Alle'
    }
  };

  $.extractAttribute = function(obj, qualifiedName) {
    var value;
    var parts = qualifiedName.split(".");
    var current = obj;
    
    for (var i = 1; i < parts.length; i++) {
      if (current.hasOwnProperty(parts[i])) {
        current = current[parts[i]];
      } else {
        break;
      }
    }

    value = current;
    var attribute = parts[parts.length-1];
    if (value !== null && typeof(value) == 'object') {
      if (value.hasOwnProperty(attribute)) {
        value = current[attribute];
      } else {
        value = null;
      }
    }

    return value;
  };

  $.t = function(path, fl) {
    return $.extractAttribute(fl.locales, 't.'+path);
  };
})(jQuery);
