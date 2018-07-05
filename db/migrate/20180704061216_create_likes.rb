class CreateLikes < ActiveRecord::Migration[5.0]
  def change
    create_table :likes do |t|
      # 둘다 받아와야하기에 일종의 join table
      t.integer :user_id
      t.integer :movie_id
      
      t.timestamps
    end
  end
end
