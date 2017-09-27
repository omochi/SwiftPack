# SwiftPack

SwiftPack is a tool for support embedding swift library into your project by source form directly.
It convert visibility of declaration such like `class`, `struct` .

# Example

You need to specify newer swift snapshot which supports `-emit-syntax`.

```bash
$ export TOOLCHAINS=org.swift.3020170918a
$ swift run swift-pack unify Resources/example2
```

