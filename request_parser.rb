class RequestParser
  MAX_URI_LENGTH = 2083

  class << self

    def call(conn, addr_info)
      method, full_path, path, query = read_request_line(conn)
      headers = read_header(conn)
      body = read_body(conn, method, headers)

      {
        'REQUEST_METHOD': method,
        'PATH_INFO': path,
        'QUERY_STRING': query,
        'REMOTE_ADDR': addr_info.ip_address,
        'rack.input': body ? StringIO.new(body) : nil
      }.merge(rack_headers(headers))
    end

    private
  
    # NOTE: parse "POST /some-path?query HTTP/1.1"
    def read_request_line(conn)
      request_line = conn.gets("\n", MAX_URI_LENGTH)
      method, full_path, _http_version = request_line.split(' ', 3)
      path, query = full_path.split('?', 2)
      [method, full_path, path, query]
    end

    def read_header(conn)
      headers = {}
      loop do
        header_line = conn.gets("\n")&.strip
        break if header_line.nil? || header_line.empty?
        key, value = header_line.split(/:\s/, 2)
        headers[key] = value
      end
      headers
    end

    def read_body(conn, method, headers)
      return nil unless ['POST', 'PUT'].include?(method)
      content_size = headers['Content-Length'].to_i
      conn.read(content_size)
    end

    # def make_request_uri(full_path, port, remote_host)

    # end

    def rack_headers(headers)
      headers.transform_keys do |key|
        "HTTP_#{key.upcase}"
      end
    end
  end
end