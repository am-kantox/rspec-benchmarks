require 'rails/railtie'

module RSpec
  module Benchmarks
    class Middleware
      def initialize(app)
        @app = app
      end

      def call(env)
        RSpec::Benchmarks::Logger::Default.reset! if RSpec::Benchmarks::Logger::Default.reset?
        @app.call(env).tap {
          puts "==[TIME]==> #{RSpec::Benchmarks::Logger::Default.report}"
        }
      end
    end
  end
end

if defined?(::Rails::Railtie)
  class RSpec::Benchmarks::Railtie < ::Rails::Railtie
    initializer 'rspec_benchmarks.inject_middleware' do |app|
      app.config.middleware.use 'RSpec::Benchmarks::Middleware'
    end
  end
else
  ActionController::Dispatcher.middleware.use('RSpec::Benchmarks::Middleware')
end

ActiveRecord::ConnectionAdapters::AbstractAdapter.class_eval do
  def log_with_rspec_benchmarks(query, *args, &block)
    RSpec::Benchmarks::Logger::Default.log(query) do
      log_without_rspec_benchmarks(query, *args, &block)
    end
  end

  alias_method_chain :log, :rspec_benchmarks
end
