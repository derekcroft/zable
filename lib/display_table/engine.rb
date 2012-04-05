require 'display_table'
require 'rails'
require 'action_controller'

module DisplayTable
  class Engine < Rails::Engine
    initializer "static assets" do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
    end
  end
end