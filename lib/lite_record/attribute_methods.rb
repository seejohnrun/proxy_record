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
        attribute_names.each do |method|
          method = method.to_sym
          mod.define_method(method) do
            data_model.public_send(method)
          end
          mod.send(:private, method)
        end

        mod
      end
    end
  end
end
