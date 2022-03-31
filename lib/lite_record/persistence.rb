module LiteRecord
  module Persistence
    def self.included(base)
      base.extend ClassMethods
    end

    private

    # Returns true, may raise RecordNotSaved
    def save!
      data_model.save!
    end

    module ClassMethods
      private

      # Return the created record, may raise RecordInvalid
      def create!(*attributes)
        created_record = data_model_class.create!(*attributes)
        ProxyRecord.wrap(created_record)
      end
    end
  end
end
