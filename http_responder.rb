class HttpResponder
  STATUS_MESSAGES = {
    '200': 'OK',
    '404': 'Not Found'
  }.freeze

  def self.call(conn, status, headers, body)
    status_msg = STATUS_MESSAGES[status]
    conn.send("HTTP/1.1 #{status} #{status_msg}\r\n", 0)

    content_length = body.sum(&:length)
    conn.send("Content-Length: #{content_length}\r\n", 0)
    headers.each do |key, value|
      conn.send("#{key}: #{value}\r\n", 0)
    end

    conn.send("Connection: close\r\n", 0)
    conn.send("\r\n", 0)

    body.each do |chunk|
      conn.send(chunk, 0)
    end
  end
end