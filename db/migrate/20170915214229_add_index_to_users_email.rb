class AddIndexToUsersEmail < ActiveRecord::Migration[5.1]
  #the email uniqueness is implemented at the database too
  #to avoid race condition on save the same user from
  #duplicated requests
  def change
    add_index :users, :email, unique: true
  end
end
