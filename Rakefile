require 'bundler'
Bundler::GemHelper.install_tasks
require 'rake/testtask'

Rake::TestTask.new(:spec) do |test|
  test.libs << 'lib' << 'spec'
  test.pattern = 'spec/**/*_spec.rb'
  test.verbose = true
end
