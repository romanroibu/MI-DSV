require 'socket'

require './message'
require './extensions'

class Node
  attr_reader :id
  attr_accessor :host, :port, :next_host, :next_port, :leader_id, :participant, :ping_timestamp

  def initialize node_address, next_address=nil
    next_address ||= node_address # Default next node address to this node

    @participant = false
    @leader_id   = nil
    @ping_timestamp = Time.now.to_i
    @id = Node.id_from_address node_address

    @host,      @port      = Node.parse_address node_address
    @next_host, @next_port = Node.parse_address next_address

    puts "[THIS NODE'S ID: #{self.id}]"
  end

  def start
    if self.next_host != self.host or self.next_port != self.port
      message = ConnectMessage.new host: self.host, port: self.port
      response = send_to_next_node message, true
      raise RuntimeError, "Expected 'ConnectedMessage', got: #{response.inspect}" unless response.is_a? ConnectedMessage
      self.next_host, self.next_port = response.host, response.port
    end

    init_leader_election
  end

  def connect host, port
    old_host,  old_port  = next_host, next_port
    self.next_host, self.next_port = host, port
    [old_host, old_port]
  end

  def init_leader_election
    self.participant = true
    message = ElectionMessage.new node_id: self.id
    send_to_next_node message
  end

  def chang_roberts message
    case message
    when ElectionMessage
      if self.id < message.node_id # Not the leader
        self.participant = true

      elsif self.id > message.node_id and not self.participant # Try to get elected
        self.participant = true
        message.node_id = self.id

      else # I'm the leader
        self.participant = false
        self.leader_id = message.node_id
        message = ElectedMessage.new node_id: self.leader_id
      end

    when ElectedMessage
      if self.id == message.node_id # I'm the leader
        puts "[THIS NODE IS THE NEW LEADER WITH ID: #{self.leader_id}]"
        return

      else
        self.participant = false
        self.leader_id = message.node_id
        puts "[NEW LEADER ELECTED WITH ID: #{self.leader_id}]"
      end

    else
      raise RuntimeError, "Unexpected message: #{message.inspect}"
    end

    send_to_next_node message
  end

  def send_chat_message text
    message = ChatMessage.new node_id: self.id, text: text
    propagate_chat_message message
  end

  def propagate_chat_message message
    leader_address = Node.address_from_id self.leader_id
    self_address   = Node.address_from_id self.id

    if self.leader_id == self.id
      text      = message.text
      sender_id = message.node_id
      message = BroadcastMessage.new node_id: sender_id, text: text
      persist_chat_message message, true
    else
      send_to_next_node message
    end
  end

  def persist_chat_message message, initial=false
    text      = message.text
    sender_id = message.node_id

    return if self.leader_id == self.id and not initial

    send_to_next_node message

    address = Node.address_from_id sender_id
    $stdout.puts "#{address}> #{text}"
  end

  def quit
    return if self.next_host == self.host and self.next_port == self.port

    node_hash = {
      host:      self.host,
      port:      self.port,
      next_host: self.next_host,
      next_port: self.next_port
    }

    message = DisconnectMessage.new node_hash
    send_to_next_node message
  end

  def set_next new_host, new_port
    old_host = self.next_host
    old_port = self.next_port
    self.next_host = new_host
    self.next_port = new_port

    puts "[CHANGED NEXT NODE FROM #{old_host}:#{old_port} TO #{new_host}:#{new_port}]"
    init_leader_election
  end

  def dead_node message=nil
    message ||= DeadNodeMessage.new host: self.host, port: self.port

    begin
      send_to_next_node message
    rescue Errno::ECONNREFUSED
      set_next message.host, message.port
    end
  end

  def send_to_next_node message, need_response=false
      socket = socket_connect self.next_host, self.next_port

      if socket
        socket.send_message message
        response = need_response ? socket.recv_message : nil
        socket.close unless socket.closed?
        response
      end
  end

  private

  def self.id_from_address address
    host, port = parse_address address
    ip = host.split('.').inject(0) { |mem, var| (mem + var.to_i) << 8 }
    (ip << 8) + port.to_i
  end

  def self.address_from_id id
    port = id & 65535
    host = id >> 16
    host =[24,16,8,0].collect{|n| (host >> n) & 255 }.join('.')
    [host, port].join(':')
  end

  def self.parse_address address
    host, port = address.split ':'
    [host, port.to_i]
  end

  def socket_connect host, port
    socket = Socket.new :INET, :STREAM
    socket.connect Addrinfo.tcp(host, port.to_i)
    socket
  end
end

