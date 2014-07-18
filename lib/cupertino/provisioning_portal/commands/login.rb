command :login do |c|
  c.syntax = 'ios login'
  c.summary = 'Save account credentials'
  c.description = ''

  c.action do |args, options|
    say_warning "You are already authenticated" if Security::InternetPassword.find(:server => Cupertino::ProvisioningPortal::HOST)

    user = ask "Username:"
    pass = password "Password:"

    if Security::InternetPassword.add(Cupertino::ProvisioningPortal::HOST, user, pass)
      say_ok "Account credentials saved"
    else
      say_error "Error saving credentials"
    end
  end
end
