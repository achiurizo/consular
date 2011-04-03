require 'rubygems'
require 'riot'
require 'riot/rr'
require File.expand_path('../../lib/terminitor',__FILE__)


# Yield the block if the platform matches current platform
# example:
#   on_platform('linux') { puts 'hi' }
def on_platform(*platform)
  platform = [platform] unless platform.respond_to? :each
  platform.each { |p|  yield && break if RUBY_PLATFORM.downcase.include?(p) }
end

on_platform('linux', 'darwin') do
  require 'fakefs/safe'
end

Riot.pretty_dots

class Riot::Situation
end

class Riot::Context
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
