module RSpec
  module Benchmarks
    class BeautyCaller
      PARAMS = [:file, :line, :meth]
      def self.yo
        BeautyCaller.new.result
      end

      attr_reader :stack
      def initialize base = nil
        @stack = caller
        @base = base
      end

      def based
        detect(stack, @base).tap { |h| h && h.merge(type: :based) }
      end
      def local
        (Kernel.const_defined?('Rails') && detect(stack, Rails.root)).tap do |h|
          h && h.merge(type: :local)
        end
      end
      def dummy
        detect(stack, '').tap do |h|
          h && h.merge(type: :dummy)
        end
      end

      def result
        {
          location: based || local || PARAMS.zip([nil] * PARAMS.length).to_h,
          based: based,
          local: local,
          dummy: dummy,
          stack: stack
        }
      end

      def detect c, path
        path &&
          c.detect { |cc| cc[/\A(#{path}\/.+?):(\d+):in\s+`(.*?)'/] } &&
          PARAMS.zip(Regexp.last_match.captures).to_h
      end
      private :detect
    end
  end
end
