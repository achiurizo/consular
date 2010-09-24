require File.expand_path('../teststrap', __FILE__)

context "Terminitor" do
  setup     { @yaml = File.read(File.expand_path('../fixtures/foo.yml', __FILE__)) }
  setup     { @template = File.read(File.expand_path('../../lib/templates/example.yml.tt', __FILE__)) }
  setup     { FakeFS.activate! }
  teardown  { FakeFS.deactivate! }

  context "shows the help" do
    setup { capture(:stdout) { Terminitor::Cli.start(['-h']) } }
    asserts_topic.matches   %r{start PROJECT_NAME}
    asserts_topic.matches   %r{setup}
    asserts_topic.matches   %r{open PROJECT_NAME}
  end

  context "list" do
    setup { @path = "#{ENV['HOME']}/.terminitor/" }
    setup { File.open(File.join(@path,'foo.yml'),"w") { |f| f.puts @template } }
    setup { File.open(File.join(@path,'bar.yml'),"w") { |f| f.puts @template } }
    setup { capture(:stdout) { Terminitor::Cli.start(['list']) } }
    asserts_topic.matches %r{foo - COMMENT OF SCRIPT HERE}
    asserts_topic.matches %r{bar - COMMENT OF SCRIPT HERE}
  end

  context "setup" do
    setup { capture(:stdout) { Terminitor::Cli.start(['setup']) } }
    asserts("creates .terminitor") { File.exists?("#{ENV['HOME']}/.terminitor") }
  end

  context "open" do
    setup     { FakeFS.deactivate! }
    setup     { `rm -rf #{ENV['HOME']}/.terminitor/test_foo_bar2.yml`}

    teardown  { `rm -rf /tmp/sample_project` }

    context "for project yaml" do
      setup { mock.instance_of(Terminitor::Cli).open_in_editor("#{ENV['HOME']}/.terminitor/test_foo_bar2.yml",nil) { true }.once }
      setup { capture(:stdout) { Terminitor::Cli.start(['open','test_foo_bar2']) } }
      asserts_topic.matches %r{create}
      asserts_topic.matches %r{test_foo_bar2.yml}
    end

    context "for Termfile" do
      context "with open" do
        setup { mock.instance_of(Terminitor::Cli).open_in_editor("/tmp/sample_project/Termfile",nil) { true }.once }
        setup { capture(:stdout) { Terminitor::Cli.start(['open','-r=/tmp/sample_project']) } }
        asserts_topic.matches %r{create}
        asserts_topic.matches %r{Termfile}
      end

      context "with create" do
        setup { mock.instance_of(Terminitor::Cli).invoke(:open, [], :root => '/tmp/sample_project') { true }.once }
        asserts('calls open') { capture(:stdout) { Terminitor::Cli.start(['create','-r=/tmp/sample_project']) }   }
      end


      context "with -c(editor) flag" do
        setup { FileUtils.mkdir_p('/tmp/sample_project')  }
        setup { @path = '/tmp/sample_project/Termfile'    }
        setup { File.open(@path,"w") { |f| f.puts @yaml } }
        setup { mock.instance_of(Terminitor::Cli).open_in_editor(@path,'nano') { true }.once }
        asserts("runs nano") { capture(:stdout) { Terminitor::Cli.start(['open','-r=/tmp/sample_project','-c=nano']) } }
      end

    end

    context "delete" do

      context "directory Termfile" do
        setup { FileUtils.mkdir_p('/tmp/sample_project')}
        setup { FileUtils.touch("/tmp/sample_project/Termfile") }
        setup { capture(:stdout) { Terminitor::Cli.start(['delete',"-r=/tmp/sample_project"]) } }
        asserts("Termfile") { File.exists?("/tmp/sample_project/Termfile") }.not!
      end

      context "global script" do
        setup { FileUtils.touch("#{ENV['HOME']}/.terminitor/delete_this.yml") }
        setup { capture(:stdout) { Terminitor::Cli.start(['delete','delete_this']) } }
        asserts(" script") { File.exists?("#{ENV['HOME']}/.terminitor/delete_this.yml") }.not!
      end
    end


  end

  context "start" do

    context "for Termfile" do
      asserts "will no longer support yaml syntax"
      # setup { FileUtils.mkdir_p('/tmp/sample_project') }
      # setup { @path = '/tmp/sample_project/Termfile' }
      # setup { File.open(@path,"w") { |f| f.puts @yaml } }
      # setup { mock.instance_of(Terminitor::Cli).do_project(@path) { true }.once }
      # asserts("runs .terminit") { capture(:stdout) { Terminitor::Cli.start(['start','-r=/tmp/sample_project']) } }
    end

    context "with invalid project" do
      setup { capture(:stdout) { Terminitor::Cli.start(['start','nonono']) } }
      asserts_topic.matches %r{'nonono.yml' doesn't exist! Please run 'terminitor open nonono'}
    end

  end
end
