module Mumukit::Metatest
  class Framework
    def initialize(options={})
      @runner = options[:runner]
      @checker = options[:checker]
    end

    def test(compilation, examples)
      [examples.map { |it| example(compilation, it) }]
    rescue Aborted => e
      [e.message, :aborted]
    rescue Errored => e
      [e.message, :errored]
    end

    def example(compilation, example)
      @checker.check(@runner.run(compilation, example), example)
    end
  end
end