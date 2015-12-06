class CreateSuggestions < ActiveRecord::Migration
  def change
    create_table :suggestions do |t|
      t.belongs_to :user, index: true, null: false
      t.belongs_to :movie, index: true, null: false

      t.integer :stars, null: false

      t.timestamps null: false
    end
  end
end
