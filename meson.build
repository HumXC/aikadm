project(
  'aikadm',
  ['vala', 'c'],
  version: '0.1.0',
  meson_version: '>= 1.0.0',
  default_options: [
    'warning_level=2',
    'werror=false',
  ],
  default_options: ['buildtype=debug'],
)
gnome = import('gnome')

sources = []
subdir('data')
subdir('src')