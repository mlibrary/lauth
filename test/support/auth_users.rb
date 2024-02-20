module AuthUsers
  def bad_user
    "lauth-denied"
  end

  def good_user
    "lauth-allowed"
  end

  def another_good_user
    "lauth-allowed-also"
  end

  def inst_user
    "lauth-inst-member"
  end
end
