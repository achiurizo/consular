require File.expand_path('../spec_helper', __FILE__)

class FakeCore < Consular::Core

  def self.valid_system?
    true
  end

  def process!; puts('process'); end
  def setup!;   puts('setup');   end
end

describe Consular::CLI do

  before do
    @template = File.read File.expand_path('../../lib/templates/example.yml.tt', __FILE__)
    FakeFS.activate!
    FileUtils.mkdir_p Consular.global_path
  end

  after do
    FakeFS.deactivate!
    Consular.instance_variable_set(:@global_path, nil)
  end

  it "displays help" do
    output = capture_io { Consular::CLI.start ['-h'] }.join('')

    assert_match /start \[PROJECT\]/, output
    assert_match /init/,          output
    assert_match /edit \[PROJECT\]/,  output
  end

  it "lists out all global scripts" do
    File.open(Consular.global_path('foo.yml'),   "w") { |f| f.puts @template }
    File.open(Consular.global_path('bar.term'),  "w") { |f| f.puts @template }
    File.open(Consular.global_path('bar.term~'), "w") { |f| f.puts @template }
    output = capture_io { Consular::CLI.start ['list'] }.join('')

    assert_match /foo\.yml -  COMMENT OF SCRIPT HERE/,   output
    assert_match /bar -  COMMENT OF SCRIPT HERE/,        output
    refute_match /bar\.term -  COMMENT OF SCRIPT HERE/,  output
    refute_match /bar\.term~/, output
  end

  describe "start command" do
    before do
      FileUtils.mkdir_p '/tmp'
      FileUtils.touch '/tmp/Termfile'
      FileUtils.touch Consular.global_path('foo.term')
      FileUtils.touch Consular.global_path('foo.yml')
      Consular.instance_variable_set(:@cores,[])
      Consular.add_core FakeCore
    end

    after do
      Consular.instance_variable_set(:@cores,[])
    end

    it "should start a Termfile" do
      output = capture_io { Consular::CLI.start ['start', '-r=/tmp'] }.join('')
      assert_match /process/, output
    end

    it "should start a global term script" do
      output = capture_io { Consular::CLI.start ['start', 'foo']  }.join('')
      assert_match /process/, output
    end

    it "should start a global yaml script" do
      output = capture_io { Consular::CLI.start ['start', 'foo.yml']  }.join('')
      assert_match /process/, output
    end

    it "should return an error message if it doesn't exist" do
      output = capture_io { Consular::CLI.start ['start', 'barr']  }.join('')
      assert_match /does not exist/, output
    end

    it "should SystemExit if no core can be found" do
      Consular.instance_variable_set(:@cores,[])
      assert_raises SystemExit do
        capture_io { Consular::CLI.start ['start', 'foo']  }.join('')
      end
    end

    it "should bring up a core selection if more than one matching core" do
      Consular::CLI.any_instance.expects(:core_selection).with(anything).returns(FakeCore)
      Consular.add_core FakeCore
      Consular.add_core FakeCore
      assert capture_io { Consular::CLI.start ['start', 'foo'] }.join('')
    end
  end

  describe "setup command" do
    before do
      FileUtils.mkdir_p '/tmp'
      FileUtils.touch '/tmp/Termfile'
      FileUtils.touch Consular.global_path('foo.term')
      FileUtils.touch Consular.global_path('foo.yml')
      Consular.instance_variable_set(:@cores,[])
      Consular.add_core FakeCore
    end

    after do
      Consular.instance_variable_set(:@cores,[])
    end

    it "should setup a Termfile" do
      output = capture_io { Consular::CLI.start ['setup', '-r=/tmp'] }.join('')
      assert_match /setup/, output
    end

    it "should setup a global term script" do
      output = capture_io { Consular::CLI.start ['setup', 'foo']  }.join('')
      assert_match /setup/, output
    end

    it "should setup a global yaml script" do
      output = capture_io { Consular::CLI.start ['setup', 'foo.yml']  }.join('')
      assert_match /setup/, output
    end

    it "should return an error message if it doesn't exist" do
      output = capture_io { Consular::CLI.start ['setup', 'barr']  }.join('')
      assert_match /does not exist/, output
    end

    it "should SystemExit if no core can be found" do
      Consular.instance_variable_set(:@cores,[])
      assert_raises SystemExit do
        capture_io { Consular::CLI.start ['setup', 'foo']  }.join('')
      end
    end
    
    it "should bring up a core selection if more than one matching core" do
      Consular::CLI.any_instance.expects(:core_selection).with(anything).returns(FakeCore)
      Consular.add_core FakeCore
      Consular.add_core FakeCore
      assert capture_io { Consular::CLI.start ['setup', 'foo'] }.join('')
    end
  end

  it "init creates a new global script directory and consularc" do
    FileUtils.rm_rf Consular.global_path
    capture_io { Consular::CLI.start ['init'] }.join('')

    assert File.exists?(Consular.global_path), "global script directory exists"
  end

  describe "delete command" do

    it "removes Termfile" do
      FileUtils.mkdir_p '/tmp/sample_project'
      FileUtils.touch "/tmp/sample_project/Termfile"
      capture_io { Consular::CLI.start ['delete',"-r=/tmp/sample_project"] }

      refute File.exists?("/tmp/sample_project/Termfile"), 'deletes Termfile'
    end

    it "removes .yml files" do
      FileUtils.touch Consular.global_path('foo.yml')
      capture_io { Consular::CLI.start ['delete','foo.yml'] }

      refute File.exists?(Consular.global_path('foo.yml')), 'deletes .yml files'
    end

    it "removes .term file" do
      FileUtils.touch Consular.global_path('delete_this.term')
      capture_io { Consular::CLI.start ['delete','delete_this'] }

      refute File.exists?(Consular.global_path('delete_this.term')), 'deletes .term file'
    end

    it "removes .term file" do
      output = capture_io { Consular::CLI.start ['delete','barr'] }.join('')

      assert_match /does not exist/, output
    end

  end

  describe "edit command" do
    before do
      FakeFS.deactivate!
      @path = File.join ENV['HOME'], '.config', 'consular'
      @yaml = File.join @path, 'foobar.yml'
      @term = File.join @path, 'foobar.term'
      `rm -f #{@yaml}`
      `rm -f #{@term}`
      `rm -f /tmp/Termfile`
    end

    after do
      `rm -f #{@yaml}`
      `rm -f #{@term}`
      `rm -f /tmp/Termfile`
    end

    it "edits yaml files" do
      FakeFS.deactivate!
      Consular::CLI.any_instance.expects(:open_in_editor).with(@yaml, nil).returns(true)
      output = capture_io { Consular::CLI.start ['edit', 'foobar.yml'] }.join('')

      assert_match /create/,      output
      assert_match /foobar\.yml/, output
      assert_match /- tab1/,      File.read(@yaml)
    end

    it "edits .term file" do
      FakeFS.deactivate!
      Consular::CLI.any_instance.expects(:open_in_editor).with(@term, nil).returns(true)
      output = capture_io { Consular::CLI.start ['edit', 'foobar'] }.join('')

      assert_match /create/,       output
      assert_match /foobar\.term/, output
      assert_match /setup/,        File.read(@term)
    end

    it "edits a Termfile" do
      FakeFS.deactivate!
      Consular::CLI.any_instance.expects(:open_in_editor).with('/tmp/Termfile', nil).returns(true)
      output = capture_io { Consular::CLI.start ['edit', '-r=/tmp'] }.join('')

      assert_match /create/,       output
      assert_match /Termfile/,     output
      assert_match /setup/,        File.read('/tmp/Termfile')
    end

    it "alias create" do
      FakeFS.deactivate!
      Consular::CLI.any_instance.expects(:open_in_editor).with('/tmp/Termfile', nil).returns(true)
      output = capture_io { Consular::CLI.start ['create', '-r=/tmp'] }.join('')

      assert_match /create/,       output
      assert_match /Termfile/,     output
      assert_match /setup/,        File.read('/tmp/Termfile')
    end

  end

end
