class AddUserToSalevalue < ActiveRecord::Migration[5.0]
  def up
  	add_column :salevalues, :other_user, :string

  	User.where(team_id: nil).each do |u|
  		u.salevalues.update_all(other_user: u.prefered_name)
  	end
  end

  def down
  	remove_column :salevalues, :ren
  end
end
