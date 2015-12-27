# def log
#   puts "global, self is #{ self }"
#   [:global, 'main']
# end

class Logger_
  
  def self.create obj
    puts "creating for #{ obj }"
    
    name = obj.respond_to?(:name) ? obj.name : obj.to_s
    logger = Logger_.new(name)
    obj.instance_variable_set :@logger, logger
    
    body = ->(msg) {
      puts "calling log for #{ self }"
      logger.log msg
    }
    
    if obj.is_a? Class
      puts "#{ obj } is a class"
      obj.define_singleton_method :log, &body
      obj.send :define_method, :log, &body
      
    elsif obj.is_a? Module
      puts "#{ obj } is a module"
      obj.define_singleton_method :log, &body
      
    else
      puts "#{ obj } is an instance"
      obj.send :define_method, :log, &body
    end
  end
  
  def self.reference obj, from
    puts "referencing for #{ obj }"
    
    logger = from.instance_variable_get :@logger
    
    body = ->(msg) {
      puts "calling log for #{ self }"
      logger.log msg
    }
    
    if obj.is_a? Class
      puts "#{ obj } is a class"
      obj.define_singleton_method :log, &body
      obj.send :define_method, :log, &body
      
    elsif obj.is_a? Module
      puts "#{ obj } is a module"
      obj.define_singleton_method :log, &body
      
    else
      puts "#{ obj } is an instance"
      obj.send :define_method, :log, &body
    end
  end
  
  attr_reader :name
  
  def initialize name
    @name = name
  end
  
  def log msg
    puts "logging from Logger_ #{ @name }: #{ msg }"
    @name
  end
end

Logger_.create self

module M1
  def self.f msg
    log msg
  end
end

module M2
  Logger_.create self
  
  def self.f msg
    log msg
  end
end

class C1
  Logger_.create self
  
  def self.f msg
    log msg
  end
  
  def g msg
    self.class.log msg
  end
  
  def h msg
    log msg
  end
end

class C2 < C1
  def self.f msg
    log msg
  end
end

module M3
  Logger_.create self
  
  module M4
    Logger_.reference self, M3
    
    def self.f msg
      log msg
    end
  end
end

describe "playing around with globals and modules and includes and stuff" do
  specify do
    expect(log 'hey').to eq 'main'
    expect(M1.f 'ho').to eq 'main'
    expect(M2.log "let's go!").to eq 'M2'
    
    expect(C1.f 'sdfsd').to eq 'C1'
    
    c1 = C1.new
    expect(c1.g 'blah').to eq 'C1'
    expect(c1.h 'ex').to eq 'C1'
    
    expect(C2.f 'eff').to eq 'C1'
    
    expect(M3::M4.f 'lay').to eq 'M3'
  end
end