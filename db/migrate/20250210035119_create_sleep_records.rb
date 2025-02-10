class CreateSleepRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :sleep_records do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :clock_in, null: false
      t.datetime :clock_out
      t.integer :duration

      t.timestamps
    end
  end
end
