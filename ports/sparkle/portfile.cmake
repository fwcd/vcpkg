vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sparkle-project/Sparkle
    REF "${VERSION}"
    SHA512 ad7c66a392287aa7f49329f89218dfb87d5c0f9e2c60930aa9e7132acd791cccc70dd461ebe1749e2a05c065275db3ca516e4905da178c2844ac47dd172f7dcf
    HEAD_REF 2.x
)

foreach(_buildtype IN ITEMS "debug" "release")
    if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "${_buildtype}")
        if("${_buildtype}" STREQUAL "debug")
            set(_xcode_configuration "Debug")
            set(_short_build_type "dbg")
        else()
            set(_xcode_configuration "Release")
            set(_short_build_type "rel")
        endif()

        message(STATUS "Building ${TARGET_TRIPLET}-${_short_build_type}")
        vcpkg_execute_build_process(
            COMMAND xcodebuild
                -scheme Distribution
                -configuration "${_xcode_configuration}"
                -derivedDataPath "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${_short_build_type}"
                build
            WORKING_DIRECTORY "${SOURCE_PATH}"
            LOGNAME "build-${TARGET_TRIPLET}-${_short_build_type}"
        )
    endif()
endforeach()
