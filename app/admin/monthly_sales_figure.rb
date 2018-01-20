ActiveAdmin.register_page "Monthly Sales Figure" do

  # menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }
  menu parent: 'Analytics', priority: 2

  content title: 'Monthly Sales Figure' do

    columns do
      column span: 4.9 do
        data = controller.instance_variable_get(:@sales)
        total = number_to_currency(data.values.inject(:+), unit: 'RM ')
        column_chart data, height: "80vh", xtitle: 'Month', ytitle: 'Nett Value (RM)', title: "Monthly Sales Figure ~ Total Nett Value: #{total}"
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
                current_user.subtree.order(:prefered_name).each do |u|
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

      params['q']['date_gteq'] ||= ApplicationHelper.current_sales_cycle[:startdate]
      params['q']['date_lteq'] ||= ApplicationHelper.current_sales_cycle[:enddate]

      @sales = current_user.team_members_sales.search(params['q']).result.group_by_month(:date).sum(:nett_value)
      @sales = ApplicationHelper.populate_sales_cycle(@sales)
    end
  end
end
