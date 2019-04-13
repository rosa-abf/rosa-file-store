class AddUserToFileStore < ActiveRecord::Migration[5.2]
  def change
    add_column :file_stores, :user_id, :integer
    add_column :file_stores, :user_uname, :string
    add_index :file_stores, :user_id
  end
end
