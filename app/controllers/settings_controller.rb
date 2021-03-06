class SettingsController < ApplicationController

  # GET /reminder_config
  def reminder_config
    @title = "Reminder setting"
    @admin_reminder = Setting[:admin_reminder]
    @national_reminder = Setting[:national_reminder]
    @provincial_reminder = Setting[:provincial_reminder]
    @od_reminder = Setting[:od_reminder]
    @hc_reminder = Setting[:hc_reminder]
    @village_reminder = Setting[:village_reminder]
    @reminder_days = Setting[:reminder_days]

    @provinces_checked = AlertPf.last.nil?? [] : AlertPf.last.provinces
    @provinces = Province.all
  end

  # POST /update_reminder_config
  def update_reminder_config
    Setting[:admin_reminder]      = params[:setting][:admin_reminder]
    Setting[:national_reminder]   = params[:setting][:national_reminder]
    Setting[:provincial_reminder] = params[:setting][:provincial_reminder]
    Setting[:od_reminder] = params[:setting][:od_reminder]
    Setting[:hc_reminder] = params[:setting][:hc_reminder]
    Setting[:village_reminder] = params[:setting][:village_reminder]
    Setting[:reminder_days] = params[:reminder_days]

    # save provinces into alert_pf
    # escape select all {:all => ""}
    alert_pf = AlertPf.last.nil?? AlertPf.new : AlertPf.last
    alert_pf.provinces = params[:provinces].nil?? [] : params[:provinces].select { |k, v| v != ""}.values
    alert_pf.save

    flash["msg-notice"] = "Settings have been saved successfully"
    redirect_to reminder_config_url
  end

  def alert_config
    @title = "Alert setting"
    @provincial_alert = Setting[:provincial_alert]
    @admin_alert = Setting[:admin_alert]
    @national_alert = Setting[:national_alert]
   end

   def update_alert_config
     Setting[:provincial_alert] = params[:setting][:provincial_alert]
     Setting[:national_alert]   = params[:setting][:national_alert]
     Setting[:admin_alert]      = params[:setting][:admin_alert]

     flash["msg-notice"] = "Settings have been saved successfully"
     redirect_to alert_config_url
   end

   def template_config
     @templates = Templates.new
   end

   def update_template_config
     @templates = Templates.new params[:templates]
     if @templates.save
       flash["notice"] = "Templates have been saved successfully"
       redirect_to :action => :template_config
     else
       render :template_config
     end
   end
end
