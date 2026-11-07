#! /usr/bin/env python
#  -*- coding: iso-8859-1 -*-
# Copyright (C) 2009-2026  EDF
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
# See http://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
#
usage="""
hxx2salome.py [options] <CPPCOMPO>_root_dir lib<CPPCOMPO>.hxx <CPPCOMPO>.so installDir

generate a SALOME component that wrapps given the C++ component

Mandatory arguments:

  - <CPPCOMPO>_root_dir   : install directory (absolute path) of the c++ component
  - <CPPCOMPO>.hxx        : header of the c++ component"
  - lib<CPPCOMPO>.so      : the shared library containing the c++ component
  - installDir            : directory where the generated files and the build should be installed 

  Note that <CPPCOMPO>.hxx and lib<CPPCOMPO>.so should be found in <CPPCOMPO>_root_dir)
  
"""

import os
import sys
import string
import optparse
from module_generator import Generator,Module,Service,HXX2SALOMEComponent

# ------------------------------------------------------------------------------

def main():
#   Reproduce the main options of original hxx2salome script
    parser = optparse.OptionParser(usage=usage)
    parser.add_option(
        '-e', 
        dest="environ_file", 
        default='sh', 
        help="specify the name of a environment file (bash/sh) that will" +\
             " be updated")
    parser.add_option(
        '-g', 
        action="store_true", 
        dest="do_gui", 
        default=False,
        help="to create a generic gui in your component building tree")
    parser.add_option(
        '-c', 
        action="store_true", 
        dest="do_compile", 
        default=False,
        help="to compile after generation")
    parser.add_option(
        '-s', 
        dest="shell_syntax", 
        help="use this option with csh to update the environment " +\
             "with the CSH syntax")

    options, args = parser.parse_args()

    assert len(args) == 4, \
        'ERROR, four mandatory arguments are expected!\n\n%s\n' % usage
    cppdir = args[0]      # install directory of the c++ component
    hxxfile = args[1]     # header of the c++ component
    libfile = args[2]     # the shared library containing the c++ component
    installpath = args[3] # directory where the generated files are installed

#   Make sure given paths/files are valid
    if not os.path.exists(cppdir):
        print("ERROR: cppdir %s does not exist. It is mandatory" % cppdir)
        print(usage)
        sys.exit(1)

    if not os.path.exists(installpath):
        print("ERROR: installpath %s does not exist. It is mandatory" \
              % installpath)
        print(usage)
        sys.exit(1)

    if options.environ_file != None:
        if not os.path.exists(options.environ_file):
            print("ERROR: environ_file %s does not exist. It is mandatory" \
                  % options.environ_file)
            print(usage)
            sys.exit(1)

    hxx2salome(cppdir=cppdir,
               hxxfile=hxxfile,
               libfile=libfile,
               installpath=installpath,
               do_gui=options.do_gui,
               do_compile=options.do_compile,
               environ_file=options.environ_file,
               shell_syntax=options.shell_syntax
               )
    pass

# ------------------------------------------------------------------------------

def hxx2salome(cppdir,
        hxxfile,
        libfile,
        installpath,
        do_gui,
        do_compile,
        environ_file,
        shell_syntax):

    # setup from environment a minimal context
    kernel_root_dir=os.environ["KERNEL_ROOT_DIR"]
    gui_root_dir=os.environ["GUI_ROOT_DIR"]
    context={'update':1,
             "makeflags":"-j2",
             "kernel":kernel_root_dir,
             "gui":gui_root_dir,
            }
    #
    salome_compo = HXX2SALOMEComponent(hxxfile,libfile,cppdir)
    install_root_dir = os.path.join(installpath,salome_compo.name)
    module_root_dir = os.path.join(install_root_dir,
            salome_compo.name+"_INSTALL")

    # to be able to compile the generated component
    os.environ[salome_compo.name+"CPP_ROOT_DIR"]=cppdir  

    # if necessary creates the directory in which the component 
    # will be geberated and compiled.
    try: 
        os.mkdir(install_root_dir)
    except OSError:
        print("Warning : directory %s already exixts!" % install_root_dir)

    # if a graphical user interface is required,
    # ask HXX2SALOMEComponent to generate template files
    if do_gui:
        gui_files=salome_compo.getGUIfilesTemplate()
        g=Generator(Module(salome_compo.name,components=[salome_compo],
            prefix=module_root_dir,
            gui=gui_files),
            context)
    else:
        g=Generator(Module(salome_compo.name,components=[salome_compo],
            prefix=module_root_dir),
            context)

    # go in install_root_dir, generate the component
    os.chdir(install_root_dir)
    g.generate()

    # if specified : compile and install the generated component
    if do_compile:
        g.configure()
        g.make()
        g.install()
        pass
    #
    # update environment file if furnished
    if environ_file != None:
       envfile=open(environ_file,"a")
       if shell_syntax == "csh":
           update_environ="""
#------ ${compo_name}
setenv ${compo_name}_SRC_DIR ${install_root_dir}/${compo_name}_SRC
setenv ${compo_name}_ROOT_DIR ${install_root_dir}/${compo_name}_INSTALL
"""
       else:
           update_environ="""
#------ ${compo_name}
export ${compo_name}_SRC_DIR=${install_root_dir}/${compo_name}_SRC
export ${compo_name}_ROOT_DIR=${install_root_dir}/${compo_name}_INSTALL
"""
       update_environ=string.Template(update_environ)
       update_environ=update_environ.substitute(compo_name=salome_compo.name,
               install_root_dir=install_root_dir)
       envfile.write(update_environ)
       envfile.close()
    pass

# ------------------------------------------------------------------------------

if __name__ == '__main__':
    main()
    pass
