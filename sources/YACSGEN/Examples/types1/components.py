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

import os

#import context from ..
exec(compile(open("../context.py").read(), "../context.py", 'exec'))

from module_generator import Generator,Module,Service,CPPComponent,PYComponent,add_type,add_module

#overload GEOM_Object definition
add_type("GEOM_Object", "GEOM::GEOM_Object_ptr", "GEOM::GEOM_Object_out", "GEOM", "GEOM::GEOM_Object","GEOM::GEOM_Object_ptr")


cwd=os.getcwd()

defs="""
"""

body="""
//inputs
//Parameter
std::cerr << "Parameter:" << std::endl;
std::cerr << "a: " << a.name << "=" << a.value << std::endl;
std::cerr << "" << std::endl;

//ParameterList
std::cerr << "ParameterList:" << std::endl;
for(CORBA::ULong i = 0;i<b.length();i++)
  std::cerr << "b["<<i<<"]:"<<b[i].name <<"="<<b[i].value << std::endl;
std::cerr << "" << std::endl;

//Variable
std::cerr << "Variable:" << std::endl;
for(CORBA::ULong i = 0;i<c.length();i++)
  std::cerr << "c["<<i<<"]="<<c[i] << std::endl;
std::cerr << "" << std::endl;

//VariableSequence
std::cerr << "VariableSequence:" << std::endl;
for(CORBA::ULong i = 0;i<d.length();i++)
  for(CORBA::ULong j = 0;j<d[i].length();j++)
    std::cerr << "d["<<i<<"]["<< j<< "]="<<d[i][j] << std::endl;
std::cerr << "" << std::endl;

//StateSequence
std::cerr << "StateSequence:" << std::endl;
for(CORBA::ULong i = 0;i<d2.length();i++)
  for(CORBA::ULong j = 0;j<d2[i].length();j++)
    for(CORBA::ULong k = 0;k<d2[i][j].length();k++)
      std::cerr << "d2["<<i<<"]["<< j<< "]["<<k<<"]="<<d2[i][j][k] << std::endl;
std::cerr << "" << std::endl;

//TimeSequence
std::cerr << "TimeSequence:" << std::endl;
for(CORBA::ULong i = 0;i<d3.length();i++)
  for(CORBA::ULong j = 0;j<d3[i].length();j++)
    for(CORBA::ULong k = 0;k<d3[i][j].length();k++)
      for(CORBA::ULong l = 0;l<d3[i][j][k].length();l++)
      std::cerr << "d3["<<i<<"]["<< j<< "]["<<k<<"]["<<l<<"]="<<d3[i][j][k][l] << std::endl;
std::cerr << "" << std::endl;

//ParametricInput
for(CORBA::ULong i = 0;i<f.inputVarList.length();i++)
  std::cerr << "f.inputVarList["<<i<<"]="<<f.inputVarList[i] << std::endl;
for(CORBA::ULong i = 0;i<f.outputVarList.length();i++)
  std::cerr << "f.outputVarList["<<i<<"]="<<f.outputVarList[i] << std::endl;
for(CORBA::ULong i = 0;i<f.inputValues.length();i++)
  for(CORBA::ULong j = 0;j<f.inputValues[i].length();j++)
    for(CORBA::ULong k = 0;k<f.inputValues[i][j].length();k++)
      for(CORBA::ULong l = 0;l<f.inputValues[i][j][k].length();l++)
      std::cerr << "f.inputValues["<<i<<"]["<< j<< "]["<<k<<"]["<<l<<"]="<<f.inputValues[i][j][k][l] << std::endl;
for(CORBA::ULong i = 0;i<f.specificParameters.length();i++)
  std::cerr << "f.specificParameters["<<i<<"]:"<<f.specificParameters[i].name <<"="<<f.specificParameters[i].value << std::endl;

//ParametricOutput
for(CORBA::ULong i = 0;i<g.outputValues.length();i++)
  for(CORBA::ULong j = 0;j<g.outputValues[i].length();j++)
    for(CORBA::ULong k = 0;k<g.outputValues[i][j].length();k++)
      for(CORBA::ULong l = 0;l<g.outputValues[i][j][k].length();l++)
      std::cerr << "g.outputValues["<<i<<"]["<< j<< "]["<<k<<"]["<<l<<"]="<<g.outputValues[i][j][k][l] << std::endl;

//outputs
//Parameter
aa=new SALOME_TYPES::Parameter;
aa->name=CORBA::string_dup(a.name);
aa->value=CORBA::string_dup(a.value);
std::cerr << "aa: " << aa->name << "=" << aa->value << std::endl;
//ParameterList
ab=new SALOME_TYPES::ParameterList;
ac= new SALOME_TYPES::Variable;
ad= new SALOME_TYPES::VariableSequence;
ad2= new SALOME_TYPES::StateSequence;
ad3= new SALOME_TYPES::TimeSequence;
ae= new SALOME_TYPES::VarList;
af= new SALOME_TYPES::ParametricInput;
ag= new SALOME_TYPES::ParametricOutput;
"""

s2body="""
std::cerr << "service s2 C++ component" << std::endl;
aa=GEOM::GEOM_Object::_duplicate(a);
a->Register();
"""

c1=CPPComponent("compo1",services=[
          Service("s1",inport=[("a","SALOME_TYPES/Parameter"),
                               ("b","SALOME_TYPES/ParameterList"),
                               ("c","SALOME_TYPES/Variable"),
                               ("d","SALOME_TYPES/VariableSequence"),
                               ("d2","SALOME_TYPES/StateSequence"),
                               ("d3","SALOME_TYPES/TimeSequence"),
                               ("e","SALOME_TYPES/VarList"),
                               ("f","SALOME_TYPES/ParametricInput"),
                               ("g","SALOME_TYPES/ParametricOutput"),
                              ],
                       outport=[("aa","SALOME_TYPES/Parameter"),
                                ("ab","SALOME_TYPES/ParameterList"),
                                ("ac","SALOME_TYPES/Variable"),
                                ("ad","SALOME_TYPES/VariableSequence"),
                                ("ad2","SALOME_TYPES/StateSequence"),
                                ("ad3","SALOME_TYPES/TimeSequence"),
                                ("ae","SALOME_TYPES/VarList"),
                                ("af","SALOME_TYPES/ParametricInput"),
                                ("ag","SALOME_TYPES/ParametricOutput"),
                               ],
                       defs=defs,body=body,
                 ),
          Service("s2",inport=[("a","GEOM_Object"),],outport=[("aa","GEOM_Object"),],body=s2body,),
                                  ],
         )

pydefs="""import SALOME_TYPES"""

pybody="""
print (a,b,c,d,d2,d3,e,f,g)
aa=SALOME_TYPES.Parameter(name="a",value="45.")
ab=[]
ac=[1,2,3]
ad=[[1,2,3]]
ad2=[[[1,2,3]]]
ad3=[[[[1,2,3]]]]
ae=["aaa","bbb"]
af=SALOME_TYPES.ParametricInput(inputVarList=ae,outputVarList=ae, inputValues=[[[[1,2,3]]]],specificParameters=[])
ag=SALOME_TYPES.ParametricOutput(outputValues=[[[[1,2,3]]]], specificOutputInfos=[], returnCode=1, errorMessage="error")
print (aa,ab,ac,ad,ad2,ad3,ae,af,ag)
"""

s2pybody="""
print ("service s2 python component")
aa=a
a.Register()
"""

c2=PYComponent("compo2",services=[
          Service("s1",inport=[("a","SALOME_TYPES/Parameter"),
                               ("b","SALOME_TYPES/ParameterList"),
                               ("c","SALOME_TYPES/Variable"),
                               ("d","SALOME_TYPES/VariableSequence"),
                               ("d2","SALOME_TYPES/StateSequence"),
                               ("d3","SALOME_TYPES/TimeSequence"),
                               ("e","SALOME_TYPES/VarList"),
                               ("f","SALOME_TYPES/ParametricInput"),
                               ("g","SALOME_TYPES/ParametricOutput"),
                              ],
                       outport=[("aa","SALOME_TYPES/Parameter"),
                                ("ab","SALOME_TYPES/ParameterList"),
                                ("ac","SALOME_TYPES/Variable"),
                                ("ad","SALOME_TYPES/VariableSequence"),
                                ("ad2","SALOME_TYPES/StateSequence"),
                                ("ad3","SALOME_TYPES/TimeSequence"),
                                ("ae","SALOME_TYPES/VarList"),
                                ("af","SALOME_TYPES/ParametricInput"),
                                ("ag","SALOME_TYPES/ParametricOutput"),
                               ],
                       body=pybody,defs=pydefs,
                 ),
          Service("s2",inport=[("a","GEOM_Object"),],outport=[("aa","GEOM_Object"),],body=s2pybody,),
                                 ],
              )


g=Generator(Module("mymodule",components=[c1,c2],prefix="./install"),context)
g.generate()
g.configure()
g.make()
g.install()
g.make_appli("appli", restrict=["KERNEL"],
             altmodules={"GUI":GUI_ROOT_DIR,
                         "YACS":YACS_ROOT_DIR,
                         "GEOM":GEOM_ROOT_DIR},
             sys_modules=SYS_MODULES)

