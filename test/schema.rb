ActiveRecord::Migration.verbose = false
 
ActiveRecord::Schema.define(:version => 0) do

  create_table :design_test_design_boxes, :force => true do |t|
    t.string :name, :title, :owner_type
    t.integer :owner_id, :number
  end

  create_table :design_test_design_blocks, :force => true do |t|
    t.string :title, :type
    t.integer :box_id, :position 
    t.text :settings
  end
 
  create_table :design_test_users, :force => true do |t|
    t.string :name, :limit => 80
    t.text :design_data
  end
 
end
 
ActiveRecord::Migration.verbose = true



