require File.expand_path('../teststrap', __FILE__)

context "Terminitor" do
  setup     { @yaml = File.read(File.expand_path('../fixtures/foo.yml', __FILE__)) }
  setup     { @template = File.read(File.expand_path('../../lib/templates/example.yml.tt', __FILE__)) }
  setup     { FakeFS.activate! }
  setup     { FileUtils.mkdir_p(File.join(ENV["HOME"],'.terminitor')) }
  teardown  { FakeFS.deactivate! }

  context "help" do
    setup { capture(:stdout) { Terminitor::Cli.start(['-h']) } }
    asserts_topic.matches   %r{start PROJECT_NAME}
    asserts_topic.matches   %r{init}
    asserts_topic.matches   %r{edit PROJECT_NAME}
  end

  context "list" do
    setup { @path = "#{ENV['HOME']}/.terminitor/" }
    setup { File.open(File.join(@path,'foo.yml'),"w") { |f| f.puts @template } }
    setup { File.open(File.join(@path,'bar.yml'),"w") { |f| f.puts @template } }
    setup { capture(:stdout) { Terminitor::Cli.start(['list']) } }
    asserts_topic.matches %r{foo - COMMENT OF SCRIPT HERE}
    asserts_topic.matches %r{bar - COMMENT OF SCRIPT HERE}
  end

  context "init" do
    setup { capture(:stdout) { Terminitor::Cli.start(['init']) } }
    asserts("creates .terminitor") { File.exists?("#{ENV['HOME']}/.terminitor") }
  end

  context "edit" do
    setup     { FakeFS.deactivate! }
    setup     { `rm -rf #{ENV['HOME']}/.terminitor/test_foo_bar2.yml`}
    setup     { `rm -rf #{ENV['HOME']}/.terminitor/test_foo_bar2.term`}
    teardown  { `rm -rf /tmp/sample_project` }
    teardown  { `rm -rf #{ENV['HOME']}/.terminitor/test_foo_bar2.yml`}
    teardown  { `rm -rf #{ENV['HOME']}/.terminitor/test_foo_bar2.term`}
    context "for project" do
      context "for yaml" do
        setup { mock.instance_of(Terminitor::Cli).open_in_editor("#{ENV['HOME']}/.terminitor/test_foo_bar2.yml",nil) { true }.once }
        setup { capture(:stdout) { Terminitor::Cli.start(['edit','test_foo_bar2', '-s=yml']) } }
        asserts_topic.matches %r{create}
        asserts_topic.matches %r{test_foo_bar2.yml}
        asserts("has term template") { File.read(File.join(ENV['HOME'],'.terminitor','test_foo_bar2.yml')) }.matches %r{- tab1}
      end

      context "for term" do
        setup { mock.instance_of(Terminitor::Cli).open_in_editor("#{ENV['HOME']}/.terminitor/test_foo_bar2.term",nil) { true }.once }
        setup { capture(:stdout) { Terminitor::Cli.start(['edit','test_foo_bar2', '-s=term']) } }
        asserts_topic.matches %r{create}
        asserts_topic.matches %r{test_foo_bar2.term}
        asserts("has term template") { File.read(File.join(ENV['HOME'],'.terminitor','test_foo_bar2.term')) }.matches %r{setup}
      end

    end

    context "for Termfile" do
      setup { mock.instance_of(Terminitor::Cli).open_in_editor("/tmp/sample_project/Termfile",nil) { true }.once }
      setup { capture(:stdout) { Terminitor::Cli.start(['edit','-s=yml','-r=/tmp/sample_project']) } }
      asserts_topic.matches %r{create}
      asserts_topic.matches %r{Termfile}
      asserts("has term template") { File.read('/tmp/sample_project/Termfile') }.matches %r{setup}
    end

    context "for editor flag" do
      setup { FileUtils.mkdir_p('/tmp/sample_project')  }
      setup { mock.instance_of(Terminitor::Cli).open_in_editor('/tmp/sample_project/Termfile','nano') { true }.once }
      asserts("runs nano") { capture(:stdout) { Terminitor::Cli.start(['edit','-r=/tmp/sample_project','-c=nano']) } }
    end

  end

  context "create" do
    setup { mock.instance_of(Terminitor::Cli).invoke(:edit, [], 'root' => '/tmp/sample_project') { true }.once }
    asserts('calls open') { capture(:stdout) { Terminitor::Cli.start(['create','-r=/tmp/sample_project']) }   }
  end


  context "open" do
    setup { mock.instance_of(Terminitor::Cli).invoke(:edit, [""], {'syntax' => 'term', 'root' => '/tmp/sample_project'}) { true }.once }
    setup { capture(:stdout) { Terminitor::Cli.start(['open','-r=/tmp/sample_project']) } }
    asserts_topic.matches %r{'open' is now deprecated. Please use 'edit' instead}
  end

  context "delete" do
    context "directory Termfile" do
      setup { FileUtils.mkdir_p('/tmp/sample_project') }
      setup { FileUtils.touch("/tmp/sample_project/Termfile") }
      setup { capture(:stdout) { Terminitor::Cli.start(['delete',"-r=/tmp/sample_project"]) } }
      asserts("Termfile") { File.exists?("/tmp/sample_project/Termfile") }.not!
    end

    context "for yaml" do
      setup { FileUtils.touch("#{ENV['HOME']}/.terminitor/delete_this.yml") }
      setup { capture(:stdout) { Terminitor::Cli.start(['delete','delete_this', '-s=yml']) } }
      asserts(" script") { File.exists?("#{ENV['HOME']}/.terminitor/delete_this.yml") }.not!
    end

    context "for term" do
      setup { FileUtils.touch("#{ENV['HOME']}/.terminitor/delete_this.term") }
      setup { capture(:stdout) { Terminitor::Cli.start(['delete','delete_this']) } }
      asserts("script") { File.exists?("#{ENV['HOME']}/.terminitor/delete_this.term") }.not!
    end
  end

  context "setup" do
    setup { mock.instance_of(Terminitor::Cli).execute_core(:setup!,'project') {true } }
    asserts("calls execute_core") { Terminitor::Cli.start(['setup','project']) }
  end


  context "start" do
    setup { mock.instance_of(Terminitor::Cli).execute_core(:process!,'project') {true } }
    asserts("calls execute_core") { Terminitor::Cli.start(['start','project']) }
  end
  
  context "fetch" do
    setup { mock.instance_of(Terminitor::Cli).fetch_repo('achiu','terminitor', 'root' => '.', 'setup' => true) { true } }
    asserts("run setup in project dir") { capture(:stdout) { Terminitor::Cli.start(['fetch','achiu','terminitor'])} }
  end
end
