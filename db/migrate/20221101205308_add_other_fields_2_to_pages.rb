class AddOtherFields2ToPages < ActiveRecord::Migration[7.0]
  def change
    add_column :pages, :ad_content_encoding, :string
    add_column :pages, :ad_rows_separator, :string
    add_column :pages, :ad_columns_separator, :string
  end
end
