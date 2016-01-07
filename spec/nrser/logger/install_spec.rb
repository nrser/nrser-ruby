require 'spec_helper'

describe 'NRSER::Logger.install' do
  it "installs on the global instance" do
    NRSER::Logger.install MAIN
    
    expect(logger).to be_a NRSER::Logger
    expect(logger.name).to eq 'main'
    
    expect_to_not_log { info "hey" }
    
    logger.on
    
    expect_to_log { info "hey" }
    expect_to_not_log { debug "hey" }
  end
  
  it "is accesible in modules" do
    
    mod = Module.new do
      def self.log
        info "hey"
      end
      
      def self.logger_name
        logger.name
      end
    end
    
    expect_to_log { mod.log }
    expect(mod.logger_name).to eq 'main'
  end
  
  it "is accessible in classes" do
    
    cls = Class.new do
      def self.log
        info "hey"
      end
      
      def log
        info "hey"
      end
    end
    
    expect_to_log { cls.log }
    
    c = cls.new
    expect_to_log { c.log }
  end
  
  it "installs in modules" do
    mod = Module.new do
      NRSER::Logger.install self
    end
    
    expect(mod.logger).to_not be MAIN.logger
    expect(mod.logger.name).to match /\#\<Module/
    
    expect_to_not_log { mod.send :info, "hey" }
    
    mod.logger.on
    
    expect_to_log { mod.send :info, "hey" }
  end
  
  it "installs in classes" do
    cls = Class.new do
      NRSER::Logger.install self
    end
    
    expect(cls.logger).to_not be MAIN.logger
    expect(cls.logger.name).to match /\#\<Class/
    
    c = cls.new
    
    expect(c.logger).to be cls.logger
    expect(c.logger.name).to match /\#\<Class/
    
    expect_to_not_log { cls.send :info, "hey" }
    expect_to_not_log { c.send :info, "hey" }
    
    cls.logger.on
    
    expect_to_log { cls.send :info, "hey" }
    expect_to_log { c.send :info, "hey" }
    
    expect_to_not_log { cls.send :debug, "hey" }
    
    # @todo hmmm... this switches the log level for the entire class, not
    #     the instance...
    c.logger.level = :debug
    
    expect_to_log { cls.send :debug, "hey" }
    expect_to_log { c.send :debug, "hey" }
  end
  
end