# == Schema Information
#
# Table name: websites
#
#  id              :integer          not null, primary key
#  subdomain       :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  superteam_name  :string
#  logo            :string
#  external_host   :string
#  email           :string
#  password        :string
#  password_digest :string
#

require 'test_helper'

class WebsiteTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
