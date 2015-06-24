require_relative '../spec/spec_helper'

include Mumukit

describe Mumukit::ContentType do

  it { expect(ContentType.parse(:plain)).to eq ContentType::Plain }
  it { expect(ContentType.parse(:markdown)).to eq ContentType::Markdown }
  it { expect(ContentType.parse(:html)).to eq ContentType::Html }

  let(:exception) { OpenStruct.new(message: 'foo', backtrace: ['l1', 'l2'])}

  it { expect(ContentType::Plain.format_exception(exception)).to eq(
%q{foo:

-----
l1
l2
-----

})}

  it { expect(ContentType::Markdown.format_exception(exception)).to eq(
%q{**foo**

```
l1
l2
```

})}
  it { expect(ContentType::Html.format_exception(exception)).to eq "<strong>foo</strong>\n<pre>l1\nl2</pre>" }

end
