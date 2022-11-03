class AddOtherFieldsToPages < ActiveRecord::Migration[7.0]
  def change
    add_column :pages, :content_encoding, :string
    add_column :pages, :rows_separator, :string
    add_column :pages, :columns_separator, :string
  end
end
