require 'will_paginate/view_helpers/link_renderer'

module Zable
  module WillPaginate
    class LinkWithParamsRenderer < ::WillPaginate::ViewHelpers::LinkRenderer

      def initialize(zable_view, params = {})
        @zable_view = zable_view
        @params = params
      end

      def url(page)
        page_params = {:page => {:num => page}}
        @zable_view.current_path_with_params(page_params, @zable_view.params.slice(:search, :sort), @params)
      end

    protected

      def default_url_params
        super.merge(@params)
      end

    end
  end
end
