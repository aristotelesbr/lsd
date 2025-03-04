require "spec_helper"

RSpec.describe Lsd::DirectoryLister do
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

  describe ".list" do
    it "lists directory contents" do
      allow(Lsd::TableFormatter).to receive(:format).and_return("formatted table")
      allow(Kernel).to receive(:puts)

      Dir.chdir(temp_dir) do
        expect { Lsd::DirectoryLister.list }.not_to raise_error
      end
    end

    it "handles permission errors" do
      allow(Dir).to receive(:entries).and_raise(Errno::EACCES)

      expect {
        Lsd::DirectoryLister.list("some/path")
      }.to raise_error(Lsd::DirectoryLister::Error, /Permission denied/)
    end

    it "rejects hidden files" do
      hidden_file = File.join(temp_dir, ".hidden")
      File.write(hidden_file, "hidden content")

      captured_entries = []

      allow(Lsd::TableFormatter).to receive(:format) do |entries|
        captured_entries = entries.map(&:name)
        "formatted table"
      end
      allow(Kernel).to receive(:puts)

      Dir.chdir(temp_dir) do
        Lsd::DirectoryLister.list
      end

      expect(captured_entries).not_to include(".hidden")
      expect(captured_entries).to include("test.txt", "test_dir")
    end

    it "sorts directories before files" do
      allow(Lsd::TableFormatter).to receive(:format).and_return("formatted table")
      allow(Kernel).to receive(:puts)

      dir_entry = instance_double("Lsd::Entry", name: "test_dir", type: "dir", size: "0 B", modified: "now")
      file_entry = instance_double("Lsd::Entry", name: "test.txt", type: "file", size: "0 B", modified: "now")

      allow(Lsd::Entry).to receive(:new) do |name|
        if name == "test_dir"
          dir_entry
        else
          file_entry
        end
      end

      allow(File).to receive(:directory?).and_call_original
      allow(File).to receive(:directory?).with("test_dir").and_return(true)
      allow(File).to receive(:directory?).with("test.txt").and_return(false)

      allow(Dir).to receive(:entries).and_return(["test.txt", "test_dir"])

      formatted_entries = nil
      allow(Lsd::TableFormatter).to receive(:format) do |entries|
        formatted_entries = entries
        "formatted table"
      end

      Lsd::DirectoryLister.list

      expect(formatted_entries.first).to eq(dir_entry)
      expect(formatted_entries.last).to eq(file_entry)
    end
  end
end
