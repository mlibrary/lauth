RSpec.describe "Passive authentication" do
  # This relates to CosignProtected On CosignAllowPublicAccess On
  #
  # There is an edge case for delegated configuration where a user who could
  # log in visits a login-or-IP-restricted resource from an authorized network
  # and is allowed access. If the user logs in for another service, they will
  # become known on subsequent requests. Applications in passive mode should
  # make the user aware of their login status and allow them authenticate.
end
