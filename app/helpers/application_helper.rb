module ApplicationHelper

	def sales_cycle
		if Date.today >= "#{Date.today.year}-12-15"
			startdate = "#{Date.today.year}-12-15"
			enddate = "#{Date.today.year+1}-12-14"
		else
			startdate = "#{Date.today.year-1}-12-15"
			enddate = "#{Date.today.year}-12-14"
		end
		{startdate: startdate, enddate: enddate}
	end

end
