# frozen_string_literal: true

module Lsd
  class TableFormatter
    MAX_NAME_LENGTH = 30
    AVAILABLE_COLUMNS = {
      'index' => { header: '#', value: ->(_entry, idx) { idx.to_s.light_green } },
      'name' => { header: 'name', value: ->(entry, _) { entry.name.light_cyan } },
      'type' => { header: 'type', value: ->(entry, _) { entry.type } },
      'size' => { header: 'size', value: ->(entry, _) { entry.size.light_green } },
      'modified' => { header: 'modified', value: ->(entry, _) { entry.modified.light_magenta } },
      'permissions' => { header: 'permissions', value: ->(entry, _) { entry.permissions } }
    }.freeze

    DEFAULT_COLUMNS = %w[index name type size modified permissions]
    REQUIRED_COLUMNS = %w[index]

    def self.format(entries, columns = DEFAULT_COLUMNS)
      new(entries, columns).format
    end

    def initialize(entries, columns = DEFAULT_COLUMNS)
      @entries = entries
      @columns = process_columns(columns)
    end

    def format
      table = Terminal::Table.new(headings: headers, rows: formatted_rows, style: { border: :unicode })

      table.to_s.gsub(/[┌┐└┘]/, { '┌' => '╭', '┐' => '╮', '└' => '╰', '┘' => '╯' })
    end

    private

    def process_columns(columns)
      filtered_columns = columns.reject { |col| REQUIRED_COLUMNS.include?(col) }

      valid_columns =
        filtered_columns.select do |col|
          if AVAILABLE_COLUMNS.key?(col)
            true
          else
            warn "Warning: Unknown column '#{col}'. Available columns: #{(AVAILABLE_COLUMNS.keys - REQUIRED_COLUMNS).join(', ')}".yellow
            false
          end
        end

      REQUIRED_COLUMNS + valid_columns
    end

    def headers
      @columns.map { |col| AVAILABLE_COLUMNS[col][:header].light_green }
    end

    def formatted_rows
      @entries.map.with_index do |entry, index|
        @columns.map { |col| AVAILABLE_COLUMNS[col][:value].call(entry, index) }
      end
    end
  end
end
