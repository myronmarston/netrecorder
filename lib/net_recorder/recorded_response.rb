module NetRecorder
  class RecordedResponse < Struct.new(:method, :uri, :response)
  end
end