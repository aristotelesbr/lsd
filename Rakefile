require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "standard/rake"

namespace :coverage do
  desc "Check test coverage using SimpleCov"
  task :check do
    require "simplecov"

    SimpleCov.minimum_coverage 90
    SimpleCov.minimum_coverage_by_file 80
    SimpleCov.refuse_coverage_drop

    puts "Coverage check completed successfully!"
  end

  desc "Generate coverage report"
  task :report do
    require "simplecov"
    puts "HTML report available at coverage/index.html"
  end
end
desc "Run full coverage validation and reporting"
task coverage: ["spec", "coverage:check"]

task default: %i[spec standard]
