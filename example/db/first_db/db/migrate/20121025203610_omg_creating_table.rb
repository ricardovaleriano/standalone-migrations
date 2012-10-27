class OmgCreatingTable < ActiveRecord::Migration
  def change
    create_table :opalhes do |t|
      t.string :vamo
      t.text :borba
      t.integer :opalhes
    end
  end
end
