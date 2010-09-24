require File.expand_path('../teststrap', __FILE__)

class TestRunner
  include Terminitor::Runner
  
  def say(caption)
    puts caption
  end
end

class TestObject
  attr_accessor :test_item
  
  def initialize(test_item)
    @test_item = test_item
  end
  
  def windows
    [@test_item]
  end
end

class TestItem
  def do_script(prompt,hash)
    true
  end
  
  def get
    true
  end
  
  def keystroke(prompt,hash)
    true
  end
  
end


context "Runner" do
  setup     { @yaml = File.read(File.expand_path('../fixtures/foo.yml', __FILE__)) }
  setup     { @template = File.read(File.expand_path('../../lib/templates/example.yml.tt', __FILE__)) }
  setup     { @test_runner = TestRunner.new }
  setup     { FakeFS.activate! }
  teardown  { FakeFS.deactivate! }

  context "open_in_editor" do
    context "using $EDITOR" do
      setup { ENV['EDITOR'] = 'mate' }
      setup { mock(@test_runner).system("mate /tmp/sample_project/foo.yml").returns {true}.once       }
      asserts("calls") { capture(:stdout) { @test_runner.open_in_editor("/tmp/sample_project/foo.yml") } }
    end

    context "using $TERM_EDITOR" do
      setup { ENV['TERM_EDITOR'] = 'vim'  }
      setup { ENV['EDITOR'] = 'jack'      }
      setup { mock(@test_runner).system("vim /tmp/sample_project/foo.yml").returns {true}.once       }
      asserts("calls") { capture(:stdout) { @test_runner.open_in_editor("/tmp/sample_project/foo.yml")}  }
    end

    context "without any editor" do
      setup { ENV['TERM_EDITOR'] = nil  }
      setup { ENV['EDITOR'] = nil       }
      setup { mock(@test_runner).system("open /tmp/sample_project/foo.yml").returns {true}.once       }
      setup { capture(:stdout) { @test_runner.open_in_editor("/tmp/sample_project/foo.yml")}  }
      asserts_topic.matches %r{please set}
    end

    context "accepts an editor" do
      setup { ENV['TERM_EDITOR'] = 'vim'  }
      setup { ENV['EDITOR'] = 'jack'      }
      setup { mock(@test_runner).system("nano /tmp/sample_project/foo.yml").returns {true}.once          }
      asserts("calls") { capture(:stdout) { @test_runner.open_in_editor("/tmp/sample_project/foo.yml","nano")} }
    end

  end

  context "do_project" do
    setup do
      @test_item = TestItem.new
      @test_runner = TestRunner.new
      stub(@test_runner).open_tab(anything) { true }.twice
      mock(@test_item).do_script('cd /foo/bar', anything) { true }.once
      mock(@test_item).do_script('gitx', anything) { true }.once
      mock(@test_item).do_script('ls', anything) { true }.once
      mock(@test_item).do_script('mate .', anything) { true }.once
      stub(@test_runner).app('Terminal') { TestObject.new(@test_item) }
    end
    setup { capture(:stdout) { Terminitor::Cli.start(['setup']) } }
    setup { @path = "#{ENV['HOME']}/.terminitor/foo.yml" }
    setup { File.open(@path,"w") { |f| f.puts @yaml } }
    asserts("runs project") { @test_runner.do_project(@path) }
  end

  context "resolve_path" do
    
  end

end
