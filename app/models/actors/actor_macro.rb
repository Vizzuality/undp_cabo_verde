class ActorMacro < Actor
  has_many :actor_meso_macros, foreign_key: :macro_id
  has_many :actor_micro_macros, foreign_key: :macro_id

  has_many :mesos, through: :actor_meso_macros, dependent: :destroy
  has_many :micros, through: :actor_micro_macros, dependent: :destroy

  before_update :deactivate_dependencies, if: '!active and active_changed?'

  validates :operational_filed, presence: true, on: :update

  def operational_filed_txt
    %w(Global International National)[operational_filed - 1]
  end

  private
    def deactivate_dependencies
      mesos.filter_actives.each do |meso|
        unless meso.deactivate
          return false
        end
      end

      micros.filter_actives.each do |micro|
        unless micro.deactivate
          return false
        end
      end
    end
end
