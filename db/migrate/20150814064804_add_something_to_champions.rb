class AddSomethingToChampions < ActiveRecord::Migration
  def change
    add_column :champions, :key, :string
  end
end
