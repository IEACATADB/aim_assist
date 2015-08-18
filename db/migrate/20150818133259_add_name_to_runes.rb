class AddNameToRunes < ActiveRecord::Migration
  def change
    add_column :runes, :name, :string
  end
end
