import 'package:flutter/foundation.dart';

Future<void> registerExtraLicenses() async {
  LicenseRegistry.addLicense(() => Stream<LicenseEntry>.value(
        const LicenseEntryWithLineBreaks(<String>['Vector Playing Cards 3.2'], '''\
Vector Playing Cards 3.2
https://totalnonsense.com/open-source-vector-playing-cards/
Copyright 2011,2021 – Chris Aguilar – conjurenation@gmail.com
Licensed under: LGPL 3.0 - https://www.gnu.org/licenses/lgpl-3.0.html'''),
      ));
}
