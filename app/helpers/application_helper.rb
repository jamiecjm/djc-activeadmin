module ApplicationHelper

	def self.current_sales_cycle
		if Date.today >= "#{Date.today.year}-12-15".to_date
			startdate = "#{Date.today.year}-12-15".to_date
			enddate = "#{Date.today.year+1}-12-14".to_date
		else
			startdate = "#{Date.today.year-1}-12-15".to_date
			enddate = "#{Date.today.year}-12-14".to_date
		end
		{startdate: startdate, enddate: enddate}
	end

	def self.first_day_of_month(date)
		Time.parse(date.to_s).strftime('%Y-%m-01')
	end

	def self.populate_sales_cycle(month_hash=nil)
		months = []
		(1..13).each do |n|
			if n-1 == 0 
				date = [ApplicationHelper.current_sales_cycle[:startdate].beginning_of_month, 0]
			else
				if ApplicationHelper.current_sales_cycle[:startdate].year == Date.today.year
					date = ["#{Date.today.year + 1}-#{n-1}-01".to_date, 0]
				else
					date = ["#{Date.today.year}-#{n-1}-01".to_date, 0]
				end
			end
			months << date
		end
		months = months.to_h
		if month_hash
			months&.merge!(month_hash) { |k, o, n| o + n }
			Hash[months.map{ |k, v| ["#{k.strftime("%B")} #{k.year}", v] }]
		else
			months.map{ |k, v| "#{k.strftime("%B")} #{k.year}" }
		end
	end

end
