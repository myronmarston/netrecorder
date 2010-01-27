require 'net/http'

module Net
  class HTTP
    def request_with_netrecorder(request, body = nil, &block)
      response = request_without_netrecorder(request, body, &block)
      store_response(response, request)
      response
    end
    alias_method :request_without_netrecorder, :request
    alias_method :request, :request_with_netrecorder

    private

    def store_response(response, request)
      if sandbox = NetRecorder.current_sandbox
        # Copied from: http://github.com/chrisk/fakeweb/blob/fakeweb-1.2.8/lib/fake_web/ext/net_http.rb#L39-52
        protocol = use_ssl? ? "https" : "http"

        path = request.path
        path = URI.parse(request.path).request_uri if request.path =~ /^http/

        if request["authorization"] =~ /^Basic /
          userinfo = FakeWeb::Utility.decode_userinfo_from_header(request["authorization"])
          userinfo = FakeWeb::Utility.encode_unsafe_chars_in_userinfo(userinfo) + "@"
        else
          userinfo = ""
        end

        uri = "#{protocol}://#{userinfo}#{self.address}:#{self.port}#{path}"
        method = request.method.downcase.to_sym

        sandbox.store_recorded_response!(NetRecorder::RecordedResponse.new(method, uri, response))
      end
    end
  end
end