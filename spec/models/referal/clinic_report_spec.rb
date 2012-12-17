require "spec_helper"

describe Referal::ClinicReport do
  before(:each) do
    @province = Province.make
    @od = @province.ods.make :abbr => "BDB", :name => "BatDamBong", :code => "123456"
    
    @hc1 = @od.health_centers.make :name => "hc1", :code => "12345678"
    @hc2 = @od.health_centers.make :name => "hc2"
    @hc3 = @od.health_centers.make :name => "hc3"
    @hc4 = @od.health_centers.make :name => "hc4"
    
    @hc_user11 = @hc1.users.make :phone_number => "8558190", :apps => [User::APP_REFERAL], :status => true
    @hc_user12 = @hc1.users.make :phone_number => "8558191", :apps => [User::APP_REFERAL, User::APP_MDO], :status => true
    @hc_user13 = @hc1.users.make :phone_number => "8558192", :apps => [User::APP_REFERAL], :status => false
    @hc_user14 = @hc1.users.make :phone_number => "8558193", :apps => [User::APP_MDO], :status => true
    
    @hc_user21 = @hc2.users.make :phone_number => "8558180", :apps => [User::APP_REFERAL], :status => true
    @hc_user22 = @hc2.users.make :phone_number => "8558181", :apps => [User::APP_REFERAL, User::APP_MDO], :status => true
    @hc_user23 = @hc2.users.make :phone_number => "8558182", :apps => [User::APP_REFERAL], :status => false
    @hc_user24 = @hc2.users.make :phone_number => "8558183", :apps => [User::APP_MDO], :status => true
    
    @od_user1 = @od.users.make :phone_number => "8558195", :apps => [User::APP_REFERAL], :status => true
    @od_user2 = @od.users.make :phone_number => "8558196"

    @valid_message = {:from => "sms://8558192", :body => "F123M012345678", :guid => "123456"}
  end
  
  describe "Valid report" do
    it "should alert only to all users in specified in the reference health center " do
     Setting[:referal_clinic_health_center] = "You receive a patient {phone_number} from {place} with {slip_code}"
     Setting[:referal_clinic_clinic]        = "You have sent patient {phone_number} to {health_center} with {slip_code}" 
     report = Referal::ClinicReport.create! :phone_number          => "012123456",
                                            :place                 => @od ,
                                            :send_to_health_center => @hc1 ,
                                            :sender                => @od_user1 ,
                                            :slip_code             => "001001" ,
                                            :book_number           => "001",
                                            :code_number           => "001",
                                            :text                  => "xxx xxx xxx"
     messages = report.valid_alerts

     messages.should eq [
       {:to=>"sms://8558190", :body=>"You receive a patient 012123456 from 123456 BatDamBong (Od) with 001001", :from => MessageProxy.app_name},
       {:to=>"sms://8558191", :body=>"You receive a patient 012123456 from 123456 BatDamBong (Od) with 001001", :from => MessageProxy.app_name}, 
       {:to=>"sms://8558195", :body=>"You have sent patient 012123456 to 12345678 hc1 (Health Center) with 001001", :from => MessageProxy.app_name} 
       ]
    end
    
    it "should send to all users in all health centers under the od" do
      Setting[:referal_clinic_health_center] = "You receive a patient {phone_number} from {place} with {slip_code}"
      Setting[:referal_clinic_clinic]        = "You have sent patient {phone_number} with {slip_code}"
      
      report = Referal::ClinicReport.create! :phone_number          => "012123456",
                                            :place                 => @od ,
                                            :send_to_health_center => nil ,
                                            :sender                => @od_user1 ,
                                            :slip_code             => "001001" ,
                                            :book_number           => "001",
                                            :code_number           => "001",
                                            :text                  => "xxx xxx xxx"
      messages = report.valid_alerts
      
      messages.should eq [
          {:to=>"sms://8558190", :body=>"You receive a patient 012123456 from 123456 BatDamBong (Od) with 001001", :from => MessageProxy.app_name}, 
          {:to=>"sms://8558191", :body=>"You receive a patient 012123456 from 123456 BatDamBong (Od) with 001001", :from => MessageProxy.app_name}, 
          {:to=>"sms://8558180", :body=>"You receive a patient 012123456 from 123456 BatDamBong (Od) with 001001", :from => MessageProxy.app_name}, 
          {:to=>"sms://8558181", :body=>"You receive a patient 012123456 from 123456 BatDamBong (Od) with 001001", :from => MessageProxy.app_name}, 
          {:to=>"sms://8558195", :body=>"You have sent patient 012123456 with 001001", :from => MessageProxy.app_name}
        ]
    end
    
    
    
  end
end