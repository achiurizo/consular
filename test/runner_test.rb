require File.expand_path('../teststrap', __FILE__)

class TestRunner
  include Terminitor::Runner
  def say(caption); puts caption; end
end

class TestObject
  attr_accessor :test_item
  def initialize(test_item); @test_item = test_item; end
  def windows; [@test_item]; end
end

class TestItem
  def do_script(prompt,hash); true; end
  def get; true; end
  def keystroke(prompt,hash); true; end
end

context "Runner" do
  setup     { @yaml = File.read(File.expand_path('../fixtures/foo.yml', __FILE__)) }
  setup     { @template = File.read(File.expand_path('../../lib/templates/example.yml.tt', __FILE__)) }
  setup     { @test_runner = TestRunner.new }
  setup     { FakeFS.activate! }
  teardown  { FakeFS.deactivate! }


  context "find_core" do
    context "for Darwin" do
      setup { @test_runner.find_core('darwin') }
      asserts_topic.equals Terminitor::MacCore
    end

    if platform?('linux') # TODO Gotta be a better way.
      context "for KDE" do
        setup { @test_runner.find_core('linux') }
        asserts_topic.equals Terminitor::KonsoleCore
      end
    end
  end

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

  context "resolve_path" do
    setup { FileUtils.mkdir_p(File.join(ENV['HOME'],'.terminitor')) }

    context "with yaml" do
      setup { FileUtils.touch(File.join(ENV['HOME'],'.terminitor','test.yml'))  }
      setup { @test_runner.resolve_path('test') }
      asserts_topic.equals File.join(ENV['HOME'],'.terminitor','test.yml')
    end

    context "with term" do
      setup { FileUtils.touch(File.join(ENV['HOME'],'.terminitor','test.term')) }
      setup { FileUtils.rm(File.join(ENV['HOME'],'.terminitor','test.yml'))     }
      setup { @test_runner.resolve_path('test') }
      asserts_topic.equals File.join(ENV['HOME'],'.terminitor','test.term')
    end

    context "with Termfile" do
      setup { FileUtils.rm(File.join(ENV['HOME'],'.terminitor','test.yml'))   }
      setup { FileUtils.rm(File.join(ENV['HOME'],'.terminitor','test.term'))  }
      setup { FileUtils.touch("Termfile") }
      setup { mock(@test_runner).options { {:root => '.'} }  }
      setup { @test_runner.resolve_path("") }
      asserts_topic.equals "./Termfile"
    end

    context "with nothing" do
      setup { FileUtils.rm(File.join(ENV['HOME'],'.terminitor','test.yml'))   }
      setup { FileUtils.rm(File.join(ENV['HOME'],'.terminitor','test.term'))  }
      setup { FileUtils.rm("Termfile") }

      context "with a project" do
        setup { @test_runner.resolve_path('hey') }
        asserts_topic.nil
      end

      context "without a project" do
        setup { mock(@test_runner).options { {:root => '.'} }  }
        setup { @test_runner.resolve_path("") }
        asserts_topic.nil
      end
    end

  end

  context "config_path" do
    context "for yaml" do
      setup { @test_runner.config_path('test',:yml) }
      asserts_topic.equals File.join(ENV['HOME'],'.terminitor','test.yml')
    end

    context "for term" do
      setup { @test_runner.config_path('test', :term) }
      asserts_topic.equals File.join(ENV['HOME'],'.terminitor', 'test.term')
    end

    context "for Termfile" do
      setup { mock(@test_runner).options { {:root => '/tmp'} } }
      setup { @test_runner.config_path("") }
      asserts_topic.equals "/tmp/Termfile"
    end

  end

  context "grab_comment_for_file" do
    setup { File.open('foo.yml','w') { |f| f.puts @yaml } }
    setup { @test_runner.grab_comment_for_file('foo.yml') }
    asserts_topic.matches %r{- Foo.yml}
  end

  context "return_error_message" do
    context "with project" do
      setup { mock(@test_runner).say(%r{'hi' doesn't exist}) { true } }
      asserts("that it says") { @test_runner.return_error_message('hi') }
    end
    context "without project" do
      setup { mock(@test_runner).say(%r{Termfile}) { true } }
      asserts("that is says") { @test_runner.return_error_message('') }
    end
  end

  context "execute_core" do

    context "with no found path" do
      setup { mock(@test_runner).resolve_path('project') { nil } }
      setup { mock(@test_runner).return_error_message('project') { true } }
      asserts("shows error message") { @test_runner.execute_core(:process!,'project') }
    end

    context "with no found core" do
      setup { mock(@test_runner).resolve_path('project') { true }  }
      setup { mock(@test_runner).find_core(anything)     { nil  }  }
      setup { mock(@test_runner).say(/No suitable/)      { true }  }
      asserts("shows message") { @test_runner.execute_core(:process!,'project') }
    end

    context "with found core" do
      context "#process!" do
        setup { mock(@test_runner).resolve_path('project') { '/path/to' } }
        setup do
          any_instance_of(Terminitor::AbstractCore) do |core|
            stub(core).load_termfile('/path/to')  { true }
            stub(core).process! { true }
          end
          mock(@test_runner).find_core(anything) { Terminitor::AbstractCore }
        end
        asserts("calls process!") { @test_runner.execute_core(:process!, 'project') }
      end

      context "#setup!" do
        setup { mock(@test_runner).resolve_path('project') { '/path/to' } }
        setup do
          any_instance_of(Terminitor::AbstractCore) do |core|
            stub(core).load_termfile('/path/to')  { true }
            stub(core).setup! { true }
          end
          mock(@test_runner).find_core(anything) { Terminitor::AbstractCore }
        end
        asserts("calls process!") { @test_runner.execute_core(:setup!, 'project') }
      end
    end
  end

  context "clone_repo" do
    context "with github" do
      setup { stub(@test_runner).__double_definition_create__.call(:`,'which github') { "github" } }
      context "with read/write priv" do
        setup { mock(@test_runner).system("github clone achiu terminitor --ssh") { true } }
        asserts("invokes ssh") { @test_runner.clone_repo('achiu','terminitor') }
      end

      context "with read only" do
        setup { mock(@test_runner).system("github clone achiu terminitor --ssh") { false } }
        setup { mock(@test_runner).system("github clone achiu terminitor") { true } }
        asserts("invokes git://") { @test_runner.clone_repo('achiu', 'terminitor') }
      end
    end
  end

  context "fetch_repo" do
    context "with setup" do
      setup { mock(@test_runner).clone_repo('achiu','terminitor') { true } }
      setup { mock(FileUtils).cd(File.join(Dir.pwd,'terminitor')) { true } }
      setup { mock(@test_runner).invoke(:setup, []) { true } }
      asserts("invokes setup") { @test_runner.fetch_repo('achiu','terminitor', :setup => true) }
    end

    context "without setup" do
      setup { mock(@test_runner).clone_repo('achiu','terminitor') { true } }
      setup { mock(FileUtils).cd(File.join(Dir.pwd,'terminitor')) { true } }
      asserts("invokes setup") { @test_runner.fetch_repo('achiu','terminitor') }.nil
    end

    context "failed on repo" do
      setup { mock(@test_runner).clone_repo('achiu','terminitor') { false } }
      setup { mock(@test_runner).say("could not fetch repo!") { true } }
      asserts("invokes say") { @test_runner.fetch_repo('achiu', 'terminitor') }
    end

  end


end
