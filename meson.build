project(
  'aikadm',
  ['c', 'vala'],
  version: '0.1.0',
  meson_version: '>= 1.0.0',
  default_options: [
    'warning_level=2',
    'werror=false',
  ],
)
deps = [
  dependency('gtk4'),
]
sources = [
  'src/Aikadm.vala',
]

executable(
  'aikadm',
  sources,
  dependencies: deps,
)