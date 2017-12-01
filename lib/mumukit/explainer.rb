class Mumukit::Explainer
  def explain(content, test_results)
    explain_methods
        .map { |selector, key| eval_explain(selector, key, content, test_results) }
        .compact
        .map do |key, binding|
          if binding.key?(:type)
            binding.merge message: I18n.t(key)
          else
            "* #{I18n.t key, binding}"
          end
        end
  end

  def eval_explain(selector, key, content, test_results)
    send(selector, content, test_results).try do |it|
      [key, it]
    end
  end

  def explain_methods
    self.class
        .instance_methods(false)
        .flat_map { |it| it.to_s.captures(/explain_(.*)/).map { [it, $1] } }
        .compact
  end
end
