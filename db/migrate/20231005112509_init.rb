class Init < ActiveRecord::Migration[7.1]
  def change
    create_table :dway_users do |t|
      t.string :uid, null: false

      t.timestamps

      t.index :uid, unique: true
    end

    create_table :submissions do |t|
      t.references :dway_user, foreign_key: true, null: false

      t.timestamps
    end

    create_table :requests do |t|
      t.references :dway_user,  foreign_key: true, null: false
      t.references :submission, foreign_key: true

      t.integer :status, null: false

      t.timestamps
    end
  end
end
