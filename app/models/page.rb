# == Schema Information
#
# Table name: pages
#
#  id                     :integer          not null, primary key
#  result                 :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  completed_at           :datetime
#  patient_col            :integer          default(0)
#  event_col              :integer          default(1)
#  base_traits_identifier :string
#  baseline_intervals     :string
#  follow_up_intervals    :string
#  header_row             :integer          default(0)
#  content_encoding       :string
#  rows_separator         :string
#  columns_separator      :string
#  ad_content_encoding    :string
#  ad_rows_separator      :string
#  ad_columns_separator   :string
#
class Page < ApplicationRecord
  include Feedbackable

  # STORED_ATTRIBUTES = [:patient_col, :event_col, :base_traits_identifier, :baseline_intervals, :follow_up_intervals]

  def set_auto_detection_attributes(reader)
    self.ad_content_encoding  = reader[:content_encoding]
    self.ad_rows_separator    = reader[:rows_separator].code
    self.ad_columns_separator = reader[:columns_separator].code
    self.content_encoding  = reader[:content_encoding]
    self.rows_separator    = reader[:rows_separator].code
    self.columns_separator = reader[:columns_separator].code
  end
end
