class StaticView < Flexirails::View
  attr_reader :items
  def initialize params, items
    @items = items
    super params
  end

  def query offset, limit
    items[offset..(offset+limit-1)]
  end

  def total
    items.size
  end

  def url *args
    Rails.application.routes.url_helpers.company_attendances_path(*args)
  end

  def columns
    %w(id name)
  end
end