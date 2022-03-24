class AddCompletedAtToPage < ActiveRecord::Migration[7.0]
  def change
    add_column :pages, :completed_at, :datetime, default: nil
  end
end
