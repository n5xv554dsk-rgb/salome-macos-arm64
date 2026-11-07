# Copyright (C) 2019-2026  CEA, EDF
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

from salome.kernel import SHAPERSTUDY_ORB__POA
from salome.kernel import GEOM

class SHAPERSTUDY_Field(SHAPERSTUDY_ORB__POA.Field):
    """
    Construct an instance of SHAPERSTUDY Field.
    """
    def __init__ ( self, *args ):
        pass

    def GetDataType( self ):
        """
        Returns type of field data (GEOM.field_data_type)
        """
        return GEOM.FDT_Double

    def GetShape( self ):
        """
        Returns the shape the field lies on
        """
        #from SHAPERSTUDY_Object import SHAPERSTUDY_Object
        return SHAPERSTUDY_Object()

    def GetSteps( self ):
        """
        Returns a list of time step IDs in the field
        """
        return [1]

    def GetComponents( self ):
        """
        Returns names of components
        """
        return ['X']

    def GetDimension( self ):
        """
        Returns dimension of the shape the field lies on:
        0 - VERTEX, 1 - EDGE, 2 - FACE, 3 - SOLID, -1 - whole shape
        """
        return -1

    ### unnecessary methods that can be accidentally called from any module
    def AddStep(self, *args): return 
    def RemoveStep(self, *args): return 
    def CountSteps(self, *args): return 0
    def GetStep(self, *args): return 0
    def GetArraySize(self, *args): return 0

    pass



class SHAPERSTUDY_FieldStep(SHAPERSTUDY_ORB__POA.FieldStep):
    """
    Construct an instance of SHAPERSTUDY FieldStep.
    """
    def __init__ ( self, *args):
        pass

    def GetStamp( self ):
        """
        Returns the time of the field step
        """
        return 100

    def GetID( self ):
        """
        Returns the number of the field step
        """
        return 1

    pass


class SHAPERSTUDY_DoubleFieldStep(SHAPERSTUDY_ORB__POA.DoubleFieldStep):
    """
    Construct an instance of SHAPERSTUDY FieldStep.
    """
    def __init__ ( self, *args):
        SHAPERSTUDY_FieldStep.__init__(self, *args)
        pass

    def GetValues( self ):
        """
        Returns values of the field step
        """
        return [1.0]

    pass


class SHAPERSTUDY_IntFieldStep(SHAPERSTUDY_ORB__POA.IntFieldStep):
    """
    Construct an instance of SHAPERSTUDY FieldStep.
    """
    def __init__ ( self, *args):
        SHAPERSTUDY_FieldStep.__init__(self, *args)
        pass

    def GetValues( self ):
        """
        Returns values of the field step
        """
        return [1]

    pass


class SHAPERSTUDY_BoolFieldStep(SHAPERSTUDY_ORB__POA.BoolFieldStep):
    """
    Construct an instance of SHAPERSTUDY FieldStep.
    """
    def __init__ ( self, *args):
        SHAPERSTUDY_FieldStep.__init__(self, *args)
        pass

    def GetValues( self ):
        """
        Returns values of the field step
        """
        return [True]

    pass
