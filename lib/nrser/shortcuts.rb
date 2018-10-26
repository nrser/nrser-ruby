# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Using {String#underscore}, {String#constantize}
require 'active_support/core_ext/string/inflections'

# Project / Package
# -----------------------------------------------------------------------


# Refinements
# =======================================================================


# Namespace
# =======================================================================

module  NRSER

# Definitions
# =======================================================================

def self.def_shortcuts module_name, *method_names, **aliases
  method_names.each do |method_name|
    define_method method_name do |*args, &block|
      require module_name.underscore

      module_ref = module_name.constantize

      module_ref.public_send method_name, *args, &block
    end
  end
end


def_shortcuts 'NRSER::Ext::Object::Booly', :truthy?, :falsy?


# /Namespace
# =======================================================================

end # module NRSER
