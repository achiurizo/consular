require File.expand_path('../teststrap', __FILE__)

context "Dsl" do
  setup { Terminitor::Dsl.new File.expand_path('../fixtures/bar.term', __FILE__) }
  asserts_topic.assigns :setup
  asserts_topic.assigns :windows
  asserts_topic.assigns :_context
 
  context "to_hash" do
    setup { topic.to_hash }
    asserts(:[],:setup).equals ["echo \"setup\""]
    context ":windows" do
      setup { topic[:windows] }

      context "with 'window1' key" do
        setup { topic['window1'] }

        asserts(:[],:before).equals ['cd /path']
        asserts(:[],:options).equals({ :size => [70,30]})

        context "with :tabs" do
          setup { topic[:tabs] }
          
          asserts(:[], 'tab2').equivalent_to({
            :commands=>["echo 'named tab'", "ls"],
            :options => {
              :name => "named tab",
              :settings=>"Grass"
            }
          })

          asserts(:[], 'tab1').equivalent_to({
            :commands=>["echo 'first tab'", "motion &", "echo 'than now'"]
          })

          asserts(:[],'tab3').equivalent_to({
            :commands=>["top","(mate &) && (gitx &) && cd /this"],
            :options =>{
              :name => "a tab",
              :settings => "Pro"
            }
          })

          asserts(:[],'tab4').equivalent_to({
            :commands=>["ls"],
            :options =>{
              :name => "another named tab",
              :settings => "Grass"
            }
          })

          asserts(:[],'default').equivalent_to({
            :commands=>['whoami && who && ls']
          })
        end

      end

      context "with 'window2' key" do
        setup { topic['window2'] }

        asserts(:[],:before).equals ['whoami']

        context "with :tabs" do
          setup { topic[:tabs] }

          asserts(:[], 'tab1').equals({ :commands => ["uptime"]})
          asserts(:[], 'default').equals({ :commands => []})
        end
      end

      context "with 'default' key" do
        setup { topic['default'] }

        context "with :tags key" do
          setup { topic[:tabs] }

          asserts(:[],'tab1').equals({
            :commands=>["echo 'default'", "echo 'default tab'", "ok", "for real"]
          })

          asserts(:[],'default').equals({
            :commands => []
          })
        end
      end
    end
  end
end

context "with panes" do
  setup { Terminitor::Dsl.new File.expand_path('../fixtures/iterm_panes.term', __FILE__) }
  asserts_topic.assigns :setup
  asserts_topic.assigns :windows
  asserts_topic.assigns :_context
 
  context "creates correct hash" do
    setup { topic.to_hash }

    context "in windows" do
      setup { topic[:windows] }

      context "with default window" do
        setup { topic['default'] }

        context "tabs with panes " do
          setup { topic[:tabs] }

          context "tabs can hold panes" do
            asserts(:[], 'tab1').equivalent_to({
              :commands=>["ls"],
              :panes => {
                'pane0' => {
                  :commands => ["echo 'first level pane'"],
                  :is_first_lvl_pane => true,
                  :panes => {
                    'pane0' => {
                      :commands => ["echo 'first second level pane'"]
                    }
                   }
                },
                'pane1' => {
                  :commands => ["gitx"],
                  :is_first_lvl_pane => true,
                  :panes => {
                    'pane0' => {
                      :commands => ["ls"]
                    },
                    'pane1' => {
                      :commands => ["echo 'wohoo'", "echo '2nd cmd'"]
                    }
                  }
                }
              }
            })
            asserts(:[], 'tab2').equivalent_to({
              :commands => ["echo 'second tab'"]
            })
          end
        end
      end
    end
  end
end
