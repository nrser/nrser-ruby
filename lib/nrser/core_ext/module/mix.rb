# encoding: UTF-8
# frozen_string_literal: true

class ::Module
  def prepend_and_copy mod
    prepend mod

    mod.instance_methods( false ).each do |name|
      define_method name, mod.instance_method( name )
    end
  end
end # class Module
