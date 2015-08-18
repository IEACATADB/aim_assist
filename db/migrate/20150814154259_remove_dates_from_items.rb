class RemoveDatesFromItems < ActiveRecord::Migration
  def change
    remove_column :items,:created_at
    remove_column :items,:updated_at
  end
end
