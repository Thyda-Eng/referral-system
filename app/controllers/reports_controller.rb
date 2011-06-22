class ReportsController < ApplicationController
  include ReportsConcern

  before_filter :set_tab
  before_filter :get_report, :only => [:edit, :update, :ignore, :stop_ignoring]

  def index
    @pagination = {
      :page => get_page,
      :per_page => 20,
      :order => 'id desc'
    }

    if params[:error] == 'last'
      @reports = @place.reports.last_error_per_sender_per_day
    else
      @reports = @place.reports
      @reports = @reports.where(:error => true) if params[:error] == 'true'
    end
    @reports = @reports.includes(:sender, :village, :health_center)
    @reports = @reports.paginate @pagination
  end

  def edit
    if @report.place.class == HealthCenter
      @od = @report.place.parent
    else
      @od = @report.place.parent.parent
    end
    @villages = @od.health_centers.includes(:villages).to_a.map do |health_center|
      [health_center.short_description, health_center.villages.to_a.map do |village|
        [village.short_description, village.id]
      end]
    end
    @villages.insert 0, ['', ['Select one...', '']]
  end

  def update
    @report.update_attributes params[:report].slice(:sex, :age, :malaria_type, :village_id)
    @report.error = false
    if @report.save
      redirect_to reports_path(params.slice(:error, :place, :page)), :notice => 'Report edited successfully'
    else
      edit and render :edit
    end
  end

  def ignore
    @report.ignored = true
    @report.save

    redirect_to params[:next_url], :notice => 'Report ignored successfully'
  end

  def stop_ignoring
    @report.ignored = false
    @report.save

    redirect_to params[:next_url], :notice => 'Report is not ignored anymore'
  end

  #GET report_form
  def report_form
    @tab = :reported_case
    @reports = []
    @reports = Report.report_cases_paginate params if params[:from].present?
  end

  #GET report_detail
  def report_detail
    @place = Place.find(params[:place_id])
    @reports = Report.no_error.not_ignored.at_place(@place).between_dates(params[:from], params[:to])
    @reports = @reports.paginate :page => get_page, :per_page => 20
    render :layout =>false
  end

  # GET reports/report_csv
  def report_csv
    file = Report.write_csv(params)
    file = File.open(file, "rb")
    contents = file.read
    send_data contents, :type => "text/csv" , :filename => Report.report_file(params[:place_type],params[:from],params[:to])
  end

  def generated_messages
    @report = Report.find(params[:id])
    @messages = @report.generated_messages
    render :layout => false
  end

  def duplicated
    @tab = :duplicated_messages
    @pagination = {
      :page => get_page,
      :per_page => 20,
      :order => 'reports.id desc'
    }
    @reports = @place.reports.duplicated_per_sender_per_day
    @reports = @reports.includes(:sender, :village, :health_center)
    @reports = @reports.paginate @pagination
    render 'index'
  end

  private

  def set_tab
    @tab = case params[:error]
    when 'true'
      :error_messages
    when 'last'
      :last_error_messages
    else
      :all_messages
    end
  end

  def get_report
    @report = Report.find params[:id]
  end
end
