namespace :unit do
  desc "TODO"
  task combine: :environment do
  	Unit.all.each do |u|
  		sales = Sale.where(unit_id: u.id)
  		sales.update(u.attributes.except('created_at', 'updated_at','project_id','sale_id','id'))
  	end
  end

  task drop: :environment do
  	ActiveRecord::Migration.drop_table :units
  end
end
