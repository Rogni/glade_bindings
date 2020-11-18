
src = [
    'glade/builder_bindings.d',
    'glade/package.d'
]


glade_lib = library(
    'glade_bindings', src
    , dependencies: [glib, gtkdep]
    , include_directories: ['.']
    , install: true
    )

glade_dep = declare_dependency(
        link_with: glade_lib
        , dependencies: [glib, gtkdep]
        , include_directories: ['.']
    )
