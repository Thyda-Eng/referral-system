module Helpers
  def health_center code, od_id=nil
    HealthCenter.create! :name => code, :name_kh => code, :code => code, :parent_id => od_id
  end

  def village name, code = nil, health_center_id = nil
    Village.create! :name => name, :name_kh => name, :code => code, :parent_id => health_center_id
  end

  def od name , id = nil
    OD.create! :name => name, :name_kh => name, :code => name, :parent_id => id
  end

  def province name
    Province.create! :name => name, :name_kh => name, :code => name
  end

  def user attribs
    User.create! attribs
  end

  def national_user number
    User.create! :phone_number => number, :role => "national"
  end

  def admin_user number
    User.create! :phone_number => number, :role => "admin"
  end
end
