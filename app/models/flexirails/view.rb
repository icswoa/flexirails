# encoding: utf-8
module Flexirails
  class View
    attr_reader :current_page, :per_page, :responder

    delegate :current_page, :per_page, to: :responder

    def initialize responder
      @responder = responder
    end

    def data_url
      raise 'ImplentationMissing'
    end

    def columns
      raise 'ImplentationMissing'
    end

    def to_h
       {
        :currentPage => self.current_page,
        :perPage => self.per_page,
        :cols => columns.map { |column|
          {
            :title => column,
            :attribute => column,
            :visible => 1,
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
    no_results: 'Keine Einträge vorhanden',
    results: {
      perPage         :   '#{I18n.t(:'flexirails.navigation.per_page')}',
      page            :   '#{I18n.t(:'flexirails.navigation.page')}',
      of              :   '#{I18n.t(:'flexirails.navigation.of')}',
      total           :   '#{I18n.t(:'flexirails.navigation.results')}'
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