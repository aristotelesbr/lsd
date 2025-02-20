# frozen_string_literal: true

module Lsd
  class Entry
    attr_reader :stat

    def initialize(name)
      @full_path = name
      @stat = File.stat(name)
    end

    def name
      @name ||= File.basename(@full_path)
    end

    def type
      @type ||= directory? ? 'dir'.light_blue : 'file'.light_black
    end

    def size
      @size ||= format_size(raw_size)
    end

    def raw_size
      @raw_size ||= calculate_size
    end

    def modified
      @modified ||= format_time_ago(stat.mtime)
    end

    def permissions
      @permissions ||= perms_string(stat.mode.to_s(8)[2..])
    end

    private

    def directory?
      @is_directory ||= File.directory?(@full_path)
    end

    def calculate_size
      if directory?
        dir_size = 0
        begin
          Dir.glob("#{@full_path}/**/*", File::FNM_DOTMATCH).each do |f|
            next if File.directory?(f)
            next if f.end_with?('/.', '/..')

            dir_size += File.size(f)
          rescue Errno::ENOENT, Errno::EACCES
            next
          end
        rescue Errno::EACCES
          return 0
        end
        dir_size
      else
        stat.size
      end
    end

    def format_size(bytes)
      return '0 B' if bytes == 0

      {
        1024**3 => 'GiB',
        1024**2 => 'MiB',
        1024 => 'KiB'
      }.each do |threshold, unit|
        if bytes >= threshold
          value = bytes.to_f / threshold
          return value < 10 ? format('%.1f %s', value, unit) : format('%d %s', value.round, unit)
        end
      end
      "#{bytes} B"
    end

    TIME_INTERVALS = {
      86_400 => ->(diff) { "#{(diff / 86_400).round} days ago" },
      3600 => ->(diff) { "#{(diff / 3600).round} hours ago" },
      60 => ->(diff) { "#{(diff / 60).round} minutes ago" },
      0 => ->(diff) { "#{diff.round} seconds ago" }
    }.freeze

    def format_time_ago(time)
      diff = Time.now - time
      TIME_INTERVALS.each do |threshold, formatter|
        return formatter.call(diff) if diff >= threshold
      end
    end

    def perms_string(perms)
      pstring = ''
      perms.each_char do |p|
        case p
        when '0'
          pstring += '--- '
        when '1'
          pstring += '--x '
        when '2'
          pstring += '-w- '
        when '3'
          pstring += '-wx '
        when '4'
          pstring += 'r-- '
        when '5'
          pstring += 'r-x '
        when '6'
          pstring += 'rw- '
        when '7'
          pstring += 'rwx '
        end
      end

      pstring
    end
  end
end
