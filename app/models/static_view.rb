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

  def render_actions row, context
    return context.render partial: 'actions', locals: { attendance: row }
  end

  def sortable_columns
    return %w(id name)
  end

  def columns
    sortable_columns + %w(full_name)
  end
end