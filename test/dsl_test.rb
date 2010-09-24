require File.expand_path('../teststrap', __FILE__)

context "Dsl" do
  setup { @path = File.expand_path('../fixtures/bar.term', __FILE__)}
  setup { @yaml = Terminitor::Dsl.new(@path) }
  asserts_topic.assigns :setup
  asserts_topic.assigns :windows
  asserts_topic.assigns :_context

  context "to_hash" do
    setup { @yaml.to_hash }
    asserts_topic.equivalent_to(:setup=>["echo \"setup\""], :windows=>{"window1"=>{"named tab"=>["echo 'named tab'", "ls"], "tab0"=>["echo 'first tab'", "echo 'of window'"]}, "default"=>{"tab0"=>["echo 'default'", "echo 'default tab'"]}})
  end

end
