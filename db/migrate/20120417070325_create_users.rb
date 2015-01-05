class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|

      t.string    :username,       :null => false
      t.string    :roles,          :null => false
      t.string    :friend_uids

      t.timestamps
    end
  end
end
