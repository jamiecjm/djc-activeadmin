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

class Website < ApplicationRecord

	after_create :prepare_tenant, unless: :skip_callback

	# mount_uploader :logo, LogoUploader

	has_secure_password

	attr_accessor :skip_callback

	private

    def prepare_tenant
        create_schema
        load_tables
    end

    # create new schema for each new tenant
    def create_schema
        PgTools.create_schema id unless PgTools.schemas.include? id.to_s
    end

    # load table to new tenant's schema
    def load_tables
        return if Rails.env.test?
        PgTools.set_search_path id, false
        load "#{Rails.root}/db/schema.rb"
        ActiveRecord::Base.connection.execute %{drop table "websites"}
        PgTools.restore_default_search_path
    end	

	# def use_database
	# 	if self.subdomain == "www"
	# 		Website.revert_database
	# 	else
	#   		ActiveRecord::Base.establish_connection(self.database)
	#   	end
	# end

	# # Revert back to the shared database
	# def self.revert_database
	#   ActiveRecord::Base.establish_connection(@default_config)
	# end

	# def database
	# 	YAML::load(ERB.new(File.read(Rails.root.join("config","#{self.subdomain}_db.yml"))).result)[Rails.env]
	# end

	# def self.db(team)
	#   YAML::load(ERB.new(File.read(Rails.root.join("config","#{team}_db.yml"))).result)[Rails.env]
	# end

 # 	def self.connect_db(team)
	#   ActiveRecord::Base.establish_connection(self.db(team))
	# end

end
