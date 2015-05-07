class ::ActiveSupport::Notifications::Event
  def to_s
    props = inspected_props(__callee__).map do |prop|
              [prop, public_send(prop)]
            end.to_h
#    props[:children] = "[#{children.map(&:to_s).join(',')}]" # WTF?! Rails4 goodness?
    "<\#ActiveSupport::Notification::Event #{props}>"
  end
  alias_method :inspect, :to_s

  def inspected_props clle
    %i(name duration transaction_id time).tap do |props|
      props << :end << :payload if clle == :inspect
    end
  end
  private :inspected_props
end
