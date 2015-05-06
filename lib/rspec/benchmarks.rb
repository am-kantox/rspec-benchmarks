require 'rspec/benchmarks/version'

require 'rspec/benchmarks/parser/rparsec'
require 'rspec/benchmarks/parser/sql/sql'
require 'rspec/benchmarks/parser/sql/sql_parser'

require 'rspec/benchmarks/beauty_caller'
require 'rspec/benchmarks/payload'
require 'rspec/benchmarks/logger'
require 'rspec/benchmarks/middleware'

module RSpec
  module Benchmarks
    require "rspec/core"
    ::RSpec::configure do |config|
      config.around(:each) do |example|
        RSpec::Benchmarks::Logger::Default.reset!
        time = Benchmark.realtime do
          example.run
        end
        RSpec::Benchmarks::Logger::Default.pause!

        puts "#{'=' * 32} #{'%10.3f' % time} sec #{'=' * 32}"
        RSpec::Benchmarks::Logger::Default.queries.
          map(&:payload).
          group_by(&:type).
          to_a.
          map do |type, qs|
            [type, qs.group_by(&:id).to_a.map { |id, qs| [id, qs.map(&:time).compact.inject(:+) || 0]}]
          end.each do |key, qs|
            puts "#{'%11s' % key} :: #{'%50.50s' % (qs.length == 1 ? qs.first.first : '')} :: #{'%10.6f' % qs.map(&:last).inject(:+)}s"
          end

        puts '=' * 80
        puts "\n"
      end
    end
  end
end
