class ChangeMarksType < ActiveRecord::Migration[6.1]
  def change
    change_column :questions, :marks, :integer

  end
end
