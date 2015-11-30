class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.belongs_to :user, index: true, null: false
      t.belongs_to :movie, index:true, null: false    
      
      t.text :comment
      t.integer :stars

      t.timestamps null: false
    end
  end
end
