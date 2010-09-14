require File.expand_path('../teststrap',__FILE__)

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

  context "setup" do
    setup { capture(:stdout) { Terminitor::Cli.start(['setup']) } }
    asserts("creates .terminitor") { File.exists?("#{ENV['HOME']}/.terminitor") }
  end

  context "open" do
    setup     { FakeFS.deactivate! }
    setup     { `rm -rf #{ENV['HOME']}/.terminitor/test_foo_bar2.yml`}
    teardown  { `rm -rf /tmp/sample_project` }
    
    context "for project yaml" do
      setup { mock.instance_of(Terminitor::Cli).open_in_editor("#{ENV['HOME']}/.terminitor/test_foo_bar2.yml") { true }.once }
      setup { capture(:stdout) { Terminitor::Cli.start(['open','test_foo_bar2']) } }
      asserts_topic.matches %r{create}
      asserts_topic.matches %r{test_foo_bar2.yml}
    end

    context "for Termfile" do
      setup { mock.instance_of(Terminitor::Cli).open_in_editor("/tmp/sample_project/Termfile") { true }.once }
      setup { capture(:stdout) { Terminitor::Cli.start(['open','-r=/tmp/sample_project']) } }
      asserts_topic.matches %r{create}
      asserts_topic.matches %r{Termfile}
    end

  end

  context "start" do
    
    context "for project yaml" do
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

    context "for Termfile" do
      setup { FileUtils.mkdir_p('/tmp/sample_project') }
      setup { @path = '/tmp/sample_project/Termfile' }
      setup { File.open(@path,"w") { |f| f.puts @yaml } }
      setup { mock.instance_of(Terminitor::Cli).do_project(@path) { true }.once }
      asserts("runs .terminit") { capture(:stdout) { Terminitor::Cli.start(['start','-r=/tmp/sample_project']) } }
    end

    context "with invalid project" do
      setup { capture(:stdout) { Terminitor::Cli.start(['start','nonono']) } }
      asserts_topic.matches %r{'nonono.yml' doesn't exist! Please run 'terminitor open nonono'}
    end

  end  
end
