require File.expand_path('../teststrap',__FILE__)

context "Terminitor" do
  setup     { @yaml = File.read(File.expand_path('../fixtures/foo.yml', __FILE__)) }
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
    setup { mock.instance_of(Terminitor::Cli).open_in_editor("#{ENV['HOME']}/.terminitor/foo.yml") { true }.once }
    setup { capture(:stdout) { Terminitor::Cli.start(['open','foo']) } }
    asserts_topic.matches %r{create}
  end

  context "start" do
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
    setup { File.open("#{ENV['HOME']}/.terminitor/foo.yml","w") { |f| f.puts @yaml } }
    asserts("runs project") { @test_runner.do_project("foo") }
  end


end
