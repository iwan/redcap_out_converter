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
#
class Page < ApplicationRecord
  include Feedbackable

  STORED_ATTRIBUTES = [:patient_col, :event_col, :base_traits_identifier, :baseline_intervals, :follow_up_intervals]
end
