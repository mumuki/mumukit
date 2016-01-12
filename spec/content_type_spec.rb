require_relative '../spec/spec_helper'

describe Mumukit::ContentType do

  it { expect(Mumukit::ContentType.parse(:plain)).to eq Mumukit::ContentType::Plain }
  it { expect(Mumukit::ContentType.parse(:markdown)).to eq Mumukit::ContentType::Markdown }
  it { expect(Mumukit::ContentType.parse(:html)).to eq Mumukit::ContentType::Html }

  let(:exception) { OpenStruct.new(message: 'foo', backtrace: ['l1', 'l2'])}

  it { expect(Mumukit::ContentType::Plain.format_exception(exception)).to eq(
%q{foo:

-----
l1
l2
-----

})}

  it { expect(Mumukit::ContentType::Markdown.format_exception(exception)).to eq(
%q{**foo**

```
l1
l2
```

})}
  it { expect(Mumukit::ContentType::Html.format_exception(exception)).to eq "<strong>foo</strong>\n<pre>l1\nl2</pre>" }

end
