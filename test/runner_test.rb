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
  setup do 
    @yaml = File.read(File.expand_path('../fixtures/foo.yml', __FILE__))
    @template = File.read(File.expand_path('../../lib/templates/example.yml.tt', __FILE__))
    @test_runner = TestRunner.new
    FakeFS.activate!
  end
  teardown  { FakeFS.deactivate! }


  context "#find_core" do
    if platform?('darwin')
      if ENV['TERM_PROGRAM'] == 'iTerm.app'
        should("have Darwin") { @test_runner.find_core('darwin') }.equals Terminitor::ItermCore
      else
        should("have Darwin") { @test_runner.find_core('darwin') }.equals Terminitor::MacCore
      end
    end

    if platform?('linux') # TODO Gotta be a better way.
      should("have KDE") { @test_runner.find_core('linux') }.equals Terminitor::KonsoleCore
    end
  end
  
  context "#capture_core" do 
    if platform?('darwin')
      if ENV['TERM_PROGRAM'] == 'iTerm.app'
        should("have Darwin") { @test_runner.capture_core('darwin') }.equals Terminitor::ItermCapture
      else
        should("have Darwin") { @test_runner.capture_core('darwin') }.equals Terminitor::MacCapture
      end
    end
  end

  context "#open_in_editor" do

    should "use $EDITOR" do
      ENV['EDITOR'] = 'mate'
      mock(@test_runner).system("mate /tmp/sample_project/foo.yml").returns {true}.once
      capture(:stdout) { @test_runner.open_in_editor("/tmp/sample_project/foo.yml") }
    end

    should "use $TERM_EDITOR" do
      ENV['TERM_EDITOR'] = 'vim'
      ENV['EDITOR']      = 'jack'
      mock(@test_runner).system("vim /tmp/sample_project/foo.yml").returns {true}.once
      capture(:stdout) { @test_runner.open_in_editor("/tmp/sample_project/foo.yml") }
    end

    should "return a message without any editor that" do
      ENV['TERM_EDITOR'] = nil
      ENV['EDITOR']      = nil
      mock(@test_runner).system("open /tmp/sample_project/foo.yml").returns {true}.once
      capture(:stdout) { @test_runner.open_in_editor("/tmp/sample_project/foo.yml")}
    end.matches %r{please set}

    should "accept an editor" do
      ENV['TERM_EDITOR'] = 'vim'
      ENV['EDITOR']      = 'jack'
      mock(@test_runner).system("nano /tmp/sample_project/foo.yml").returns {true}.once 
      capture(:stdout) { @test_runner.open_in_editor("/tmp/sample_project/foo.yml","nano") }
    end

  end

  context "#resolve_path" do
    setup { FileUtils.mkdir_p(File.join(ENV['HOME'],'.terminitor')) }

    should "return yaml" do
      FileUtils.touch(File.join(ENV['HOME'],'.terminitor','test.yml'))
      @test_runner.resolve_path('test')
    end.equals File.join(ENV['HOME'],'.terminitor','test.yml')

    should "return term" do
      FileUtils.touch(File.join(ENV['HOME'],'.terminitor','test.term'))
      FileUtils.rm(File.join(ENV['HOME'],'.terminitor','test.yml'))
      @test_runner.resolve_path('test')
    end.equals File.join(ENV['HOME'],'.terminitor','test.term')


    should "return Termfile" do
      FileUtils.rm(File.join(ENV['HOME'],'.terminitor','test.yml'))
      FileUtils.rm(File.join(ENV['HOME'],'.terminitor','test.term'))
      FileUtils.touch("Termfile")
      mock(@test_runner).options { {:root => '.'} }
      @test_runner.resolve_path("")
    end.equals "./Termfile"


    context "with nothing" do
      setup do
        FileUtils.rm(File.join(ENV['HOME'],'.terminitor','test.yml'))
        FileUtils.rm(File.join(ENV['HOME'],'.terminitor','test.term'))
        FileUtils.rm("Termfile")
      end
      
      should("have path with a project") { @test_runner.resolve_path('hey') }.nil

      should("have path without a project") do
        mock(@test_runner).options.returns(:root => '.')
        @test_runner.resolve_path ""
      end.nil

    end

  end

  context "config_path" do
    should("have yaml") { @test_runner.config_path('test',:yml)   }.equals File.join(ENV['HOME'],'.terminitor','test.yml')
    should("have term") { @test_runner.config_path('test', :term) }.equals File.join(ENV['HOME'],'.terminitor', 'test.term')
    
    should "have Termfile" do
      mock(@test_runner).options { {:root => '/tmp'} }
      @test_runner.config_path ""
    end.equals '/tmp/Termfile'

  end

  asserts "#grab_comment_for_file executes" do
    File.open('foo.yml','w') { |f| f.puts @yaml }
    @test_runner.grab_comment_for_file('foo.yml')
  end.matches %r{- Foo.yml}


  context "#return_error_message" do
    
    should "return message with project" do
      mock(@test_runner).say(%r{'hi' doesn't exist}) { true }
      @test_runner.return_error_message('hi')
    end

    should "return message without project" do
      mock(@test_runner).say(%r{Termfile}) { true }
      @test_runner.return_error_message('')
    end

  end

  context "#execute_core" do

    should "have error message with no path" do
      mock(@test_runner).resolve_path('project')         { nil  }
      mock(@test_runner).return_error_message('project') { true }
      @test_runner.execute_core(:process!,'project')
    end

    should "have error message with no core" do
      mock(@test_runner).resolve_path('project') { true }
      mock(@test_runner).find_core(anything)     { nil  }
      mock(@test_runner).say(/No suitable/)      { true }
      @test_runner.execute_core(:process!,'project')
    end

    context "with found core" do

      should "call #process!" do
        mock(@test_runner).resolve_path('project') { '/path/to' }
        any_instance_of(Terminitor::AbstractCore) do |core|
          stub(core).load_termfile('/path/to')  { true }
          stub(core).process! { true }
        end
        mock(@test_runner).find_core(anything) { Terminitor::AbstractCore }
        @test_runner.execute_core(:process!, 'project')
      end

      should "call #setup!" do
        mock(@test_runner).resolve_path('project') { '/path/to' }
        any_instance_of(Terminitor::AbstractCore) do |core|
          stub(core).load_termfile('/path/to')  { true }
          stub(core).setup! { true }
        end
        mock(@test_runner).find_core(anything) { Terminitor::AbstractCore }
        @test_runner.execute_core(:setup!, 'project')
      end

    end
  end

  context "#github_clone" do

    context "with github" do
      setup { stub(@test_runner).__double_definition_create__.call(:`,'which github') { "github" } }
      
      should "invoke ssh with read/write priv" do
        mock(@test_runner).system("github clone achiu terminitor --ssh") { true }
        @test_runner.github_clone('achiu','terminitor')
      end

      should "invoke git:// with read only" do
        mock(@test_runner).system("github clone achiu terminitor --ssh") { false }
        mock(@test_runner).system("github clone achiu terminitor") { true }
        @test_runner.github_clone('achiu', 'terminitor')
      end
    
    end
  
  end

  context "github_repo" do
    should "invoke setup" do
      mock(@test_runner).github_clone('achiu','terminitor') { true }
      mock(FileUtils).cd(File.join(Dir.pwd,'terminitor')) { true }
      mock(@test_runner).invoke(:setup, []) { true }
      @test_runner.github_repo('achiu','terminitor', :setup => true)
    end

    should "invoke without setup" do
      mock(@test_runner).github_clone('achiu','terminitor') { true }
      mock(FileUtils).cd(File.join(Dir.pwd,'terminitor')) { true }
      @test_runner.github_repo('achiu','terminitor')
    end.nil

    should "return a message on a failed repo" do
      mock(@test_runner).github_clone('achiu','terminitor') { false }
      mock(@test_runner).say("could not fetch repo!") { true }
      @test_runner.github_repo('achiu', 'terminitor')
    end

  end


end
