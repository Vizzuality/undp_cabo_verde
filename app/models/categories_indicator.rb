class CategoriesIndicator < ActiveRecord::Base
  belongs_to :indicator
  belongs_to :category
end
