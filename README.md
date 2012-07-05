# Cupertino
**Mechanize the Apple Dev Center**

Automate administrative tasks that you would normally have to do through the Apple Dev Center websites. Life's too short to manage device identifiers by hand!

This project is starting with the iOS Provisioning Portal, and may later expand to include iTunes Connect and/or Mac Developer Certificate Utility.

## Usage

```sh
$ ios devices:list

Mattt Thompson's iPad     abcdef0123456789...
Mattt Thompson's iPhone   abcdef0123456789...

$ ios devices:add "iPad 1"=abc123
$ ios devices:add "iPad 2"=def456 "iPad 3"=ghi789 ...

$ ios devices:remove "iPad 1"
```

## Commands

- `devices:list`

### To Be Implemented

#### Devices

- `devices:add`
- `devices:remove`

#### Certificates

- `certificates:list [-e development|distribution]`
- `certificates:add [-e development|distribution]`
- `certificates:download CERTIFICATE_NAME`
- `certificates:revoke CERTIFICATE_NAME`

#### Application IDs

- `app_ids:list`
- `app_ids:new`
