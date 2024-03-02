set(VCPKG_ENV_PASSTHROUGH_UNTRACKED EMSCRIPTEN_ROOT EMSDK PATH)

if(NOT DEFINED ENV{EMSCRIPTEN_ROOT})
   # Try locating the emscripten SDK root relative to the (resolved) emcc binary

   find_program(EMCC_PATH "emcc")
   get_filename_component(EMCC_REALPATH "${EMCC_PATH}" REALPATH)
   get_filename_component(EMCC_DIRECTORY "${EMCC_REALPATH}" DIRECTORY)

   set(EMSCRIPTEN_ROOT_RELATIVE_PATHS
      .          # Linux
      ../libexec # macOS/Homebrew
   )

   foreach(RELATIVE_PATH ${EMSCRIPTEN_ROOT_RELATIVE_PATHS})
      get_filename_component(CANDIDATE "${EMCC_DIRECTORY}/${RELATIVE_PATH}" REALPATH)
      if(EXISTS "${CANDIDATE}/cmake" AND IS_DIRECTORY "${CANDIDATE}/cmake")
         set(EMSCRIPTEN_ROOT "${CANDIDATE}")
         break()
      endif()
   endforeach()
else()
   set(EMSCRIPTEN_ROOT "$ENV{EMSCRIPTEN_ROOT}")
endif()

if(NOT EMSCRIPTEN_ROOT)
   if(NOT DEFINED ENV{EMSDK})
      message(FATAL_ERROR "The emcc compiler not found in PATH")
   endif()
   set(EMSCRIPTEN_ROOT "$ENV{EMSDK}/upstream/emscripten")
endif()

if(NOT EXISTS "${EMSCRIPTEN_ROOT}/cmake/Modules/Platform/Emscripten.cmake")
   message(FATAL_ERROR "Emscripten.cmake toolchain file not found")
endif()

set(VCPKG_TARGET_ARCHITECTURE wasm32)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_CMAKE_SYSTEM_NAME Emscripten)
set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${EMSCRIPTEN_ROOT}/cmake/Modules/Platform/Emscripten.cmake")

set(VCPKG_BUILD_TYPE release)
