class CreateChapters < ActiveRecord::Migration
  def change
    create_table :chapters do |t|

      t.string    :title,          :null => false
      t.string    :slug,           :null => false
      t.integer   :sort_order,     :default => nil

      t.timestamps
    end
  end
end
