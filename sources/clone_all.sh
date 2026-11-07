#!/bin/bash
set -e
REPOS=(
  "SALOMEBOOTSTRAP:salome_bootstrap.git"
  "LIBBATCH:libbatch.git"
  "KERNEL:kernel.git"
  "MEDCOUPLING:medcoupling.git"
  "GUI:gui.git"
  "CommonGeomLib:common_geometry_lib.git"
  "GEOM:geom.git"
  "SHAPER:shaper.git"
  "SHAPERSTUDY:shaper_study.git"
  "SMESH:smesh.git"
  "NETGENPLUGIN:netgenplugin.git"
  "GMSHPLUGIN:gmshplugin.git"
  "MMGPLUGIN:mmgplugin.git"
  "MESHBOOLEANPLUGIN:meshbooleanplugin.git"
  "BLSURFPLUGIN:blsurfplugin.git"
  "GHS3DPLUGIN:ghs3dplugin.git"
  "HYBRIDPLUGIN:hybridplugin.git"
  "HexoticPLUGIN:hexoticplugin.git"
  "HEXABLOCK:hexablock.git"
  "HEXABLOCKPLUGIN:hexablockplugin.git"
  "HOMARD:homard.git"
  "FIELDS:med.git"
  "PARAVIS:paravis.git"
  "PARAVISADDONS:paravisaddons_common.git"
  "JOBMANAGER:jobmanager.git"
  "YACS:yacs.git"
  "YACSGEN:yacsgen.git"
  "PY2CPP:py2cpp.git"
  "YDEFX:ydefx.git"
  "PMML:pmml.git"
  "SOLVERLAB:solverlab.git"
  "EFICAS_TOOLS:eficas_tools.git"
  "EFICAS:eficas.git"
  "ADAO:adao.git"
  "ADAO_INTERFACE:adao_interface.git"
  "COMPONENT:component.git"
  "CALCULATOR:calculator.git"
  "PYCALCULATOR:pycalculator.git"
  "HELLO:hello.git"
  "PYHELLO:pyhello.git"
  "SAMPLES:datafiles.git"
  "DOCUMENTATION:documentation.git"
  "SALOME:SALOME.git"
  "TopIIVolMesh:top_ii_vol.git"
  "MEDREADER:medreader.git"
)

clone_one() {
  local item="$1"
  local dir="${item%%:*}"
  local repo="${item#*:}"
  if [ -d "$dir/.git" ]; then
    echo "[SKIP] $dir already cloned"
    return 0
  fi
  echo "[CLONE] $dir from https://github.com/SalomePlatform/$repo ..."
  git clone --depth 1 "https://github.com/SalomePlatform/$repo" "$dir" -q && echo "[DONE] $dir"
}
export -f clone_one
printf "%s\n" "${REPOS[@]}" | xargs -n 1 -P 6 bash -c 'clone_one "$@"' _
