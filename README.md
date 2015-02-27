![Cupertino](https://raw.github.com/nomad/nomad.github.io/assets/cupertino-banner.png)

Automate administrative tasks that you would normally have to do through the Apple Dev Center websites. Life's too short to manage device identifiers by hand!

> Cupertino is named after [Cupertino, CA](http://en.wikipedia.org/wiki/Cupertino,_California): home to Apple, Inc.'s world headquarters.
> It's part of a series of world-class command-line utilities for iOS development, which includes [Shenzhen](https://github.com/mattt/shenzhen) (Building & Distribution), [Houston](https://github.com/mattt/houston) (Push Notifications), [Venice](https://github.com/mattt/venice) (In-App Purchase Receipt Verification), [Dubai](https://github.com/mattt/dubai) (Passbook pass generation), and [Nashville](https://github.com/nomad/nashville) (iTunes Store API).

## Requirements

Cupertino requires the [Xcode Command Line Tools](https://developer.apple.com/xcode/), which can be installed with the following command:

```
$ xcode-select --install
```

## Installation

```
$ gem install cupertino
```

## Usage

### Authentication

```
$ ios login
$ ios [command] -u [username] -p [password]
```

_Credentials are saved in the Keychain. You will not be prompted for your username or password by commands while you are logged in. (Mac only)_

### Team Selection

```
$ ios [command] --team [TEAM]
```

This is also an interactive choice

### Devices

```
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

```
$ ios profiles:list

+----------------------------------+--------------+---------+
| Profile                          | App ID       | Status  |
+----------------------------------+--------------+---------+
| iOS Team Provisioning Profile: * | ABCDEFG123.* | Valid   |
+----------------------------------+--------------+---------+
```

```
$ ios profiles:create "Profile 1" "ABCDEFG123.com.company.app"
Development profile created with all certificates and all devices

$ ios profiles:create --download "Profile 1" "ABCDEFG123.com.company.app"
Downloaded Profile_1.mobileprovision

$ ios profiles:create --certificateid "AB123XYZG" "Profile 1" "ABCDEFG123.com.company.app"
Development profile created with 1 certificate and all devices

$ ios profiles:create --type appstore --certificateid "AB123XYZG" "Profile 1" "ABCDEFG123.com.company.app"
App Store profile created called Profile 1

$ ios profiles:create --type adhoc --certificateid "AB123XYZG" "Profile 1" "ABCDEFG123.com.company.app"
Ad Hoc profile created with 1 certificate and all devices
```

---

```
$ ios profiles:manage:devices
```

_Opens an editor with a list of devices, each of which can be commented / uncommented to turn them off / on for that provisioning profile._

```
# Comment / Uncomment Devices to Turn Off / On for Provisioning Profile
Johnny Appleseed iPad 0123456789012345678901234567890123abcdef
# Johnny Appleseed iPhone abcdef0123456789012345678901234567890123
```

```
$ ios profiles:devices:add MyApp_Development_Profile "Johnny Appleseed iPad"=0123456789012345678901234567890123abcdef "Johnny Appleseed iPhone"=abcdef0123456789012345678901234567890123
```

_Adds (without an editor) a list of devices to a provisioning profile_

```
$ ios profiles:devices:remove MyApp_Development_Profile "Johnny Old iPad"=0123456789012345678901234567890123abcdef "Johnny Old iPhone"=abcdef0123456789012345678901234567890123
```

_Removes (without an editor) a list of devices from a provisioning profile_

---

```
$ ios profiles:devices:list MyApp_Development_Profile

+--------------------------+------------------------------------------+--------+
|         Listing devices for provisioning profile MyApp_Development_Profile   |
+--------------------------+------------------------------------------+--------+
| Device Name              | Device Identifier                        | Active |
+--------------------------+------------------------------------------+--------+
| Person's iPhone 5        | 888888883e48a3e0458aab2691d565a8a63f7888 |   Y    |
+--------------------------+------------------------------------------+--------+

```

### App IDs

```
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

```
$ ios app_ids:add "App Bundle Description"=123ABCDEFG.com.mattt.bundle
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

```
$ ios certificates:download
$ ios certificates:download --type distribution
$ ios certificates:download NAME
```

```
$ ios certificates:create request.csr
$ ios certificates:create --type devpush request.csr 123ABCDEFG.com.mattt.bundle
$ ios certificates:create --type production request.csr
$ ios certificates:create --type prodpush request.csr 123ABCDEFG.com.mattt.bundle
$ ios certificates:create --type prodpush --download --internalid request.csr
$ ios certificates:create --download request.csr
$ ios certificates:create --download --internalid --type TYPE CSR (APPID)
```
App ID is required for Push Certificates.

The download flag retrieves the certificate file to the current directory

The internalid flag quiets all output but returns Apple's internal id for the created certificate to the STDOUT. Can be used in combination with the download flag.

## CSV Output

The following commands will format their output as [comma-separated values](http://en.wikipedia.org/wiki/Comma-separated_values) when the `--format csv` argument is passed:

- `app_ids:list`
- `devices:list`
- `profiles:list`
- `profiles:manage:devices:list`

## Commands

- `login`
- `logout`
- `devices:add`
- `devices:list`
- `profiles:list`
- `profiles:create`
- `profiles:manage:devices`
- `profiles:manage:devices:add`
- `profiles:manage:devices:remove`
- `profiles:download`
- `profiles:download:all`
- `profiles:devices:list`
- `certificates:list`
- `certificates:download`
- `certificates:create`
- `app_ids:add`
- `app_ids:list`

## Proxies

Cupertino will access the provisioning portal through a proxy if the `HTTP_PROXY` environment variable is set, with optional credentials `HTTP_PROXY_USER` and `HTTP_PROXY_PASSWORD`.

## License

Cupertino is available under the MIT license. See the LICENSE file for more info.
