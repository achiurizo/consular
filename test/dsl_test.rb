require File.expand_path('../teststrap',__FILE__)

context "Dsl" do
  setup     { @term = File.read(File.expand_path('../fixtures/bar.term', __FILE__)) }
  setup     { @template = File.read(File.expand_path('../../lib/templates/example.yml.tt', __FILE__)) }
  setup     { FakeFS.activate! }
  teardown  { FakeFS.deactivate! }
  
  context "tab 'one','two','three' " do
    setup do
      @test_item = TestItem.new
      @test_runner = TestRunner.new
      stub(@test_runner).open_window(anything) { true }.twice
      stub(@test_runner).open_tab(anything) { true }.times 3
      mock(@test_item).do_script("echo 'named tab'", anything)  { true }.once
      mock(@test_item).do_script("echo 'first tab'" , anything) { true }.once
      mock(@test_item).do_script('gitx', anything)    { true }.once
      mock(@test_item).do_script('ls', anything)      { true }.once
      mock(@test_item).do_script('mate .', anything)  { true }.once
      stub(@test_runner).app('Terminal') { TestObject.new(@test_item) }
    end
    setup { capture(:stdout) { Terminitor::Cli.start(['setup']) } }
    setup { @path = "#{ENV['HOME']}/.terminitor/bar.term" }
    setup { File.open(@path,"w") { |f| f.puts @term } }
    asserts("runs project") { @test_runner.run_termfile(@path) }
    
  end
  
  context "description" do
    
  end
  
end