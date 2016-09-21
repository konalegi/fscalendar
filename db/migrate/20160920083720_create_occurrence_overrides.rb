class CreateOccurrenceOverrides < ActiveRecord::Migration
  def change
    create_table :occurrence_overrides do |t|
      t.integer :recurrence_period_id
      t.integer :event_id
      t.date :overriden_date

      t.timestamps null: false
    end
  end
end
