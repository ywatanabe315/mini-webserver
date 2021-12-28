require 'socket'
require './request_parser.rb'
require './http_responder.rb'
require './sample_rack_app.rb'

class SingleThreadServer
  PORT = ENV.fetch('PORT', 3000).freeze
  HOST = ENV.fetch('HOST', '127.0.0.1').freeze
  SOCKET_READ_BACKLOG = ENV.fetch('TCP_BACKLOG', 12).freeze

  attr_accessor :app

  def initialize(app)
    self.app = app
  end

  def start
    socket = Socket.new(:INET, :STREAM)
    socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
    socket.bind(Addrinfo.tcp(HOST, PORT))
    socket.listen(SOCKET_READ_BACKLOG)
    loop do
      conn, addr_info = socket.accept
      request = RequestParser.call(conn, addr_info)
      status, headers, body = app.call(request)
      HttpResponder.call(conn, status, headers, body)
    rescue => e
      puts e.message
    ensure
      conn&.close
    end
  end
end

SingleThreadServer.new(SampleRackApp.new).start
