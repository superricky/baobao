#encoding: utf-8
class Backend::StatisticsController < BackendApplicationController
  def shop_stat_month
    @month = params[:month]||Date.today.month
    @year = params[:year]||Date.today.year
    @first_day = [Date.new(@year.to_i, @month.to_i), @current_shop.created_at.to_date].max
    @last_day = [@first_day.end_of_month, Date.today].min
    @x_axis = []
    @y_axis_users = []
    @y_axis_amounts = []

    @users_counter_array = @current_shop.users.
      where("DATE_FORMAT(CONVERT_TZ(created_at,'+00:00','+08:00'), '%m') = ? and DATE_FORMAT(CONVERT_TZ(created_at,'+00:00','+08:00'), '%Y') = '?'",
         '%02d' % @first_day.month, @first_day.year).group("DATE_FORMAT(CONVERT_TZ(created_at,'+00:00','+08:00'), '%Y-%m-%d')").count

    @y_axis_orders = []
    orders_group = @current_shop.orders.
      where("DATE_FORMAT(CONVERT_TZ(created_at,'+00:00','+08:00'), '%m') = ? and DATE_FORMAT(CONVERT_TZ(created_at,'+00:00','+08:00'), '%Y') = '?'",
         '%02d' % @first_day.month, @first_day.year).group("DATE_FORMAT(CONVERT_TZ(created_at,'+00:00','+08:00'), '%Y-%m-%d')")
    @orders_counter_array = orders_group.count
    @orders_amount_array = orders_group.sum(:amount)
    @first_day.upto(@last_day).to_a.each do |day|
      @x_axis << day.strftime("%m-%d")
      count = @users_counter_array[day.strftime("%Y-%m-%d")]
      if count.nil?
        @y_axis_users<< 0
      else
        @y_axis_users<< count
      end

      count = @orders_counter_array[day.strftime("%Y-%m-%d")]
      if count.nil?
        @y_axis_orders << 0
      else
        @y_axis_orders << count
      end

      amount = @orders_amount_array[day.strftime("%Y-%m-%d")]
      if count.nil?
        @y_axis_amounts << 0
      else
        @y_axis_amounts << amount.to_s.to_f
      end
    end
    render 'stat_month'
  end

  def shop_stat_year
    @year = (params[:year]||Date.today.year).to_i
    if @year.to_i > @current_shop.created_at.year
      @first_month = 1
      @end_month =  @year == Date.today.year ? [12, Time.new.month].min : 12
    elsif @year.to_i == @current_shop.created_at.year
      @first_month = @current_shop.created_at.month
      @end_month = @year == Date.today.year ? Date.today.month : 12
    end
    @x_axis = []
    @y_axis_users = []
    @y_axis_orders = []
    @y_axis_amounts = []
    @users_counter_array = @current_shop.all_users.for_year(@year).group_by { |t| t.created_at.beginning_of_month}.inject({}) { |m, (k,v)| m[k.month] = v; m }
    @orders_array = @current_shop.orders.for_year(@year).group_by { |t| t.created_at.beginning_of_month}
    @orders_counter_array = @orders_array.inject({}) { |m, (k,v)| m[k.month] = v.count; m }
    @orders_amounts_array = @orders_array.inject({}) { |m, (k,v)| m[k.month] = v.inject(1.0){|sum,x| sum + x.amount }; m }
    @first_month.upto(@end_month) do |month|
      @x_axis << month
      @y_axis_users << (@users_counter_array[month].count rescue 0)
      @y_axis_orders << (@orders_counter_array[month] || 0)
      @y_axis_amounts << (@orders_amounts_array[month] || 0).to_s.to_f
    end
    render 'stat_year'
  end

  def branch_stat_month
    @month = (params[:month]||Date.today.month).to_i
    @year = (params[:year]||Date.today.year).to_i
    @first_day = [Date.new(@year, @month), @current_branch.created_at.to_date].max
    @last_day = [@first_day.end_of_month, Date.today].min
    @x_axis = []
    @y_axis_amounts = []
    @y_axis_orders = []
    orders_group = @current_branch.orders.
      where("DATE_FORMAT(CONVERT_TZ(created_at,'+00:00','+08:00'), '%m') = ? and DATE_FORMAT(CONVERT_TZ(created_at,'+00:00','+08:00'), '%Y') = '?'",
         '%02d' % @first_day.month, @first_day.year).group("DATE_FORMAT(CONVERT_TZ(created_at,'+00:00','+08:00'), '%Y-%m-%d')")
    @orders_counter_array = orders_group.count
    @orders_amount_array = orders_group.sum(:amount)
    @first_day.upto(@last_day).to_a.each do |day|
      @x_axis << day.strftime("%m-%d")
      count = @orders_counter_array[day.strftime("%Y-%m-%d")]
      if count.nil?
        @y_axis_orders << 0
      else
        @y_axis_orders << count
      end

      amount = @orders_amount_array[day.strftime("%Y-%m-%d")]
      if count.nil?
        @y_axis_amounts << 0
      else
        @y_axis_amounts << amount.to_s.to_f
      end
    end
    render 'stat_month'
  end

  def branch_stat_year
    @year = (params[:year]||Date.today.year).to_i
    if @year.to_i > @current_branch.created_at.year
      @first_month = 1
      @end_month =  @year == Date.today.year ? [12, Time.new.month].min : 12
    elsif @year.to_i == @current_branch.created_at.year
      @first_month = @current_branch.created_at.month
      @end_month = @year == Date.today.year ? Date.today.month : 12
    end
    @x_axis = []
    @y_axis_users = []
    @y_axis_orders = []
    @y_axis_amounts = []
    @users_counter_array = @current_branch.users.for_year(@year).group_by { |t| t.created_at.beginning_of_month}.inject({}) { |m, (k,v)| m[k.month] = v; m }
    @orders_array = @current_branch.orders.for_year(@year).group_by { |t| t.created_at.beginning_of_month}
    @orders_counter_array = @orders_array.inject({}) { |m, (k,v)| m[k.month] = v.count; m }
    @orders_amounts_array = @orders_array.inject({}) { |m, (k,v)| m[k.month] = v.inject(1.0){|sum,x| sum + x.amount }; m }
    @first_month.upto(@end_month) do |month|
      @x_axis << month
      @y_axis_users << (@users_counter_array[month].count rescue 0)
      @y_axis_orders << (@orders_counter_array[month] || 0)
      @y_axis_amounts << (@orders_amounts_array[month] || 0)
    end
    render 'stat_year'
  end

end