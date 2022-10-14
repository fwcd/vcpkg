vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Be-ing/portaudio
    REF 3364bca3c01a0aedf64ba5a5abeb8e7019717ffc
    SHA512 ce67f3e32cd55c02f4966735b39e329016a6723de3e8eedde87254df6b22a4eaa7f2fcc99729125a1baff52dea35cb4664a3dec26805fe75425a167371963aaf
    HEAD_REF jack_windows
    PATCHES
        "add-basic-support-for-ios.patch"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    asio ASIO
    jack JACK
)

if(VCPKG_TARGET_IS_IOS)
    set(OPTIONS -DPA_USE_COREAUDIO_IOS=ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${FEATURE_OPTIONS} ${OPTIONS}
    # The ASIO variable is only used on Windows.
    MAYBE_UNUSED_VARIABLES ASIO
    OPTIONS_DEBUG -DDEBUG_OUTPUT:BOOL=ON
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")
