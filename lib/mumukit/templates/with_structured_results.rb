module Mumukit::Templates::WithStructuredResults
  def post_process_file(file, result, status)
    if [:passed, :failed].include? status
      [to_structured_result(result)]
    else
      post_process_unstructured_result(file, result, status)
    end
  rescue JSON::ParserError
    [result, :errored]
  end

  def post_process_unstructured_result(_file, result, status)
    [result, status]
  end

  def to_structured_result(result)
    JSON.pretty_parse(result)
  end
end
