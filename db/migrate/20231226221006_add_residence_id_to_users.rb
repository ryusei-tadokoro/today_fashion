class AddResidenceIdToUsers < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :residence, null: false, foreign_key: true
  end
end