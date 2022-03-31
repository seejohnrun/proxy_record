require_relative './lite_record/querying'
require_relative './lite_record/persistence'
require_relative './lite_record/validations'
require_relative './lite_record/attribute_methods'
require_relative './lite_record/associations'

module LiteRecord
  def self.included(base)
    base.extend Querying
    base.include Validations
    base.include Persistence
    base.include AttributeMethods
    base.include Associations
  end
end
