require 'fileutils'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require 'netrecorder'

After do
  FileUtils.rm_rf File.join(File.dirname(__FILE__), '..', 'fixtures', 'temp')
end

NetRecorder.cucumber_tags do |t|
  t.tag '@netrecorder_sandbox', :record => :unregistered
end