module Mumukit::Metatest
  class TestResultBuilder
    attr_accessor :title, :status, :result, :summary_type, :summary_message

    def summary
      {type: summary_type.presence, message: summary_message.presence}.compact
    end

    def build
      raise 'missing status' unless status
      raise "invallid #{status}" unless status.passed? || status.failed?

      if summary_message.present? || summary_type.present?
        [title, status, result, summary]
      else
        [title, status, result]
      end
    end
  end
end
