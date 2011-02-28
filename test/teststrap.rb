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

# Yield the block if the platform matches current platform
# example:
#   on_platform('linux') { puts 'hi' }
def on_platform(platform)
  yield if RUBY_PLATFORM.downcase.include?(platform)
end

module Kernel
  def capture(stream)
    eval "$#{stream} = StringIO.new"
    yield
    eval("$#{stream}").string
  ensure
    eval("$#{stream} = #{stream.to_s.upcase}")
  end
end

# This is to silence the 'task' warning for the mocks.
class Thor
  class << self
    def create_task(meth) #:nodoc:
      if @usage && @desc
        base_class = @hide ? Thor::HiddenTask : Thor::Task
        tasks[meth] = base_class.new(meth, @desc, @long_desc, @usage, method_options)
        @usage, @desc, @long_desc, @method_options, @hide = nil
        true
      elsif self.all_tasks[meth] || meth == "method_missing"
        true
      else
        false
      end
    end
  end
end
