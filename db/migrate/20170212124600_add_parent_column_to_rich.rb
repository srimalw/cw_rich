class AddParentColumnToRich < ActiveRecord::Migration
  def change
		add_column :rich_rich_files, :parent_id, :integer, :default => 0
  end
end
