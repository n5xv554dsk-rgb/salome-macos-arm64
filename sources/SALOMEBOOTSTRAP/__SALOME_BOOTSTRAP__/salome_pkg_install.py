#!/usr/bin/env python3

import argparse
import os, sys, shutil

from pathlib import Path

from SalomeOnDemandTK.extension_utilities import get_logger, EXT_DFT_STORE_ZONE, get_app_root

def install(args):
    """ Install extension module in salome_appli_dir
    extname: extension module name
    """
    # get défault salome_appli_dir with extension_utilities.get_app_root(level_up = 3).
    # levels_up is steps up in dir hierarchy relative to the extension_utilities.py file.
    salome_appli_dir = get_app_root(3)
    if args.install_dir is not None and Path(args.install_dir).is_dir():
        salome_appli_dir = args.install_dir
    ext_file_path = args.file_path
    force = args.force
    ext_pkg_name = os.path.basename(ext_file_path)

    if not os.path.isfile(ext_file_path):
        get_logger().error( "Extension package {} does not exist.\nPlease be sure that you have this package in {}"
        .format(ext_pkg_name, ext_file_path) )
        return 1

    # Unpack the new extension
    get_logger().info("Install %s"%ext_pkg_name)
    os.environ["SALOME_APPLICATION_DIR"] = salome_appli_dir
    import SalomeOnDemandTK.extension_unpacker as extension_unpacker
    extension_unpacker.install_salomex(ext_file_path, force)

def add_arguments(parser):
    parser.add_argument('-p', '--file-path', required = True, help = 'extension package file path')
    parser.add_argument('-d', '--install-dir', default = None, help = 'salome install directory')
    parser.add_argument('-f', '--force', action='store_true',default = False)
    parser.set_defaults(func=install)

if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    add_arguments(parser)
    args = parser.parse_args()
    args.func(args)
