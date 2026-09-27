#!/usr/bin/env python
# Idempotent OpenCV 4.6.0 source fixups for i386 / macOS 10.6, applied after the
# upstream deps/OpenCV patches. Add entries here as errors surface.
# Usage: /usr/bin/python opencv_fixups.py <OpenCV source root>
import sys, os

root = sys.argv[1]

def sub(rel, old, new):
    p = os.path.join(root, rel)
    try:
        s = open(p).read()
    except IOError:
        return "MISS %s (file not found)" % rel
    if new in s:
        return "skip %s" % rel
    if old not in s:
        return "MISS %s (pattern not found)" % rel
    open(p, "w").write(s.replace(old, new, 1))
    return "fix  %s" % rel

# imgcodecs unconditionally compiles apple_conversions.mm / macosx_conversions.mm
# on APPLE; these need AVFoundation (10.7+) / AppKit paths absent on 10.6. Nothing
# else references them, and bundled libpng/libjpeg cover imdecode, so skip them.
print(sub("modules/imgcodecs/CMakeLists.txt",
          "if(APPLE OR APPLE_FRAMEWORK)", "if(FALSE) # SL 10.6: no AVFoundation"))
print(sub("modules/imgcodecs/CMakeLists.txt",
          "if(APPLE AND (NOT IOS))", "if(FALSE) # SL 10.6: no AppKit imgcodecs"))
