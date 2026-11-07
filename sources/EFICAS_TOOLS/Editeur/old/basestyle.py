# Copyright (C) 2007-2026   EDF R&D
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License.
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
try :
    from builtins import object
except : pass

class STYLE(object):
    background='gray90'
    foreground='black'
    entry_background='white'
    list_background='white'
    list_select_background='#00008b'
    list_select_foreground='grey'
    tooltip_background="yellow"

    standard = ("Helvetica",12)
    standard_italique = ("Helvetica",12,'italic')
    standard_gras = ("Helvetica",12,'bold')
    standard_gras_souligne = ("Helvetica",12,'bold','underline')

    canvas = ('Helvetica',10)
    canvas_italique = ('Helvetica',10,'italic')
    canvas_gras = ("Helvetica",10,'bold')
    canvas_gras_italique = ("Helvetica",12,'bold','italic')

    standard12 = ("Helvetica",14)
    standard12_gras = ("Helvetica",14,'bold')
    standard12_gras_italique = ( "Helvetica",14,'bold','italic')

    standardcourier10 = ("Courier",14)
    statusfont = ("Helvetica",16)

style=STYLE()
