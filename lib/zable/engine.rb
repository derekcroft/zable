require 'zable'
require 'rails'
require 'action_controller'

module Zable
  class Engine < Rails::Engine
    initializer "static assets" do |app|
    end
  end
end
