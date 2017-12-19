class Mumukit::Explainer
  def explain(content, test_results)
    explain_methods
        .flat_map { |selector, key| eval_explain(selector, key, content, test_results) }
        .compact
        .map { |explain| translate_and_format(*explain) }
  end

  def eval_explain(selector, key, content, test_results)
    send(selector, content, test_results).try do |it|
      it.map {|binding| [key, binding]}
    end
  end

  def explain_methods
    self.class
        .instance_methods(false)
        .flat_map { |it| it.to_s.captures(/explain_(.*)/).map { [it, $1] } }
        .compact
  end

  def translate_and_format(key, binding)
    if binding.key?(:type)
      explanation = binding.merge message: I18n.t(key)
      merge_numeric_key explanation, binding, :line
      merge_numeric_key explanation, binding, :column if binding.key? :column
      explanation
    else
      { message: "* #{I18n.t key, binding}" }
    end
  end

  def merge_numeric_key(explanation, binding, key)
    explanation.merge! key => binding[key].to_i
  end
end
