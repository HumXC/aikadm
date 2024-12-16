subdir('ui')
subdir('scss')
gnome = import('gnome')
sources = [
    'C.vala',
    'Aikadm.vala',
    'Utils.vala',
    'Option.vala',
]

sources += gnome.compile_resources(
    meson.project_name(),
    'aikadm.gresource.xml',
    dependencies: [blueprints, scss],
    source_dir: meson.current_build_dir(),
)
deps = [
    dependency('gtk4-layer-shell-0'),
    dependency('gtk4'),
    dependency('astal-greet-0.1'),
    dependency('astal-io-0.1'),
    dependency('gdk-pixbuf-2.0'),
]
executable(
    'aikadm',
    sources,
    dependencies: deps,
    link_args: ['-lm'],
)