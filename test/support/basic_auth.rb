module BasicAuth
  include AuthUsers

  def basic_auth_bad_user
    "Basic #{Base64.urlsafe_encode64("#{bad_user}:lauth-denied")}"
  end

  def basic_auth_good_user
    "Basic #{Base64.urlsafe_encode64("#{good_user}:lauth-allowed")}"
  end

  def basic_auth_inst_member
    "Basic #{Base64.urlsafe_encode64("#{inst_user}:lauth-inst-member")}"
  end
end
