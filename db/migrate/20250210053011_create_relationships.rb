class CreateRelationships < ActiveRecord::Migration[8.0]
  def change
    create_table :relationships do |t|
      t.references :follower, null: false, foreign_key: { to_table: :users }, index: true
      t.references :following, null: false, foreign_key: { to_table: :users }, index: true
      t.timestamps
    end

    add_index :relationships, [ :follower_id, :following_id ], unique: true
  end
end
