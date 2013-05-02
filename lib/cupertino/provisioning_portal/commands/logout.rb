command :logout do |c|
  c.syntax = 'ios logout'
  c.summary = 'Remove account credentials'
  c.description = ''

  c.action do |args, options|
    say_error "You are not authenticated" and abort unless Security::InternetPassword.find(:server => Cupertino::ProvisioningPortal::HOST)

    Security::InternetPassword.delete(:server => Cupertino::ProvisioningPortal::HOST)

    say_ok "Account credentials removed"
  end
end
