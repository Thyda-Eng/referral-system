class Referral::ClinicReport < Referral::Report
  default_scope where(:type => "Referral::ClinicReport")
  
  # return an Array of hashes
  def valid_alerts
    
    alerts = []
    alert_hcs = []

    if self.send_to_health_center.nil?
       alert_hcs = self.place.health_centers
    else
       alert_hcs << self.send_to_health_center
    end
    
    alert_hcs.each do |hc|
      body = translate_message_for(:referral_clinic_health_center)
      alerts += hc.acknowledgemente(body)
    end
    
    body = translate_message_for(:referral_clinic_clinic)
    alerts << self.sender.message(body)
    alerts
  end
  
  def self.confirmed
    where "confirm_from_id IS NOT NULL"
  end
  
  def self.not_confirmed
    where "confirm_from_id IS NULL"
  end
end
