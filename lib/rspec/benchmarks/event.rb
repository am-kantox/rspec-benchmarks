require 'active_support/json'
require 'active_support/core_ext'

module RSpec
  module Benchmarks

    # Subclass of ActiveSupport Event :: Rethrowable
    class Event < ::ActiveSupport::Notifications::Event
      attr_reader :duration

      def initialize(name, start, ending, transaction_id, payload)
        super(name, start, ending, transaction_id, hash_it(payload))
        @duration = 1000.0 * (ending - start)

      end

      def hash_it garbage
        case garbage
        when Hash then garbage
        when ->(g) { File.exist? g } then Hashie.Mash.load(g)
        when String then Hash(payload: garbage)
        when OpenStruct then garbage.each_pair.to_h
        when ->(g) { !g.instance_variables.length.zero? }
          garbage.instance_variables.map do |iv|
            [iv, garbage.instance_variable_get(iv)]
          end.to_h
        else Hash(payload: "#{garbage}")
        end
      end
    end
  end
end
