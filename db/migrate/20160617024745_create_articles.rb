class CreateArticles < ActiveRecord::Migration[5.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.integer :author_id
      t.text :content
      t.string :remark

      t.timestamps
    end
  end
end
