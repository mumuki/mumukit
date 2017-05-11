module Mumukit::Templates::WithMetatest
  def metatest
    Mumukit::Metatest::Framework.new checker: metatest_checker,
                                     runner: metatest_runner
  end

  def metatest_runner
    Mumukit::Metatest::IdentityRunner.new
  end

  def run_metatest!(target, examples)
    metatest.test target, examples
  end
end