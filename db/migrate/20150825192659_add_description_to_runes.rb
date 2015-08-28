class AddDescriptionToRunes < ActiveRecord::Migration
  def change
    add_column :runes, :description, :string
  end
end
