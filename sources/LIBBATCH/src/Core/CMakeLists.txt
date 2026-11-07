# Copyright (C) 2007-2021  CEA/DEN, EDF R&D, OPEN CASCADE
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
# See http://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
#

SET(CLASS_LIST Core/APIInternalFailureException
               Core/BatchManager
               Core/BatchManagerCatalog
               Core/BoolType
               Core/CommandsOverloader
               Core/CommunicationProtocol
               Core/Constants
               Core/Couple
               Core/CoupleType
               Core/Environnement
               Core/FactBatchManager
               Core/GenericException
               Core/GenericType
               Core/InvalidArgumentException
               Core/InvalidKeyException
               Core/Job
               Core/JobId
               Core/JobInfo
               Core/ListIsFullException
               Core/LongType
               Core/MpiImpl
               Core/NotYetImplementedException
               Core/ParameterTypeMap
               Core/Parametre
               Core/RunTimeException
               Core/StringType
               Core/TypeMismatchException
               Core/Versatile
   )

APPEND_CLASSES_TO_SRC_FILES(${CLASS_LIST}
                            Core/Utils
                            Core/Log)
APPEND_CLASSES_TO_HDR_FILES(${CLASS_LIST})
APPEND_CLASSES_TO_HDR_FILES(Core/Defines)

APPEND_CLASSES_TO_SRC_FILES(Core/CommunicationProtocolSH)
APPEND_CLASSES_TO_SRC_FILES(Core/CommunicationProtocolRSH)
APPEND_CLASSES_TO_SRC_FILES(Core/CommunicationProtocolSSH)
APPEND_CLASSES_TO_SRC_FILES(Core/CommunicationProtocolRsync)

IF (LIBBATCH_BUILD_TESTS)
    ADD_SUBDIRECTORY(Test)
ENDIF ()
