class AddIndexesToOptimize < ActiveRecord::Migration[8.0]
  def change
    add_index :sleep_records, :clock_in
  end
end
