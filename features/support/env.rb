require 'fileutils'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require 'netrecorder'

NetRecorder.config do |c|
  c.cache_dir = File.join(File.dirname(__FILE__), '..', 'fixtures', 'netrecorder_sandboxes')
end

NetRecorder.module_eval do
  def self.completed_cucumber_scenarios
    @completed_cucumber_scenarios ||= []
  end

  class << self
    attr_accessor :current_cucumber_scenario
  end
end

After do |scenario|
  NetRecorder.completed_cucumber_scenarios << scenario
end

Before do |scenario|
  NetRecorder.current_cucumber_scenario = scenario
  temp_dir = File.join(NetRecorder::Config.cache_dir, 'temp')
  FileUtils.rm_rf(temp_dir) if File.exist?(temp_dir)
end

Before('@copy_not_the_real_response_to_temp') do
  orig_file = File.join(NetRecorder::Config.cache_dir, 'not_the_real_response.yml')
  temp_file = File.join(NetRecorder::Config.cache_dir, 'temp', 'not_the_real_response.yml')
  FileUtils.mkdir_p(File.join(NetRecorder::Config.cache_dir, 'temp'))
  FileUtils.cp orig_file, temp_file
end

at_exit do
  %w(record_sandbox1 record_sandbox2).each do |tag|
    cache_file = File.join(NetRecorder::Config.cache_dir, 'cucumber_tags', "#{tag}.yml")
    FileUtils.rm_rf(cache_file) if File.exist?(cache_file)
  end
end

NetRecorder.cucumber_tags do |t|
  t.tags '@record_sandbox1', '@record_sandbox2', :record => :unregistered
  t.tags '@replay_sandbox1', '@replay_sandbox2', :record => :none
end