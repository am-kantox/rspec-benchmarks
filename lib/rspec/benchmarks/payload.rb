module RSpec
  module Benchmarks
    module Payload
      def yo name, payload
        Hashie::Mash.new  case name
                          when  'sql.active_record'
                            # @payload={
                            #    :sql=>"SELECT `profiles`.* FROM `profiles`",
                            #    :name=>"Profile Load",
                            #    :connection_id=>125909900,
                            #    :binds=>[],
                            #    :line=>21,
                            #    :filename=>"/.../index.html.haml",
                            #    :method=>"_app_views_admin_todos_index_html_haml__536951581_126761300",
                            query = q(payload[:sql])
                            #<SelectRelation:0xb18c45b8
                            #   @select=[#<QualifiedColumnExpr:0xb18d0b60 @owner="bid_sides", @col=#<WildcardExpr:0xf20a0d0>>],
                            #   @distinct=false,
                            #   @from=#<JoinRelation:0xb18c6610 @kind=:inner,
                            #           @left=#<TableRelation:0xb18d0034 @table="bid_sides">,
                            #           @right=#<TableRelation:0xb18c7c7c @table="bids">,
                            #           @on=#<ComparePredicate:0xb18c6a70
                            #               @left=#<QualifiedColumnExpr:0xb18c73a8 @owner="bids", @col="id">,
                            #               @op=:"=",
                            #               @right=#<QualifiedColumnExpr:0xb18c6e58 @owner="bid_sides", @col="bid_id">
                            #           >
                            #   >,
                            #   @where=#<CompoundPredicate:0xb18c4900
                            #           @left=#<ComparePredicate:0xb18c5918
                            #               @left=#<QualifiedColumnExpr:0xb18c6110 @owner="bid_sides", @col="hedge_id">,
                            #               @op=:"=",
                            #               @right=#<LiteralExpr:0xb18c5cb0 @lit="24167">
                            #           >,
                            #           @op=:and,
                            #           @right=#<ComparePredicate:0xb18c4acc
                            #               @left=#<QualifiedColumnExpr:0xb18c53b4 @owner="bids", @col="workflow_state">,
                            #               @op=:"=",
                            #               @right=#<LiteralExpr:0xb18c4ea0 @lit="'accepted'">
                            #           >
                            #   >,
                            #   @groupby=nil,
                            #   @orderby=nil>

                            #<LimitRelation:0xb183e760 @rel=#<SelectRelation:0xb183ea30 ...>, @limit=1>

                            id =  case query
                                  when NilClass
                                    # Lexer was unable to parse the query.
                                    # SHOW XXX XXX
                                    payload[:sql]
                                  when SelectRelation
                                    "select\##{query.select.map{|s| s.owner}.join('|')}"
                                  when LimitRelation
                                    "select\##{query.rel.select.map{|s| s.owner}.join('|')}"
                                  when TableRelation
                                    query.table
                                  when AliasRelation
                                    query.relation.table
                                  else
                                    puts "==[QRY::UNK]==> #{query.inspect}"
                                    payload[:sql]
                                  end
                            {
                              type: :sql,
                              id: id,
                              desc: payload[:name],
                              query: { sql: payload[:sql], parsed: query }
                            }
                          when 'render_partial.action_view', 'render_template.action_view'
                            {
                              type: :render,
                              id: payload[:identifier]
                            }
                          when 'process_action.action_controller'
                            # "action" => "index",
                            # "controller" => "Admin::TodosController",
                            # "db_runtime" => 86.564069,
                            # "format" => :html,
                            # "method" => "GET",
                            # "params" => {
                            #   "action" => "index",
                            #   "controller" => "admin/todos",
                            #   "default" => {
                            #     "locale" => "en"
                            #   },
                            #   "locale" => "en"
                            # },
                            # "path" => "/en/admin",
                            # "status" => 200,
                            # "view_runtime" => 1737.7329160000002
                            {
                              type: :controller,
                              id: "#{payload[:controller]}\##{payload[:action]}",
                              timing: {
                                db: payload[:db_runtime],
                                view: payload[:view_runtime]
                              },
                              time: (payload[:db_runtime] || 0) + (payload[:view_runtime] || 0),
                              request: {
                                status: payload[:status],
                                format: payload[:format],
                                method: payload[:method],
                                params: payload[:params],
                                path: payload[:path]
                              }
                            }

                          else {}

                          end.merge(location: payload[:location], raw: payload)
      end
      def self.q sql
        (@parser ||= SqlParser::make(SqlParser::relation)).parse(sql.gsub(/`/, '')) rescue nil
      end
      module_function :yo
    end
  end
end
