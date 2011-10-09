require File.expand_path('../spec_helper', __FILE__)

describe Consular do

  after do 
    Consular.instance_variable_set(:@cores,[])
    Consular.instance_variable_set(:@global_path,nil)
  end

  it "can add cores" do
    Consular.add_core Consular::Core
    assert_equal 1, Consular.cores.size
  end

  it "has default configurations" do
    assert_equal File.join(ENV['HOME'],'.config','consular',''), Consular.global_path
  end

  it "can be configured" do
    Consular.configure do |c|
      c.global_path    = '/tmp/'
      c.default_editor = 'vim'
    end

    assert_equal '/tmp/',         Consular.global_path
    assert_equal 'vim',           Consular.default_editor
    assert_equal '/tmp/Termfile', Consular.global_path('Termfile')
  end

end
