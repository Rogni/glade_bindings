
asresources = gnome.compile_resources(
    'ui_resources', 'ui.gresource.xml',
    source_dir: 'resources',
    c_name: 'ui_resources'
)


src = [
    'main.d',
    asresources
]



executable(
    'bind_glade_example', src
    , dependencies: [glib, gtkdep, glade_dep]
    , include_directories: ['.']
    )


