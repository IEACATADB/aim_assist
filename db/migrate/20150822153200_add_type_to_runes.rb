class AddTypeToRunes < ActiveRecord::Migration
  def change
    add_column :runes, :r_type, :string
  end
end
