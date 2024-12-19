sass = find_program('sass')

scss_deps = files( )

scss = custom_target(
    'generate-css',
    input: 'main.scss',
    output: 'style.css',
    command: [
        sass,
        '@INPUT@',
        '@OUTPUT@',
    ],
    depend_files: scss_deps,
)