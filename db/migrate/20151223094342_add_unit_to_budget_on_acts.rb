class AddUnitToBudgetOnActs < ActiveRecord::Migration
  def change
    add_monetize :acts, :budget, currency: { present: false }
  end
end
