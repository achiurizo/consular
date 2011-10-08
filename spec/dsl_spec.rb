require File.expand_path('../spec_helper', __FILE__)

describe Consular::DSL do
  before do
    @dsl  = Consular::DSL.new File.expand_path('../fixtures/bar.term', __FILE__)
    @yaml = Consular::DSL.new File.expand_path('../fixtures/foo.yml', __FILE__)
  end

  it "on .initialize setup some variables" do
    refute_nil @dsl._setup
    refute_nil @dsl._windows
    refute_nil @dsl._context
  end

  describe ".to_hash with DSL" do
    before do
      @result = @dsl.to_hash
    end

    it "returns the initial setup" do
      assert_equal @result[:setup], ['setup']
    end

    it "returns the first window" do
      @window1 = @result[:windows]['window1']
      @tab1    = @window1[:tabs]

      assert_equal @window1[:before],  ['before']
      assert_equal @window1[:options], :size => [70, 30]

      assert_equal @tab1['default'][:commands], ['whoami && who && ls']
      assert_equal @tab1['tab1'][:commands],    ['first-tab', 'motion &', 'foo']

      assert_equal @tab1['tab2'][:options],  :settings => 'Grass', :name => 'second'
      assert_equal @tab1['tab2'][:commands], ['second-tab','second-tab:ls']

      assert_equal @tab1['tab3'][:options],  :settings => 'Pro', :name => 'third'
      assert_equal @tab1['tab3'][:commands], ['third-tab', "(mvim &) && (gitx &) && uptime"]

      assert_equal @tab1['tab4'][:options],  :settings => 'Grass', :name => 'fourth'
      assert_equal @tab1['tab4'][:commands], ['fourth-tab']
    end

    it "returns the second window" do
      @window2 = @result[:windows]['window2']
      @tab2    = @window2[:tabs]

      assert_equal @window2[:before],  ['name:before']
      assert_equal @window2[:options], :name => 'name'

      assert_equal @tab2['tab1'][:commands], ['name:tab']
    end

  end

  describe ".to_hash with YAML" do
    before do
      @result = @yaml.to_hash
    end

    it "returns no setup" do
      assert_equal @result[:setup], nil
    end

    it "returns the default window" do
      @tabs = @result[:windows]['default'][:tabs]

      assert_equal @tabs['tab1'][:commands], ['cd /foo/bar', 'gitx']
      assert_equal @tabs['tab1'][:options],  {}

      assert_equal @tabs['tab2'][:commands], ['ls', 'mate .']
      assert_equal @tabs['tab2'][:options],  {}
    end

  end
end
