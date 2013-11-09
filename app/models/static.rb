class Static < Struct.new(:id, :name)
  def full_name
    "##{id} #{name}"
  end
end