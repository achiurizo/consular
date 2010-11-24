require File.expand_path('../teststrap', __FILE__)

context "AbstractCore" do

  asserts "#setup! executes setup block" do
    any_instance_of(Terminitor::AbstractCore) do |core|
      stub(core).load_termfile('/path/to')  { { :setup => ['ls','ok'] } }
      mock(core).active_window  { true }.times 3
    end
    core = Terminitor::AbstractCore.new('/path/to')
    mock(core).execute_command("cd #{Dir.pwd}", :in => true)
    mock(core).execute_command('ls', :in => true)
    mock(core).execute_command('ok', :in => true)
    core.setup!
  end

  context "#process!" do

    should "execute without default" do
      any_instance_of(Terminitor::AbstractCore) do |core|
          stub(core).load_termfile('/path/to') do 
            {:windows => {'window1' => {:tabs => {'tab1' => ['ls', 'ok']}}, 
                          'default' => {:tabs => {}}
                         }
            }
          end
      end
      core = Terminitor::AbstractCore.new('/path/to')
      mock(core).run_in_window('window1', {:tabs => {'tab1' => ['ls', 'ok']}})
      core.process!
    end

    should "execute with default" do
      any_instance_of(Terminitor::AbstractCore) do |core|
          stub(core).load_termfile('/path/to') do
            {:windows => {'window1' => {:tabs => {'tab1' => ['ls', 'ok']} }, 
                          'default' => {:tabs => {'tab0' => ['echo']} }
                         }
            }
          end
        end
      core = Terminitor::AbstractCore.new('/path/to')
      mock(core).run_in_window('default',{:tabs => {'tab0'=>['echo']}}, :default => true)
      mock(core).run_in_window('window1', {:tabs => {'tab1' => ['ls', 'ok']}})
      core.process!
    end

  end

  context "#run_in_window" do

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

      should "execute without default" do
        core = topic.dup
        mock(core).open_window(nil)    { "first"  }
        mock(core).open_tab(nil)       { "second" }
        mock(core).set_delayed_options { true     }
        mock(core).execute_command('ls', :in => "first")
        mock(core).execute_command('ok', :in => "first")
        mock(core).execute_command('ps', :in => "second")
        core.process!
      end

      should "execute with default" do
        core = topic.dup
        mock(core).open_tab(nil) { true  }
        mock(core).execute_command('echo', :in => true)
        core.run_in_window('default',{:tabs => {'tab0'=>{:commands => ['echo']}}}, :default => true)
      end

      should "execute with working_dir" do
        core = topic.dup
        stub(Dir).pwd { '/tmp/path' } 
        mock(core).execute_command("cd \"/tmp/path\"", :in => '/tmp/path')
        mock(core).execute_command('ls', :in => '/tmp/path')
        core.run_in_window('window1', {:tabs => {'tab1' => {:commands => ['ls']}}})
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
        Terminitor::AbstractCore.new('/path/to')
      end
      
      should "execute" do
        core = topic.dup
        mock(core).open_window(:bounds => [10,10], :settings => 'cool', :name => "first tab")  { "first"  }
        mock(core).open_tab(:settings => 'grass', :name => 'second tab')    { "second"  }
        mock(core).set_delayed_options { true  }
        mock(core).execute_command('ls', :in => "first")
        mock(core).execute_command('ok', :in => "first")
        mock(core).execute_command('ps', :in => "second")
        core.process!
      end  
    end
  
  end



end
