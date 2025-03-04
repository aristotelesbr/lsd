module Lsd
  module DirectoryLister
    Error = Class.new(StandardError)

    FILE_PRIORITY = 1
    DIRECTORY_PRIORITY = 0

    def self.list(path = ".")
      entries = Dir.entries(path)
        .reject { |entry| entry.start_with?(".") }
        .sort_by { |name| [File.directory?(name) ? DIRECTORY_PRIORITY : FILE_PRIORITY, name.downcase] }
        .map { |name| Entry.new(name) }

      puts TableFormatter.format(entries)
    rescue Errno::EACCES
      raise Error, "Permission denied: #{path}"
    end
  end
end
