# encoding: utf-8
module Flexirails
  class Responder
    attr_reader :offset, :limit, :current_page, :per_page, :order, :direction

    def initialize params
      pagination = params || Hash.new

      @current_page = pagination.fetch(:current_page) { 1 }.to_i
      @per_page = pagination.fetch(:per_page) { 25 }.to_i
      @order = pagination.fetch(:order) { nil }
      @direction = pagination.fetch(:direction) { nil }

      @offset = (current_page-1) * per_page
      @limit = per_page
    end

    def order_results?
      return order.present? && direction.present?
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

    def rows
      raw_rows = query offset, limit
      raw_rows.map { |object| pluck object }
    end
  end
end