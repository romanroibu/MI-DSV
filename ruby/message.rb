# Abstract Class
class Message
  def initialize options={}
    options[:node_id] = options[:node_id].to_i
    @options = options
  end

  # Handy getters
  def data
    @options
  end

  # Handy setter
  def node_id= id
    @options[:node_id] = id
  end

  # Serialization
  def _dump level
    data.map{|k,v| "#{k}=>#{v}" }.join('||')
  end

  # Deserialization
  def self._load args
    key_value_pairs = args.split('||').map{|p| p.split('=>')  }.map{|k,v| [k.to_sym, v] }
    new Hash[key_value_pairs]
  end

  def method_missing method, *args, &block
    if @options.keys.include? method
      @options[method]
    else
      super method, *args, &block
    end
  end
end

# Chang-Roberts Algorithm Messages

# Abstract Class
class ChangRoberstAlgorithmMessage < Message
  def initialize options={}
    options[:type] = :CHANG_ROBERTS
    super options
  end
end

class ElectionMessage < ChangRoberstAlgorithmMessage
  def initialize options={}
    options[:subtype] = :ELECTION
    super options
  end
end

class ElectedMessage < ChangRoberstAlgorithmMessage
  def initialize options={}
    options[:subtype] = :ELECTED
    super options
  end
end

# Chat Message

class ChatMessage < Message
  def initialize options={}
    options[:type]    = :CHAT
    options[:subtype] = :SIMPLE_TEXT
    super options
  end
end

class BroadcastMessage < Message
  def initialize options={}
    options[:type]    = :CHAT
    options[:subtype] = :SIMPLE_TEXT
    super options
  end
end

# Network Topology Control Messages

# Abstract Class
class NetworkControlMessage < Message
  def initialize options={}
    options[:type] = :NETWORK_CONTROL
    super options
  end
end

class ConnectMessage < NetworkControlMessage
  def initialize options={}
    options[:subtype] = :CONNECT
    super options
  end
end

class ConnectedMessage < NetworkControlMessage
  def initialize options={}
    options[:subtype] = :CONNECTED
    super options
  end
end

class DisconnectMessage < NetworkControlMessage
  def initialize options={}
    options[:subtype] = :DISCONNECT
    super options
  end
end

class PingMessage < NetworkControlMessage
  def initialize options={}
    options[:subtype] = :PING
    super options
  end
end

class DeadNodeMessage < NetworkControlMessage
  def initialize options={}
    options[:subtype] = :DEAD_NODE
    super options
  end
end




