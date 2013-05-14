![Cupertino](https://raw.github.com/mattt/nomad-cli.com/assets/cupertino-banner.png)

Automate administrative tasks that you would normally have to do through the Apple Dev Center websites. Life's too short to manage device identifiers by hand!

> Cupertino is named after [Cupertino, CA](http://en.wikipedia.org/wiki/Cupertino,_California): home to Apple, Inc.'s world headquarters.
> It's part of a series of world-class command-line utilities for iOS development, which includes [Shenzhen](https://github.com/mattt/shenzhen) (Building & Distribution), [Houston](https://github.com/mattt/houston) (Push Notifications), [Venice](https://github.com/mattt/venice) (In-App Purchase Receipt Verification), and [Dubai](https://github.com/mattt/dubai) (Passbook pass generation).

## Installation

    $ gem install cupertino

## Usage

### Authentication

    $ ios login


_Credentials are saved in the Keychain. You will not be prompted for your username or password by commands while you are logged in. (Mac only)_

### Devices

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

### Provisioning Profiles

    $ ios profiles:list

    +----------------------------------+--------------+---------+
    | Profile                          | App ID       | Status  |
    +----------------------------------+--------------+---------+
    | iOS Team Provisioning Profile: * | ABCDEFG123.* | Valid   |
    +----------------------------------+--------------+---------+

---

    $ ios profiles:manage:devices

_Opens an editor with a list of devices, each of which can be commented / uncommented to turn them off / on for that provisioning profile._

    # Comment / Uncomment Devices to Turn Off / On for Provisioning Profile
    Johnny Appleseed iPad 0123456789012345678901234567890123abcdef
    # Johnny Appleseed iPhone abcdef0123456789012345678901234567890123


    $ ios profiles:devices:add MyApp_Development_Profile "Johnny Appleseed iPad"=0123456789012345678901234567890123abcdef "Johnny Appleseed iPhone"=abcdef0123456789012345678901234567890123

_Adds (without an editor) a list of devices to a provisioning profile_

    $ ios profiles:devices:remove MyApp_Development_Profile "Johnny Old iPad"=0123456789012345678901234567890123abcdef "Johnny Old iPhone"=abcdef0123456789012345678901234567890123

_Removes (without an editor) a list of devices from a provisioning profile_

### App IDs

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

### Certificates

    $ ios certificates:list

    +------------------+----------------------------------+-----------------+--------+
    | Name             | Provisioning Profiles            | Expiration Date | Status |
    +------------------+----------------------------------+-----------------+--------+
    | Johnny Appleseed | iOS Team Provisioning Profile: * | Dec 23, 2012    | Issued |
    +------------------+----------------------------------+-----------------+--------+

## Commands

- `login`
- `logout`
- `devices:add`
- `devices:list`
- `profiles:list`
- `profiles:manage:devices`
- `profiles:manage:devices:add`
- `profiles:manage:devices:remove`
- `profiles:download`
- `certificates:list [development|distribution]`
- `certificates:download`
- `app_ids:list`

### Disabled Commands

> With the latest updates to the Apple Developer Portal, the following functionality has been removed.

- `pass_type_ids:list`
- `pass_type_ids:add`
- `pass_type_ids:certificates:list`
- `pass_type_ids:certificates:add`
- `pass_type_ids:certificates:download`

## Contact

Mattt Thompson

- http://github.com/mattt
- http://twitter.com/mattt
- m@mattt.me

## License

Cupertino is available under the MIT license. See the LICENSE file for more info.
