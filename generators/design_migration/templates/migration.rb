class DesignMigration < ActiveRecord::Migration
  def self.up
    create_table :design_boxes do |t|
      t.string :name, :title, :owner_type
      t.integer :owner_id, :number
    end

    create_table :design_blocks do |t|
      t.string :title, :type
      t.integer :box_id, :position 
      t.text :settings
    end

  end

  def self.down
    drop_table :design_boxes
    drop_table :design_blocks
  end

end
