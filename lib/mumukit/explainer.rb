class Mumukit::Explainer
  include Mumukit::WithContentType

  def explain(content, test_results)
    content_type.enumerate(explanations(content, test_results))
  end

  def explanations(content, test_results)
    explain_methods
        .map { |selector, key| eval_explain(selector, key, content, test_results) }
        .compact
        .map { |explain| I18n.t(explain[:key], explain[:binding]) }
  end

  def eval_explain(selector, key, content, test_results)
    send(selector, content, test_results).try do |it|
      {key: key, binding: it}
    end
  end

  def explain_methods
    self.class
        .instance_methods(false)
        .flat_map { |it| it.to_s.captures(/explain_(.*)/).map { [it, $1] } }
        .compact
  end
end