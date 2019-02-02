require 'nrser'
require 'nrser/support/pp/config/ivars'


$count = 1
def set_ivars! **kwds
  names = %i{ @a @b @c @j @k @x @y @z }
  ivars = NRSER::Support::PP::Config::IVars.new names, **kwds
  
  puts
  pp kwds
  puts
  pp ivars.names
  puts
  puts 
  
  # $count += 1
end



puts \
%%1.  Print *only* `@a`, `@b` and `@c`, and only if they are already defined. %
set_ivars! \
  mode: :defined,
  only: [ :@a, :@b, :@c ]


puts \
%%2.  Print all of `#pretty_print_instance_variables` that are already defined
     *except* `@x`, `@y` and `@z` %
set_ivars! \
  mode: :defined,
  except: [ :@x, :@y, :@z ]


puts \
%%3.  Same as (2), but with explicit mapping to `false` or `:never`. %
set_ivars! \
  mode: :defined,
  except: { :@x => false, :@y => false, :@z => :never }


puts \
%%4.  Print all of `#pretty_print_instance_variables` that are *defined*,
      except *always* print `:@x` and `:@y`, and *never* print `@z`. %
set_ivars! \
  mode: :defined,
  except: { :@x => :always, :@y => :always, :@z => :never }


puts \
%%5.  Same as (4). %
set_ivars! \
  mode: :defined,
  except: {
    always: [ :@x, :@y ],
    never: [ :@z ]
  }


puts \
%%6.  Always print `@a` and `@b`, and print `@c` when it's value is `#present?`,
     and never print anything else (top-level `mode:` makes no difference in
     this case). %
set_ivars! \
  only: {
    :@a => :always,
    :@b => true,
    :@c => :present,
  }


puts \
%%7.  Same as (6).%
set_ivars! \
  only: {
    always: [ :@a, :@b ],
    present: [ :@c ]
  }


puts \
%%8.  Only with `:never` / false / nil (which is dumb BTW).%
set_ivars! \
  only: {
    never: [ :@a, :@b ],
    present: [ :@c ],
    :@j => false,
    :@k => nil,
  }


puts \
%%9.  Make sure `mode:` works.%
set_ivars! \
  mode: :always,
  except: [ :@x, :@y, :@z ]