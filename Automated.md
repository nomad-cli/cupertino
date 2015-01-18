![Cupertino](https://raw.github.com/nomad/nomad.github.io/assets/cupertino-banner.png)

Automate the entire process of submitting a new app to development devices. Or automate the entire process of submitting a production app to the app store, now with more security!

## Requirements
1. Keypair Passphrase
1. ADC Account & Login Credentials
1. ADC Team Name (only if on multiple teams)
1. App Name
## Process
### Development
1. Generate Keypair
`$ ssh-keygen -t rsa -b 2048 -f keypair -N passphrase`
1. Generate CSR
`$ openssl req -nodes -new -key keypair -passin pass:passphrase -out request.csr -subj "/C=US/ST=NC/L=Raleigh/O=Queue Software/OU=DropSource/CN=UserApp`
1. Generate App ID
`$ ios -u user -p pass --team team app_ids:add DropSourceApp=com.queuesoftware.dropsource`
1. Generate & Download Certificate
`$ ios -u user -p pass --team team certificates:create --download --type development request.csr`
1. Add Devices
`$ ios devices:add "iPad 2"=def456 "iPad 3"=ghi789 ...`
1. Generate & Download Profile
`$ ios -u user -p pass --team team profiles:create --download "Dev Profile" "com.queuesoftware.dropsource"`

### Production
1. Generate Keypair
`$ ssh-keygen -t rsa -b 4096 -f keypair -N passphrase`
1. Generate CSR
`$ openssl req -nodes -new -key keypair -passin pass:passphrase -out request.csr -subj "/C=US/ST=NC/L=Raleigh/O=Queue Software/OU=DropSource/CN=UserApp`
1. Generate App ID
`$ ios -u user -p pass --team team app_ids:add --type distribution DropSourceApp=com.queuesoftware.dropsource`
1. Generate & Download Certificate
`$ cert=(ios -u user -p pass --team team certificates:create --download --type production --internalid request.csr com.queuesoftware.dropsource)`
1. Generate & Download Profile
`$ ios -u user -p pass --team team profiles:create --type production --certificateid $cert --download "Dev Profile" "com.queuesoftware.dropsource"`