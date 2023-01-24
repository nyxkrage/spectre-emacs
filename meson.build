project('emacs-spectre-module', 'c',
  version : '1.0.0',
  license : 'GPL-3')

spectre_dep = dependency('spectre')

spectre_module_sources = [
  'spectre-module.c'
]

libspectre = library('spectre-module', spectre_module_sources, dependencies : spectre_dep, install : true, name_prefix : '')
