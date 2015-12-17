class CreateUnits < ActiveRecord::Migration
  def change
    create_table :units do |t|
      t.string :name
      t.string :symbol

      t.timestamps null: false
    end

    add_column :act_indicator_relations, :unit_id, :integer, null: true
    add_column :measurements, :unit_id, :integer, null: true

    Unit.find_or_create_by(symbol: '€', name: 'Euro')
  end
end
