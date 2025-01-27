# frozen_string_literal: true

require_relative "lsd/version"
require_relative "lsd/directory_lister"
require_relative "lsd/entry"
require_relative "lsd/table_formatter"

module Lsd
  class Error < StandardError; end
end
