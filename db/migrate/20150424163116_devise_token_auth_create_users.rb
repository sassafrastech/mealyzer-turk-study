class DeviseTokenAuthCreateUsers < ActiveRecord::Migration
  def self.up
    change_table(:users) do |t|
      ## Required
      t.string :provider, :null => false, :default => ""

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## User Info
      #t.string :name
      t.string :nickname

      ## Tokens
      t.text :tokens

    end

    add_index :users, [:uid, :provider],     :unique => true
  end

  def self.down
    # By default, we don't want to make any assumption about how to roll back a migration when your
    # model already existed. Please edit below which fields you would like to remove in this migration.
    raise ActiveRecord::IrreversibleMigration
  end
end
