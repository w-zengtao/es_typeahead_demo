class CreateChemicals < ActiveRecord::Migration[5.0]
  def change
    create_table :chemicals do |t|
      t.string 'cas'
      t.string 'name'         , limit: 1000
      t.string 'alias_name'   , limit: 1000
      t.string 'name_cn'      , limit: 1000
      t.string 'alias_name_cn', limit: 1000
      t.string 'formula'

      t.timestamps
    end
  end
end
