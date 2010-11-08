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
                                  "window1"=>{:tabs=>{"named tab"=>{:commands=>["echo 'named tab'", "ls"], :options => {:settings=>"Grass"}}, 
                                                      "tab0"=>{:commands=>["echo 'first tab'", "echo 'of window'", "echo 'than now'"]}}, :options => {:size=>[70,30]}}, 
                                  "default"=>{:tabs=>{"tab0"=>{:commands=>["echo 'default'", "echo 'default tab'", "ok", "for real"]}}}}
  end

end
