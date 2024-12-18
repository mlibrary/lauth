module BasicAuth
  include AuthUsers

  def basic_auth_bad_user
    basic_auth_for(bad_user)
  end

  def basic_auth_good_user
    basic_auth_for(good_user)
  end

  def basic_auth_inst_member
    basic_auth_for(inst_user)
  end

  def basic_auth_group_member
    basic_auth_for(group_user)
  end

  def basic_auth_for(user)
    "Basic #{Base64.urlsafe_encode64("#{user}:#{user}")}"
  end
end
