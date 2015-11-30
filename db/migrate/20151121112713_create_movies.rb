class CreateMovies < ActiveRecord::Migration
  def change
    create_table :movies do |t|
      
      t.string :imdb_id
      t.string :title
      t.string :year
      t.string :rating
      t.string :runtime
      t.string :genre
      t.date :released
      t.string :director
      t.string :writer
      t.string :cast
      t.string :metacritic
      t.float :imdb_rating
      t.integer :imdb_votes
      t.string :poster_url
      t.text :plot
      t.text :full_plot
      t.string :language
      t.string :country
      t.string :awards

      t.timestamps null: false
    end
  end
end
