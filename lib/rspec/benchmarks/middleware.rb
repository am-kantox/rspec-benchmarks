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

    class Notifications
      # Subscribe to all events relevant to RSpec/Benchmarks
      def self.subscribe
        new.
          subscribe('sql.active_record').
          subscribe('render_partial.action_view').
          subscribe('render_template.action_view').
          subscribe('process_action.action_controller.exception').
          subscribe('console_logger.message').
          subscribe('process_action.action_controller')
      end

      def subscribe(event_name)
        ActiveSupport::Notifications.subscribe(event_name) do |*args|
          name, start, ending, transaction_id, payload = args
          payload = RSpec::Benchmarks::Payload.yo(name, payload.merge(RSpec::Benchmarks::BeautyCaller.yo))
          event = ActiveSupport::Notifications::Event.new(name, start, ending, transaction_id, payload)
          RSpec::Benchmarks::Logger::Default.log event
        end
        self
      end

    end

  end
end

if defined?(::Rails::Railtie)
  class RSpec::Benchmarks::Railtie < ::Rails::Railtie
    initializer 'rspec_benchmarks.inject_middleware' do |app|
      app.config.middleware.use 'RSpec::Benchmarks::Middleware'
    end
    initializer 'rspec_benchmarks.subscribe_to_notifications' do
      RSpec::Benchmarks::Notifications.subscribe
    end
  end
else
  ActionController::Dispatcher.middleware.use('RSpec::Benchmarks::Middleware')
  RSpec::Benchmarks::Notifications.subscribe
end

# ActiveRecord::ConnectionAdapters::AbstractAdapter.class_eval do
#   def log_with_rspec_benchmarks(query, *args, &block)
#     RSpec::Benchmarks::Logger::Default.log(query) do
#       log_without_rspec_benchmarks(query, *args, &block)
#     end
#   end
#
#   alias_method_chain :log, :rspec_benchmarks
# end
