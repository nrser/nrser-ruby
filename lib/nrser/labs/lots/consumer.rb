# encoding: UTF-8
# frozen_string_literal: true

class Consumer
  def initialize
    @consumed = []
  end
end


class ArgConsumer < Consumer

  def can_consume? tokens
    return 0 unless consumed.empty?

    if tokens[0][0] == '-'
      0
    else
      1
    end
  end
  
end # class ArgConsumer


class OptionalArgConsumer
  
end


class OptConsumer < Consumer

  def initialize name:, aliases: []
    @name = name
    @aliases = aliases.dup
  end

  def names
    @names ||= [name, *aliases]
  end

  def long_names
    @long_names ||= @names.select { |name| name.length > 1 }
  end

  def can_consume? tokens
    return 0 unless consumed.empty?

    first = tokens[0]

    return 1 if long_names.any? { |name|
      /\-\-#{ name }\=.*/ =~ first
    }

    if  tokens.length > 1 &&
        names.any? { |name|
          if name.length == 1
            first == "-#{ name }"
          else
            first == "--#{ name }"
          end
        }
      return 2
    end

    return 0
  end

  def satisfied?
    if consumed.empty?
      type.test?( nil )
    else
      true
    end
  end

end # class OptConsumer


class BoolOptConsumer < Consumer

  def switch_tokens
    @switches ||= names.each_with_object( Set.new ) do |name, set|
      if name.length == 1
        set << "-#{ name }"
      else
        set << "--#{ name }"
        set << "--no-#{ name }"
      end
    end
  end

  def can_consume? tokens
    return 0 unless consumed.empty?

    first = tokens[0]

    return 1 if self.switch_tokens.include?( tokens[0] )

    return 0
  end

end # class BoolOptConsumer

