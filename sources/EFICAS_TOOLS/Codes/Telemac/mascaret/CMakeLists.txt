#  Copyright (C) 2012-2026 EDF
#
#  This file is part of SALOME HYDRO module.
#
#  SALOME HYDRO module is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  SALOME HYDRO module is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with SALOME HYDRO module.  If not, see <http://www.gnu.org/licenses/>.

# --- Python files ---

SET(PYFILES
  __init__.py
  appli.py
  configuration_mascaret.py
  prefs_mascaret.py
  prefs.py
  mascaret_V7_cata.py
)

# --- rules ---

SALOME_INSTALL_SCRIPTS("${PYFILES}" ${SALOME_INSTALL_PYTHON}/salome/hydro/mascaret/eficas)
