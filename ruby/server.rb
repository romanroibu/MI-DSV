require 'socket'

require './message'
require './extensions'

Thread.abort_on_exception = true

class Channel
  def initialize items=[]
    @queue = items.reverse
  end

  def push item
    Thread.exclusive { @queue.push item }
  end

  def pop
    Thread.exclusive { @queue.pop }
  end
end

class NodeServer
  attr_reader :node

  def initialize node
    @node = node
    @message_channel = Channel.new
  end

  def start

    # Server accept thread
    Thread.new(@node) do |node|
      server_socket = Socket.new :INET, :STREAM
      server_socket.bind Addrinfo.tcp(node.host, node.port)
      server_socket.listen 2

      loop do
        client_socket, client_address = server_socket.accept
        message = client_socket.recv_message
        @message_channel.push [client_socket, message]
        handle_message
      end
    end

    self.node.start

    # Keyboard input thread
    Thread.new do
      loop do
        input = $stdin.gets.chomp
        self.node.send_chat_message input
      end
    end

    # Ping thread
    Thread.new do
      count = 1

      loop do
        begin
          message = PingMessage.new
          self.node.send_to_next_node message
        rescue Errno::ECONNREFUSED
          #Do nothing
        end

        if (Time.now.to_i - self.node.ping_timestamp) > 11 # Tolerance for non-responsice nodes, in seconds
          self.node.dead_node
        end

        sleep 5
        count += 1
      end
    end

    # Main blocking thread
    loop do
      begin
        sleep 1
      rescue Interrupt => e
        self.node.quit
        exit
      end
    end
  end

  # private

  def handle_message
    socket, message = @message_channel.pop
    return if message.nil?

    case message
    when ConnectMessage
      old_host, old_port = self.node.connect message.host, message.port
      message = ConnectedMessage.new host: old_host, port: old_port
      socket.send_message message

    when ElectionMessage, ElectedMessage
      self.node.chang_roberts message

    when ChatMessage
      self.node.propagate_chat_message message

    when BroadcastMessage
      self.node.persist_chat_message message

    when DisconnectMessage
      if self.node.next_host == message.host and self.node.next_port == message.port
        # This is the node that points to the dead node; change it's pointer
        self.node.set_next message.next_host, message.next_port
      else
        self.node.send_to_next_node message
      end

    when PingMessage
      self.node.ping_timestamp = Time.now.to_i

    when DeadNodeMessage
      self.node.dead_node message

    else
      raise RuntimeError, "Unexpected message: #{message.inspect}"
    end

    socket.close if not socket.closed?
  end

end
