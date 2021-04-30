IOSKeePass
===========

IOSKeePass ist a fork of MiniKeePass, i do it, because i find that this Software is great stuff for password storing
and sensible data to a local file, and not in the cloud, also i mean, it was free and it should be keep for free in future.
I have create a new repo on Github, because the original Github project was setting to read only, and i can´t support the original Software development.

*New
- Support for KDBx Version 4 (Mar. 2021)
- IOS Darkmode Support (Aug. 2020)
- One Time password support secure secret key storing (Released in 1.80)
  The Time-based One-time Password algorithm (TOTP) is an extension of the HMAC-based One-time Password algorithm (HOTP) that generates a one-time password (OTP) by instead taking         
  uniqueness from the current time. It has been adopted as Internet Engineering Task Force (IETF)[1] standard RFC 6238,
  [1] is the cornerstone of Initiative for Open Authentication (OATH), and is used in a number of two-factor authentication (2FA) systems. 
- open key db file from ios local storage
- support open db by FaceID using LAPolicyDeviceOwnerAuthenticationWithBiometrics

*Older Stuff from Original
MiniKeePass provides secure password storage on your phone that's compatible with KeePass.

- View, Edit, and Create KeePass 1.x and 2.x files
- Search for entries from the top of tables like in Mail
- Key File Support
- Import/Export files to Dropbox using the Dropbox iPhone app
- Copy password entries to the clipboard for easy entry
- Open websites in Safari while MiniKeePass runs in the background
- Prevent unauthorized access to MiniKeePass with a PIN
- Remember database passwords in the device's secure keychain
- Optionally clear the clipboard after set time on devices that support background tasks
- Generate new passwords

FAQ
---

### Copying KeePass files using Dropbox ###

You can copy KeePass files from Dropbox to your device using the [Dropbox iOS App](https://www.dropbox.com/help/80/en).  This method will also work with any other app that let you open files in other apps (Google Drive, Box.net, Mail, Safari, etc).

You can use a similar procedure in MiniKeePass to copy your KeePass file from MiniKeePass to another app.  Open the KeePass file in MiniKeePass, and select the action button on the bottom toolbar, and you will be presented with a list of apps that can open the KeePass file.

### Copying KeePass files using iTunes ###

You can copy your KeePass files to/from your device using [File Sharing](http://support.apple.com/kb/ht4094) in iTunes.

### KeePass File Not Restored During Backup ###

iOS should backup and restore the files MiniKeePass uses automatically, (MiniKeePass doesn't have to do anything special to support backups).  There have been occasional reports of KeePass files not being restored when restoring from a backup.

If you backup to iTunes, you can usually retrieve your KeePass files stored in the backup file using a tool that can open iOS backup files (iExplorer, iBackup Extractor, etc).  The file should be located in the MiniKeePass Documents folder.  Once you find the file, you can use one of the available methods for copying your KeePass files to get it back into MiniKeePass.

License
-------

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

Credits
-------
MiniKeePass
Copyright 2011 Jason Rush and John Flanagan. All rights reserved.

German Translation - Florian Holzapfel<br />
Japanese Translation - Katherine Lake<br />
Russian Translation - Foster "Forst" Snowhill<br />
Italian Translation - Emanuele Di Vita and Gabriele Cirulli<br />
Simplified Chinese Translation - Caspar Zhang and David Wong<br />
French Translation - Patrice Lachance<br />
Brazilian Portuguese Translation - BR Lingo<br />
Turkish Translation - Durul Dalkanat<br />

MiniKeePass Icon - Gabriele Cirulli

Nuvola Icons
Copyright (c) 2003-2004  David Vignoni. All rights reserved.
Released under GNU Lesser General Public License (LGPL)
http://www.gnu.org/licenses/lgpl-2.1.html

KeePass Database Library
Copyright 2010 Qiang Yu. All rights reserved.

KeePassKit DB Library
KeePassKit - Cocoa KeePass Library Copyright (c) 2012-2016 Michael Starke, HicknHack Software GmbH

References
-------
KeePassKit uses code from the following projects
Argon2 Copyright (c) 2015 Daniel Dinu, Dmitry Khovratovich (main authors), Jean-Philippe Aumasson and Samuel Neves
ChaCha20 Simple Copyright (c) 2014 insane coder (http://insanecoding.blogspot.com/, http://chacha20.insanecoding.org/)
Twofish Copyright (c) 2002 by Niels Ferguson.
KissXML Copyright (c) 2012 Robbie Hanson. All rights reserved.
MiniKeePass Copyright (c) 2011 Jason Rush and John Flanagan. All rights reserved.
KeePass Database Library Copyright (c) 2010 Qiang Yu. All rights reserved.

KeepassX Copyright (c) 2012 Felix Geyer debfx@fobos.de

NSData Gzip Category from the CocoaDev Wiki

NSData CommonCrypto Category Copyright (c) 2008-2009 Jim Dovey, All rights reserved.
