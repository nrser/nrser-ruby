require 'nrser/ext/open_struct'

def dl *a, &b
  NRSER::Ext::OpenStruct.deep_load *a, &b
end
