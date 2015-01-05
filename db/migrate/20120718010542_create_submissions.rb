class CreateSubmissions < ActiveRecord::Migration
  def change
    create_table :submissions do |t|

      t.integer :user_id, :null => false
      t.integer :article_id
      t.string  :title
      t.text    :body
      t.string  :status, :default => 'pending'
      t.text    :rejected_reason

      t.timestamps
    end
  end
end
