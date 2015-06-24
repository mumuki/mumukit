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
  end
end
