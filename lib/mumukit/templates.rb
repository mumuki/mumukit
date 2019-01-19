module Mumukit
  module Templates
  end
end

require_relative './templates/with_structured_results'
require_relative './templates/with_metatest'
require_relative './templates/with_metatest_results'
require_relative './templates/with_mashup_file_content'
require_relative './templates/with_embedded_environment'
require_relative './templates/with_isolated_environment'
require_relative './templates/with_line_number_offset'
require_relative './templates/with_multiple_files'
require_relative './templates/with_code_smells'
require_relative './templates/with_cookie'

require_relative './templates/file_hook'
require_relative './templates/multi_file_hook'
require_relative './templates/try_hook'
require_relative './templates/expectations_hook'
require_relative './templates/mulang_expectations_hook'
require_relative './templates/multi_file_precompile_hook'
