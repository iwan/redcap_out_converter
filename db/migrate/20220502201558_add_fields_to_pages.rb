class AddFieldsToPages < ActiveRecord::Migration[7.0]
  def change
    add_column :pages, :patient_col, :integer, default: 1
    add_column :pages, :event_col, :integer, default: 2
    add_column :pages, :base_traits_identifier, :string
    add_column :pages, :baseline_intervals, :string
    add_column :pages, :follow_up_intervals, :string
  end
end
