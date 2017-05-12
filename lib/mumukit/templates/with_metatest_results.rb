module Mumukit::Templates::WithMetatestResults
  def compile_file_content(request)
    @examples = compile_metatest_examples(request)
    compile_metatest_file_content(request)
  end

  def compile_metatest_examples(request)
    YAML.load(request.test).deep_symbolize_keys[:examples]
  end

  def post_process_file(file, result, status)
    if status == :passed
      run_metatest! to_metatest_compilation(result), @examples
    else
      post_process_unsuccessful_result(file, result, status)
    end
  rescue JSON::ParserError
    [result, :errored]
  end

  def post_process_unsuccessful_result(_file, result, status)
    [result, status]
  end

  def to_metatest_compilation(result)
    JSON.pretty_parse(result).deep_symbolize_keys
  end
end



