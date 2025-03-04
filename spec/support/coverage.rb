require "simplecov"
require "simplecov-json"

SimpleCov.start do
  enable_coverage :branch
  formatters = [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::JSONFormatter
  ]
  SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(formatters)

  track_files "lib/**/*.rb"
  add_filter "/spec/"
end
