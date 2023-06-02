# Package

version       = "0.5.0"
author        = "xTrayambak and Ferus developers (originally Juan Carlos)"
description   = "Firejail wrapper for Nim, Isolate your Production App before its too late!"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.6.2"

import distros
foreignDep "firejail"
