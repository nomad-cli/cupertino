# Cupertino
**CLI for the Apple Dev Center**

Automate administrative tasks that you would normally have to do through the Apple Dev Center websites. Life's too short to manage device identifiers by hand!

This project is starting with the iOS Provisioning Portal, and may later expand to include iTunes Connect and/or Mac Developer Certificate Utility.

## Installation

```sh
$ gem install cupertino
```

## Usage

### Authentication

```sh
$ ios login
```

_Credentials are saved in the Keychain. You will not be prompted for your username or password by commands while you are logged in. (Mac only)_

### Devices

```sh
$ ios devices:list

+------------------------------+---------------------------------------+
|       Listing 2 devices. You can register 98 additional devices.     |
+---------------------------+------------------------------------------+
| Device Name               | Device Identifier                        |
+---------------------------+------------------------------------------+
| Johnny Appleseed iPad     | 0123456789012345678901234567890123abcdef |
| Johnny Appleseed iPhone   | abcdef0123456789012345678901234567890123 |
+---------------------------+------------------------------------------+

$ ios devices:add "iPad 1"=abc123
$ ios devices:add "iPad 2"=def456 "iPad 3"=ghi789 ...
```

### Provisioning Profiles

```sh
$ ios profiles:list

+----------------------------------+--------------+---------+
| Profile                          | App ID       | Status  |
+----------------------------------+--------------+---------+
| iOS Team Provisioning Profile: * | ABCDEFG123.* | Valid   |
+----------------------------------+--------------+---------+
```

---

```sh
$ ios profiles:manage:devices
```

_Opens an editor with a list of devices, each of which can be commented / uncommented to turn them off / on for that provisioning profile._

```
# Comment / Uncomment Devices to Turn Off / On for Provisioning Profile
Johnny Appleseed iPad 0123456789012345678901234567890123abcdef
# Johnny Appleseed iPhone abcdef0123456789012345678901234567890123
```

### App IDs

```sh
$ ios app_ids:list

+-----------------------------+------------------------+-------------------+-------------------+
| Bundle Seed ID              | Description            | Development       | Distribution      |
+-----------------------------+------------------------+-------------------+-------------------+
| 123ABCDEFG.com.mattt.bundle | App Bundle Description | Passes            | Passes            |
|                             |                        | Data Protection   | Data Protection   |
|                             |                        | iCloud            | iCloud            |
|                             |                        | In-App Purchase   | In-App Purchase   |
|                             |                        | Game Center       | Game Center       |
|                             |                        | Push Notification | Push Notification |
+-----------------------------+------------------------+-------------------+-------------------+
```

### Certificates

```
$ ios certificates:list

+------------------+----------------------------------+-----------------+--------+
| Name             | Provisioning Profiles            | Expiration Date | Status |
+------------------+----------------------------------+-----------------+--------+
| Johnny Appleseed | iOS Team Provisioning Profile: * | Dec 23, 2012    | Issued |
+------------------+----------------------------------+-----------------+--------+
```

### Pass Type IDs

```sh
$ ios pass_type_ids:add --pass_type_id pass.com.example.coupon.myExamplePass --description "My Example Pass Coupon"
Added pass.com.example.coupon.myExamplePass: My Example Pass Coupon
```

---

```sh
$ ios pass_type_ids:list

+------------+--------------------------------------------+------------------------------+-------------------+
| Card ID    | Identifier                                 | Description                  | Pass Certificates |
+------------+--------------------------------------------+------------------------------+-------------------+
| WWWWWWWWWW | pass.com.example.coupon.myExamplePass      | My Example Pass Coupon       | None              |
| XXXXXXXXXX | pass.com.example.eventTicket.myExamplePass | My Example Pass Event Ticket | Pass Certificate  |
| YYYYYYYYYY | pass.com.example.movieTicket.myExamplePass | My Example Pass Movie Ticket | Pass Certificate  |
| ZZZZZZZZZZ | pass.com.example.test.001                  | Test                         | Pass Certificate  |
+------------+--------------------------------------------+------------------------------+-------------------+
```

---

```sh
$ ios pass_type_ids:pass_certificates:add --pass_type_id pass.com.example.coupon.myExamplePass --csr_path _path/to/csr_
Configured pass.com.example.coupon.myExamplePass. Apple is generating the certificate...
Certificate generated and is ready to be downloaded.
```

---

```sh
$ ios pass_type_ids:pass_certificates:list --pass_type_id pass.com.example.coupon.myExamplePass
+--------------------------+------------+-----------------+----------------+
| Name                     | Status     | Expiration Date | Certificate ID |
+--------------------------+------------+-----------------+----------------+
|         Pass Certificate | Configured | Nov 21, 2013    | AAAAAAAAAA     |
+--------------------------+------------+-----------------+----------------+
```

---

```sh
$ ios pass_type_ids:pass_certificates:download --pass_type_id pass.com.example.coupon.myExamplePass --cert_id AAAAAAAAAA
Successfully downloaded: 'AAAAAAAAAA.cer'
```

## Commands

_Crossed out commands are not yet implemented_

- `login`
- `logout`

- `devices:add`
- `devices:list`
- ~~`devices:remove`~~

- `profiles:list`
- `profiles:manage:devices`
- `profiles:download`
- ~~`profiles:add`~~
- ~~`profiles:edit`~~

- `certificates:list [development|distribution]`
- `certificates:download`
- ~~`certificates:revoke CERTIFICATE_NAME`~~

- `app_ids:list`
- ~~`app_ids:new`~~

- `pass_type_ids:list`
- `pass_type_ids:add`
- `pass_type_ids:pass_certificates:list`
- `pass_type_ids:pass_certificates:add`
- `pass_type_ids:pass_certificates:download`

## Contact

Mattt Thompson

- http://github.com/mattt
- http://twitter.com/mattt
- m@mattt.me

## License

Cupertino is available under the MIT license. See the LICENSE file for more info.
