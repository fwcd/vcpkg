# Workaround for iOS sdkroot, see https://github.com/microsoft/vcpkg/issues/25334

function(ios_set_sdkroot)
    if(VCPKG_TARGET_IS_IOS)
        vcpkg_backup_env_variables(VARS SDKROOT)
        execute_process(
            COMMAND xcrun --sdk iphoneos --show-sdk-path
            OUTPUT_VARIABLE NEW_SDKROOT
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        set(ENV{SDKROOT} "${NEW_SDKROOT}")
    endif() 
endfunction()

function(ios_restore_sdkroot)
    if(VCPKG_TARGET_IS_IOS)
        vcpkg_restore_env_variables(VARS SDKROOT)
    endif() 
endfunction()
