cmake_minimum_required(VERSION 3.18)

project(autogest LANGUAGES C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

add_library(
    autogest
    SHARED
    src/inputs.c
    src/validacao.c
    src/calculos.c
    src/alertas.c
)

target_include_directories(
    autogest
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

if(WIN32)
    set_target_properties(
        autogest
        PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON
    )
endif()


if(NOT ANDROID)
    enable_testing()

    add_executable(
        autogest_tests
        Test/test_autogest.c
    )

    target_link_libraries(
        autogest_tests
        PRIVATE autogest
    )

    add_test(
        NAME autogest_tests
        COMMAND autogest_tests
    )
endif()