class AddLeaderToUser < ActiveRecord::Migration[5.0]
  def up
  	add_column :users, :leader?, :boolean, default: false

  	User.all.each do |u|
  		u.update(leader?: true) if u.is_leader? == true
  	end
  end

  def down
  	remove_column :users, :leader?
  end
end
