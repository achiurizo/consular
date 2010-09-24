require File.expand_path('../teststrap', __FILE__)

context "Yaml" do
  setup { @path = File.expand_path('../fixtures/foo.yml', __FILE__)}
  setup { @yaml = Terminitor::Yaml.new(@path) }
  asserts_topic.assigns :file
  
  context "to_hash" do
    setup { @yaml.to_hash }
    asserts_topic.equivalent_to({ :setup => nil, :windows => {'default' => {'tab1' => ['cd /foo/bar','gitx'], 'tab2' => ['ls','mate .']}}})
  end
  
end