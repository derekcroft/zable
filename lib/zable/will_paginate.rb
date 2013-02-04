require 'will_paginate/view_helpers/link_renderer'

module Zable
  module WillPaginate
    class LinkWithParamsRenderer < ::WillPaginate::ViewHelpers::LinkRenderer

      def initialize(zable_view, params = {})
        @zable_view = zable_view
        @params = params
      end

      def url(page)
        page_param = @zable_view.param(:page, :num, page)
        all_params = [page_param, @zable_view.current_sort_params, @zable_view.search_params].reject(&:blank?).join("&".html_safe)
        @zable_view.current_url << "?".html_safe << all_params
      end

    protected

      def default_url_params
        super.merge(@params)
      end

    end
  end
end
