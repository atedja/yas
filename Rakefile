require 'rake/testtask'

task :default => "test"

Rake::TestTask.new do |t|
  t.description = "Run tests"
  t.name = "test"
  t.pattern = "./test/**/*.rb"
end

desc "Build the gemfile"
task :build do
  `gem build yas.gemspec`
end
