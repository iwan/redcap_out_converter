class AddHeaderRowToPages < ActiveRecord::Migration[7.0]
  def change
    add_column :pages, :header_row, :integer, default: 0
  end
end
