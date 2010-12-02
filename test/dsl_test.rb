require File.expand_path('../teststrap', __FILE__)

context "Dsl" do
  setup { @path = File.expand_path('../fixtures/bar.term', __FILE__)}
  setup { @yaml = Terminitor::Dsl.new(@path) }
  asserts_topic.assigns :setup
  asserts_topic.assigns :windows
  asserts_topic.assigns :_context
 
  context "to_hash" do
    setup { @yaml.to_hash }
    asserts_topic.equivalent_to :setup=>["echo \"setup\""], 
                                :windows=>{
                                  "window1"=>{:tabs=>{"tab2"=>{:commands=>["echo 'named tab'", "ls"], 
                                                               :options => {:name => "named tab", :settings=>"Grass"}}, 
                                                      "tab1"=>{:commands=>["echo 'first tab'", "echo 'of window'", "echo 'than now'"]},
                                                      "tab3"=>{:commands=>["top"],
                                                               :options =>{:name => "a tab", :settings => "Pro"}},
                                                      "default"=>{:commands=>['whoami']}
                                                     },
                                              :before => ['cd /path'],
                                              :options => {:size=>[70,30]}},
                                  "window2"=>{:tabs=>{"tab1"=>{:commands=>["uptime"]},
                                                      "default"=>{:commands=>[]}
                                                     },
                                              :before => ['whoami'],
                                              :options => {:name => 'server'}},
                                  "default"=>{:tabs=>{"tab1"=>{:commands=>["echo 'default'", "echo 'default tab'", "ok", "for real"]},
                                                      "default"=>{:commands=>[]}
                                                     }}}
  end

end
