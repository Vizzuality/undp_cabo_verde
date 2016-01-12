class Localization < ActiveRecord::Base
  include Activable

  belongs_to :user, foreign_key: :user_id, touch: true
  
  has_many :actor_localizations, foreign_key: :localization_id
  has_many :actors, through: :actor_localizations, dependent: :destroy
  has_many :act_localizations, foreign_key: :localization_id
  has_many :acts, through: :act_localizations, dependent: :destroy

  accepts_nested_attributes_for :act_localizations,   allow_destroy: true
  accepts_nested_attributes_for :actor_localizations, allow_destroy: true

  validates :long, presence: true
  validates :lat,  presence: true
  
  after_save :fix_web

  def actor_macros
    actors.where(type: 'ActorMacro')
  end

  def actor_mesos
    actors.where(type: 'ActorMeso')
  end

  def actor_micros
    actors.where(type: 'ActorMicro')
  end

  def act_macros
    acts.where(type: 'ActMacro')
  end

  def act_mesos
    acts.where(type: 'ActMeso')
  end

  def act_micros
    acts.where(type: 'ActMicro')
  end

  private

    def fix_web
      unless self.web_url.blank? || self.web_url.start_with?('http://') || self.web_url.start_with?('https://')
        self.web_url = "http://#{self.web_url}"
      end
    end
end
