function(find_qt_mkspec TARGET_PLATFORM_MKSPEC_OUT HOST_PLATFORM_MKSPEC_OUT EXT_HOST_TOOLS_OUT)
    ## Figure out QTs target mkspec
    if(NOT DEFINED VCPKG_QT_TARGET_MKSPEC)
        message(STATUS "Figuring out qt target mkspec. Target arch ${VCPKG_TARGET_ARCHITECTURE}") 
        if(VCPKG_TARGET_IS_WINDOWS)    
            if(VCPKG_TARGET_IS_MINGW)
                set(_tmp_targ_out "win32-g++")
            elseif(VCPKG_TARGET_IS_UWP)
                if(VCPKG_PLATFORM_TOOLSET STREQUAL "v140")
                    set(msvc_year "2015")
                elseif(VCPKG_PLATFORM_TOOLSET STREQUAL "v141")
                    set(msvc_year "2017")
                elseif(VCPKG_PLATFORM_TOOLSET STREQUAL "v142")
                    set(msvc_year "2019")
                else()
                    message(FATAL_ERROR "No target mkspec found!")
                endif()
                set(_tmp_targ_out "winrt-${VCPKG_TARGET_ARCHITECTURE}-msvc${msvc_year}")
            else()            
                if("${VCPKG_TARGET_ARCHITECTURE}" MATCHES "arm64")
                    message(STATUS "Figuring out arm64") 
                    set(_tmp_targ_out "win32-arm64-msvc2017") #mkspec does not have anything defined related to msvc2017 so this should work
                else()
                    set(_tmp_targ_out "win32-msvc")
                endif()
            endif()
        elseif(VCPKG_TARGET_IS_LINUX)
            set(_tmp_targ_out "linux-g++" )
        elseif(VCPKG_TARGET_IS_OSX)
            set(_tmp_targ_out "macx-clang") # switch to macx-g++ since vcpkg requires g++ to compile any way? 
        endif()
    else()
        set(_tmp_targ_out ${VCPKG_QT_TARGET_MKSPEC})
    endif()
    message(STATUS "Target mkspec set to: ${_tmp_targ_out}") 
    set(${TARGET_PLATFORM_MKSPEC_OUT} ${_tmp_targ_out} PARENT_SCOPE)
    
    ## Figure out QTs host mkspec
    if(NOT DEFINED VCPKG_QT_HOST_MKSPEC)
        if(VCPKG_HOST_IS_OSX)
            find_program(UNAME_EXECUTABLE uname /bin /usr/bin /usr/local/bin )
            if(UNAME_EXECUTABLE)
                exec_program(${UNAME_EXECUTABLE} ARGS -m OUTPUT_VARIABLE HOST_SYSTEM_PROCESSOR
                      RETURN_VALUE val)
                if(HOST_SYSTEM_PROCESSOR MATCHES "arm64")  
                    set(_tmp_host_out "macx-aarch64-clang") 
                endif()
            endif()           
        endif()
        #if(WIN32)
        #    set(_tmp_host_out "win32-msvc")
        #elseif("${CMAKE_HOST_SYSTEM}" STREQUAL "Linux")
        #    set(_tmp_host_out "linux-g++")
        #elseif("${CMAKE_HOST_SYSTEM}" STREQUAL "Darwin")
        #    set(_tmp_host_out "macx-clang")
        #endif()
        if(HOST_TRIPLET MATCHES "^arm64-osx")
            # When compiling on Apple Silicon (arm64 macOS) hosts we need to
            # set the host mkspec explicitly (since find_qt_mkspec won't do that
            # for us and Qt 5.12's build system will default to using Rosetta otherwise).
            set(_tmp_host_out "macx-aarch64-clang")
        endif()
        if(DEFINED _tmp_host_out)
            message(STATUS "Host mkspec set to: ${_tmp_host_out}") 
        else()
            message(STATUS "Host mkspec not set. Qt's own buildsystem will try to figure out the host system") 
        endif()
    else()
        set(_tmp_host_out ${VCPKG_QT_HOST_MKSPEC})
    endif()

    if(DEFINED _tmp_host_out)
        set(${HOST_PLATFORM_MKSPEC_OUT} ${_tmp_host_out} PARENT_SCOPE)
    endif()
    
    ## Figure out VCPKG qt-tools directory for the port. 
    if(NOT DEFINED VCPKG_QT_HOST_TOOLS_ROOT AND DEFINED VCPKG_QT_HOST_PLATFORM) ## Root dir of the required host tools 
        if(NOT "${_tmp_host_out}" MATCHES "${_tmp_host_out}")
            if(CMAKE_HOST_WIN32)
                
                if($ENV{PROCESSOR_ARCHITECTURE} MATCHES "[aA][rR][mM]64")
                    list(APPEND _test_triplets arm64-windows)
                elseif($ENV{PROCESSOR_ARCHITECTURE} MATCHES "[aA][mM][dD]64")
                    list(APPEND _test_triplets x64-windows x64-windows-static)
                    list(APPEND _test_triplets x86-windows x86-windows-static)
                elseif($ENV{PROCESSOR_ARCHITECTURE} MATCHES "x86")
                    list(APPEND _test_triplets x86-windows x86-windows-static)
                else()
                    message(FATAL_ERROR "Unknown host processor! Host Processor $ENV{PROCESSOR_ARCHITECTURE}")
                endif()
            elseif(CMAKE_HOST_SYSTEM STREQUAL "Linux")
                list(APPEND _test_triplets "x64-linux")
            elseif(CMAKE_HOST_SYSTEM STREQUAL "Darwin")
                list(APPEND _test_triplets "x64-osx")
            else()
            endif()
            foreach(_triplet ${_test_triplets})
                find_program(QMAKE_PATH qmake PATHS  ${VCPKG_INSTALLED_DIR}/${_triplet}/tools/qt5/bin NO_DEFAULT_PATHS)
                message(STATUS "Checking: ${VCPKG_INSTALLED_DIR}/${_triplet}/tools/qt5/bin. ${QMAKE_PATH}")
                if(QMAKE_PATH)
                    set(_tmp_host_root "${VCPKG_INSTALLED_DIR}/${_triplet}/tools/qt5")
                    set(_tmp_host_qmake ${QMAKE_PATH} PARENT_SCOPE)
                    message(STATUS "Qt host tools root dir within vcpkg: ${_tmp_host_root}")
                    break()
                endif()     
            endforeach()
            if(NOT DEFINED _tmp_host_root)
                message(FATAL_ERROR "Unable to locate required host tools. Please define VCPKG_QT_HOST_TOOLS_ROOT to the required root dir of the host tools") 
            endif()       
        endif()
    else()
        set(_tmp_host_root ${VCPKG_QT_HOST_TOOLS_ROOT})
    endif()
    
    if(DEFINED _tmp_host_root)
        set(${EXT_HOST_TOOLS_OUT} ${_tmp_host_root} PARENT_SCOPE)
    endif()

endfunction()
