class ActorMeso < Actor
  has_many :actor_meso_macros, foreign_key: :meso_id
  has_many :actor_micro_mesos, foreign_key: :meso_id

  has_many :macros, through: :actor_meso_macros, dependent: :destroy
  has_many :micros, through: :actor_micro_mesos, dependent: :destroy

  before_update :deactivate_dependencies, if: '!active and active_changed?'

  def empty_relations?
    macros.empty?
  end

  private
    def deactivate_dependencies
      micros.filter_actives.each do |micro|
        unless micro.deactivate
          return false
        end
      end
    end
end
