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

  # rather than including DisplayTableHelper into Object, which is rather imprecise,
  # include it into the ActionView::TestCase
  def self.included(base)
    base.send :include, DisplayTableHelper
  end

  def setup
    @COLUMNS = [
      { :name => :string_column },
      { :name => :integer_column },
      { :name => :string_column_2 }
    ]
    @COLUMN_PROC = -> {
      column :string_column
      column :integer_column
      column :string_column_2 }
    @COLUMN_PROC_RETURNING_NIL = -> {
      column :string_column
      column :integer_column
      column :string_column_2
      nil }
    mock_controller
  end

  # Create a mock controller for DisplayTableHelper to interact with in unit tests
  def mock_controller
    @controller = ActionView::TestCase::TestController.new
    @controller.request = ActionDispatch::TestRequest.new
    @controller.request.instance_variable_set :@display_table_columns, []
  end

  # DisplayTableHelper stores data on the controller's request,
  # this method is the mock implementation of ActionView::Base#controller
  def controller
    @controller
  end
end

ActionView::TestCase.send(:include, TestPatches)
