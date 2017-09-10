class MergeUnitTable < ActiveRecord::Migration[5.0]
  def change
  	change_table :sales do |t|
	    t.string   "unit_no"
	    t.integer  "size"
	    t.float    "nett_price"
	    t.float    "spa_price"
	    t.float    "comm"
	    t.float    "comm_percentage"	
  	end


  end
end
