require 'display_table/display_table_test_helper'

module DisplayTableTestHelper
  def self.included(base)
    DisplayTableHelper.module_eval do
      def pagination_element(*args)
        ''.html_safe
      end
    end
  end
end