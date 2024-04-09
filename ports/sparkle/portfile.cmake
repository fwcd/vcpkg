vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sparkle-project/Sparkle
    REF "${VERSION}"
    SHA512 ad7c66a392287aa7f49329f89218dfb87d5c0f9e2c60930aa9e7132acd791cccc70dd461ebe1749e2a05c065275db3ca516e4905da178c2844ac47dd172f7dcf
    HEAD_REF 2.x
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    COPY_SOURCE
    SKIP_CONFIGURE
)

vcpkg_build_make()
