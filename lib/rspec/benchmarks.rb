require 'rspec/benchmarks/version'

require 'rspec/benchmarks/parser/rparsec'
require 'rspec/benchmarks/parser/sql/sql'
require 'rspec/benchmarks/parser/sql/sql_parser'

require 'rspec/benchmarks/monkeypatches'
require 'rspec/benchmarks/beauty_caller'
require 'rspec/benchmarks/payload'
require 'rspec/benchmarks/logger'
require 'rspec/benchmarks/middleware'

module RSpec
  module Benchmarks
    require "rspec/core"

    SYMBOLS = { scs: ['107', '✔'], nfo: ['68', '✓'], wrn: ['226', '✗'], err: ['196', '✘'] }
    def self.report type, msg
      sym = SYMBOLS[type.to_sym]
      puts "\e[01;38;05;#{sym.first}m#{sym.last} #{msg}\e[0m"
    end

    TIMESLICE_SAMPLE = 1_000.0 / Benchmark.realtime do
      arr = []
      100_000.times do |i|
        id = (1..1_000).to_a.sample
        arr[id] ||= 0
        arr[id] += i
      end
      arr.shuffle
    end

    TIMESLICE_CRITICAL = [100.0, 200.0]

    def self.time_with_normalized
      msecs = Benchmark.realtime { yield if block_given? }
      [1_000.0 * msecs, msecs, TIMESLICE_SAMPLE * msecs]
    end

    ::RSpec::configure do |config|
      config.around(:each) do |example|
        RSpec::Benchmarks::Logger::Default.reset!
        time = RSpec::Benchmarks.time_with_normalized { example.run }
        success = if time.last > TIMESLICE_CRITICAL.last
                    :err
                  elsif time.last > TIMESLICE_CRITICAL.first
                    :wrn
                  else
                    :scs
                  end


        RSpec::Benchmarks::Logger::Default.pause!
        RSpec::Benchmarks.report success, "#{'=' * 30} #{'%8.2f' % time.first} ⌚ #{'%7.2f' % time.last} #{'=' * 30}"
        #⇒ :controller=>[#<Hashie::Mash desc=nil
        #                                duration=25.041808
        #                                id="Admin::ProfilesController#index"
        #                                name="process_action.action_controller"
        #                                query=nil
        #                                timing=#<Hashie::Mash db=0.975736 view=19.674158>
        #                                type=:controller>]
        result = RSpec::Benchmarks::Logger::Default.queries.
          map do |q|
            Hashie::Mash.new([
              [:name, q.name], [:duration, q.duration],
              [:type, q.payload.type], [:id, q.payload.id],
              [:desc, q.payload.desc], [:query, q.payload.query],
              [:timing, q.payload.timing || {}]
            ].to_h)
          end.
          group_by(&:type).map do |type, qs|
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
            top = grouped.max_by { |_, v| v[:duration] }.first
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
                          Hash(:"#{top} +#{grouped.length - 1}" => sums)
                        end
            [type, collapsed]
          end.to_h.each do |k, v|
            # {
            #   :sql=>{:"ROLLBACK +40"=>{:duration=>32.775403, :db=>0, :controller=>0, :view=>0}},
            #   :rb_db=>{:"SAVEPOINT +40"=>{:duration=>254.559984, :db=>0, :controller=>0, :view=>0}},
            #   :controller=>{"Admin::ProfilesController#index"=>{:duration=>30.123558000000003, :db=>2.188841, :controller=>0, :view=>16.706754}}
            # }
            RSpec::Benchmarks.report success, "#{'%12s' % k} | #{'%39.36s' % v.keys.first} | #{'%5.1f %5.1f %5.1f %5.1f' % v.values.first.values}"
          end

        RSpec::Benchmarks.report success, '=' * 80
      end
    end
  end
end
