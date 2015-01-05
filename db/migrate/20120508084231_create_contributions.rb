class CreateContributions < ActiveRecord::Migration
  def change
    create_table :contributions do |t|
      t.integer :user_id,             :null => false
      t.integer :article_id,          :null => false
      t.integer :article_version_id,  :null => false
      t.integer :word_size,           :default => 0, :limit => 8
      t.integer :line_size,           :default => 0, :limit => 8

      t.timestamps
    end
    add_index :contributions, :user_id
    add_index :contributions, :article_id
    add_index :contributions, :article_version_id
  end
end
