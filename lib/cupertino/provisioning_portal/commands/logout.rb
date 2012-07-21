command :logout do |c|
  c.syntax = 'ios logout'
  c.summary = 'Remove account credentials'
  c.description = ''

  c.action do |args, options|
    say_error "You are not authenticated" and abort unless Security::InternetPassword.find(:server => Cupertino::HOSTNAME)

    Security::InternetPassword.delete(:server => Cupertino::HOSTNAME)

    say_ok "Account credentials removed"
  end
end
