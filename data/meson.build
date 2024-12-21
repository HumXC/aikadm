subdir('ui')
subdir('scss')

sources += gnome.compile_resources(
    meson.project_name(),
    'aikadm.gresource.xml',
    dependencies: [blueprints, scss],
    source_dir: meson.current_build_dir(),
)