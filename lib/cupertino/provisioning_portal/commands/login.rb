command :login do |c|
  c.syntax = 'ios login'
  c.summary = 'Save account credentials'
  c.description = ''

  c.action do |args, options|
    say_warning "You are already authenticated" if Netrc.read[Cupertino::HOSTNAME]

    user = ask "Username:"
    pass = password "Password:"

    netrc = Netrc.read
    netrc[Cupertino::HOSTNAME] = user, pass
    netrc.save

    say_ok "Account credentials saved"
  end
end
