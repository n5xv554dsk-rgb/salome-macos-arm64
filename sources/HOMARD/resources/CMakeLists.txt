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
# See http://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
#

SET(HOMARD_RESOURCES_FILES
  advanced_mesh_info.png
  boxdxy.png
  boxdxy_2.png
  boxdxyz.png
  boxdxyz_2.png
  cas_calcule.png
  cas_non_calcule.png
  conedxyz.png
  cone.png
  conepointvector.png
  cylinderpointvector.png
  cylinderpointvector_2.png
  delete.png
  drapeau_en.gif
  drapeau_fr.gif
  disk.png
  disk_2.png
  diskwithhole.png
  diskwithhole_2.png
  full_view.png
  geometry.png
  HOMARD.png
  HOMARD_2.png
  hypotheses.png
  iter0.png
  iter_calculee.png
  iter_next.png
  iter_non_calculee.png
  iter_poursuite.png
  loop.png
  med.png
  mesh_compute.png
  mesh_hypo_edit.png
  mesh_tree_mesh.png
  mesh_tree_importedmesh.png
  mesh_whatis.png
  pipe.png
  pipe_2.png
  save.png
  schema.png
  spherepoint.png
  spherepoint_2.png
  table_view.png
  texte.png
  texte_2.png
  toruspointvector.png
  triangle.png
  whatis.png
  write.png
  yacs.png
  yacs_01.fr.xml
  yacs_01.en.xml
  zone_boxdxyz.png
  zone_boxdxyz_2.png
  zone_icone.png
  zone_icone_2.png
  zone_spherepoint.png
  zone_spherepoint_2.png
  zones.png
)

INSTALL(FILES ${HOMARD_RESOURCES_FILES} DESTINATION ${SALOME_HOMARD_INSTALL_RES_DATA})

SALOME_CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/SalomeApp.xml.in ${CMAKE_CURRENT_BINARY_DIR}/SalomeApp.xml INSTALL ${SALOME_HOMARD_INSTALL_RES_DATA})
SALOME_CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/SalomeApp.xml.in ${CMAKE_CURRENT_BINARY_DIR}/SalomeAppSL.xml INSTALL ${SALOME_HOMARD_INSTALL_RES_DATA})
SALOME_CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/HOMARDCatalog.xml.in ${CMAKE_CURRENT_BINARY_DIR}/HOMARDCatalog.xml INSTALL ${SALOME_HOMARD_INSTALL_RES_DATA})
