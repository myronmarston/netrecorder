require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe NetRecorder do
  def create_sandbox
    NetRecorder.create_sandbox!(:sandbox_test)
  end

  describe 'create_sandbox!' do
    it 'should create a new sandbox' do
      create_sandbox.should be_instance_of(NetRecorder::Sandbox)
    end

    it 'should take over as the #current_sandbox' do
      orig_sandbox = NetRecorder.current_sandbox
      new_sandbox = create_sandbox
      new_sandbox.should_not == orig_sandbox
      NetRecorder.current_sandbox.should == new_sandbox
    end
  end

  describe 'destroy_sandbox!' do
    def destroy_sandbox
      NetRecorder.destroy_sandbox!
    end

    it 'should destroy the current sandbo' do
      sandbox = create_sandbox
      sandbox.should_receive(:destroy!)
      NetRecorder.destroy_sandbox!
    end

    it 'should return the destroyed sandbox' do
      sandbox = create_sandbox
      NetRecorder.destroy_sandbox!.should == sandbox
    end

    it 'should return the #current_sandbox to the previous one' do
      sandbox1, sandbox2 = create_sandbox, create_sandbox
      lambda { NetRecorder.destroy_sandbox! }.should change(NetRecorder, :current_sandbox).from(sandbox2).to(sandbox1)
    end
  end

  describe 'with_sandbox' do
    it 'should create a new sandbox' do
      new_sandbox = NetRecorder::Sandbox.new(:with_sandbox_test)
      NetRecorder.should_receive(:create_sandbox!).and_return(new_sandbox)
      NetRecorder.with_sandbox(:sandbox_test) { }
    end

    it 'should yield' do
      yielded = false
      NetRecorder.with_sandbox(:sandbox_test) { yielded = true }
      yielded.should be_true
    end

    it 'should destroy the sandbox' do
      NetRecorder.should_receive(:destroy_sandbox!)
      NetRecorder.with_sandbox(:sandbox_test) { }
    end

    it 'should destroy the sandbox even if there is an error' do
      NetRecorder.should_receive(:destroy_sandbox!)
      lambda { NetRecorder.with_sandbox(:sandbox_test) { raise StandardError } }.should raise_error
    end
  end

  describe 'config' do
    it 'should yield the configuration object' do
      yielded_object = nil
      NetRecorder.config do |obj|
        yielded_object = obj
      end
      yielded_object.should == NetRecorder::Config
    end
  end
end
