module LiteRecord
  module Persistence
    private

    # Returns true, may raise RecordNotSaved
    def save!
      data_model.save!
    end
  end
end
