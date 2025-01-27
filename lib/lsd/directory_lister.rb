# frozen_string_literal: true

require "terminal-table"
require "colorize"

require_relative "entry"
require_relative "table_formatter"

module Lsd
  module DirectoryLister
    class Error < StandardError; end

    def self.list(path = ".")
      entries = Dir.entries(path)
        .reject { |e| e.start_with?(".") }
        .sort_by { |name| [File.directory?(name) ? 0 : 1, name.downcase] }
        .map { |name| Entry.new(name) }

      puts TableFormatter.format(entries)
    rescue Errno::EACCES => e
      raise Error, "Permission denied: #{path}"
    end
  end
end
