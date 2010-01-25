require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe NetRecorder::CucumberTags do
  before(:each) do
    # It'd be nice if we could mock/stub Kernel, but I haven't had luck doing that, and this is a work around.
    @hook_args = { :before => { :args => [], :blocks => [] }, :after => { :args => [], :blocks => [] } }
    store_hook_args = lambda { |type, args, block| @hook_args[type][:args] << args; @hook_args[type][:blocks] << block }
    Kernel.class_eval do
      define_method :Before do |*args, &block|
        store_hook_args.call(:before, args, block)
      end

      define_method :After do |*args, &block|
        store_hook_args.call(:after, args, block)
      end
    end
  end

  describe 'tag' do
    [:before, :after].each do |hook|
      it "should set up a cucumber #{hook} hook for the given tag that creates a new sandbox" do
        NetRecorder::CucumberTags.tag 'tag_test'
        @hook_args[hook][:args].should == [['@tag_test']]

        if hook == :before
          NetRecorder.should_receive(:create_sandbox!).with('cucumber_tags/tag_test', {})
        else
          NetRecorder.should_receive(:destroy_sandbox!)
        end
        @hook_args[hook][:blocks].first.call
      end

      it "should set up separate hooks for each tag, passing the given options to each sandbox" do
        NetRecorder::CucumberTags.tags 'tag_test1', 'tag_test2', :record => :none
        @hook_args[hook][:args].should == [['@tag_test1'], ['@tag_test2']]

        if hook == :before
          NetRecorder.should_receive(:create_sandbox!).with('cucumber_tags/tag_test1', { :record => :none }).once
          NetRecorder.should_receive(:create_sandbox!).with('cucumber_tags/tag_test2', { :record => :none }).once
        else
          NetRecorder.should_receive(:destroy_sandbox!).twice
        end
        @hook_args[hook][:blocks].each { |b| b.call }
      end

      it "should work with tags that start with an @" do
        NetRecorder::CucumberTags.tag '@tag_test'
        @hook_args[hook][:args].should == [['@tag_test']]

        if hook == :before
          NetRecorder.should_receive(:create_sandbox!).with('cucumber_tags/tag_test', {})
        else
          NetRecorder.should_receive(:destroy_sandbox!)
        end
        @hook_args[hook][:blocks].first.call
      end
    end
  end
end