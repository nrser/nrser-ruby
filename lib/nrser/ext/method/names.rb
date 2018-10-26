# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

# Need {NRSER::Ext::Module::Names#safe_name}
require 'nrser/ext/module/names'


# Namespace
# ========================================================================

module  NRSER
module  Ext


# Definitions
# ========================================================================

# Extensions for working with {::Method} names.
# 
module Method
  
  # Returns the method's {::Method#receiver} and {::Method#name} in the common
  # `A.cls_meth` / `A#inst_meth` format.
  # 
  def full_name
    case receiver
    when ::Module
      "#{ receiver.n_x.safe_name }.#{ name }"
    else
      "#{ receiver.class.n_x.safe_name }##{ name }"
    end
  end
  
  # Use full name as a {Method}'s "summary"
  alias_method :to_summary, :full_name
  
end # module Method


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER
