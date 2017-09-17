class MergeUnitTable < ActiveRecord::Migration[5.0]
  def change
		change_table :sales do |t|
	    t.string   "unit_no"
	    t.integer  "size"
	    t.float    "nett_price", null: false
	    t.float    "spa_price", null: false
	    t.float    "comm"
	    t.float    "comm_percentage"	
		end

		Unit.all.each {|u| u.sale.update(u.attributes.except('sale_id','project_id','created_at','updated_at','id'))}
  end
end

