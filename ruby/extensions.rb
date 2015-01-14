require 'socket'
require './log'

class Socket
  # Returns the host local IPv4 address as Addrinfo object
  def self.local_address
    ip_address_list.reject(&:ipv4_loopback?).find(&:ipv4?)
  end

  # Returns the host local IPv4 address as String object
  def self.local_ip
    local_address.ip_address
  end

  # Serialize and send an instance of Message
  def send_message message
    dump = Marshal.dump message
    self.send dump, 0
  end

  # Recieve and deserialize an instance of Message
  def recv_message
    dump = self.recv 1024

    begin
      Marshal.load dump
    rescue ArgumentError => e
      nil
    end
  end
end

