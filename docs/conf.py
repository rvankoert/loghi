# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# http://www.sphinx-doc.org/en/master/config

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#
# import os
# import sys
# sys.path.insert(0, os.path.abspath('.'))

extensions = ['myst_parser']

# -- Project information -----------------------------------------------------

project = 'Loghi'
copyright = '2025, Rutger van Koert, Stefan Klut, Tim Koornstra, Luke Peters'
author = 'Rutger van Koert, Stefan Klut, Tim Koornstra, Luke Peters'

# The short X.Y version
version = '2.2.13'

# The full version, including alpha/beta/rc tags
release = '2.2.13'


# -- General configuration ---------------------------------------------------

# The suffix(es) of source filenames.
# You can specify multiple suffix as a list of string:
#
# source_suffix = ['.rst', '.md']
source_suffix = '.md'

# The master toctree document.
master_doc = 'index'

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = []


# -- Options for HTML output -------------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
#html_theme = 'alabaster'

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
# html_static_path = ['static']

html_title = "Loghi Documentation"
html_theme = "sphinx_rtd_theme"

html_theme_options = {
    'prev_next_buttons_location': 'bottom',
    'navigation_depth': 4,
}
