class ActorMacro < Actor
  validates :operational_field, presence: true
  after_save :rebuild_operational_field, if: 'operational_field_changed?'

  def operational_field_txt
    field = OperationalField.find_by_id(operational_field) if operational_field.present?
    field.name if field.present?
  end

  def empty_relations?
    parents.empty?
  end

  private

    def rebuild_operational_field
      operational_fields.delete_all
      query = "INSERT INTO actors_categories(actor_id, category_id) VALUES(#{id}, #{operational_field})"
      ActiveRecord::Base.connection.insert(query)
    end
end
