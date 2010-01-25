require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe NetRecorder::Config do
  describe '#cache_dir=' do
    temp_dir(File.expand_path(File.dirname(__FILE__) + '/fixtures/config_spec'))

    it 'should create the directory if it does not exist' do
      lambda { NetRecorder::Config.cache_dir = @temp_dir }.should change { File.exist?(@temp_dir) }.from(false).to(true)
    end

    it 'should not raise an error if given nil' do
      lambda { NetRecorder::Config.cache_dir = nil }.should_not raise_error
    end
  end
end