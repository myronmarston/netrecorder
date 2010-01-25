# NetRecorder allows you to record requests and responses from the web

require 'yaml'
require "net_recorder/net_http_extensions"
require "net_recorder/fake_web_extensions"
require "net_recorder/config"
require "net_recorder/recorded_response"
require "net_recorder/sandbox"
require "net_recorder/cucumber_tags"

# NetRecorder - the global namespace
module NetRecorder
  extend self

  def current_sandbox
    sandboxes.last
  end

  def create_sandbox!(*args)
    sandbox = Sandbox.new(*args)
    sandboxes.push(sandbox)
    sandbox
  end

  def destroy_sandbox!
    sandbox = sandboxes.pop
    sandbox.destroy! if sandbox
    sandbox
  end

  def with_sandbox(*args)
    create_sandbox!(*args)
    yield
  ensure
    destroy_sandbox!
  end

  def config
    yield NetRecorder::Config
  end

  def cucumber_tags
    yield NetRecorder::CucumberTags
  end

private

  def sandboxes
    @sandboxes ||= []
  end
end