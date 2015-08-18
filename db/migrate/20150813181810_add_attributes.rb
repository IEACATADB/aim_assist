class AddAttributes < ActiveRecord::Migration
  def change
    add_column :items, :name, :string
    add_column :items, :spellvamp, :float
  end
end
