if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "WindowsStore not supported")
endif()

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kcat/openal-soft
    REF openal-soft-1.19.0
    SHA512 59623792e560c9ef8069b7b4e4c12c67c9814433fc57d5b5650951f3adad338570ec785bbac8f7e1e7596220bab433e9f29161ced7d1a37da4f5418f6a3b7581
    HEAD_REF master
    PATCHES
        dont-export-symbols-in-static-build.patch
        cmake-3-11.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(OPENAL_LIBTYPE "SHARED")
else()
    set(OPENAL_LIBTYPE "STATIC")
endif()

if(VCPKG_CMAKE_SYSTEM_NAME)
    set(ALSOFT_REQUIRE_WINDOWS OFF)
    set(ALSOFT_REQUIRE_LINUX ON)
else()
    set(ALSOFT_REQUIRE_WINDOWS ON)
    set(ALSOFT_REQUIRE_LINUX OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DLIBTYPE=${OPENAL_LIBTYPE}
        -DALSOFT_UTILS=OFF
        -DALSOFT_NO_CONFIG_UTIL=ON
        -DALSOFT_EXAMPLES=OFF
        -DALSOFT_TESTS=OFF
        -DALSOFT_CONFIG=OFF
        -DALSOFT_HRTF_DEFS=OFF
        -DALSOFT_AMBDEC_PRESETS=OFF
        -DALSOFT_BACKEND_ALSA=${ALSOFT_REQUIRE_LINUX}
        -DALSOFT_BACKEND_OSS=OFF
        -DALSOFT_BACKEND_SOLARIS=OFF
        -DALSOFT_BACKEND_SNDIO=OFF
        -DALSOFT_BACKEND_QSA=OFF
        -DALSOFT_BACKEND_PORTAUDIO=OFF
        -DALSOFT_BACKEND_PULSEAUDIO=OFF
        -DALSOFT_BACKEND_COREAUDIO=OFF
        -DALSOFT_BACKEND_JACK=OFF
        -DALSOFT_BACKEND_OPENSL=OFF
        -DALSOFT_BACKEND_WAVE=ON
        -DALSOFT_REQUIRE_WINMM=${ALSOFT_REQUIRE_WINDOWS}
        -DALSOFT_REQUIRE_DSOUND=${ALSOFT_REQUIRE_WINDOWS}
        -DALSOFT_REQUIRE_MMDEVAPI=${ALSOFT_REQUIRE_WINDOWS}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/OpenAL TARGET_PATH share/openal)

foreach(HEADER al.h alc.h)
    file(READ ${CURRENT_PACKAGES_DIR}/include/AL/${HEADER} AL_H)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        string(REPLACE "defined(AL_LIBTYPE_STATIC)" "1" AL_H "${AL_H}")
    else()
        string(REPLACE "defined(AL_LIBTYPE_STATIC)" "0" AL_H "${AL_H}")
    endif()
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/AL/${HEADER} "${AL_H}")
endforeach()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/openal-soft)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/openal-soft/COPYING ${CURRENT_PACKAGES_DIR}/share/openal-soft/copyright)
vcpkg_copy_pdbs()
