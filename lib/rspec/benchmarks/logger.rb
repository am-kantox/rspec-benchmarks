module RSpec
  module Benchmarks
    # FIXME Print most queried tables
    class Logger
      QUERY_TYPES = {
        unknown: nil,
        db: /^(select|create|update|delete|insert)\b/i,
        req: /\A\s*Started (GET|POST|PUT|DELETE|PATCH)/
      }

      def time type = nil
        (queries.sum { |e| type.nil? || e[:type] == type ? e[:time] : 0 } * 1000).round
      end

      def count type = nil
        type.nil? ? queries.size : queries.select { |q| q[:type] == type.to_sym }.size
      end

      def report
        QUERY_TYPES.map do |type, _|
          [type, { time: time(type), count: count(type) }]
        end.to_h
      end

      def reset!
        @queries = []
        @pause = false
      end

      def log query
        return if pause?

        queries << query
      end

      def pause= pause
        @pause = pause
      end

      def pause!
        pause = true
      end

      def pause?
        @pause ||= false
      end

      def reset= reset
        @reset = reset
      end

      def reset?
        @reset ||= false
      end

      def queries
        @queries ||= []
      end

      def initialize
        reset!
      end
      Default = Logger.new
      private_class_method :new
    end
  end
end
