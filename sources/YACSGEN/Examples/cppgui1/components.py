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

#import context from ..
exec(compile(open("../context.py").read(), "../context.py", 'exec'))

import os
from module_generator import *

idldefs="""
#include "myinterface.idl"
"""

compodefs=r"""


class A: public virtual POA_Idl_A
{
public:
  void createObject(::SALOMEDS::Study_ptr theStudy, const char* name){};

  // Driver interface
  virtual SALOMEDS::TMPFile* Save(SALOMEDS::SComponent_ptr theComponent, const char* theURL, bool isMultiFile){return 0;};
  virtual SALOMEDS::TMPFile* SaveASCII(SALOMEDS::SComponent_ptr theComponent, const char* theURL, bool isMultiFile){return 0;};
  virtual bool Load(SALOMEDS::SComponent_ptr theComponent, const SALOMEDS::TMPFile& theStream, const char* theURL, bool isMultiFile){return 0;};
  virtual bool LoadASCII(SALOMEDS::SComponent_ptr theComponent, const SALOMEDS::TMPFile& theStream, const char* theURL, bool isMultiFile){return 0;};
  virtual void Close(SALOMEDS::SComponent_ptr IORSComponent){};
  virtual char* ComponentDataType(){return (char*)"cppcompos";};
  virtual char* IORToLocalPersistentID(SALOMEDS::SObject_ptr theSObject, const char* IORString, CORBA::Boolean isMultiFile, CORBA::Boolean isASCII){return 0;};
  virtual char* LocalPersistentIDToIOR(SALOMEDS::SObject_ptr theSObject, const char* aLocalPersistentID, CORBA::Boolean isMultiFile,
                                       CORBA::Boolean isASCII){return 0;};
  virtual bool  CanPublishInStudy(CORBA::Object_ptr theIOR){return 0;};
  virtual SALOMEDS::SObject_ptr PublishInStudy(SALOMEDS::SObject_ptr theSObject,CORBA::Object_ptr theObject,
                                               const char* theName){return 0;};
  virtual CORBA::Boolean CanCopy(SALOMEDS::SObject_ptr theObject){return 0;};
  virtual SALOMEDS::TMPFile* CopyFrom(SALOMEDS::SObject_ptr theObject, CORBA::Long& theObjectID){return 0;};
  virtual CORBA::Boolean CanPaste(const char* theComponentName, CORBA::Long theObjectID){return 0;};
  virtual SALOMEDS::SObject_ptr PasteInto(const SALOMEDS::TMPFile& theStream, CORBA::Long theObjectID, SALOMEDS::SObject_ptr theObject){return 0;};
};

"""

compomethods=r"""

  Engines::TMPFile* DumpPython(CORBA::Object_ptr theStudy,
                               CORBA::Boolean isPublished,
                               CORBA::Boolean isMultiFile,
                               CORBA::Boolean& isValidScript)
  {
    std::cerr << "je suis dans le dump:" << __LINE__ << std::endl;
    SALOMEDS::Study_var aStudy = SALOMEDS::Study::_narrow(theStudy);
    if(CORBA::is_nil(aStudy))
      return new Engines::TMPFile(0);

    SALOMEDS::SObject_var aSO = aStudy->FindComponent("cppcompos");
    if(CORBA::is_nil(aSO))
       return new Engines::TMPFile(0);

    std::string Script = "import cppcompos_ORB\n";
    Script += "import salome\n";
    Script += "compo = salome.lcc.FindOrLoadComponent('FactoryServer','cppcompos')\n";
    Script += "def RebuildData(theStudy):\n";
    Script += "  compo.SetCurrentStudy(theStudy)\n";
    const char* aScript=Script.c_str();

    char* aBuffer = new char[strlen(aScript)+1];
    strcpy(aBuffer, aScript);
    CORBA::Octet* anOctetBuf =  (CORBA::Octet*)aBuffer;
    int aBufferSize = strlen(aBuffer)+1;
    Engines::TMPFile_var aStreamFile = new Engines::TMPFile(aBufferSize, aBufferSize, anOctetBuf, 1);
    isValidScript = true;
    return aStreamFile._retn();
  }


"""

body="""
std::cerr << "a: " << a << std::endl;
std::cerr << "b: " << b << std::endl;
c=a+b;
std::cerr << "c: " << c << std::endl;
"""
c1=CPPComponent("cppcompos",services=[
          Service("s1",inport=[("a","double"),("b","double")],
                       outport=[("c","double")],
                       defs="//def1",body=body,
                 ),
          ],
         idls=["*.idl"],
         interfacedefs=idldefs,
         inheritedinterface="Idl_A",
         compodefs=compodefs,
         inheritedclass="A",
         addedmethods=compomethods,
         )

modul=Module("cppcompos",components=[c1],prefix="./install",
             doc=["*.rst",],
             gui=["cppcomposGUI.cxx","cppcomposGUI.h","demo.ui","*.png"],
            )

g=Generator(modul,context)
g.generate()
#g.configure("-DTBB_INCLUDE_DIR=/opt/tbb/2018.u6/include  -DTBB_ROOT=/opt/tbb/2018.u6/")
g.configure()
g.make()
g.install()
g.make_appli("appli", restrict=["KERNEL"], altmodules={"GUI":GUI_ROOT_DIR, "YACS":YACS_ROOT_DIR}, sys_modules=SYS_MODULES)

