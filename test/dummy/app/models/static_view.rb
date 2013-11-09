class StaticView < Flexirails::ArrayView
  def columns
    %w(id name)
  end
end