class CategoriesIndicator < ActiveRecord::Base
  belongs_to :indicator, touch: true
  belongs_to :category
end
