module NetRecorder
  module CucumberTags
    extend self

    def tags(*tag_names)
      options = tag_names.last.is_a?(::Hash) ? tag_names.pop : {}
      tag_names.each do |tag_name|
        tag_name = "@#{tag_name}" unless tag_name.start_with?('@')
        sandbox_name = "cucumber_tags/#{tag_name.gsub(/\A@/, '')}"

        Before(tag_name) do
          NetRecorder.create_sandbox!(sandbox_name, options)
        end

        After(tag_name) do
          NetRecorder.destroy_sandbox!
        end
      end
    end
    alias :tag :tags
  end
end