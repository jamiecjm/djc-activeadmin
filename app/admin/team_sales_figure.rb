ActiveAdmin.register_page "Team Sales Figure" do

  menu parent: 'Analytics', priority: 1

  content title: 'Team Sales Figure' do

    columns do
      column span: 4.9 do
        render 'team_sales_figure/barchart', sales: controller.instance_variable_get(:@sales), startdate: params['q']['date_gteq'], enddate: params['q']['date_lteq']
      end

      column do
        panel 'Filters', class: 'sidebar_section' do
          form action: 'team_sales_figure', 'data-remote': true, class: 'filter_form' do |f|

            div class: 'filter_form_field filter_date_range' do
              label 'Date', class: 'label'
              input type: :text, name: 'q[date_gteq]', value: params['q']['date_gteq'], class: 'datepicker', placeholder: 'From'
              input type: :text, name: 'q[date_lteq]', value: params['q']['date_lteq'], class: 'datepicker', placeholder: 'To'
            end

            div class: 'filter_form_field' do
              label 'Status', class: 'label'
              
              select name: 'q[status_eq]' do
                option
                Sale.statuses.each do |k,v|
                  option value: v do
                    k
                  end
                end
              end
            end

            div class: 'filter_form_field' do
              label 'Location', class: 'label'
              
              select name: 'q[users_location_eq]' do
                option
                User.locations.each do |k,v|
                  option value: v do
                    k
                  end
                end
              end
            end

            div class: 'filter_form_field' do
              label 'View as', class: 'label'
              
              select name: 'q[by_team]' do
                option 
                current_user.team_members.order(:prefered_name).each do |u|
                  option value: "[#{u.id}]" do
                    u.prefered_name
                  end
                end
              end
            end
            
            input type: :submit
          end
        end
      end
    end
  end # content

  controller do

    def index
      params['q'] ||= {}

      params['q']['date_gteq'] ||= ApplicationHelper.first_day_of_month(Date.today)
      params['q']['date_lteq'] ||= Date.today

      @sales = current_user.team_members_sales.search(params['q']).result.group('users.prefered_name').sum(:nett_value)
      @sales = Hash[@sales.sort_by{|k,v| v}.reverse]
      @startdate = params['q']['date_gteq']
      @enddate = params['q']['date_lteq']

      if @sales.length < 35
        @sales = @sales.to_a
        remaining = 35 - @sales.length
        remaining.times do 
          @sales << ['',0]
        end
      end

      respond_to do |format|
        format.html
        format.js
      end 
    end
  end
end