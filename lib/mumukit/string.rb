class String
  def sanitize_as_filename
    self.gsub /[^0-9A-Z\.-]/i, '_'
  end
end