ActiveAdmin.register_page "Monthly Sales Figure" do

  # menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }
  menu parent: 'Analytics', priority: 2

  content title: 'Monthly Sales Figure' do
    # div class: "blank_slate_container", id: "dashboard_default_message" do
    #   span class: "blank_slate" do
    #     span I18n.t("active_admin.dashboard_welcome.welcome")
    #     small I18n.t("active_admin.dashboard_welcome.call_to_action")
    #   end
    # end

    # Here is an example of a simple dashboard with columns and panels.
    #
    columns do
      column do
        data = controller.instance_variable_get(:@sales)
        total = number_to_currency(data.values.inject(:+), unit: 'RM ')
        column_chart data, height: "80vh", xtitle: 'Month', ytitle: 'Nett Value (RM)', title: "Monthly Sales Figure ~ Total Nett Value: #{total}"
      end
    end
  end # content

  controller do

    def index
      params[:startdate] ||= ApplicationHelper.current_sales_cycle[:startdate]
      params[:enddate] ||= ApplicationHelper.current_sales_cycle[:enddate]
      @sales = current_user.team_members_sales.where("date >= ?", params[:startdate]).where("date <= ?", params[:enddate]).group_by_month(:date).sum(:nett_value)
      @sales = ApplicationHelper.populate_sales_cycle(@sales)
    end
  end
end
