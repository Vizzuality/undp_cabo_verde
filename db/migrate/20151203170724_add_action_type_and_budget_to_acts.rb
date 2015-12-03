class AddActionTypeAndBudgetToActs < ActiveRecord::Migration
  def change
    add_column :acts, :action_type, :string
    add_column :acts, :budget, :string
  end
end
