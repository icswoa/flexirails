# encoding: utf-8
module Flexirails
  class View
    attr_reader :offset, :limit, :current_page, :per_page, :order, :direction, :url_params

    def initialize params, url_params = {}
      pagination = params.fetch(:pagination) { params || Hash.new }

      @current_page = pagination.fetch(:current_page) { 1 }.to_i
      @per_page = pagination.fetch(:per_page) { 25 }.to_i
      @order = sanitize(pagination.fetch(:order) { nil })
      @direction = sanitize_direction(pagination.fetch(:direction) { nil })
      @url_params = url_params

      if @current_page > total_page_count
        @current_page = 1
      end

      @offset = (current_page-1) * per_page
      @limit = per_page
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
    def prev_path
      return has_prev_path ? url({pagination: pagination_hash.merge({current_page: current_page - 1})}.merge(url_params)) : first_path
    end
    def first_path
      return url({pagination: pagination_hash.merge({current_page: 1})}.merge(url_params))
    end
    def has_next_path
      return self.current_page < total_page_count
    end
    def next_path
      return has_next_path ? url({pagination: pagination_hash.merge({current_page: current_page + 1})}.merge(url_params)) : last_path
    end
    def last_path
      return url({pagination: pagination_hash.merge({current_page: self.total_page_count})}.merge(url_params))
    end
    def current_url(options = {})
      return url({pagination: pagination_hash}.merge(url_params).merge(options))
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
      return self.send method_to_call.to_sym, row, context
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