# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

### Stdlib ###

require 'set'


# Namespace
# =======================================================================

module  NRSER
module  Support
module  PP
class   Config


# Definitions
# =======================================================================

# A probably totally over-engineered configurator class to handle how you can
# tell {NRSER::Support::PP} to print instance variables. But, hey, I wrote it,
# so, whatever, it's here.
# 
# Works along the `only` / `except` lines that you see in Rails, like in 
# filters and shit.
# 
class IVars
  
  # Constants
  # ==========================================================================
  
  MODES = Set[ :always, :never, :defined, :present ]
  DEFAULT_MODE = :defined
  
  attr_reader :names
  
  # Construction
  # ==========================================================================
  
  # Instantiate a new `IVars`.
  def initialize names, mode: DEFAULT_MODE, except: nil, only: nil
    @mode = mode
    @names = names.map { |name| [ name, @mode ] }.to_h
    
    only! only
    except! except
    
    @names.reject! { |name, mode| !mode || mode == :never }
    @names = @names.sort
  end # #initialize
  
  
  # Instance Methods
  # ==========================================================================
  
  def only! only
    case only
    when nil
      # pass
      
    when ::Array
      @names.select! { |name, mode|
        only.any? { |selector| selector === name }
      }
    
    when ::Hash
      new_names = {}
    
      only.each { |key, value|
        if MODES.include? key
          new_mode = key
          [ *value ].each { |selector|
            @names.each { |name, current_mode|
              if selector === name
                new_names[ name ] = new_mode
              end
            }
          }
        else
          selector = key
          new_mode = value
          @names.each { |name, current_mode|
            if selector === name
              new_names[ name ] = new_mode
            end
          }
        end
      }
              
      @names = new_names
    else
      raise NRSER::ArgumentError.new \
        "`only:` must be", ::Array, "of ivar name selectors, or",
        ::Hash, "of either `(selector, mode)` or `(mode, [selector])`",
        "found:", only
    end

  end # #only!
  
  
  def except! except
    case except
    when nil
      # pass
    
    when ::Array
      @names.reject! { |name, mode|
        except.any? { |selector| selector === name }
      }
      
    when ::Hash
      except.each { |key, value|
        if MODES.include? key
          new_mode = key
          [ *value ].each { |selector|
            @names.each { |name, current_mode|
              if selector === name
                @names[ name ] = new_mode
              end
            }
          }
        else
          selector = key
          new_mode = value
          
          @names.each { |name, current_mode|
            if selector === name
              @names[ name ] = new_mode
            end
          }
        end
      }
    else
      raise NRSER::ArgumentError.new \
        "`except:` must be", ::Array, "of ivar name selectors, or",
        ::Hash, "of either `(selector, mode)` or `(mode, [selector])`",
        "found:", except
    end
  end # #except!
  
  
end # class IVars


# /Namespace
# =======================================================================

end # class Config
end # module PP
end # module Support
end # module NRSER

