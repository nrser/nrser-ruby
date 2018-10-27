# encoding: UTF-8
# frozen_string_literal: true

require 'nrser/ext/module/method_objects'

class Module
  def prepend_and_copy mod
    prepend mod

    mod.instance_methods( false ).each do |name|
      define_method name, mod.instance_method( name )
    end
  end
end # class Module
