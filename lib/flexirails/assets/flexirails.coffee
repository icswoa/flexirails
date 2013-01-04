#  Project: Flexirails
#  Description:
#  Copyright 2010 - 2012, Raphael Randschau
#  License: MIT

(($, window) ->
  pluginName = 'flexirails'
  document = window.document

  firstPageSVG = '<svg version="1.2" baseProfile="tiny" id="Navigation_first" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="16px" height="16px" viewBox="0 0 512 512" overflow="inherit" xml:space="preserve"> <path d="M186.178,256.243l211.583,166.934V89.312L186.178,256.243z M112.352,422.512h66.179V89.975h-66.179V422.512z"/> </svg>'
  prevPageSVG = '<svg version="1.2" baseProfile="tiny" id="Navigation_left" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="16px" height="16px" viewBox="0 0 512 512" overflow="inherit" xml:space="preserve"> <polygon points="148.584,255.516 360.168,88.583 360.166,422.445 "/> </svg>'
  lastPageSVG = '<svg version="1.2" baseProfile="tiny" id="Navigation_last" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="16px" height="16px" viewBox="0 0 512 512" overflow="inherit" xml:space="preserve"> <path d="M111.708,424.514l211.581-166.927L111.708,90.654V424.514z M330.935,87.311v332.544h66.173V87.311H330.935z"/> </svg>'
  nextPageSVG = '<svg version="1.2" baseProfile="tiny" id="Navigation_right" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="16px" height="16px" viewBox="0 0 512 512" overflow="inherit" xml:space="preserve"> <polygon points="360.124,255.513 148.535,422.442 148.537,88.58 "/> </svg>'

  defaults =
    # how many items to fetch when querying for data
    limitFetchResultsTo: 50
    # how many items to display on each page
    limitDisplayPerPageTo: 25
    # per page selection options
    limitDisplayPerPageOptions: [5, 25, 50, 100, 250]

    locales:
      no_results: 'No results found'
      results:
        perPage: 'Results per Page:'
        page: 'Page '
        of: ' of '
        total: ' Results'

  extractAttribute = (obj, qualifiedName) ->
    parts = qualifiedName.split(".")
    current = obj

    for part in parts
      if current.hasOwnProperty part
        current = current[part]
      else
        break

    value = current
    attribute = parts[parts.length-1]
    if value? && typeof(value) is 'object'
      if value.hasOwnProperty(attribute)
        value = current[attribute]
      else
        value = null

    return value

  #
  class Flexirails
    t: (name) -> return extractAttribute(@options.locales, name)

    constructor: (@element, options) ->
      @options = $.extend {}, defaults, options

      @_defaults = defaults
      @_name = pluginName

      @_formatterFunctions = {}
      @_currentView = options.view
      @_url = options.url
      @_pagination = {
        last: 1,
        first: 1
      }

      @locales = options.locales if options.hasOwnProperty 'locales'
      @setupEventListeners()

      @init()

    init: ->
      @initializingView = true;

      @_currentView.totalResults or= 1
      @_currentView.currentPage or= @_currentView.current_page or 1
      @_currentView.perPage or= @_currentView.per_page or 1

      @_currentView.currentPage = if @_currentView.hasOwnProperty('currentPage') then parseInt(@_currentView.currentPage, 10) else 1
      @_currentView.perPage = if @_currentView.hasOwnProperty('perPage') then parseInt(@_currentView.perPage, 10) else @_defaults.perPage

      @initializingView = false

      @flexiContainer = $(document.createElement('div')).addClass('flexirails')

      $(@flexiTable).remove() if @flexiTable?

      @flexiTable = document.createElement('table')
      @flexiContainer.append(@flexiTable)

      navigation = $(document.createElement('div'))
      @createNavigation(navigation)
      $(@element).append(navigation.clone())

      @flexiContainer.append(@flexiTable)
      $(@element).append(@flexiContainer)

      $(@element).append(navigation)

      @invalidateView()

    setupEventListeners: ->
      $(@element).on "click",  "a[name=toFirstPage]", @paginateToFirstPage
      $(@element).on "click",  "a[name=toPrevPage]", @paginateToPrevPage
      $(@element).on "click",  "a[name=toNextPage]", @paginateToNextPage
      $(@element).on "click",  "a[name=toLastPage]", @paginateToLastPage
      $(@element).on "change", ":input[name=current_page_box]", @paginateToAnyPage
      $(@element).on "change", ":input[name=per_page]", @changePerPage

    reloadFlexidata: ->
      if (!@_url? or @dontExecuteQueries or @initializingView or @loadingData)
        return

      $(@element).find(".js-fr-from-page").attr('disabled','disabled')
      request = $.ajax({
        type: 'GET',
        url: @_url,
        data: this.buildFlexiOptions(),
        dataType: 'json'
      })
      request.done @buildFlexiview

      @loadingData = true
      @appendResults = false

    buildFlexiview: (data, textStatus, XMLHttpRequest) =>
      @_currentView.totalResults = parseInt(data.total, 10) || 0

      @setFlexirailsOptions(data)

      fragment = document.createDocumentFragment()

      if (!@appendResults)
        while(@flexiTable.hasChildNodes())
          @flexiTable.removeChild(@flexiTable.firstChild);
        @loadedRows = 0

        header = document.createElement("tr")
        for col in @_currentView.cols
          th = document.createElement('th')
          th.className = col.attribute
          th.appendChild(document.createTextNode(col.title))
          header.appendChild(th)

        fragment.appendChild(header)

      arr = data.rows

      @loadedRows += arr.length
      cur_req = Math.round(@loadedRows / @_defaults.limitFetchResultsTo)

      if (arr.length is 0)
        _tr = document.createElement('tr')
        _tr.className = 'no_results'

        td = document.createElement('td')
        td.className = 'center'
        td.colSpan = @_currentView.cols.length
        td.appendChild(document.createTextNode(@t('no_results')))

        _tr.appendChild(td)
        fragment.appendChild(_tr)

      fragment.appendChild(@buildFlexiRow(item)) for item in arr

      @flexiTable.appendChild(fragment.cloneNode(true))

      @setupFirstLastColumns()

      @loadingData = false

      if ((@loadedRows < @_currentView.perPage) && (@loadedRows < @_currentView.totalResults))
        @appendFlexiData()
        if (@_currentView.currentPage is @_pagination.last)
          $(@element).find(".js-fr-from-page").removeAttr('disabled')
      else
        @appendResults = false;
        $(@element).find(".js-fr-from-page").removeAttr('disabled')
        $(@element).find(".flexirails-container").trigger("complete")

    appendFlexiData: ->
      if ((@_currentView.perPage * (@_currentView.currentPage - 1) + @loadedRows) < @_currentView.totalResults)
        @appendResults = true

        limit = @_defaults.limitFetchResultsTo
        if (@_currentView.perPage > 0)
          limit = Math.min( @_defaults.limitFetchResultsTo, @_currentView.perPage - @loadedRows )

        req = $.ajax({
          type: 'GET'
          url: @_url
          data: @buildFlexiOptions({}, {
            limit: limit
            offset: @loadedRows
          })
          dataType: 'json'
        })
        req.done @buildFlexiview

    buildFlexiRow: (obj) ->
      @prepareFormatters()

      _tr = document.createElement('tr')
      _tr.className = 'flexirow'

      if (obj.hasOwnProperty('id'))
        _tr.className += (' row-' + obj.id)

      for col, j in @_currentView.cols
        td = document.createElement 'td'
        @appendClasses(td, j, col)
        @_formatterFunctions[col.attribute](td, obj, col, extractAttribute(obj, col.attribute))
        _tr.appendChild(td)

      return _tr

    buildFlexiOptions: (options, override) ->
      opts = {}

      $.extend(opts, options)
      opts.pagination = {}
      opts.pagination.current_page = @_currentView.currentPage
      opts.pagination.per_page = @_currentView.perPage

      opts.limit = @_defaults.limitFetchResultsTo
      opts.offset = 0

      $.extend(opts, override)
      return opts

    changePerPage: (evt) => @updatePerPage($(evt.currentTarget).val())

    paginateToAnyPage: (evt) => @paginate($(evt.currentTarget).val())

    paginateToFirstPage: => @paginate(@_pagination.first)

    paginateToPrevPage: => @paginate(Math.max(parseInt(@_currentView.currentPage, 10) - 1, @_pagination.first))

    paginateToNextPage: => @paginate(Math.min(parseInt(@_currentView.currentPage, 10) + 1, @_pagination.last))

    paginateToLastPage: => @paginate(@_pagination.last)

    changePerPageOption: (evt) => @updatePerPage($(evt.currentTarget).val())

    paginate: (to_page) ->
      if (to_page > @_pagination.last || to_page < 1)
        $(@element).find(".js-fr-from-page").val(@_currentView.currentPage)
      if (@_currentView.currentPage != to_page)
        @_currentView.currentPage = parseInt(to_page, 10)

        @reloadFlexidata()

    appendClasses: (td, index, col) ->
      className = ''
      if (index is 0)
        className = 'first '
      else if (index is @_currentView.cols.length - 1)
        className = 'last '
      className += " #{col.attribute} "
      td.className = className

    updatePerPage: (new_per_page) =>
      if (new_per_page == -1)
        if (!confirm(@t('confirm.loadAll')))
          $(":input[name=per_page]").val(@_currentView.perPage)
          return

      if (new_per_page != @_currentView.perPage)
        @_currentView.currentPage = 1
        @_currentView.perPage = new_per_page

        @reloadFlexidata();

    setupFirstLastColumns: ->
      $(@element).find("td.first,th.first").removeClass("first")
      $(@element).find("td.last,th.last").removeClass("last")

      firstCol = @_currentView.cols[0]
      $(@element).find("td."+firstCol.cacheName).addClass("first")
      $(@element).find("th."+firstCol.cacheName).addClass("first")

      lastCol = @_currentView.cols[@_currentView.cols.length - 1]
      $(@element).find("td."+lastCol.cacheName).addClass("last")
      $(@element).find("th."+lastCol.cacheName).addClass("last")

    buildDefaultFlexiCell: (td, obj, col, val) ->
      if val?
        td.appendChild(document.createTextNode(val))
      else
        val = "-"
        td.className += 'center'

    setViewOptions: ->
      $(@element).find(".total_results").html(@_currentView.totalResults)
      $(@element).find(".js-fr-from-page").val(@_currentView.currentPage)
      $(@element).find(".to").html(@_pagination.last)
      $(@element).find(":input[name=per_page]").val(@_currentView.perPage)

    setFlexirailsOptions: (data) ->
      return if (@appendResults)

      @_pagination.last = Math.ceil(@_currentView.totalResults / (if @_currentView.perPage == -1 then data.total else @_currentView.perPage))
      @_currentView.currentPage = data.currentPage

      @setViewOptions()
      @dontExecuteQueries = false

      if (@_currentView.perPage == -1 || @_pagination.last == @_pagination.first)
        $(@element).find(".pagination.logic").hide()
      else
        $(@element).find(".pagination.logic").show()

    resetFormatters: ->
      @_formatterFunctions = {}

    registerFormatter: (keyPath, fnc) ->
      @_formatterFunctions[keyPath] = fnc

    updateRow: (obj) -> $(".row-" + obj.id, @flexiTable).replaceWith(@buildFlexiRow( obj ))

    createNavigation: (container) ->
      resultsPerPage = []

      for item in @_defaults.limitDisplayPerPageOptions
        resultsPerPage.push({
          value : item
          label : item
        })

      container.addClass('navigation')
      data =
        locales:
          "resultsPerPage"    : @t('results.perPage', this)
          "page"              : @t('results.page', this)
          "of"                : @t('results.of', this)
        "resultsPerPage"      : resultsPerPage
      navigation = '<div class="results">'+
            '<span class="total_results">1</span>'+
            ' Ergebnisse,'+
          '</div>'+
          '<div>'+data.locales.resultsPerPage+'</div>'+
          '<div class="select">'+
            '<select id="per_page" name="per_page">';
      for item in resultsPerPage
        navigation += '<option value="'+item.value+'">'+item.label+'</option>'
      navigation += '</select>'+
          '</div>'+
          '<div class="pagination">'+
            '<a name="toFirstPage"><span class="first">'+firstPageSVG+'</span></a>'+
            '<a name="toPrevPage"><span class="prev">'+prevPageSVG+'</span></a>'+
            '<div class="page">'+
              '<span>'+data.locales.page+'</span>'+
              '<input class="js-fr-from-page" name="current_page_box" type="text">'+
              '<span>'+data.locales.of+'</span>'+
              '<span class="to">1</span>'+
            '</div>'+
            '<a name="toNextPage"><span class="next">'+nextPageSVG+'</span></a>'+
            '<a name="toLastPage"><span class="last">'+lastPageSVG+'</span></a>'+
          '</div>';

      container.append(navigation)

    prepareFormatters: ->
      for col in @_currentView.cols
        if (!@_formatterFunctions.hasOwnProperty(col.attribute))
          @_formatterFunctions[col.attribute] = @buildDefaultFlexiCell

    invalidateView: ->
      @dontExecuteQueries = true

      @setViewOptions()

      if (@_pagination.last is @_pagination.first || @_currentView.totalResults is 0)
        $(@element).find(".pagination.logic").hide()
      else
        $(@element).find(".pagination.logic").show()

      @dontExecuteQueries = false;
      @prepareFormatters()
      @reloadFlexidata()

  # A really lightweight plugin wrapper around the constructor,
  # preventing against multiple instantiations
  $.fn[pluginName] = (options) ->
    @each ->
      if !$.data(this, "plugin_#{pluginName}")
        $.data(@, "plugin_#{pluginName}", new Flexirails(@, options))
        $(this).trigger 'initialized'

)(jQuery, window)