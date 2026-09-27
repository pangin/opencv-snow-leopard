# opencv-snow-leopard

Build **OpenCV 4.6.0** (core/imgproc/imgcodecs/world) static for
**Mac OS X 10.6.8 / i386**.

```sh
./build.sh      # -> prefix/lib/libopencv_world.a (i386)
```

Key 10.6/i386 fixes:
- All SSE/AVX/IPP disabled (plain i386 baseline); bundled libjpeg/libpng.
- `opencv_fixups.py`: skip the `apple_conversions.mm`/`macosx_conversions.mm`
  imgcodecs sources (they need AVFoundation, which is 10.7+).
- Upstream `0001-OpenCV-fix.patch` + `0002-clang19-macos.patch`.
