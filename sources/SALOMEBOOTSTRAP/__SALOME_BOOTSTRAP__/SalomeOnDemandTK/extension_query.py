#!/usr/bin/env python3
# -*- coding:utf-8 -*-
# Copyright (C) 2007-2026  CEA, EDF
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

from pathlib import Path
from SalomeOnDemandTK.extension_utilities import get_logger, position_verbosity_level
from SalomeOnDemandTK.extension_query_impl import dir_size_str, ext_by_dependants_of_application, ext_info_dict, ext_size_str

def readableString( dico : str ) -> str:
    import json
    return json.dumps( dico, indent=4)

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(prog = 'extension_query', description = "Executable requiring on SOD application installed." )
    parser.add_argument('salome_application_dir', type = Path, help = "Top repository containing SALOME application in Sod mode." )
    parser.add_argument("-e", "--extension", dest = "extension", type=str, default = None, help = "Optionnal extension to request size of it." )
    parser.add_argument("-j", "--json-data", dest = "json_data", help= "Produce json structure", action='store_true')
    parser.add_argument("-v", "--verbose-level", dest = "verbose_level", type=str, choices=["ERROR", "WARNING", "INFO", "DEBUG"], default="INFO", help=" Verbosity level.")
    args = parser.parse_args()
    position_verbosity_level( args.verbose_level )
    salomeAppTopDir = str( args.salome_application_dir )
    if args.extension is None:
        get_logger().info( f'Size of SOD application {salomeAppTopDir!r} : {dir_size_str( salomeAppTopDir )}' )
        ordered_exts_list = ext_by_dependants_of_application( salomeAppTopDir )
        get_logger().info( f'List of extensions (sorted by dependancies) of SOD application {salomeAppTopDir!r} : {ordered_exts_list}' )
        if args.json_data:
            installed_exts = ext_info_dict( salomeAppTopDir )
            ret = [(elt, installed_exts[elt]) for elt in ordered_exts_list]
            get_logger().info( readableString( ret ) )
    else:
        get_logger().info( f"Size of {args.extension!r} extension in SOD application {salomeAppTopDir!r} : {ext_size_str( salomeAppTopDir, args.extension ) }" )
        if args.json_data:
            installed_exts = ext_info_dict( salomeAppTopDir )
            get_logger().info( readableString( installed_exts[ args.extension ] ) )
