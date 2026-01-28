cmake_minimum_required(VERSION 3.16)

project(QMLChart VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Charts Core Gui Qml Quick)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(QMLChart
    main.cpp
    backend.h backend.cpp
)

# ✅ استفاده از qt6_add_resources بجای qt_add_qml_module
qt6_add_resources(QMLChart "qmlchartsgallery"
    PREFIX "/"
    FILES
        Main.qml
        CButton.qml
)

set_target_properties(QMLChart PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(QMLChart PRIVATE
    Qt6::Charts
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
)

if(ANDROID)
    set_target_properties(QMLChart PROPERTIES
        QT_ANDROID_PACKAGE_SOURCE_DIR
            ${CMAKE_CURRENT_SOURCE_DIR}/android
    )
endif()

include(GNUInstallDirs)
install(TARGETS QMLChart
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
