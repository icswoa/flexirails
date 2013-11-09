require "test_helper"

module Flexirails
  class ViewTest < ActiveSupport::TestCase
    class TestView < ::Flexirails::View
      def total
        10
      end
    end

    test "initialize with empty params" do
      view = TestView.new({})
      assert_equal 1, view.current_page
      assert_equal 0, view.offset
      assert_equal 25, view.per_page
      assert_equal nil, view.order
      assert_equal nil, view.direction
    end

    test "only accepts ASC and DESC as direction" do
      view = TestView.new({ :per_page => "5" })
    end

    test "initialize with different per_page" do
      view = TestView.new({ :per_page => "5" })
      assert_equal 5, view.per_page

      view = TestView.new({ :pagination => { :per_page => "5" } })
      assert_equal 5, view.per_page
    end

    test "initialize with current_page" do
      view = TestView.new({ :per_page => "5", :current_page => "2" })
      assert_equal 2, view.current_page

      view = TestView.new({ :pagination => { :per_page => "5", :current_page => "2" } })
      assert_equal 2, view.current_page

      view = TestView.new({ :per_page => "25", :current_page => "2" })
      assert_equal 1, view.current_page

      view = TestView.new({ :pagination => { :per_page => "25", :current_page => "2" } })
      assert_equal 1, view.current_page
    end
  end
end