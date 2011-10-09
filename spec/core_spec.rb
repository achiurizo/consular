require File.expand_path('../spec_helper', __FILE__)

describe Consular::Core do
  before do
    @core = Consular::Core.new File.expand_path('../fixtures/bar.term', __FILE__)
  end

  it "on .initialize assigns the right values" do
    refute_nil @core.termfile
  end

  it "stubs out the methods that need to be defined" do
    assert_raises(NotImplementedError) { @core.class.valid_system?   }
    assert_raises(NotImplementedError) { @core.class.capture!        }
    assert_raises(NotImplementedError) { @core.setup!                }
    assert_raises(NotImplementedError) { @core.process!              }
  end

end
