# encoding: utf-8
module Flexirails
  class View
    attr_reader :offset, :limit, :current_page, :per_page, :order, :direction, :params

    def initialize params
      @params = params
      pagination = params.fetch(:pagination) { params || Hash.new }

      @current_page = pagination.fetch(:current_page) { 1 }.to_i
      @per_page = pagination.fetch(:per_page) { 25 }.to_i
      @order = sanitize(pagination.fetch(:order) { nil })
      @direction = sanitize_direction(pagination.fetch(:direction) { nil })

      if @current_page > total_page_count
        @current_page = 1
      end

      @offset = (current_page-1) * per_page
      @limit = per_page
    end

    def next_pagination_direction column
      if order == column
        if direction == "DESC"
          nil
        else
          if direction == nil
            "ASC"
          else
            "DESC"
          end
        end
      else
        "ASC"
      end
    end

    def total_page_count
      return (self.total.to_f / self.per_page.to_f).ceil
    end

    def total
      raise "ImplementationMissing"
    end

    def query offset, limit
      raise "ImplementationMissing"
    end

    def pluck object
      raise "ImplementationMissing"
    end

    def url(*args)
      raise 'ImplentationMissing'
    end

    def has_prev_path
      return self.current_page > 1
    end
    def has_next_path
      return self.current_page < total_page_count
    end

    def sortable_columns
      return %w()
    end

    def columns
      raise 'ImplentationMissing'
    end

    def order_results?
      return order.present? && direction.present?
    end

    def rows
      return @rows ||= query(offset, limit)
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

    def render_column column, row, context
      method_to_call = "render_#{column.gsub(/\./, '_')}"
      if self.respond_to?(method_to_call.to_sym)
        return self.send method_to_call.to_sym, row, context
      else
        parts = column.split('.').map(&:to_sym)
        object = row
        parts.each do |part|
          object = object.send(part)
        end
        return object
      end
    end

    def t name, args = {}
      I18n.t([i18n_scope,name].compact.join('.'), { default: i18n_default(name) }.merge(args))
    end

    def pagination_hash
      return {
        current_page: self.current_page,
        per_page: self.per_page,
        order: self.order,
        direction: self.direction
      }
    end

    private
    def sanitize_direction direction
      return %w(ASC DESC).include?(direction) ? direction : nil
    end
    def sanitize attribute
      return columns.include?(attribute) ? attribute : nil
    end
  end
end