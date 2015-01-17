![Cupertino](https://raw.github.com/nomad/nomad.github.io/assets/cupertino-banner.png)

## Generate Certificate Signing Request

### Option 1 - OSX Keychain & Security Tools
Generate the RSA keypair in the login keychain in OSX
```
$ security create-keypair -s 2048 [name]
```

Generate the CSR based on key in keychain
```
$ certtool r outputFileName [options]
```

### Option 2 - Linux Tools

1. Generate the RSA keypair
Example:
```
$ ssh-keygen -t rsa -b 2048 -f keypair -N passphrase
```
Options:
```
$ ssh-keygen -t rsa -b 2048 -f [keys-name] -N [user-password]
```

1. Generate the CSR
Example:
```
$ openssl req -nodes -new -key keypair -passin pass:passphrase -out request.csr -subj "/C=US/ST=NC/L=Raleigh/O=Queue Software/OU=DropSource/CN=UserApp"
```
Options:
```
$ openssl req -nodes -new -key [private-key-name] -passin pass:[user-password] -out [csr-file-name] -subj "/C=US/ST=NC/L=Raleigh/O=Queue Software/OU=DropSource/CN=[app-name]"
```