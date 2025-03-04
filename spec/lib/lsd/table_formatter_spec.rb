require "spec_helper"

RSpec.describe Lsd::TableFormatter do
  let(:entry) { instance_double("Lsd::Entry") }
  let(:entries) { [entry] }

  before do
    allow(entry).to receive(:name).and_return("test.txt")
    allow(entry).to receive(:type).and_return("file")
    allow(entry).to receive(:size).and_return("100 B")
    allow(entry).to receive(:modified).and_return("5 minutes ago")
  end

  describe ".format" do
    it "delegates to a new instance" do
      formatter = instance_double("Lsd::TableFormatter")
      expect(Lsd::TableFormatter).to receive(:new).with(entries, anything).and_return(formatter)
      expect(formatter).to receive(:format).and_return("formatted table")

      result = Lsd::TableFormatter.format(entries)
      expect(result).to eq("formatted table")
    end
  end

  describe "#initialize" do
    it "sets entries and processes columns" do
      formatter = Lsd::TableFormatter.new(entries)
      expect(formatter.instance_variable_get(:@entries)).to eq(entries)
      expect(formatter.instance_variable_get(:@columns)).to eq(Lsd::TableFormatter::DEFAULT_COLUMNS)
    end

    it "processes custom columns" do
      custom_columns = %w[name size]
      formatter = Lsd::TableFormatter.new(entries, custom_columns)

      expected_columns = Lsd::TableFormatter::REQUIRED_COLUMNS + custom_columns
      expect(formatter.instance_variable_get(:@columns)).to eq(expected_columns)
    end

    it "filters out invalid columns with a warning" do
      custom_columns = %w[name invalid_column]
      expect {
        formatter = Lsd::TableFormatter.new(entries, custom_columns)
        expected_columns = Lsd::TableFormatter::REQUIRED_COLUMNS + %w[name]
        expect(formatter.instance_variable_get(:@columns)).to eq(expected_columns)
      }.to output(/Warning: Unknown column 'invalid_column'/).to_stderr
    end
  end

  describe "#format" do
    it "creates a formatted table" do
      formatter = Lsd::TableFormatter.new(entries)
      result = formatter.format

      expect(result).to be_a(String)
      expect(result).to include("test.txt")
      expect(result).to include("file")
      expect(result).to include("100 B")
    end

    it "replaces corner characters with rounded ones" do
      formatter = Lsd::TableFormatter.new(entries)
      result = formatter.format

      expect(result).to include("╭")
      expect(result).to include("╮")
      expect(result).to include("╰")
      expect(result).to include("╯")
    end
  end
end
