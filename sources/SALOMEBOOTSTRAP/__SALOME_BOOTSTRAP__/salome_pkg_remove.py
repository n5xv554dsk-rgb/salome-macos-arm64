#!/usr/bin/env python3

import argparse
import os, sys, shutil


from SalomeOnDemandTK.extension_utilities import get_logger, EXT_DFT_STORE_ZONE

# get salome_appli_dir
try:
    salome_appli_dir = os.environ["SALOME_APPLICATION_DIR"]
except:
    salome_bootstrap_dir = os.path.dirname(os.path.realpath(__file__))
    salome_appli_dir = os.path.dirname(salome_bootstrap_dir)

ext_pkg_dir = os.path.join(salome_appli_dir, EXT_DFT_STORE_ZONE)

#extname, force, only
def remove(args):
    """ Remove extension module from salome_appli_dir
    extname: extension module name
    """
    extname = args.extension_name
    force = args.force
    only = args.only

    get_logger().info("Remove %s"%extname)
    from SalomeOnDemandTK.extension_remover import remove_salomex, AtRemoveAskerForce
    remove_comp = not only
    removed_list = remove_salomex(salome_appli_dir, extname, AtRemoveAskerForce(remove_comp), force)
    get_logger().info(f"Removed extensions list: {removed_list}")

def add_arguments(parser):
    parser.add_argument('-e', '--extension-name',default = argparse.SUPPRESS, required = True, help = 'extension package name')
    parser.add_argument('-f', '--force', action='store_true',default = False)
    parser.add_argument('-o', '--only', action='store_true',default = False, help = 'remove only main component')
    parser.set_defaults(func=remove)

if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    add_arguments(parser)
    args = parser.parse_args()
    args.func(args)
