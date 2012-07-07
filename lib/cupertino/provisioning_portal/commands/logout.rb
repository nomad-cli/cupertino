command :logout do |c|
  c.syntax = 'ios logout'
  c.summary = 'Remove account credentials'
  c.description = ''

  c.action do |args, options|
    say_error "You are not authenticated" and abort unless Netrc.read[Cupertino::HOSTNAME]

    netrc = Netrc.read
    netrc.delete(Cupertino::HOSTNAME)
    netrc.save

    say_ok "Account credentials removed"
  end
end
