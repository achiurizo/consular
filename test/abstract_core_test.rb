require File.expand_path('../teststrap', __FILE__)

context "AbstractCore" do

  context "setup!" do
    setup do
      any_instance_of(Terminitor::AbstractCore) do |core|
        stub(core).load_termfile('/path/to')  { { :setup => ['ls','ok'] } }
        mock(core).active_window  { true }.times 3
      end
    end
    setup { @core = Terminitor::AbstractCore.new('/path/to') }
    setup { mock(@core).execute_command("cd #{Dir.pwd}", :in => true)}
    setup { mock(@core).execute_command('ls', :in => true) }
    setup { mock(@core).execute_command('ok', :in => true) }
    asserts("ok") { @core.setup! }
  end

  context "process!" do
    context "without default" do
      setup do
        any_instance_of(Terminitor::AbstractCore) do |core|
          stub(core).load_termfile('/path/to')  { {:windows => {'tab1' => ['ls', 'ok'], 'default' => [] } } }
        end
      end
      setup { @core = Terminitor::AbstractCore.new('/path/to') }
      setup { mock(@core).run_in_window(['ls', 'ok']) }
      asserts("ok") { @core.process! }
    end

    context "with default" do
      setup do
        any_instance_of(Terminitor::AbstractCore) do |core|
          stub(core).load_termfile('/path/to')  { {:windows => {'tab1' => ['ls', 'ok'], 'default' => ['echo'] } } }
        end
      end
      setup { @core = Terminitor::AbstractCore.new('/path/to') }
      setup { mock(@core).run_in_window(['echo'], :default => true) }
      setup { mock(@core).run_in_window(['ls', 'ok']) }
      asserts("ok") { @core.process! }
    end

  end

  context "run_in_window" do
    setup do
      any_instance_of(Terminitor::AbstractCore) do |core|
        stub(core).load_termfile('/path/to')  { true }
      end
      @core = Terminitor::AbstractCore.new('/path/to')
    end

    context "with default" do
      setup { mock(@core).open_window { true  } }
      setup { mock(@core).open_tab    { true  } }
      setup { mock(@core).execute_command('ls', :in => true)  }
      setup { mock(@core).execute_command('ok', :in => true)  }
      asserts("ok") { @core.run_in_window('tab' => ['ls','ok']) }
    end

    context "without default" do
      setup { mock(@core).open_tab { true  } }
      setup { mock(@core).execute_command('ls', :in => true)  }
      setup { mock(@core).execute_command('ok', :in => true)  }
      asserts("ok") { @core.run_in_window({'tab' => ['ls','ok']}, :default => true) }
    end


    context "with working_dir" do
      setup { stub(Dir).pwd { '/tmp/path' } }
      setup { mock(@core).execute_command("cd \"/tmp/path\"", :in => '/tmp/path')  }
      setup { mock(@core).execute_command('ls', :in => '/tmp/path')  }
      asserts("ok") { @core.run_in_window({'tab' => ['ls']}) }
    end
  end



end
