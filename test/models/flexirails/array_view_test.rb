require 'test_helper'

module Flexirails
  class ArrayViewTest < ActiveSupport::TestCase
    Point = Struct.new(:x, :y)

    class TestView < ::Flexirails::ArrayView
      def columns
        %w(x, y)
      end
    end

    attr_reader :items
    def setup
      @items = []
      10.times do |i|
        @items << Point.new(i, i)
      end
    end

    test "test_view correct total" do
      assert_equal items.size, TestView.new({}, items).total
    end

    test "returns all items if per_page > total" do
      view = TestView.new({ :per_page => "25" }, items)
      assert_equal view.items, view.rows
    end

    test "returns correct items for current_page" do
      view = TestView.new({ :per_page => "3", :current_page => "1" }, items)
      assert_equal view.items[0..2], view.rows

      refute view.has_prev_path
      assert view.has_next_path

      view = TestView.new({ :per_page => "3", :current_page => "2" }, items)
      assert_equal view.items[3..5], view.rows

      assert view.has_prev_path
      assert view.has_next_path
    end
  end
end