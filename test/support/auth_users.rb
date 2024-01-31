module AuthUsers
  def bad_user
    "lauth-denied"
  end

  def good_user
    "lauth-allowed"
  end

  def inst_user
    "lauth-inst-member"
  end
end
