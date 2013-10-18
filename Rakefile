#!/usr/bin/env rake

require 'foodcritic'
require 'rake/testtask'

FoodCritic::Rake::LintTask.new do |t|
  # t.options = { :fail_tags => ['any'], :tags => ['~FC041'] }
  t.options = { :fail_tags => ['any'] }
end

Rake::TestTask.new do |t|
  t.name = "unit"
  t.test_files = FileList['test/unit/**/*_spec.rb']
  t.verbose = true
end

begin
  require 'kitchen/rake_tasks'
  Kitchen::RakeTasks.new
rescue LoadError
  puts ">>>>> Kitchen gem not loaded, omitting tasks" unless ENV['CI']
end

task :default => [:foodcritic, :unit]
