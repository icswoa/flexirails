# encoding: utf-8
module Flexirails
  class View
    attr_reader :responder

    delegate :current_page, :per_page, to: :responder

    def initialize responder
      @responder = responder
    end

    def data_url
      raise 'ImplentationMissing'
    end

    def sortable_columns
      return %w()
    end

    def columns
      raise 'ImplentationMissing'
    end

    def i18n_scope clazz = self.class
      return clazz.name.tableize.singularize.gsub('/','.')
    end

    def i18n_default name
      scopes = []
      clazz = self.class
      clazz.ancestors.each do |ancestor|
        break if ancestor == Object
        scopes << [i18n_scope(ancestor),name].compact.join('.').to_sym
      end
      return scopes
    end

    def t name, args = {}
      I18n.t([i18n_scope,name].compact.join('.'), { default: i18n_default(name) }.merge(args))
    end

    def to_h
      return {
        :currentPage => self.current_page,
        :perPage => self.per_page,
        :cols => columns.map { |column|
          {
            :title => t(column),
            :attribute => column,
            :visible => 1,
            :sortable => sortable_columns.include?(column)
          }
        }
      }
    end

    def as_json
      {
        rows: responder.rows,
        total: responder.total,
        currentPage: current_page,
        perPage: per_page
      }
    end

    def as_html
      return <<-CONTENT
<div class="flexirails-container"></div>
<script type="text/javascript" async>
  var aView = JSON.parse('#{to_h.to_json}');
  var aLocales = {
    no_results: '#{I18n.t(:'flexirails.no_results')}',
    results: {
      perPage         :   '#{I18n.t(:'flexirails.navigation.per_page')}',
      page            :   '#{I18n.t(:'flexirails.navigation.page')}',
      of              :   '#{I18n.t(:'flexirails.navigation.of')}',
      total           :   '#{I18n.t(:'flexirails.navigation.results')}',
      numberOf        :   '#{I18n.t(:'flexirails.results')}'
    }
  }

  $('.flexirails-container').flexirails({
    view: aView,
    url: '#{self.data_url}',
    locales: aLocales
  });
</script>
CONTENT
    end
  end
end