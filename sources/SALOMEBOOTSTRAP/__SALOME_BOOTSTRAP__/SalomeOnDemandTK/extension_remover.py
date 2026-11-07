#!/usr/bin/env python3
# -*- coding:utf-8 -*-
# Copyright (C) 2007-2026  CEA, EDF, OPEN CASCADE
#
# Copyright (C) 2003-2007  OPEN CASCADE, EADS/CCR, LIP6, CEA/DEN,
# CEDRAT, EDF R&D, LEG, PRINCIPIA R&D, BUREAU VERITAS
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
#
# See https://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
#

#  File   : extension_remover.py
#  Author : Konstantin Leontev, Open Cascade
#
#  @package SalomeOnDemandTK
#  @brief Set of utility to remove SALOME python extensions.

"""Set of utility to remove SALOME python extensions.
"""

import os
import sys
import shutil
from traceback import format_exc
import abc

from .extension_utilities import get_logger, \
    SALOME_EXTDIR, EXTISGUI_KEY, EXTSMOGULENAME_KEY, EXTNAME_KEY, \
    isvalid_dirname, list_dependants, list_dep_tobe_removed, is_empty_dir, \
    find_envpy, value_from_salomexd, check_if_installed, get_module_name, find_postinstall

class AtRemoveAskerAbstract:
    @abc.abstractmethod
    def askFor(self, extToAsk : str ):
        raise RuntimeError("Not implemented")

class AtRemoveAskerForce( AtRemoveAskerAbstract ):
    def __init__(self, ok):
        self._ok = ok

    def askFor(self, extToAsk : str ):
        return self._ok

def remove_if_empty(top_dir, directory):
    """
    Recursively remove empty directories from the given one to the top.

    Args:
        top_dir - top parent directory that can be removed as well
        directory - the given directory

    Returns:
        None.
    """

    #get_logger().debug('Check if %s is empty...', directory)
    if not is_empty_dir(directory):
        return

    get_logger().debug('Directory %s is empty. Remove it.', directory)
    os.rmdir(directory)

    # Don't go up than top root
    if top_dir == directory:
        return

    # Remove the parent dir as well
    parent_dir = os.path.abspath(os.path.join(directory, os.pardir))
    remove_if_empty(top_dir, parent_dir)


def remove_bylist(root_dir, salomexc):
    """
    Remove files and directories listed in the given salomexc file.

    Args:
        root_dir - a root dir for listed files
        salomexc - file that contents a list of files to remove.

    Returns:
        True if all the files were deleted without critical errors.
    """

    get_logger().debug('Remove files from %s dir listed in %s...',
        root_dir, salomexc)

    try:
        with open(salomexc, 'r', encoding='UTF-8') as file:
            for line in file:
                path_to_remove = os.path.join(root_dir, line.strip())
                get_logger().debug('Remove file %s...', path_to_remove)

                if os.path.isfile(path_to_remove):
                    os.remove(path_to_remove)

                    # Remove the parent folder if empty
                    parent_dir = os.path.dirname(path_to_remove)
                    remove_if_empty(root_dir, parent_dir)

                elif os.path.islink(path_to_remove):
                    os.unlink(path_to_remove)

                    # Remove the parent folder if empty
                    parent_dir = os.path.dirname(path_to_remove)
                    remove_if_empty(root_dir, parent_dir)

                elif os.path.isdir(path_to_remove):
                    get_logger().warning('Directories are not expected to be listed in %s file! '
                        'Remove %s anyway.',
                        salomexc, path_to_remove)
                    # Use instead of rmdir here, because dir can be not empty
                    shutil.rmtree(path_to_remove)

                else:
                    get_logger().warning('Unexpected path %s!'
                        'It is not a file or directory. Skip.',
                        path_to_remove)

    except OSError:
        get_logger().error(format_exc())
        return False

    return True

def remove_salomex(install_dir, salomex_name, ara : AtRemoveAskerAbstract = AtRemoveAskerForce(True) , force = False):
    """
    Remove a salome extension from SALOME install root.

    Args:
        salome_root - path to SALOME install root directory.
        salomex_name - a name of salome extension to remove.

    Returns:
        List of deleted extensions or None if the functions fails.
    """

    get_logger().debug('Starting remove a salome extension %s', salomex_name)

    # Check if provided dirname is valid
    if not isvalid_dirname(install_dir):
        return None

    # Check if the given extension is installed
    salomexd, salomexc = check_if_installed(install_dir, salomex_name)
    if not salomexc:
        get_logger().debug('Going to exit from extension removing process.')
        return None

    # Check if we cannot remove an extension because of dependencies
    dependants = list_dependants(install_dir, salomex_name)
    if len(dependants) > 0:
        if not force:
            get_logger().error( f'Cannot remove an extension {salomex_name} because followed extensions depend on it: {dependants} ! Going to exit from extension removing process.')
            return None
        else:
            get_logger().debug( f'Forcibly removing this extension {salomex_name} may break the following dependent applications: {dependants} !' )

    # Get extensions to be removed with this extension:
    # This extensions list must be get before delete all configuration files this extension,
    # But these extensions in this list must be removed after this extension to avoid the non-stop recursive loop of delete
    # REMARK: This function remove_salomex is recursive
    #         so the list of extensions to be removed is not retrieved recursively
    #         to avoid duplicate removed warning message
    exts_tobe_removed_list = list_dep_tobe_removed(install_dir, salomex_name, False)

    try:
        remove_comp = exts_tobe_removed_list and ara.askFor( exts_tobe_removed_list )
    except:
        return None

    # Try to remove all the files listed in the control file
    if not remove_bylist(os.path.join(install_dir, SALOME_EXTDIR), salomexc):
        get_logger().error("Cannot remove all files listed in the control file")
        return None

    # Remove control file
    os.remove(salomexc)

    # Remove env file
    env_py = find_envpy(install_dir, salomex_name)
    if env_py:
        os.remove(env_py)
    else:
        get_logger().warning('Cannot find and remove %s file! ', env_py)

    # Remove post_install script
    post_install_file = find_postinstall(install_dir, salomex_name)
    if post_install_file:
        os.remove(post_install_file)

    # Remove description file
    module_name = ""
    if salomexd:
        # Get salomemodule_name to deactivate in UI if the case
        module_name = get_module_name(install_dir, salomex_name)
        os.remove(salomexd)
    else:
        get_logger().warning('Cannot find and remove %s file! ', salomexd)
    if not module_name:
        module_name = salomex_name
    module_removed_list = [module_name]

    # Remove depends_on_removed
    if remove_comp:
        for comp in exts_tobe_removed_list:
            if comp == salomex_name:
                continue

            # Retrieve recursively all reverse dependencies of each extension in depends_on_removed list
            # REMARK: extensions in this list which does not appear in the exts_tobe_removed_list, will not be removed
            comp_depts = list_dependants(install_dir, comp)
            not_removed_list = []
            if len(comp_depts) > 0:
                for ext in comp_depts:
                    if ext not in exts_tobe_removed_list:
                        not_removed_list += [ext]
            if len(not_removed_list) >0:
                get_logger().warning(f"Cannot remove {comp}. The folows extensions depend on it: {not_removed_list} ")
            else:
                get_logger().info("Remove depends_on_removed extension %s"%comp)
                comp_removed_list = remove_salomex(install_dir, comp, AtRemoveAskerForce(True), force = True)
                if comp_removed_list and len(comp_removed_list)>0:
                    module_removed_list += comp_removed_list

    return module_removed_list

if __name__ == '__main__':
    if len(sys.argv) == 3:
        arg_1, arg_2 = sys.argv[1:] # pylint: disable=unbalanced-tuple-unpacking
        remove_salomex(arg_1, arg_2)
    else:
        get_logger().error('You must provide all the arguments!')
        get_logger().info(remove_salomex.__doc__)
