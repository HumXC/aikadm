sources += [
    'aikadm.vala',
    'common.vala',
    'option.vala',
    'window.vala',
    'date-time.vala',
    'ensure-types.vala',
    'wallpaper.vala',
    'blur-canvas.vala',
    'input-page.vala',
]

deps = [
    dependency('gtk4'),
    dependency('gtk4-layer-shell-0'),
    dependency('astal-greet-0.1'),
    meson.get_compiler('vala').find_library('posix'),
]
executable(
    'aikadm',
    sources,
    dependencies: deps,
    link_args: ['-lm'],
    install: true,
)