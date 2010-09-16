require 'rubygems'
require 'riot'
require 'riot/rr'
require File.expand_path('../../lib/terminitor',__FILE__)
require 'fakefs/safe'
Riot.reporter = Riot::DotMatrixReporter

class Riot::Situation
end

class Riot::Context
end

class Object
  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end
    result
  end
end

class TestRunner
  include Terminitor::Runner
  
  def say(caption)
    puts caption
  end
end


class TestObject
  attr_accessor :test_item
  
  def initialize(test_item)
    @test_item = test_item
  end
  
  def windows
    [@test_item]
  end
end

class TestItem
  def do_script(prompt,hash)
    true
  end
  
  def get
    true
  end
  
  def keystroke(prompt,hash)
    true
  end
  
end
