require File.expand_path('../teststrap', __FILE__)

context "Terminitor::Core" do
  setup do
    Terminitor::Core.new(File.expand_path('../fixtures/bar.term', __FILE__))
  end

  asserts_topic.assigns :termfile

  asserts(:setup!).raises NotImplementedError
  asserts(:process!).raises NotImplementedError
end
