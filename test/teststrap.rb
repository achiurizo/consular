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