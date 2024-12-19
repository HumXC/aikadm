gnome = import('gnome')

sources += [
    'Aikadm.vala',
    'Utils.vala',
    'Option.vala',
    'Window.vala',
]

deps = [
    dependency('gtk4-layer-shell-0'),
    dependency('gtk4'),
    dependency('astal-greet-0.1'),
    dependency('astal-io-0.1'),
    dependency('gdk-pixbuf-2.0'),
    meson.get_compiler('vala').find_library('posix'),
]
executable(
    'aikadm',
    sources,
    dependencies: deps,
    link_args: ['-lm'],
)