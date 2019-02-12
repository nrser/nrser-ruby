# TODO Remove me

require_relative './log'

NRSER.logger.warn <<~END
  DEPRECIATED - `require 'nrser/refinements'` is now a no-op,
  please remove the calls.
  
  Require specific refinements, like:
  
      require 'nrser/refinements/types'
  
  Thank you, the management.
END
