#!/bin/bash
# Build OpenCV 4.6.0 (static, no SIMD) for i386/10.6.
# libslic3r REQUIREs opencv_world (texture->color: kmeans/imdecode/cvtColor).
# Only core,imgproc,imgcodecs,world; all SSE/AVX/IPP off for a plain i386.
. "$(dirname "$0")/common.sh"
VER=4.6.0
URL="https://github.com/opencv/opencv/archive/refs/tags/${VER}.tar.gz"
SRCDIR="$DEPS_BUILD/opencv-${VER}"
mkdir -p "$DEPS_BUILD" "$DEPS_PREFIX"
if [ ! -d "$SRCDIR" ]; then
  cd "$DEPS_BUILD"
  [ -f "opencv-${VER}.tar.gz" ] || curl -fL -o "opencv-${VER}.tar.gz" "$URL"
  tar xzf "opencv-${VER}.tar.gz"
fi
if [ ! -f "$SRCDIR/.sl_patched" ]; then
  ( cd "$SRCDIR" && git apply --ignore-space-change --whitespace=fix \
      "$ROOT/0001-OpenCV-fix.patch" \
      "$ROOT/0002-clang19-macos.patch" ) \
    && touch "$SRCDIR/.sl_patched" || { echo "ERROR: OpenCV patch failed"; exit 1; }
fi
# clang-16 / i386 source fixups (idempotent)
/usr/bin/python "$ROOT/opencv_fixups.py" "$SRCDIR"
cmake -S "$SRCDIR" -B "$DEPS_BUILD/opencv-build" \
  -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$DEPS_PREFIX" \
  -DCMAKE_PREFIX_PATH="$DEPS_PREFIX;$MP" \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  -DBUILD_SHARED_LIBS=OFF \
  -DBUILD_LIST=core,imgcodecs,imgproc,world -DBUILD_opencv_world=ON \
  -DENABLE_SSE=OFF -DENABLE_SSE2=OFF -DENABLE_SSE3=OFF -DENABLE_SSE4_1=OFF -DENABLE_AVX=OFF \
  -DWITH_CPU_BASELINE=OFF -DWITH_CPU_DISPATCH=OFF -DWITH_IPP=OFF -DWITH_ITT=OFF \
  -DBUILD_ZLIB=OFF -DBUILD_PNG=ON -DBUILD_JPEG=ON -DWITH_PNG=ON -DWITH_JPEG=ON \
  -DWITH_TIFF=OFF -DWITH_WEBP=OFF -DWITH_OPENEXR=OFF -DWITH_OPENJPEG=OFF -DWITH_JASPER=OFF \
  -DBUILD_opencv_highgui=OFF -DWITH_GTK=OFF -DWITH_GTK_2_X=OFF -DHAVE_WIN32UI=FALSE \
  -DWITH_FFMPEG=OFF -DWITH_GSTREAMER=OFF -DWITH_V4L=OFF -DWITH_1394=OFF \
  -DWITH_CUDA=OFF -DWITH_OPENCL=OFF -DWITH_EIGEN=OFF -DWITH_LAPACK=OFF \
  -DWITH_PROTOBUF=OFF -DWITH_QUIRC=OFF -DWITH_ADE=OFF -DWITH_VTK=OFF \
  -DBUILD_JAVA=OFF -DBUILD_opencv_python2=OFF -DBUILD_opencv_python3=OFF \
  -DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_EXAMPLES=OFF \
  -DENABLE_PRECOMPILED_HEADERS=OFF
set +e
cmake --build "$DEPS_BUILD/opencv-build" -j2 && cmake --install "$DEPS_BUILD/opencv-build"
rc=$?; set -e
echo "OPENCV-DONE rc=$rc"
[ $rc -eq 0 ] && ls "$DEPS_PREFIX"/lib/libopencv_world*.a "$DEPS_PREFIX"/lib/opencv4/3rdparty/*.a 2>/dev/null
