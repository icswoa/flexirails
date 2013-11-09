class StaticController < ApplicationController
  def index
  end

  protected
  def static_view
    @static_view ||= StaticView.new(params, items)
  end
  helper_method :static_view

  def items
    [
      Static.new(1, "James Tiberius Kirk"),
      Static.new(2, "Commander Spock"),
      Static.new(3, "Leonard McCoy"),
      Static.new(4, "Montgomery Scott"),
      Static.new(5, "Lieutenant Uhura"),
      Static.new(6, "Hikaru Sulu")
    ]
  end
end