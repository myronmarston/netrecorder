module NetRecorder
  class Sandbox
    VALID_RECORD_MODES = [:all, :none, :unregistered].freeze

    attr_reader :name, :record_mode

    def initialize(name, options = {})
      @name = name
      @record_mode = options[:record] || NetRecorder::Config.default_sandbox_record_mode
      self.class.raise_error_unless_valid_record_mode(record_mode)
      set_fakeweb_allow_net_connect
      load_recorded_responses
    end

    def destroy!
      write_recorded_responses_to_disk
      deregister_original_recorded_responses
      restore_fakeweb_allow_net_conect
    end

    def recorded_responses
      @recorded_responses ||= []
    end

    def store_recorded_response!(recorded_response)
      recorded_responses << recorded_response
    end

    def cache_file
      File.join(NetRecorder::Config.cache_dir, "#{name.to_s.gsub(/[^\w\-]+/, '_')}.yml") if NetRecorder::Config.cache_dir
    end

    def self.raise_error_unless_valid_record_mode(record_mode)
      unless VALID_RECORD_MODES.include?(record_mode)
        raise ArgumentError.new("#{record_mode} is not a valid sandbox record mode.  Valid options are: #{VALID_RECORD_MODES.inspect}")
      end
    end

    private

    def new_recorded_responses
      recorded_responses - @original_recorded_responses
    end

    def should_allow_net_connect?
      [:unregistered, :all].include?(record_mode)
    end

    def set_fakeweb_allow_net_connect
      @orig_fakeweb_allow_connect = FakeWeb.allow_net_connect?
      FakeWeb.allow_net_connect = should_allow_net_connect?
    end

    def restore_fakeweb_allow_net_conect
      FakeWeb.allow_net_connect = @orig_fakeweb_allow_connect
    end

    def load_recorded_responses
      @original_recorded_responses = []
      return if record_mode == :all

      if cache_file
        @original_recorded_responses = File.open(cache_file, 'r') { |f| YAML.load(f.read) } if File.exist?(cache_file)
        recorded_responses.replace(@original_recorded_responses)
      end

      recorded_responses.each do |rr|
        FakeWeb.register_uri(rr.method, rr.uri, { :response => rr.response })
      end
    end

    def write_recorded_responses_to_disk
      if NetRecorder::Config.cache_dir && new_recorded_responses.size > 0
        File.open(cache_file, 'w') { |f| f.write recorded_responses.to_yaml }
      end
    end

    def deregister_original_recorded_responses
      @original_recorded_responses.each do |rr|
        FakeWeb.remove_from_registry(rr.method, rr.uri)
      end
    end
  end
end