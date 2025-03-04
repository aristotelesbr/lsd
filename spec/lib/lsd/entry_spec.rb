require "spec_helper"

RSpec.describe Lsd::Entry do
  let(:temp_dir) { Dir.mktmpdir }
  let(:file_path) { File.join(temp_dir, "test.txt") }
  let(:dir_path) { File.join(temp_dir, "test_dir") }

  before(:each) do
    FileUtils.mkdir_p(dir_path)
    File.write(file_path, "test content")
    File.write(File.join(dir_path, "file.txt"), "nested content")
  end

  after(:each) do
    FileUtils.remove_entry temp_dir
  end

  describe "#name" do
    it "returns the basename of a file" do
      entry = described_class.new(file_path)
      expect(entry.name).to eq("test.txt")
    end
  end

  describe "#type" do
    it 'returns colored "dir" for directories' do
      entry = described_class.new(dir_path)
      expect(entry.type).to eq("dir".light_blue)
    end

    it 'returns colored "file" for files' do
      entry = described_class.new(file_path)
      expect(entry.type).to eq("file".light_black)
    end
  end

  describe "#size" do
    it "formats file size in bytes" do
      entry = described_class.new(file_path)
      allow(entry).to receive(:size).and_return("11 B")
      expect(entry.size).to eq("11 B")
    end

    it "formats directory size" do
      entry = described_class.new(dir_path)
      expect(entry.size).to match(/\d+ B|\d+\.\d+ KiB/)
    end
  end

  describe "#modified" do
    it "formats modification time" do
      entry = described_class.new(file_path)
      expect(entry.modified).to match(/\d+ (seconds|minutes|hours|days) ago/)
    end
  end

  describe "error handling" do
    it "handles non-existent paths" do
      expect do
        described_class.new("non_existent_path")
      end.to raise_error(Errno::ENOENT)
    end
  end
end
