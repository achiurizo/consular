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
            {:windows => {'window1' => {:tabs => {'tab1' => {:commands => ['ls', 'ok']}, 
                                                  'tab2' => {:commands => ['ps']}}},
                          'default' => {:tabs => {}}
                         }
            }
          }
        end
        stub(Dir).pwd { nil }
        Terminitor::AbstractCore.new('/path/to')
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

      should "execute with default window" do
        core = topic.dup
        mock(core).open_tab(nil) { true  }
        mock(core).execute_command('echo', :in => true)
        core.run_in_window('default',{:tabs => {'tab0'=>{:commands => ['echo']}}}, :default => true)
      end

      should "execute with default tab" do
        core = topic.dup
        mock(core).active_window { true }
        mock(core).execute_command('uptime', :in => true)
        core.run_in_window('default',{:tabs => {'default'=>{:commands=>['uptime']}}}, :default => true)
      end

      should "execute with working_dir" do
        core = topic.dup
        stub(Dir).pwd { '/tmp/path' }
        mock(core).execute_command("cd \"/tmp/path\"", :in => '/tmp/path')
        mock(core).execute_command('clear', :in => '/tmp/path')
        mock(core).execute_command('ls', :in => '/tmp/path')
        core.run_in_window('window1', {:tabs => {'tab1' => {:commands => ['ls']}}})
      end
    end
    
    context "with options" do 
      setup do
        any_instance_of(Terminitor::AbstractCore) do |core|
          stub(core).load_termfile('/path/to') do 
            {:windows => {'window1' => {:tabs => {'tab1' => {:commands => ['ls', 'ok'], 
                                                             :options => {:settings => 'cool', :name => 'first tab'}}, 
                                                  'tab2' => {:commands => ['ps'], 
                                                             :options => {:settings => 'grass', :name => 'second tab'}},  
                                                 }, 
                                        :options => {:bounds => [10,10]}},
                          'default' => {:tabs => {}}
                         }
            }
          end
        end
        stub(Dir).pwd { nil }
        Terminitor::AbstractCore.new('/path/to')
      end
      
      should "execute" do
        core = topic.dup
        mock(core).open_window(:bounds => [10,10], :settings => 'cool', :name => "first tab")  { "first"  }
        mock(core).open_tab(:settings => 'grass', :name => 'second tab')    { "second"  }
        mock(core).set_delayed_options { true  }
        mock(core).execute_command('PS1="$PS1\e]2;first tab\a"', :in => 'first')
        mock(core).execute_command('clear', :in => 'first')
        mock(core).execute_command('ls', :in => "first")
        mock(core).execute_command('ok', :in => "first")
        mock(core).execute_command('PS1="$PS1\e]2;second tab\a"', :in => 'second')
        mock(core).execute_command('clear', :in => 'second')
        mock(core).execute_command('ps', :in => "second")
        core.process!
      end  
    end
  

    context "with before" do 
      setup do
        any_instance_of(Terminitor::AbstractCore) do |core|
          stub(core).load_termfile('/path/to')  { 
            {:windows => {'window1' => {:tabs => {'tab1' => {:commands => ['ls']}, 
                                                  'tab2' => {:commands => ['ps']}},
                                        :before => ['whoami']
                                       },
                          'default' => {:tabs => {}}
                         }
            }
          }
        end
        stub(Dir).pwd { nil }
        Terminitor::AbstractCore.new('/path/to')
      end

      should "execute without default" do
        core = topic.dup
        mock(core).open_window(nil)    { "first"  }
        mock(core).open_tab(nil)       { "second" }
        mock(core).set_delayed_options { true     }
        mock(core).execute_command('whoami', :in => 'first')
        mock(core).execute_command('ls', :in => "first")
        mock(core).execute_command('whoami', :in => "second")
        mock(core).execute_command('ps', :in => "second")
        core.process!
      end
    end
    
    should "execute tabs in order" do
      any_instance_of(Terminitor::AbstractCore) do |core|
        stub(core).load_termfile('/path/to') {
          {:windows => {'default' => {:tabs => {'tab1' => {:commands => ['ls']}, 
                                                'tab2' => {:commands => ['ps']},
                                                'tab3' => {:commands => ['whoami']},
                                                'tab4' => {:commands => ['cd']},
                                                'tab5' => {:commands => ['clear']},
                                                'tab6' => {:commands => ['nmap']}}
                                     }
                       }
          }
        }
      end
      stub(Dir).pwd { nil }
      core = Terminitor::AbstractCore.new('/path/to')
      
      mock(core).
        open_tab(nil) { "first" }.then.
        execute_command('ls', :in => "first").then.
        open_tab(nil) { "second" }.then.
        execute_command('ps', :in => "second").then.
        open_tab(nil) { "third" }.then.
        execute_command('whoami', :in => "third").then.
        open_tab(nil) { "fourth" }.then.
        execute_command('cd', :in => "fourth").then.
        open_tab(nil) { "fifth" }.then.
        execute_command('clear', :in => "fifth").then.
        open_tab(nil) { "sixth" }.then.
        execute_command('nmap', :in => "sixth")
      core.process!
    end
  end



end
