# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!

# Run any available migration
ActiveRecord::Migrator.migrate File.expand_path("../dummy/db/migrate/", __FILE__)

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

require 'pp'
require 'mocha'

module TestPatches

  # rather than including ZableHelper into Object, which is rather imprecise,
  # include it into the ActionView::TestCase
  def self.included(base)
    base.send :include, ZableHelper
  end

  def setup
    @COLUMNS = [
      { :name => :string_column },
      { :name => :integer_column },
      { :name => :string_column_2 }
    ]
    @COLUMN_PROC = Proc.new {
      column :string_column
      column :integer_column
      column :string_column_2 }
    @COLUMN_PROC_RETURNING_NIL = Proc.new {
      column :string_column
      column :integer_column
      column :string_column_2
      nil }
    mock_controller
  end

  # Create a mock controller for ZableHelper to interact with in unit tests
  def mock_controller
    @controller = ActionView::TestCase::TestController.new
    @controller.request = ActionDispatch::TestRequest.new
    @controller.request.instance_variable_set :@zable_columns, []
  end

  # ZableHelper stores data on the controller's request,
  # this method is the mock implementation of ActionView::Base#controller
  def controller
    @controller
  end
end

ActionView::TestCase.send(:include, TestPatches)



# HELPERS

def click_link(selector)
  links = css_select(selector)
  raise Test::Unit::AssertionFailedError.new("No link with selector \"#{selector}\" found.") if links.empty?
  link = links.first
  href_match = link.to_s.match(/href=['|"]([^'"]*)['|"]/)
  raise Test::Unit::AssertionFailedError.new("Link with selector \"#{selector}\" has no href attribute.") if href_match.nil?
  href = href_match[1]
  get href
end