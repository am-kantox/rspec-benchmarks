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
        (queries.sum { |q| type.nil? || q.payload.type == type ? q.duration : 0 } * 1000).round(3)
      end

      def count type = nil
        type.nil? ? queries.size : queries.select { |q| q.payload.type == type.to_sym }.size
      end

      def report_raw
        queries.map do |q|
          Hashie::Mash.new([
            [:name, q.name], [:duration, q.duration],
            [:type, q.payload.type], [:id, q.payload.id],
            [:desc, q.payload.desc], [:query, q.payload.query],
            [:timing, q.payload.timing || {}]
          ].to_h)
        end
      end

      def report
        report_raw.group_by(&:type).map do |type, qs|
          grouped = qs.group_by(&:id).map do |id, qs|
            sums = qs.inject(duration: 0, db: 0, controller: 0, view: 0) do |memo, q|
              memo[:duration] += q[:duration] || 0
              memo[:db] += q[:timing][:db] || 0
              memo[:controller] += q[:timing][:controller] || 0
              memo[:view] += q[:timing][:view] || 0
              memo
            end
            [id, sums]
          end.to_h
          #⇒ {"BEGIN"=>{:duration=>0.448338, :db=>0, :controller=>0, :view=>0}, "COMMIT"=>{:duration=>0.309235, :db=>0, :controller=>0, :view=>0},...
          top = grouped.max_by { |k, v| k =~ /^(select|update|insert|delete|create)/i && v[:duration] || 0 }.first
          collapsed = case grouped.length
                      when 1 then grouped
                      else
                        sums = grouped.inject(duration: 0, db: 0, controller: 0, view: 0) do |memo, q|
                          memo[:duration] += q.last[:duration] || 0
                          memo[:db] += q.last[:db] || 0
                          memo[:controller] += q.last[:controller] || 0
                          memo[:view] += q.last[:view] || 0
                          memo
                        end
                        Hash(:"+#{grouped.length - 1} #{top}" => sums)
                      end
          [type, collapsed]
        end.to_h
      end

      def reset!
        (_, @pause, @queries = @queries, false, []).first
      end

      def log query
        return if pause? || query.nil?
        fail ArgumentError.new("#{query.class} passed to RSpec::Benchmarks::Logger.log instean of Event") \
          unless query.is_a?(ActiveSupport::Notifications::Event)
        queries << query
      end

      def pause= pause
        @pause = pause
      end

      def pause!
        pause = true
        queries
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
