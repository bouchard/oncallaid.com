class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|

      t.string    :title,          :null => false
      t.string    :sort_title,     :null => false
      t.string    :slug,           :null => false
      t.text      :body
      t.boolean   :deleted,        :default => false
      t.boolean   :empty,          :default => true
      t.integer   :chapter_id,     :null => false

      t.timestamps
    end
  end
end
