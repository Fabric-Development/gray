libgray_dep = [
  dependency('gee-0.8'),
  dependency('gtk4'),
]

source_files = files(
  'libgray.vala'
)

introspection_version = '0.1'
introspection_name = 'Gray' + '-' + introspection_version
pkgconfig = import('pkgconfig')
g_ir_compiler = find_program('g-ir-compiler')

libgray = shared_library(
  'gray',
  source_files,
  vala_vapi: introspection_name + '.vapi',
  vala_gir: introspection_name + '.gir',
  vala_header: 'libgray.h',
  dependencies: libgray_dep,
  install: true,
  install_dir: [true, true, true, true],
)

custom_target(
  'gray typelib',
  depends: libgray,
  output: introspection_name + '.typelib',
  command: [
    g_ir_compiler,
    '--shared-library', get_option('prefix') / get_option('libdir') / 'libgray',
    '--output', '@OUTPUT@',
    join_paths(meson.current_build_dir(), introspection_name + '.gir')
  ],
  install: true,
  install_dir: get_option('libdir') / 'girepository-1.0'
)

pkgconfig.generate(
    libgray,
    requires: libgray_dep,
    description: 'a simple utility to manage and create system trays',
    version: meson.project_version(),
    url: 'https://github.com/Fabric-Development/gray',
)

declare_dependency(
    link_with: libgray,
    dependencies: libgray_dep,
)
