ActiveAdmin.register_page "Team Sales Figure" do

  menu parent: 'Analytics', priority: 1

  content title: 'Team Sales Figure' do

    columns do
      panel title='Filter' do
        form action: 'team_sales_figure', 'data-remote': true do |f|
          para 'Date Range'
          input type: :date, name: :startdate, required: true
          span 'to'
          input type: :date, name: :enddate, required: true
          input type: :submit
        end
      end
    end

    columns do
      column do
        render 'team_sales_figure/barchart', sales: controller.instance_variable_get(:@sales), startdate: params[:startdate], enddate: params[:enddate]
      end
    end
  end # content

  controller do

    def index
      params[:startdate] ||= ApplicationHelper.first_day_of_month(Date.today)
      params[:enddate] ||= Date.today
      @sales = current_user.team_members_sales.where("date >= ?", params[:startdate]).where("date <= ?", params[:enddate]).group('users.prefered_name').sum(:nett_value)
      @sales = Hash[@sales.sort_by{|k,v| v}.reverse]   

      if @sales.length < 35
        @sales = @sales.to_a
        remaining = 35 - @sales.length
        remaining.times do 
          @sales << ['',0]
        end
        byebug
      end

      respond_to do |format|
        format.html
        format.js
      end 
    end
  end
end