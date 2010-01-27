require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "NetHttpExtensions" do
  it 'should yield if a block is passed' do
    Net::HTTP.new('example.com', 80).start { |http| http.get('/') }.body.should =~ /You have reached this web page by typing.*example\.com/
  end

  context 'with a current sandbox' do
    before(:each) do
      @current_sandbox = mock
      NetRecorder.stub!(:current_sandbox).and_return(@current_sandbox)
      FakeWeb.clean_registry
    end

    describe 'a request that is not registered with FakeWeb' do
      it 'should call #store_recorded_response! on the current sandbox' do
        recorded_response = NetRecorder::RecordedResponse.new(:get, 'http://example.com:80/', :example_response)
        NetRecorder::RecordedResponse.should_receive(:new).with(:get, 'http://example.com:80/', an_instance_of(Net::HTTPOK)).and_return(recorded_response)
        @current_sandbox.should_receive(:store_recorded_response!).with(recorded_response)
        Net::HTTP.get(URI.parse('http://example.com'))
      end

      it 'should not have an error if there is no current sandbox' do
        NetRecorder.stub!(:current_sandbox).and_return(nil)
        lambda { Net::HTTP.get(URI.parse('http://example.com')) }.should_not raise_error
      end
    end

    describe 'a request that is registered with FakeWeb' do
      it 'should call #store_recorded_response! on the current sandbox' do
        FakeWeb.register_uri(:get, 'http://example.com', :body => 'example.com response')
        @current_sandbox.should_not_receive(:store_recorded_response!)
        Net::HTTP.get(URI.parse('http://example.com'))
      end

      it 'should yield if a block is passed' do
        FakeWeb.register_uri(:get, 'http://example.com', :body => 'example.com response')
        Net::HTTP.new('example.com', 80).start { |http| http.get('/') }.body.should == 'example.com response'
      end
    end
  end
end