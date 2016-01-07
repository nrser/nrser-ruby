require 'logger'
require 'yaml'
require 'pp'
require 'json'

require 'nrser'
require 'nrser/refinements'

using NRSER

module NRSER
  
  # @todo doc class
  class Logger
    # constants
    # =========
    
    # symbols for the level names
    LEVEL_SYMS = [
      :debug,
      :info,
      :warn,
      :error,
      :fatal,
      :unknown,
    ]
    
    LOGGING_METHODS = LEVEL_SYMS - [:unknown] + [:die]

    SEVERITY_COLORS = {
      'DEBUG' => :bright_black,
      'WARN' => :yellow,
      'INFO' => :green,
      'ERROR' => :red,
      'FATAL' => :on_red,
    }
    
    # class variables
    # ===============
    
    # [Pastel, false] if pastel is present, this will be an instance of
    # `Pastel` otherwise, it will be false
    @@pastel = begin
      require 'pastel'
      Pastel.new
    rescue LoadError => e
      false
    end
    
    # [Hash<IO, ::Logger>] map of IO instances (files, STDOUT, STDERR, etc.)
    # to Ruby stdlib `Logger` instances that handle the actual writing to
    # that destination.
    @ruby_loggers = {}

    # class functions
    # ==============

    # @api util
    # *pure*
    #
    # format a debug message with optional key / values to print
    #
    # @param name [String] logger name.
    # @param level [String, Symbol, Fixnum] the level in string, symbol or 
    #     integer form.
    # @param msg [String] message to print.
    # @param dump [Hash] optional hash of keys and vaues to dump.    
    def self.format name, level, msg, dump = {}
      data = {
        'logger' => name,
        'time' => Time.now,
      }
      
      data['msg'] = msg unless msg.empty?
      data['values'] = dump_value(dump) unless dump.empty?
      
      YAML.dump level_name(level) => data
    end
    # prev:
    # def self.format msg, dump = {}
    #   unless dump.empty?
    #     msg += "\n" + dump.map {|k, v| "  #{ k }: #{ v.inspect }" }.join("\n")
    #   end
    #   msg
    # end
    
    def self.dump_value value      
      case value
      when String, Fixnum, Float, TrueClass, FalseClass
        value
      when Array
        value.map {|v| dump_value v}
      when Hash
        Hash[value.map {|k, v| [k.to_s, dump_value(v)]}]
      else
        value.pretty_inspect
      end
    end

    # @api util
    #
    #
    def self.check_level level
      case level
      when Fixnum
        unless level >= 0 && level < LEVEL_SYMS.length
          raise ArgumentError.new "invalid integer level: #{ level.inspect }"
        end
      when Symbol
        unless LEVEL_SYMS.include? level
          raise ArgumentError.new "invalid level symbol: #{ level.inspect }"
        end
      when String
        unless LEVEL_SYMS.map {|_| _.to_s.upcase}.include? level
          raise ArgumentError.new "invalid level name: #{ level.inspect }"
        end
      else
        raise TypeError.new binding.erb <<-END
          level must be Fixnum, Symbol or String, not <%= level.inspect %>
        END
      end
    end # #check_level

    # @api util
    # *pure*
    #
    # get the integer value of a level (like ::Logger::DEBUG, etc.).
    #
    # @param level [Fixnum, Symbol, String] the integer level, method symbol,
    #     or string name (all caps).
    #
    # @return [Fixnum] level integer (between 0 and 5 inclusive).
    #
    def self.level_int level
      check_level level
      case level
      when Fixnum
        level
      when Symbol
        LEVEL_SYMS.each_with_index {|sym, index|
          return index if level == sym
        }
      when String
        LEVEL_SYMS.each_with_index {|sym, index|
          return index if level == sym.to_s.upcase
        }
      end
    end

    # @api util
    # *pure*
    #
    # get the string "name" of a level ('DEBUG', 'INFO', etc.).
    #
    # @param level [Fixnum, Symbol, String] the integer level, method symbol,
    #     or string name (all caps).
    #
    # @return ['DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL', 'UNKNOWN']
    #
    def self.level_name level
      check_level level
      case level
      when Fixnum
        LEVEL_SYMS[level].to_s.upcase
      when Symbol
        level.to_s.upcase
      when String
        level
      end
    end

    # @api util
    # *pure*
    #
    # get the symbol for a level as used in method sigs.
    #
    # @param level [Fixnum, Symbol, String] the integer level, method symbol,
    #     or string name (all caps).
    #
    # @return [:debug, :info, :warn, :error, :fatal, :unknown]
    #
    def self.level_sym level
      check_level level
      case level
      when Fixnum
        LEVEL_SYMS[level]
      when Symbol
        level
      when String
        level.downcase.to_sym
      end
    end
    
    # @api util
    # *pure*
    # 
    # creates methods closed around a `NRSER::Logger` instance to be attached
    # to objects to access the logger and do logging and 'installs' them on
    # the target.
    # 
    # @param target [Object] object to install methods on.
    # 
    # @param logger [NRSER::Logger] the logger to bind the methods to.
    # 
    # @return nil
    # 
    def self.install_methods! target, logger
      methods = {
        logger: {
          private: false,
          body: ->() { logger },
        },
      }
      
      LOGGING_METHODS.each do |sym|
        methods[sym] = {
          private: true,
          body: ->(*args, &block) { logger.send sym, *args, &block },
        }
      end
      
      if target.is_a? Class
        methods.each do |sym, stuff|
          target.define_singleton_method sym, &stuff[:body]
          target.send :define_method, sym, &stuff[:body]
          target.send :private, sym if stuff[:private]
        end
        
      elsif target.is_a? Module
        methods.each do |sym, stuff|
          target.define_singleton_method sym, &stuff[:body]
          target.private_class_method sym if stuff[:private]
        end
        
      else
        methods.each do |sym, stuff|
          target.send :define_method, sym, &stuff[:body]
          target.send :private, sym if stuff[:private]
        end
      end
      
      nil
    end
    
    
    # creates a new `NRSER::Logger` and 'installs' a logger on target, adding
    # singleton (class) and instance methods as appropriate
    #
    # @param target [Object] the object to install a new logger on, which can
    #     be a Module, a Class, or just any plain-old instance that you want
    #     to have it's own logger client.
    # 
    # @param options [Hash] options used when creating the `NRSER::Logger`.
    # @see NRSER::Logger#initialize
    # 
    # @return [NRSER::Logger] the new `NRSER::Logger` instance.
    # 
    def self.install target, options = {}
      options[:on] ||= false
      options[:name] ||= if target.respond_to?(:name) && !target.name.nil?
        target.name
      else
        target.to_s
      end
      
      logger = self.new options
      install_methods! target, logger
      
      logger
    end # .install
    
    
    # singleton (class) and instance methods as appropriate
    #
    # 
    # @param source [Object] source instance with a logger installed to use
    #     for the target.
    # 
    # @param target [Object] the object to use the source's logger.
    # 
    # @return [NRSER::Logger] the new `NRSER::Logger` instance.
    # 
    def self.use source, target
      install_methods! target, source.logger
    end # .use

    attr_reader :name, :dest, :level, :ruby_logger

    def initialize options = {}
      options = {
        dest: $stderr,
        level: :info,
        say_hi: true,
        on: true,
      }.merge options

      @name = options[:name]
      @on = options[:on]
      @level = self.class.level_int options[:level]
      self.dest = options[:dest]

      if @on && options[:say_hi]
        info <<-END.squish
          started to logging to #{ @dest } at level
          #{ self.class.level_name @level }...
        END
      end
    end

    def on?
      @on
    end

    def off?
      !on?
    end

    def on &block
      if block
        prev = @on
        @on = true
        block.call
        @on = prev
      else
        @on = true
      end
    end

    def off &block
      if block
        prev = @on
        @on = false
        block.call
        @on = prev
      else
        @on = false
      end
    end

    def level= level
      @level = self.class.level_int(level)
      @ruby_loggers.each do |dest, ruby_logger|
        ruby_logger.level = @level
      end
      @level
    end
    
    def with_level level, &block
      prev_level = self.level
      self.level = level
      block.call
      self.level = prev_level
    end
    
    def dest= dest
      @ruby_loggers = {}
      NRSER.each dest do |dest|
        @ruby_loggers[dest] = ::Logger.new(dest).tap do |ruby_logger|
          ruby_logger.level = @level
          ruby_logger.formatter = proc do |severity, datetime, progname, msg|
            # just pass through
            msg
          end
        end
      end
      @dest = dest
    end
    
    # logging api
    # ===========
    
    # @api logging
    def debug *args, &block
      send_log :debug, args, block
    end
    
    # @api logging
    def info *args, &block
      send_log :info, args, block
    end
    
    # @api logging
    def warn *args, &block
      send_log :warn, args, block
    end

    # @api logging
    def error *args, &block
      send_log :error, args, block
    end

    # @api logging
    def fatal *args, &block
      send_log :fatal, args, block
    end
    
    # @api logging
    def die *args, &block
      if @on
        send_log :fatal, args, block
        abort
      else
        abort self.class.format(
          @name,
          :fatal,
          *extract_msg_and_dump(args, block)
        )
      end
    end

    private
      def extract_msg_and_dump args, block
        msg = ''
        dump = {}
        case args.length
        when 0
          # if there is no block, just no-op
          # @todo is this the right way to go?
          if block
            result = block.call
            result = [result] unless result.is_a? Array
            
            return extract_msg_and_dump result, nil
          end
        when 1
          case args[0]
          when Hash
            dump = args[0]
          when String
            msg = args[0]
          else
            msg = args[0].to_s
          end
        when 2
          msg, dump = args
        else
          raise "must provide one or two arguments, not #{ args.length }"
        end
        
        [msg, dump]
      end
    
      def send_log level_sym, args, block
        return unless @on && @level <= self.class.level_int(level_sym)
        
        msg, dump = extract_msg_and_dump args, block

        @ruby_loggers.each do |dest, ruby_logger|
          ruby_logger.send(level_sym, @name) do
            self.class.format(@name, level_sym, msg, dump)
          end
        end
      end
      
    # end private

  end # Logger
end # NRSER
