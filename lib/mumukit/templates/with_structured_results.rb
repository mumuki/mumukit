module Mumukit::Templates::WithStructuredResults
  def post_process_file(file, result, status)
    if [:passed, :failed].include? status
      [to_structured_result(result)]
    else
      [result, status]
    end
  rescue JSON::ParserError
    [result, :errored]
  end

  def to_structured_result(result)
    JSON.pretty_parse(result)
  end
end