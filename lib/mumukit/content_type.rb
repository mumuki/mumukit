module Mumukit
  module ContentType
    module Markdown
      def self.title(title)
        "**#{title}**"
      end

      def self.code(code)
        "\n```\n#{code}\n```\n"
      end
    end

    module Plain
      def self.title(title)
        "#{title}:"
      end

      def self.code(code)
        "\n-----\n#{code}\n-----\n\n"
      end
    end

    module Html
      def self.title(title)
        "<strong>#{title}</strong>"
      end

      def self.code(code)
        "<pre>#{code}<pre>"
      end
    end

    def self.parse(s)
      Kernel.const_get "Mumukit::ContentType::#{s.to_s.titlecase}"
    rescue raise
      "unknown content_type #{config['content_type']}"
    end
  end
end
