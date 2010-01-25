require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe NetRecorder::Sandbox do
  before(:each) do
    FakeWeb.clean_registry
  end

  describe '#store_recorded_response!' do
    it 'should add the recorded response to #recorded_responses' do
      recorded_response = NetRecorder::RecordedResponse.new(:get, 'http://example.com', :response)
      sandbox = NetRecorder::Sandbox.new(:test_sandbox)
      sandbox.recorded_responses.should == []
      sandbox.store_recorded_response!(recorded_response)
      sandbox.recorded_responses.should == [recorded_response]
    end
  end

  describe 'on creation' do
    { :unregistered => true, :all => true, :none => false }.each do |record_mode, allow_fakeweb_connect|
      it "should set FakeWeb.allow_net_connect to #{allow_fakeweb_connect} when the record mode is #{record_mode}" do
        FakeWeb.allow_net_connect = !allow_fakeweb_connect
        NetRecorder::Sandbox.new(:name, :record => record_mode)
        FakeWeb.allow_net_connect?.should == allow_fakeweb_connect
      end
    end

    it 'should load the recorded responses from the cached yml file' do
      NetRecorder::Config.cache_dir = File.expand_path(File.dirname(__FILE__) + '/fixtures/sandbox_spec')
      sandbox = NetRecorder::Sandbox.new('example')
      sandbox.should have(2).recorded_responses

      rr1, rr2 = sandbox.recorded_responses.first, sandbox.recorded_responses.last

      rr1.method.should == :get
      rr1.uri.should == 'http://example.com:80/'
      rr1.response.body.should =~ /You have reached this web page by typing.+example\.com/

      rr2.method.should == :get
      rr2.uri.should == 'http://example.com:80/foo'
      rr2.response.body.should =~ /foo was not found on this server/
    end

    it 'should register the recorded responses with fakeweb' do
      NetRecorder::Config.cache_dir = File.expand_path(File.dirname(__FILE__) + '/fixtures/sandbox_spec')
      sandbox = NetRecorder::Sandbox.new('example')

      rr1 = FakeWeb.response_for(:get, "http://example.com")
      rr2 = FakeWeb.response_for(:get, "http://example.com/foo")
      rr1.should_not be_nil
      rr2.should_not be_nil
      rr1.body.should =~ /You have reached this web page by typing.+example\.com/
      rr2.body.should =~ /foo was not found on this server/
    end
  end

  describe '#destroy!' do
    temp_dir File.expand_path(File.dirname(__FILE__) + '/fixtures/sandbox_spec_destroy'), :assign_to_cache_dir => true

    [true, false].each do |orig_allow_net_connect|
      it "should reset FakeWeb.allow_net_connect #{orig_allow_net_connect} if it was originally #{orig_allow_net_connect}" do
        FakeWeb.allow_net_connect = orig_allow_net_connect
        sandbox = NetRecorder::Sandbox.new(:name)
        sandbox.destroy!
        FakeWeb.allow_net_connect?.should == orig_allow_net_connect
      end
    end

    it "should write the recorded responses to disk as yaml" do
      recorded_responses = [
        NetRecorder::RecordedResponse.new(:get,  'http://example.com', :get_example_dot_come_response),
        NetRecorder::RecordedResponse.new(:post, 'http://example.com', :post_example_dot_come_response),
        NetRecorder::RecordedResponse.new(:get,  'http://google.com',  :get_google_dot_come_response)
      ]

      sandbox = NetRecorder::Sandbox.new(:destroy_test)
      sandbox.stub!(:recorded_responses).and_return(recorded_responses)

      yaml_file = File.join(@temp_dir, 'destroy_test.yml')
      lambda { sandbox.destroy! }.should change { File.exist?(yaml_file) }.from(false).to(true)
      saved_recorded_responses = File.open(yaml_file, "r") { |f| YAML.load(f.read) }
      saved_recorded_responses.should == recorded_responses
    end
  end
end