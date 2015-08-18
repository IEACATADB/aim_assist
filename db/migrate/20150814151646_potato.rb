class Potato < ActiveRecord::Migration
  def change
    remove_column :champions,:created_at
    remove_column :champions,:updated_at
  end
end
