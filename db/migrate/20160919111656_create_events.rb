class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.date :start_date
      t.string :name
      t.integer :user_id
      t.timestamps null: false
    end
  end
end
