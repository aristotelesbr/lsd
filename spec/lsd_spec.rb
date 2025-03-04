require "spec_helper"

RSpec.describe Lsd do
  it "has a version number" do
    expect(Lsd::VERSION).not_to be nil
  end

  it "defines Error as a StandardError subclass" do
    expect(Lsd::Error.ancestors).to include(StandardError)
  end

  it "loads the DirectoryLister class" do
    expect(defined?(Lsd::DirectoryLister)).to eq("constant")
  end

  it "loads the Entry class" do
    expect(defined?(Lsd::Entry)).to eq("constant")
  end

  it "loads the TableFormatter class" do
    expect(defined?(Lsd::TableFormatter)).to eq("constant")
  end

  describe "when used in a temporary directory" do
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

    it "can list directory contents through DirectoryLister" do
      allow(Lsd::TableFormatter).to receive(:format).and_return("formatted table")
      allow(Kernel).to receive(:puts)

      Dir.chdir(temp_dir) do
        expect { Lsd::DirectoryLister.list }.not_to raise_error
      end
    end

    it "handles permission errors gracefully" do
      allow(Dir).to receive(:entries).and_raise(Errno::EACCES)

      expect {
        Lsd::DirectoryLister.list("some/path")
      }.to raise_error(Lsd::DirectoryLister::Error, /Permission denied/)
    end
  end
end
