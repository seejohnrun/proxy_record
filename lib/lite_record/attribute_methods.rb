module LiteRecord
  module AttributeMethods
    class << self
      def included(base)
        names = base.send(:data_model_class).attribute_names
        base.include module_containing_attribute_methods_for(names)
      end

      private

      def module_containing_attribute_methods_for(attribute_names)
        mod = Module.new

        # Define a private method inside this anonymous module for each
        # of the attribute names
        attribute_names.each do |attribute_name|
          define_private_attribute_getter(mod, attribute_name)
          define_private_attribute_setter(mod, attribute_name)
        end

        mod
      end

      def define_private_attribute_getter(mod, attribute_name)
        method = attribute_name.to_sym

        mod.define_method(method) do
          data_model.public_send(method)
        end

        mod.send(:private, method)
      end

      def define_private_attribute_setter(mod, attribute_name)
        method = "#{attribute_name}=".to_sym

        mod.define_method(method) do |value|
          data_model.public_send(method, value)
        end

        mod.send(:private, method)
      end
    end
  end
end
