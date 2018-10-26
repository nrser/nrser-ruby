# encoding: UTF-8
# frozen_string_literal: true

# Bring in all of Active Support's {Hash} extensions too.
require 'active_support/core_ext/hash'

# Implemented as a strait core ext because it depends on Active Support's
# `hash/keys` extension, so why even bother with a ext module.
require_relative './hash/keys'

require 'nrser/ext/hash'

class Hash
  prepend NRSER::Ext::Hash
end
