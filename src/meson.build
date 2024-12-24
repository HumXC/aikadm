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
    dependency('gtk4-layer-shell-0'),
    dependency('gtk4'),
    dependency('astal-greet-0.1'),
    dependency('gdk-pixbuf-2.0'),
    meson.get_compiler('vala').find_library('posix'),
]
add_project_arguments('-DGETTEXT_PACKAGE="' + meson.project_name() + '"', language: 'c')
executable(
    'aikadm',
    sources,
    dependencies: deps,
    link_args: ['-lm'],
    install: true,
)