class AddSubgroupToUsers < ActiveRecord::Migration
  def change
    add_column :users, :subgroup, :integer
  end
end
