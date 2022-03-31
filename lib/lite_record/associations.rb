module LiteRecord
  module Associations
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def has_many(field, has_many_args = {})
        unless has_many_args.key?(:class_name)
          model_name = field.to_s.singularize.camelize
          if model_name.constantize < LiteRecord
            has_many_args[:class_name] = "#{model_name}::DataModel"
          end
        end

        data_model_class.has_many field, has_many_args
        define_method field do
          result = data_model.public_send(field)
          ProxyRecord.wrap(result) # Wrap in a CollectionProxy
        end
        private field
      end
    end
  end
end
