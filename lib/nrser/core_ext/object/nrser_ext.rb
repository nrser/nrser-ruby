require 'nrser/sugar/method_missing_forwarder'

class Object

  # @!group NRSER Ext Late Binding Instance Methods
  # --------------------------------------------------------------------------

  def nrser_ext_find method_name
    method_name = method_name.to_sym unless method_name.is_a?( Symbol )

    singleton_class.ancestors.each do |cls|
      next unless cls.name && NRSER::Ext.const_defined?( cls.name )

      const = NRSER::Ext.const_get cls.name
      next unless const.is_a?( Module )

      next unless const.instance_methods.include? method_name

      return const.instance_method( method_name )
    end

    raise NameError,
          "Couldn't find #{ method_name } for #{ self }:#{ self.class }"
  end


  def nrser_ext_call name, *args, &block
    nrser_ext_find( name ).bind( self ).call *args, &block
  end


  def nrser_ext
    NRSER::MethodMissingForwarder.new do |name, *args, &block|
      nrser_ext_call name, *args, &block
    end
  end


  # Short name
  alias_method :n_x, :nrser_ext

  # @!endgroup NRSER Ext Late Binding Instance Methods # *********************=

end