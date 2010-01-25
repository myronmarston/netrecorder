require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe NetRecorder::Sandbox do
  describe '#store_recorded_response!' do
    it 'should add the recorded response to #recorded_responses' do
      recorded_response = NetRecorder::RecordedResponse.new(:get, 'http://example.com', :response)
      sandbox = NetRecorder::Sandbox.new(:test_sandbox)
      sandbox.recorded_responses.should == []
      sandbox.store_recorded_response!(recorded_response)
      sandbox.recorded_responses.should == [recorded_response]
    end
  end
end