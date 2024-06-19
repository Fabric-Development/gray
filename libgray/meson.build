dependencies = [
  dependency('gobject-2.0'),
  dependency('glib-2.0'),
  dependency('gtk+-3.0'),
]

all_dependencies = dependencies + [
  dependency('dbusmenu-gtk3-0.4'),
  dependency('dbusmenu-glib-0.4'),
]

source_files = files(
  'libgray.vala'
)

introspection_version = '0.1'
introspection_name = 'Gray' + '-' + introspection_version
pkgconfig = import('pkgconfig')
g_ir_compiler = find_program('g-ir-compiler')

# fix libdbusmenu's compile error
dbusmenu_cflags = run_command(
  find_program('pkg-config', required: true),
  '--cflags',
  'dbusmenu-gtk3-0.4',
  'gobject-introspection-1.0',
  'gobject-2.0', 'glib-2.0',
  capture: true,
  check: true,
).stdout().strip()

dbusmenu_libs = run_command(
  find_program('pkg-config', required: true),
  '--libs',
  'dbusmenu-gtk3-0.4',
  'gobject-introspection-1.0',
  'gobject-2.0', 'glib-2.0',
  capture: true,
  check: true,
).stdout().strip()

libgray = shared_library(
  'gray',
  source_files,
  vala_vapi: introspection_name + '.vapi',
  vala_gir: introspection_name + '.gir',
  vala_header: 'libgray.h',
  dependencies: dependencies,
  vala_args: ['--pkg', 'DbusmenuGtk3-0.4', '--pkg', 'Dbusmenu-0.4'],
  c_args: dbusmenu_cflags.split(' '),
  link_args: dbusmenu_libs.split(' '),
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
    requires: all_dependencies,
    description: 'a simple utility to manage and create system trays',
    version: meson.project_version(),
    url: 'https://github.com/Fabric-Development/gray',
)

declare_dependency(
    link_with: libgray,
    dependencies: dependencies,
)
