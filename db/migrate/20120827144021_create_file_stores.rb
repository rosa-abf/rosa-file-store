class CreateFileStores < ActiveRecord::Migration[5.2]
  def change
    create_table :file_stores do |t|
      t.string :file
      t.string :sha1_hash

      t.timestamps
    end
    add_index :file_stores, :sha1_hash, :unique => true
  end
end
