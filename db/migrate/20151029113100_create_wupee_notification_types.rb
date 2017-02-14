class CreateWupeeNotificationTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :wupee_notification_types do |t|
      t.string :name
      t.timestamps null: false
    end

    add_index :wupee_notification_types, :name, unique: true
  end
end
