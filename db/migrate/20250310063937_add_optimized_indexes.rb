class AddOptimizedIndexes < ActiveRecord::Migration[8.0]
  def change
    add_index :sleep_records, [ :user_id, :clock_in ]
    add_index :sleep_records, [ :user_id, :duration ]
    add_index :sleep_records, :clock_out
    add_index :sleep_records, :clock_in
    add_index :users, :following_count
    add_index :users, :followers_count
    add_index :users, :id
  end
end
