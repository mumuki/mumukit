class Mumukit::Cookie
  attr_accessor :statements

  def initialize(statements)
    @statements = statements || []
  end

  def code
    statements_code + "\n" + stdout_separator_code
  end

  def trim(output)
    output.split("#{stdout_separator }\n")[1]
  end

  def stdout_separator
    '!!!!MUMUKI-COOKIE-STDOUT-SEPARATOR-END!!!!'
  end
end