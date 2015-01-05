class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|

      t.integer     :user_id,      :null => false
      t.string      :name,         :null => false
      t.string      :postnominals, :default => nil
      t.string      :description,  :null => false

      t.timestamps
    end
    add_index :profiles, :user_id
  end
end
