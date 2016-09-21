class CreateRecurrencePeriods < ActiveRecord::Migration
  def change
    create_table :recurrence_periods do |t|
      t.integer :event_id
      t.date :start_date
      t.date :end_date
      t.text :schedule

      t.timestamps null: false
    end
  end
end
