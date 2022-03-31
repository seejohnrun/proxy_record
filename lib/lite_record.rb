require_relative './lite_record/querying'

module LiteRecord
  def self.included(base)
    base.extend Querying
  end
end
