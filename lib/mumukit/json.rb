require 'json'

module JSON
  def self.pretty_parse(string)
    parse(string)
  rescue => e
    raise JSON::ParserError, "Invalid JSON #{string}:\n\t#{e.message.force_encoding('utf-8')}"
  end
end