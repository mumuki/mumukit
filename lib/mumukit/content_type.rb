module Mumukit
  module ContentType
    module BaseContentType
      def format_exception(e)
        "#{title e.message}\n#{code e.backtrace.join("\n")}"
      end
    end

    module Markdown
      extend BaseContentType
      def self.title(title)
        "**#{title}**"
      end

      def self.code(code)
        "\n```\n#{code}\n```\n\n"
      end
    end

    module Plain
      extend BaseContentType
      def self.title(title)
        "#{title}:"
      end

      def self.code(code)
        "\n-----\n#{code}\n-----\n\n"
      end
    end

    module Html
      extend BaseContentType
      def self.title(title)
        "<strong>#{title}</strong>"
      end

      def self.code(code)
        "<pre>#{code}</pre>"
      end
    end

    def self.parse(s)
      Kernel.const_get "Mumukit::ContentType::#{s.to_s.titlecase}"
    rescue => e
      raise "unknown content_type #{s}"
    end
  end
end
