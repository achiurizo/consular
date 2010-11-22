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
          stub(core).load_termfile('/path/to') do 
            {:windows => {'window1' => {:tabs => {'tab1' => ['ls', 'ok']}}, 
                          'default' => {:tabs => {}}
                         }
            }
          end
        end
      end
      setup { @core = Terminitor::AbstractCore.new('/path/to') }
      setup { mock(@core).run_in_window('window1', {:tabs => {'tab1' => ['ls', 'ok']}}) }
      asserts("ok") { @core.process! }
    end

    context "with default" do
      setup do
        any_instance_of(Terminitor::AbstractCore) do |core|
          stub(core).load_termfile('/path/to') do
            {:windows => {'window1' => {:tabs => {'tab1' => ['ls', 'ok']} }, 
                          'default' => {:tabs => {'tab0' => ['echo']} }
                         }
            }
          end
        end
      end
      setup { @core = Terminitor::AbstractCore.new('/path/to') }
      setup { mock(@core).run_in_window('default',{:tabs => {'tab0'=>['echo']}}, :default => true) }
      setup { mock(@core).run_in_window('window1', {:tabs => {'tab1' => ['ls', 'ok']}}) }
      asserts("ok") { @core.process! }
    end

  end

  context "run_in_window" do
    context "without options" do 
      setup do
        any_instance_of(Terminitor::AbstractCore) do |core|
          stub(core).load_termfile('/path/to')  { 
            {:windows => {'window1' => {:tabs => {'tab1' => {:commands => ['ls', 'ok']}, 'tab2' => {:commands => ['ps']}}},
                          'default' => {:tabs => {}}
                         }
            } 
          }
        end
        @core = Terminitor::AbstractCore.new('/path/to')
      end

      context "without default" do
        setup { mock(@core).open_window(nil)          { "first"  } }
        setup { mock(@core).open_tab(nil)             { "second"  } }  
        setup { mock(@core).set_delayed_options       { true      } }  
        setup { mock(@core).execute_command('ls', :in => "first")  }
        setup { mock(@core).execute_command('ok', :in => "first")  }
        setup { mock(@core).execute_command('ps', :in => "second")  }        
        asserts("ok") { @core.process! }
      end

      context "with default" do
        setup { mock(@core).open_tab(nil) { true  } }        
        setup { mock(@core).execute_command('echo', :in => true)  }
        asserts("ok") { @core.run_in_window('default',{:tabs => {'tab0'=>{:commands => ['echo']}}}, :default => true)}
      end

      context "with working_dir" do
        setup { stub(Dir).pwd { '/tmp/path' } }
        setup { mock(@core).execute_command("cd \"/tmp/path\"", :in => '/tmp/path')  }
        setup { mock(@core).execute_command('ls', :in => '/tmp/path')  }
        asserts("ok") { @core.run_in_window('window1', {:tabs => {'tab1' => {:commands => ['ls']}}}) }
      end
    end
    
    context "with options" do 
      setup do
        any_instance_of(Terminitor::AbstractCore) do |core|
          stub(core).load_termfile('/path/to') do 
            {:windows => {'window1' => {:tabs => {'tab1' => {:commands => ['ls', 'ok'], :options => {:settings => 'cool', :name => 'first tab'}}, 
                                                  'tab2' => {:commands => ['ps'], :options => {:settings => 'grass', :name => 'second tab'}},  
                                                 }, 
                                        :options => {:bounds => [10,10]}},
                          'default' => {:tabs => {}}
                         }
            }
          end
        end
        @core = Terminitor::AbstractCore.new('/path/to')
      end
      
      setup { mock(@core).open_window(:bounds => [10,10], :settings => 'cool', :name => "first tab")  { "first"  } }
      setup { mock(@core).open_tab(:settings => 'grass', :name => 'second tab')    { "second"  } }
      setup { mock(@core).set_delayed_options { true  } }       
      setup { mock(@core).execute_command('ls', :in => "first")  }
      setup { mock(@core).execute_command('ok', :in => "first")  }
      setup { mock(@core).execute_command('ps', :in => "second")  }
      
      asserts("ok") { @core.process! }
    end
  end



end
