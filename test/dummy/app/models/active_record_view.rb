class ActiveRecordView < Flexirails::View
  def query offset, limit
    scope = if order_results?
      Person.order("#{order} #{direction}")
    else
      Person
    end

    scope.offset(offset).limit(limit)
  end

  def total
    Person.count
  end

  def sortable_columns
    %w(id firstname lastname)
  end

  def columns
    sortable_columns
  end
end