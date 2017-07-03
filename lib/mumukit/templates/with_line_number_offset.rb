module Mumukit::Templates::WithLineNumberOffset
  def cleanup_raw_result(result)
    super(result).gsub(line_number_reference_regexp) do
      rebuild_line_number_reference correct_line_number($1.to_i)
    end
  end

  def line_number_reference_regexp
    /#{masked_tempfile_path}\:(\d+)/m
  end

  def rebuild_line_number_reference(new_line_number)
    "#{masked_tempfile_path}:#{new_line_number}"
  end

  def correct_line_number(number)
    number - line_number_offset
  end
end
