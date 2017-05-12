module Mumukit::Templates::WithMetatestResults
  def post_process_file(file, result, status)
    if status == :passed
      run_metatest! to_metatest_result(result), @examples
    else
      post_process_unsuccessful_result(file, result, status)
    end
  rescue JSON::ParserError
    [result, :errored]
  end

  def post_process_unsuccessful_result(_file, result, status)
    [result, status]
  end

  def to_metatest_result(json_result)
    JSON.pretty_parse(json_result).map(&:deep_symbolize_keys)
  end
end



