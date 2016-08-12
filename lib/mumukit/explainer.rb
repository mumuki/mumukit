class Mumukit::Explainer
  def explain(content, test_results)
    explain_methods
        .map { |selector, key| eval_explain(selector, key, content, test_results) }
        .compact
        .map { |explain| I18n.t(explain[:key], explain[:binding]) }
        .map { |it| "* #{it}" }
        .join("\n")
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