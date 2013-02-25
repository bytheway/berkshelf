require 'spec_helper'

describe Berkshelf::Config do
  let(:klass) { described_class }

  describe "ClassMethods" do
    subject { klass }

    describe "::file" do
      subject { klass.file }

      context "when the file does not exist" do
        before :each do
          File.stub exists?: false
        end

        it { should be_nil }
      end
    end

    describe '::chef_config_path' do
      let(:path) { '/fake/path/for/.chef' }
      let(:config) { File.join(path, 'knife.rb') }

      before do
        ENV.stub(:[]).and_return(nil)

        File.stub(:exists?).with(any_args()).and_return(false)
        File.stub(:exists?).with(config).and_return(true)

        subject.instance_variable_set(:@chef_config_path, nil)
      end

      it 'uses $BERKSHELF_CHEF_CONFIG' do
        ENV.stub(:[]).with('BERKSHELF_CHEF_CONFIG').and_return(config)
        expect(subject.chef_config_path).to eq(config)
      end

      it 'uses $KNIFE_HOME' do
        ENV.stub(:[]).with('KNIFE_HOME').and_return(path)
        expect(subject.chef_config_path).to eq(config)
      end

      it 'uses ::working_dir' do
        Berkshelf::Config.stub(:working_dir).and_return(path)
        expect(subject.chef_config_path).to eq(config)
      end

      it 'does an ascending search' do
        Berkshelf::Config.stub(:working_dir).and_return(path)

        pathname = double('pathname')
        Pathname.stub(:new).and_return(pathname)
        Pathname.should_receive(:new).and_return(pathname)
        pathname.should_receive(:ascend).once

        expect(subject.chef_config_path).to eq(config)
      end

      it 'uses $HOME' do
        ENV.stub(:[]).with('HOME').and_return(File.join(path, '..'))
        expect(subject.chef_config_path).to eq(config)
      end
    end

    describe "::instance" do
      subject { klass.instance }

      it { should be_a klass }
    end

    describe "::path" do
      subject { klass.path }

      it { should be_a String }

      it "points to a location within ENV['BERKSHELF_PATH']" do
        ENV.stub(:[]).with('BERKSHELF_PATH').and_return('/tmp')

        subject.should eql("/tmp/config.json")
      end
    end

    describe "::chef_config" do
      it "returns the Chef::Config" do
        subject.chef_config.should eql(Chef::Config)
      end
    end

    describe "::chef_config_path" do
      subject { klass.chef_config_path }

      it { should be_a String }
    end
  end
end
