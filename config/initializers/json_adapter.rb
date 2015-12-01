# require 'active_model/serializer/adapter/json'

# module ActiveModel
#   class Serializer
#     class Adapter
#       class JsonMeta < Json
#         def initialize(serializer, options = {})
#           super
#           serializer.root = true if @options[:root]
#         end
#       end
#     end
#   end
# end

# ActiveModel::Serializer.config.adapter = ActiveModel::Serializer::Adapter::JsonMeta