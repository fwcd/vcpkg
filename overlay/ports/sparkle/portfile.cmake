vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sparkle-project/Sparkle
    REF "${VERSION}"
    SHA512 ad7c66a392287aa7f49329f89218dfb87d5c0f9e2c60930aa9e7132acd791cccc70dd461ebe1749e2a05c065275db3ca516e4905da178c2844ac47dd172f7dcf
    HEAD_REF 2.x
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(_xcode_arch "x86_64")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(_xcode_arch "arm64")
else()
    message(FATAL_ERROR "Unsupported target architecture ${VCPKG_TARGET_ARCHITECTURE}!" )
endif()

foreach(_buildtype IN ITEMS "debug" "release")
    if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "${_buildtype}")
        if("${_buildtype}" STREQUAL "debug")
            set(_xcode_configuration "Debug")
            set(_short_build_type "dbg")
            set(_install_destdir "${CURRENT_PACKAGES_DIR}/debug")
        else()
            set(_xcode_configuration "Release")
            set(_short_build_type "rel")
            set(_install_destdir "${CURRENT_PACKAGES_DIR}")
        endif()

        set(_builddir "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${_short_build_type}")

        message(STATUS "Building ${TARGET_TRIPLET}-${_short_build_type}")
        vcpkg_execute_build_process(
            COMMAND xcodebuild
                -scheme Distribution
                -arch ${_xcode_arch}
                -configuration "${_xcode_configuration}"
                -derivedDataPath "${_builddir}"
                build
            WORKING_DIRECTORY "${SOURCE_PATH}"
            LOGNAME "build-${TARGET_TRIPLET}-${_short_build_type}"
        )

        message(STATUS "Installing ${TARGET_TRIPLET}-${_short_build_type}")
        file(
            COPY "${_builddir}/Build/Products/${_xcode_configuration}/Sparkle.framework"
            DESTINATION "${_install_destdir}/lib"
        )
    endif()
endforeach()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
