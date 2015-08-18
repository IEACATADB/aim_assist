class Reordercolumsinitems < ActiveRecord::Migration
  def change
  def up
    change_column :items, :name, :string, :after => :id
  end
  def down
  end
  end
end
