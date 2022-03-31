require_relative './lite_record/querying'
require_relative './lite_record/persistence'
require_relative './lite_record/attribute_methods'

module LiteRecord
  def self.included(base)
    base.extend Querying
    base.include Persistence
    base.include AttributeMethods
  end
end
