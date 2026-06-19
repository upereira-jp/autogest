add_library(
    autogest
    SHARED
    src/banco.c
    src/dados.c
    src/validacao.c
    src/calculos.c
    src/alertas.c
    vendor/sqlite3.c
)

target_include_directories(
    autogest
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/vendor
)
