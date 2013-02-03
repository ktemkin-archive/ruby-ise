require "bundler/gem_tasks"

task :default => :test_all

task :test_all do
  sh "rspec -Ilib"
end

desc 'Builds the ruby-ise gem.'
task :build do
  sh "gem build ruby-ise.gemspec"
end

desc 'Builds and installs the ruby-ise gem.'
task :install => :build do
  sh "gem install pkg/ruby-ise-#{ISE::VERSION}.gem"
end

desc 'Tags the current version, pushes it GitHub, and pushes the gem.'
task :release => :build do
  sh "git tag v#{ISE::VERSION}"
  sh "git push origin master"
  sh "git push origin v#{ISE::VERSION}"
  sh "git push pkg.ruby-ise-#{ISE::VERSION}.gem"
end
