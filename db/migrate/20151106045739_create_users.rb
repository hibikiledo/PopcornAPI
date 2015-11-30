class CreateUsers < ActiveRecord::Migration
  def change

    create_table :users do |t|    
      t.string :readable_id  
      t.string :email
      t.string :password
      t.string :profile_pic
      t.string :token
      # used and handled by rails
      t.timestamps null: false

      # for implementing friends relationship
      create_table "user_connections", force: true, id: false do |t|
        t.integer "user_a_id", :null => false
        t.integer "user_b_id", :null => false
      end

    end
  end
end
