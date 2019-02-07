# frozen_string_literal: true
# encoding: UTF-8

def init
  super
  unless sections.empty?
    sections.place( :immutable ).after( :abstract, true )
    # binding.pry
  end
end


def immutable
  return unless object.has_tag?( :immutable )
  erb :immutable
end
