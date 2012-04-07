require 'zable/zable_test_helper'

module ZableTestHelper
  def self.included(base)
    ZableHelper.module_eval do
      def pagination_element(*args)
        ''.html_safe
      end
    end
  end
end
