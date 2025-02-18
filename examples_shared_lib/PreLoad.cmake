if(NOT DEFINED CMAKE_BUILD_TYPE)
	set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Build type")
endif()

if(WIN32)
	set(CMAKE_GENERATOR "MinGW Makefiles" CACHE STRING "Default to MinGW cross compilation")
	if(NOT DEFINED CMAKE_INSTALL_PREFIX)
		set(CMAKE_INSTALL_PREFIX "$ENV{LOCALAPPDATA}/xournalpp/plugins" CACHE PATH "Default user Xournal++ plugins directory on Windows")
		if(NOT DEFINED CMAKE_INSTALL_PREFIX_ICONS)
			set(CMAKE_INSTALL_PREFIX_ICONS "$ENV{LOCALAPPDATA}/icons" CACHE PATH "Default user GTK icons directory on Windows")
		endif()
	endif()
else()
	if(NOT DEFINED CMAKE_INSTALL_PREFIX)
		set(CMAKE_INSTALL_PREFIX "$ENV{HOME}/.config/xournalpp/plugins" CACHE PATH "Default user Xournal++ plugins directory on Linux")
		if(NOT DEFINED CMAKE_INSTALL_PREFIX_ICONS)
			set(CMAKE_INSTALL_PREFIX_ICONS "$ENV{HOME}/.local/share/icons" CACHE PATH "Default user GTK icons directory on Linux")
		endif()
	endif()
endif()

message(STATUS "CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")
message(STATUS "CMAKE_INSTALL_PREFIX: ${CMAKE_INSTALL_PREFIX}")
message(STATUS "CMAKE_INSTALL_PREFIX_ICONS: ${CMAKE_INSTALL_PREFIX_ICONS}")
