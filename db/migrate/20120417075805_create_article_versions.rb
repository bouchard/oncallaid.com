class CreateArticleVersions < ActiveRecord::Migration
  def self.up
    create_table :article_versions do |t|
      t.string   :item_type,      :null => false
      t.integer  :item_id,        :null => false
      t.string   :event,          :null => false
      t.string   :whodunnit
      t.text     :object
      t.datetime :created_at
      t.integer  :diff_word_size, :null => false
      t.integer  :diff_line_size, :null => false
      t.string   :ip,             :limit => 16
    end
    add_index :article_versions, [:item_type, :item_id]
  end

  def self.down
    remove_index :article_versions, [:item_type, :item_id]
    drop_table :article_versions
  end
end
