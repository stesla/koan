class CreateInitialSchema < ActiveRecord::Migration
  def self.up
    create_table :customers do |t|
      t.column :first_name, :string
      t.column :last_name, :string
      t.column :email, :string
    end

    create_table :products do |t|
      t.column :name, :string
      t.column :uuid, :string
      t.column :price, :decimal, :precision => 8, :scale => 2, :default => 0
    end

    create_table :licenses do |t|
      t.column :customer_id, :integer, :null => false
      t.column :product_id, :integer, :null => false
      t.column :digest, :string
      t.column :key, :text
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :licenses
    drop_table :products
    drop_table :customers
  end
end
