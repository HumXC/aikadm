blueprints = custom_target(
    'compile-blueprints',
    input: files(
        'blur-canvas.blp',
        'date-time.blp',
        'input-page.blp',
        'wallpaper.blp',
        'window.blp',
    ),
    output: '.',
    command: [
        find_program('blueprint-compiler'),
        'batch-compile',
        '@OUTPUT@',
        '@CURRENT_SOURCE_DIR@',
        '@INPUT@',
    ],
)