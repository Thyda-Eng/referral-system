class Referal::HCParser < Referal::Parser
  def initialize options
    super(options)
  end
  
  def parse message_format
    @message_format = message_format
    begin
      scan_messages
    rescue 
    end
    create_report
  end
  
  def create_report
    @report = Referal::HCReport.new @options
    @report
  end
  
  def message_format
    hc_format = Referal::MessageFormat.health_center
    raise_error :undefined_format_for_health_center if hc_format.nil?
    return hc_format
  end

    
  
end