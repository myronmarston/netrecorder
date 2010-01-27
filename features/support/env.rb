require 'fileutils'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require 'netrecorder'

After do |scenario|
  NetRecorder.completed_cucumber_scenarios << scenario
end

NetRecorder.cucumber_tags do |t|
  t.tags '@netrecorder_sandbox1', '@netrecorder_sandbox2', :record => :unregistered
end

NetRecorder.module_eval do
  def self.completed_cucumber_scenarios
    @completed_cucumber_scenarios ||= []
  end
end
