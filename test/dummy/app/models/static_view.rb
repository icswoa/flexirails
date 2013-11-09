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

  def columns
    %w(id name)
  end
end