module Mumukit::Templates::WithCookie
  def build_cookie_code(request)
    @cookie = cookie_class.new(request.cookie)
    @cookie.code
  end

  def trim_cookie_output(output)
    @cookie.trim(output)
  end
end
