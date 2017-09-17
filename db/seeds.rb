
  require 'csv'

  ActiveRecord::Base.transaction do
    csv = CSV.new(File.open('db/eliteone_teams.csv'), :headers => true)
    csv.each do |row|
      team = Team.new
      row.each do |field, value|
        team.write_attribute(field.to_sym, value)
      end
      team.save(validate: false)
    end

    csv = CSV.new(File.open('db/eliteone_units.csv'), :headers => true)
    csv.each do |row|
      unit = Unit.new
      row.each do |field, value|
        unit.write_attribute(field.to_sym, value)
      end
      unit.save(validate: false)
    end

    csv = CSV.new(File.open('db/eliteone_salevalues.csv'), :headers => true)
    csv.each do |row|
      salevalue = Salevalue.new
      row.each do |field, value|
          salevalue.write_attribute(field.to_sym, value)
      end
      salevalue.save(validate: false)
    end

    csv = CSV.new(File.open('db/eliteone_projects.csv'), :headers => true)
    csv.each do |row|
      project = Project.new
      row.each do |field, value|
          project.write_attribute(field.to_sym, value)
      end
      project.save(validate: false)
    end

    csv = CSV.new(File.open('db/eliteone_commissions.csv'), :headers => true)
    csv.each do |row|
      comm = Commission.new
      row.each do |field, value|
        comm.write_attribute(field.to_sym, value)
      end
      comm.save(validate: false)
    end

    csv = CSV.new(File.open('db/eliteone_sales.csv'), :headers => true)
    csv.each do |row|
      sale = Sale.new
      row.each do |field, value|
        if field == "status"
          sale.write_attribute(field.to_sym, value.to_i)
        else
          sale.write_attribute(field.to_sym, value)
        end
      end
      sale.save(validate: false)
      unit = sale.unit
      unit.update(comm_percentage: sale.project.commission(sale.date).percentage,sale_id: sale.id)
    end



    csv = CSV.new(File.open('db/eliteone_users.csv'), :headers => true)
    csv.each do |row|
      user = User.new
      password = 0
      row.each do |field, value|
        if field == "location" || field == "position"
          user.write_attribute(field.to_sym, value.to_i)
        else
          user.write_attribute(field.to_sym, value)
        end
      end
      user.save(validate: false)
    end
    Sale.all.each {|s| s.update(commission_id: s.project.commission(s.date).id)}
    User.where(team_id: nil).update(password: "eliteonesales2017")
    Unit.where(sale_id: nil).destroy_all
    ActiveRecord::Base.connection.reset_pk_sequence!('sales')
    ActiveRecord::Base.connection.reset_pk_sequence!('units')
    ActiveRecord::Base.connection.reset_pk_sequence!('users')
    ActiveRecord::Base.connection.reset_pk_sequence!('teams')
    ActiveRecord::Base.connection.reset_pk_sequence!('projects')
    ActiveRecord::Base.connection.reset_pk_sequence!('commissions')
    ActiveRecord::Base.connection.reset_pk_sequence!('salevalues')
  end
