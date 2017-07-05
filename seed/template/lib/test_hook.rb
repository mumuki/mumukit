class <CONSTANT>TestHook < Mumukit::Templates::FileHook
  mashup
  isolated true

  def tempfile_extension
    '...'
  end

  def command_line(filename)
    "... #{filename}"
  end
end


