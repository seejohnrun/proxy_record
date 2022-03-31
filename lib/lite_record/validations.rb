module LiteRecord
  module Validations
    def self.included(base)
      base.extend(ClassMethods)
    end

    def errors
      data_model.errors
    end

    module ClassMethods
      private

      # Adds validation, returns nil
      def validates(*args)
        # TODO this is slightly different than AR validations, since it'll be
        # a validation on the data model instead of on the class itself. What's
        # better? and if it's on the data model, should these validations just be
        # set inside of `data_model_eval`?
        data_model_class.validates(*args)
        nil
      end

      # Adds a method-based validation, which needs to be run
      # back on the model since that's where the method will be defined.
      # Returns nil
      def validate(method_name)
        # TODO not loving that we need to make a new ProxyRecord here since
        # if this validation is somehow using state from the existing object
        # that won't work. Will think more on this one
        data_model_class.validate -> { ProxyRecord.wrap(self).send(method_name) }
        nil
      end
    end
  end
end
