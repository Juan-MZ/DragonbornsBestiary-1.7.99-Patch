# This file configures the "build" of this SKSE plugin
# - how to compile the C++ plugin (in addition to settings found in CMakePresets.json)
# - where to output the resulting .dll file

# It's recommended to set a minimum CMake version.
# If you use CMake features from higher versions, update this to match.
cmake_minimum_required(VERSION 3.21)

# [BEGIN set_project_name]
# Set your project name. This will be the name of your SKSE .dll file.
project(DragonbornsBestiary VERSION 1.4.0 LANGUAGES CXX)

# [END set_project_name]

# #
# YOU DO NOT NEED TO EDIT ANYTHING BELOW HERE
# #

# If you're not using a mod manager, you probably want the SKSE plugin to go
# inside of your Skyrim "Data" folder.
#
# To do this automatically, set the `SKYRIM_FOLDER` environment variable
# to the path of your Skyrim Special Edition folder
if(DEFINED ENV{SKYRIM_FOLDER} AND IS_DIRECTORY "$ENV{SKYRIM_FOLDER}/Data")
    set(OUTPUT_FOLDER "$ENV{SKYRIM_FOLDER}/Data")
endif()

# If you're using Mod Organizer 2 or Vortex, you might want this to go inside
# of your "mods" folder, inside of a subfolder named "<your mod>".
#
# To do this automatically, set the `SKYRIM_MODS_FOLDER` environment variable
# to the path of your "mods" folder
if(DEFINED ENV{SKYRIM_MODS_FOLDER} AND IS_DIRECTORY "$ENV{SKYRIM_MODS_FOLDER}")
    set(OUTPUT_FOLDER "$ENV{SKYRIM_MODS_FOLDER}/${PROJECT_NAME}")
endif()

# Otherwise, you can set OUTPUT_FOLDER to any place you'd like :)
# set(OUTPUT_FOLDER "C:/path/to/any/folder")

# Setup your SKSE plugin as an SKSE plugin!
# CommonLibSSE-NG 6.7.0, built from source.
# The vcpkg port in the colorglass registry is stuck at 3.7.0, which predates both
# Skyrim 1.7.99 and Address Library format 5 - hence the original error:
#   REL/Relocation.h(1104): failed to open address library file
set(ENABLE_SKYRIM_VR OFF)
set(BUILD_TESTS OFF)
add_subdirectory(external/CommonLibNG CommonLibNG EXCLUDE_FROM_ALL)
# The add_commonlibsse_plugin() helper is only auto-included on CommonLib's prebuilt
# path, so pull it in explicitly for the source build.
include("${CMAKE_CURRENT_SOURCE_DIR}/external/CommonLibNG/cmake/CommonLibSSE.cmake")
add_commonlibsse_plugin(${PROJECT_NAME} SOURCES src/main.cpp
    src/EventProcessor.cpp
    src/Serialization.cpp
    src/Utility.cpp
    src/BestiaryMenu.cpp
    src/HUDWidget.cpp
    src/Sync.cpp
    src/PapyrusFunctions.cpp) # <--- specifies plugin.cpp
target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_23) # <--- use C++23 standard
target_precompile_headers(${PROJECT_NAME} PRIVATE src/PCH.h) # <--- PCH.h is required!

# SimpleIni.h pulls in <windows.h>, whose macros break two things here:
#   - the `max` macro breaks std::numeric_limits<size_t>::max()  -> NOMINMAX
#   - the `PlaySound` macro (from mmsystem.h) rewrites RE::PlaySound into
#     RE::PlaySoundA, which does not exist                        -> WIN32_LEAN_AND_MEAN
#       (WIN32_LEAN_AND_MEAN keeps windows.h from including mmsystem.h at all)
target_compile_definitions(${PROJECT_NAME} PRIVATE NOMINMAX WIN32_LEAN_AND_MEAN)

# add_commonlibsse_plugin() generates a SKSEPluginInfo() declaration whose
# StructCompatibility field lands on versionIndependenceEx, so it can only ever write
# 0 or 1 - it cannot set kVersionIndependentEx_AddressLibraryV5 (bit 1). CommonLib only
# sets that flag on the manual PluginVersionData path. Drop the generated file and
# declare the plugin in main.cpp instead, so the DLL correctly advertises that it can
# read Address Library format 5.
get_target_property(_bestiary_sources ${PROJECT_NAME} SOURCES)
list(REMOVE_ITEM _bestiary_sources "${CMAKE_CURRENT_BINARY_DIR}/__${PROJECT_NAME}Plugin.cpp")
set_target_properties(${PROJECT_NAME} PROPERTIES SOURCES "${_bestiary_sources}")

# When your SKSE .dll is compiled, this will automatically copy the .dll into your mods folder.
# Only works if you configure DEPLOY_ROOT above (or set the SKYRIM_MODS_FOLDER environment variable)
if(DEFINED OUTPUT_FOLDER)
    # If you specify an <OUTPUT_FOLDER> (including via environment variables)
    # then we'll copy your mod files into Skyrim or a mod manager for you!

    # Copy the SKSE plugin .dll files into the SKSE/Plugins/ folder
    set(DLL_FOLDER "${OUTPUT_FOLDER}/SKSE/Plugins")

    message(STATUS "SKSE plugin output folder: ${DLL_FOLDER}")

    add_custom_command(
        TARGET "${PROJECT_NAME}"
        POST_BUILD
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${DLL_FOLDER}"
        COMMAND "${CMAKE_COMMAND}" -E copy_if_different "$<TARGET_FILE:${PROJECT_NAME}>" "${DLL_FOLDER}/$<TARGET_FILE_NAME:${PROJECT_NAME}>"
        VERBATIM
    )

    # If you perform a "Debug" build, also copy .pdb file (for debug symbols)
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        add_custom_command(
            TARGET "${PROJECT_NAME}"
            POST_BUILD
            COMMAND "${CMAKE_COMMAND}" -E copy_if_different "$<TARGET_PDB_FILE:${PROJECT_NAME}>" "${DLL_FOLDER}/$<TARGET_PDB_FILE_NAME:${PROJECT_NAME}>"
            VERBATIM
        )
    endif()
endif()
