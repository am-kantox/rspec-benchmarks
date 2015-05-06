%w{parsers operators keywords expressions}.each do |lib|
  require_relative "rparsec/#{lib}"
end
