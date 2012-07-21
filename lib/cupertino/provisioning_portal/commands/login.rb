command :login do |c|
  c.syntax = 'ios login'
  c.summary = 'Save account credentials'
  c.description = ''

  c.action do |args, options|
    say_warning "You are already authenticated" if Security::InternetPassword.find(:server => Cupertino::HOSTNAME)

    user = ask "Username:"
    pass = password "Password:"

    Security::InternetPassword.add(Cupertino::HOSTNAME, user, pass)

    say_ok "Account credentials saved"
  end
end
