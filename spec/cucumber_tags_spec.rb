require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe NetRecorder::CucumberTags do
  before(:each) do
    @args =   { :before => [], :after => [] }
    @blocks = { :before => [], :after => [] }
  end

  def Before(*args, &block)
    @args[:before]   << args
    @blocks[:before] << block
  end

  def After(*args, &block)
    @args[:after]   << args
    @blocks[:after] << block
  end

  describe 'tag' do
    [:before, :after].each do |hook|
      it "should set up a cucumber #{hook} hook for the given tag that creates a new sandbox" do
        NetRecorder.cucumber_tags { |t| t.tag 'tag_test' }

        @args[hook].should == [['@tag_test']]

        if hook == :before
          NetRecorder.should_receive(:create_sandbox!).with('cucumber_tags/tag_test', {})
        else
          NetRecorder.should_receive(:destroy_sandbox!)
        end
        @blocks[hook].should have(1).block
        @blocks[hook].first.call
      end

      it "should set up separate hooks for each tag, passing the given options to each sandbox" do
        NetRecorder.cucumber_tags { |t| t.tag 'tag_test1', 'tag_test2', :record => :none }
        @args[hook].should == [['@tag_test1'], ['@tag_test2']]

        if hook == :before
          NetRecorder.should_receive(:create_sandbox!).with('cucumber_tags/tag_test1', { :record => :none }).once
          NetRecorder.should_receive(:create_sandbox!).with('cucumber_tags/tag_test2', { :record => :none }).once
        else
          NetRecorder.should_receive(:destroy_sandbox!).twice
        end
        @blocks[hook].should have(2).blocks
        @blocks[hook].each { |b| b.call }
      end

      it "should work with tags that start with an @" do
        NetRecorder.cucumber_tags { |t| t.tag '@tag_test' }
        @args[hook].should == [['@tag_test']]

        if hook == :before
          NetRecorder.should_receive(:create_sandbox!).with('cucumber_tags/tag_test', {})
        else
          NetRecorder.should_receive(:destroy_sandbox!)
        end
        @blocks[hook].should have(1).block
        @blocks[hook].first.call
      end
    end
  end
end