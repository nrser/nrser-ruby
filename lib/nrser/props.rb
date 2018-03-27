require_relative './props/class_methods'
require_relative './props/instance_methods'

module NRSER::Props
  def self.included base
    base.include  NRSER::Props::InstanceMethods
    base.extend   NRSER::Props::ClassMethods
  end
end
