module NetRecorderHelpers
  def have_expected_response(url, regex_str)
    simple_matcher("a response from #{url} that matches /#{regex_str}/") do |responses|
      regex = /#{regex_str}/i
      response = responses.detect { |r| URI.parse(r.uri) == URI.parse(url) }
      response.should_not be_nil
      response.response.body.should =~ regex
    end
  end
end

World(NetRecorderHelpers)

Given /^our cache dir is set to an empty directory$/ do
  NetRecorder.config do |c|
    c.cache_dir = File.join(File.dirname(__FILE__), '..', 'fixtures', 'temp', Time.now.to_i.to_s)
    Dir.glob("#{c.cache_dir}/*.yml").should be_empty
  end
end

Given /^this scenario is tagged with a netrecorder sandbox tag$/ do
  # do nothing...
end

When /^I make an HTTP get request to "([^\"]*)"$/ do |url|
  Net::HTTP.get_response(URI.parse(url))
end

When /^I make an HTTP get request to "([^\"]*)" within the "([^\"]*)" sandbox$/ do |url, sandbox_name|
  NetRecorder.with_sandbox(sandbox_name, :record => :all) do
    When %{I make an HTTP get request to "#{url}"}
  end
end

Then /^the "([^\"]*)" cache file should have a response for "([^\"]*)" that matches \/(.+)\/$/ do |sandbox_name, url, regex_str|
  yaml_file = File.join(NetRecorder::Config.cache_dir, "#{sandbox_name}.yml")
  responses = File.open(yaml_file, 'r') { |f| YAML.load(f.read) }
  responses.should have_expected_response(url, regex_str)
end

Then /^the current sandbox should have a recorded response for "([^\"]*)" that matches \/(.+)\/ so that it gets saved when the scenario completes$/ do |url, regex_str|
  NetRecorder.current_sandbox.recorded_responses.should have_expected_response(url, regex_str)
end
