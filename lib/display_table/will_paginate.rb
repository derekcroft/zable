require 'will_paginate/view_helpers/link_renderer'

module Zable
  module WillPaginate
    class LinkWithParamsRenderer < ::WillPaginate::ViewHelpers::LinkRenderer

      def initialize(params = {})
        @params = params
      end

    protected

      def default_url_params
        super.merge(@params)
      end

    end
  end
end
