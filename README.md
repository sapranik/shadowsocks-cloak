# Installation
Use one of these sources to install Shadowsocks and cloak
  - https://www.oilandfish.com/posts/shadowsocks-cloak.html
  - https://www.oilandfish.com/posts/shadowsocks-cloak-script.html
  - https://github.com/shadowsocks/shadowsocks-libev & https://github.com/cbeuw/Cloak

&nbsp;

You can use ssck.sh from this repo. Take a look to see how it works.

  > wget -q https://raw.githubusercontent.com/sapranik/shadowsocks-cloak/main/ssck.sh && chmod +x ssck.sh

Examples:
  - ./ssck.sh -d mahsa.WomanLifeFreedom.com  # Minimum required parameters
  - ./ssck.sh -d mahsa.WomanLifeFreedom.com -e someone@mail.com # Add email to renew SSL certificate
  - ./ssck.sh -d mahsa.WomanLifeFreedom.com -g # Use -g for debugging purposes.


# Android
### Install shadowsocks

  From Google play: https://play.google.com/store/apps/details?id=com.github.shadowsocks

  From local apk: client/android/ss.apk

&nbsp;

### Install Cloak
  From github: https://github.com/cbeuw/Cloak-android/releases/download/v2.6.0-fix2/ck-client-2.6.0.apk

  From local apk: client/android/ck.apk

&nbsp;

### Setup a connection
  In Shadowsocks app, press + and select manual settings:

    Server: server domain name (Example: mahsa.WomanLifeFreedom.com)

    Port: 443

    Password: Shadowsocks's password

    Plugin: Cloak (Update parameters with Cloak settings)

      UID: USER_UID

      Public Key: PUBLIC_KEY

      Server Name: bing.com

&nbsp;

# Windows

client/win folder contains a portable version.

You need to update configuration files:

  > Shadowsocks: -> gui-config.json

    server: server domain name (Example: mahsa.WomanLifeFreedom.com)

    password: Shadowsocks password

  > Cloak: -> ck-client.json

    UID: Update with Cloak's User UID

    PublicKey: Update with Cloak's Public key

Run ss.exe, right click on the tray icon:
  > System Proxy: Select Global

  > Server: Select server

Double click on tray icon to update connection parameters.

&nbsp;

# iOS
Install from App Store: https://apps.apple.com/us/app/shadowrocket/id932747118
Shadowrocket is not free but it is the only/best Shadowsocks client for iOS that works with Cloak.
