module NRSER
  
  # @todo Document transform method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.transform tree, source
    map_tree( tree, prune: true ) { |value|
      if value.is_a? Proc
        value.call source
      else
        value
      end
    }
  end # .transform
  
  
  class SendSerializer
    def initialize messages = []
      @messages = messages
    end
    
    def method_missing symbol, *args, &block
      messages = [
        *@messages,
        ::NRSER::Message.new( symbol, *args, &block )
      ]
      
      self.class.new messages
    end
    
    def to_proc publicly: true
      ::NRSER.chainer @messages, publicly: publicly
    end
  end
  
  
  
  # @todo Document transformer method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.transformer &block
    map_tree( block.call SendSerializer.new ) { |value|
      if value.is_a? SendSerializer
        value.to_proc
      else
        value
      end
    }
  end # .transformer
  
  
  
end # module NRSER
