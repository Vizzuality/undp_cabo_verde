class Actor < ActiveRecord::Base

  include Activable

  belongs_to :user

  validates :title, presence: true

end
