# Config class is used to capture configuration options
module NetRecorder
  class Config
    class << self
      attr_accessor :cache_dir
    end
  end
end