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
from module_generator import Generator,Module,Service,PYComponent,CPPComponent,F77Component
from module_generator import Library

# C++ component

body="""
std::cerr << "a: " << a << std::endl;
std::cerr << "b: " << b << std::endl;
int info;
double t1,t2;
float tt1,tt2;
int i=1;
int mval;
double val[10],rval[10];
int ival[10],rival[10];
long lval[10],rlval[10];
float cval[20],rcval[20];
char* sval[]={"coucou","bonjour","salut"};
char* rsval[3];
char mystring1[10];
char mystring2[10];
char mystring3[10];
rsval[0]=mystring1;
rsval[1]=mystring2;
rsval[2]=mystring3;

val[0]=3.2;
val[1]=5.2;
val[2]=9.8;
std::cerr << "val: " << val[0] << std::endl;
std::cerr << "val: " << val[1] << std::endl;
std::cerr << "val: " << val[2] << std::endl;
cp_edb(component,CP_TEMPS,0.,1,(char*)"ba",10,val);
cp_edb(component,CP_TEMPS,1.,2,(char*)"ba",10,val);
cp_edb(component,CP_TEMPS,2.,3,(char*)"ba",10,val);

std::cerr << "sval: " << sval[0] << std::endl;
std::cerr << "sval: " << sval[1] << std::endl;
std::cerr << "sval: " << sval[2] << std::endl;
cp_ech(component,CP_TEMPS,0.,1,(char*)"bb",3,sval,6);

ival[0]=1;
ival[1]=2;
ival[2]=3;
std::cerr << "ival: " << ival[0] << std::endl;
std::cerr << "ival: " << ival[1] << std::endl;
std::cerr << "ival: " << ival[2] << std::endl;
cp_een(component,CP_TEMPS,0.,1,(char*)"bc",10,ival);

cval[0]=1;
cval[1]=2;
cval[2]=3;
cval[3]=4.5;
cval[4]=5.6;
cval[5]=7.8;
std::cerr << "cval: " << cval[0] << std::endl;
std::cerr << "cval: " << cval[1] << std::endl;
std::cerr << "cval: " << cval[2] << std::endl;
std::cerr << "cval: " << cval[3] << std::endl;
std::cerr << "cval: " << cval[4] << std::endl;
std::cerr << "cval: " << cval[5] << std::endl;
cp_ecp(component,CP_TEMPS,0.,1,(char*)"bd",10,cval);

cval[0]=1.1;
cval[1]=2.2;
cval[2]=3.3;
std::cerr << "cval: " << cval[0] << std::endl;
std::cerr << "cval: " << cval[1] << std::endl;
std::cerr << "cval: " << cval[2] << std::endl;
cp_ere(component,CP_TEMPS,0.,1,(char*)"be",10,cval);

ival[0]=1;
ival[1]=0;
ival[2]=1;
std::cerr << "ival: " << ival[0] << std::endl;
std::cerr << "ival: " << ival[1] << std::endl;
std::cerr << "ival: " << ival[2] << std::endl;
cp_elo(component,CP_TEMPS,0.,1,(char*)"bf",10,ival);

lval[0]=1;
lval[1]=2;
lval[2]=3;
std::cerr << "lval: " << lval[0] << std::endl;
std::cerr << "lval: " << lval[1] << std::endl;
std::cerr << "lval: " << lval[2] << std::endl;
cp_eln(component,CP_TEMPS,0.,1,(char*)"bg",10,lval);

ival[0]=1;
ival[1]=2;
ival[2]=3;
std::cerr << "ival: " << ival[0] << std::endl;
std::cerr << "ival: " << ival[1] << std::endl;
std::cerr << "ival: " << ival[2] << std::endl;
cp_een(component,CP_TEMPS,0.,1,(char*)"bh",10,ival);

lval[0]=1;
lval[1]=2;
lval[2]=3;
std::cerr << "lval: " << lval[0] << std::endl;
std::cerr << "lval: " << lval[1] << std::endl;
std::cerr << "lval: " << lval[2] << std::endl;
cp_elg(component,CP_TEMPS,0.,1,(char*)"bi",10,lval);

/* read */
t1=0.;
t2=1.;
info=cp_ldb(component,CP_TEMPS,&t1,&t2,&i,(char*)"aa",3,&mval,rval);
std::cerr << "info: " << info << std::endl;
std::cerr << "rval: " << rval[0] << std::endl;
std::cerr << "rval: " << rval[1] << std::endl;
std::cerr << "rval: " << rval[2] << std::endl;

tt1=0.;
tt2=1.;
info=cp_lch(component,CP_TEMPS,&tt1,&tt2,&i,(char*)"ab",3,&mval,rsval,7);
std::cerr << "info: " << info << std::endl;
std::cerr << "rsval: " << rsval[0] << std::endl;
std::cerr << "rsval: " << rsval[1] << std::endl;
std::cerr << "rsval: " << rsval[2] << std::endl;

info=cp_len(component,CP_TEMPS,&tt1,&tt2,&i,(char*)"ac",3,&mval,rival);
std::cerr << "info: " << info << std::endl;
std::cerr << "rival: " << rival[0] << std::endl;
std::cerr << "rival: " << rival[1] << std::endl;
std::cerr << "rival: " << rival[2] << std::endl;

info=cp_lcp(component,CP_TEMPS,&tt1,&tt2,&i,(char*)"ad",3,&mval,rcval);
std::cerr << "info: " << info << std::endl;
std::cerr << "rcval: " << rcval[0] << std::endl;
std::cerr << "rcval: " << rcval[1] << std::endl;
std::cerr << "rcval: " << rcval[2] << std::endl;
std::cerr << "rcval: " << rcval[3] << std::endl;
std::cerr << "rcval: " << rcval[4] << std::endl;
std::cerr << "rcval: " << rcval[5] << std::endl;

rcval[0]=0.;
rcval[1]=0.;
rcval[2]=0.;
info=cp_lre(component,CP_TEMPS,&tt1,&tt2,&i,(char*)"ae",3,&mval,rcval);
std::cerr << "info: " << info << std::endl;
std::cerr << "rcval: " << rcval[0] << std::endl;
std::cerr << "rcval: " << rcval[1] << std::endl;
std::cerr << "rcval: " << rcval[2] << std::endl;

rival[0]=0;
rival[1]=0;
rival[2]=0;
i=1;
info=cp_llo(component,CP_TEMPS,&tt1,&tt2,&i,(char*)"af",3,&mval,rival);
std::cerr << "info: " << info << std::endl;
std::cerr << "rival: " << rival[0] << std::endl;
std::cerr << "rival: " << rival[1] << std::endl;
std::cerr << "rival: " << rival[2] << std::endl;

info=cp_lln(component,CP_TEMPS,&tt1,&tt2,&i,(char*)"ag",3,&mval,rlval);
std::cerr << "info: " << info << std::endl;
std::cerr << "rlval: " << rlval[0] << std::endl;
std::cerr << "rlval: " << rlval[1] << std::endl;
std::cerr << "rlval: " << rlval[2] << std::endl;

rival[0]=0;
rival[1]=0;
rival[2]=0;
i=1;
info=cp_len(component,CP_TEMPS,&tt1,&tt2,&i,(char*)"ah",3,&mval,rival);
std::cerr << "info: " << info << std::endl;
std::cerr << "rival: " << rival[0] << std::endl;
std::cerr << "rival: " << rival[1] << std::endl;
std::cerr << "rival: " << rival[2] << std::endl;

info=cp_llg(component,CP_TEMPS,&tt1,&tt2,&i,(char*)"ai",3,&mval,rlval);
std::cerr << "info: " << info << std::endl;
std::cerr << "rlval: " << rlval[0] << std::endl;
std::cerr << "rlval: " << rlval[1] << std::endl;
std::cerr << "rlval: " << rlval[2] << std::endl;

info=cp_fint(component,(char*)"aa",0.5);
std::cerr << "info: " << info << std::endl;

info=cp_efft(component,(char*)"aa",1.5);
std::cerr << "info: " << info << std::endl;

c=2*rval[0];
std::cerr << "c: " << c << std::endl;
"""
c1=CPPComponent("compo1",services=[
          Service("s1",inport=[("a","double"),("b","double")],
                       outport=[("c","double")],
                       instream=[("aa","CALCIUM_double","T"),
                                 ("ab","CALCIUM_string","T"),
                                 ("ac","CALCIUM_integer","T"),
                                 ("ad","CALCIUM_complex","T"),
                                 ("ae","CALCIUM_real","T"),
                                 ("af","CALCIUM_logical","T"),
                                 ("ag","CALCIUM_long","T"),
                                 ("ah","CALCIUM_integer","T"),
                                 ("ai","CALCIUM_integer","T"),
                                ],
                       outstream=[("ba","CALCIUM_double","T"),
                                  ("bb","CALCIUM_string","T"),
                                  ("bc","CALCIUM_integer","T"),
                                  ("bd","CALCIUM_complex","T"),
                                  ("be","CALCIUM_real","T"),
                                  ("bf","CALCIUM_logical","T"),
                                  ("bg","CALCIUM_long","T"),
                                  ("bh","CALCIUM_integer","T"),
                                  ("bi","CALCIUM_integer","T"),
                                 ],
                       defs="//def1",body=body,
                 ),
          ],
         )

# python component

defs="""
"""

body="""
#b1
info,name= calcium.cp_cd(component)
print ("name=",name)
print ("info=",info)
dep=calcium.CP_TEMPS

#double
val=numpy.zeros(10,'d')
val[0]=7.7
val[5]=a*b
nval=10
print ("--------> Appel calcium.cp_edb",val)
info=calcium.cp_edb(component, dep, 0., 1, "ba", nval,val)
info=calcium.cp_edb(component, dep, 1., 2, "ba", nval,val)
info=calcium.cp_edb(component, dep, 2., 3, "ba", nval,val)

#string
val=numpy.array(["coucouc ","bonjour ","salut "])
val=calcium.stringArray(3,8)
val[0]="coucouc"
val[1]="bonjour"
val[2]="salut"
print ("--------> Appel calcium.cp_ech",val)
info=calcium.cp_ech(component, dep, 0., 1, "bb", 3,val)

#int
val=numpy.zeros(10,'i')
val[0]=1
val[1]=3
print ("--------> Appel calcium.cp_een",val)
info=calcium.cp_een(component, dep, 0., 1, "bc", 3,val)

val=numpy.zeros(10,'F')
val[0]=1+2j
val[1]=3+2j
print ("--------> Appel calcium.cp_ecp",val)
info=calcium.cp_ecp(component, dep, 0., 1, "bd", 3,val)

val=numpy.zeros(10,'f')
val[0]=1.3
val[1]=3.2
print ("--------> Appel calcium.cp_ere",val)
info=calcium.cp_ere(component, dep, 0., 1, "be", 3,val)

val=numpy.zeros(10,'i')
val[0]=True
val[1]=False
val[2]=False
print ("--------> Appel calcium.cp_elo",val)
info=calcium.cp_elo(component, dep, 0., 1, "bf", 3,val)

val=numpy.zeros(10,'l')
val[0]=1
val[1]=3
val[2]=333
print ("--------> Appel calcium.cp_eln",val)
info=calcium.cp_eln(component, dep, 0., 1, "bg", 3,val)

val=numpy.zeros(10,'i')
val[0]=1
val[1]=3
val[2]=4
print ("--------> Appel calcium.cp_een",val)
info=calcium.cp_een(component, dep, 0., 1, "bh", 3,val)

val=numpy.zeros(10,'l')
val[0]=1
val[1]=3
val[2]=333
print ("--------> Appel calcium.cp_elg",val)
info=calcium.cp_elg(component, dep, 0., 1, "bi", 3,val)
print ("info=",info)

#read
val=numpy.zeros(10,'d')
print ("--------> Appel calcium.cp_ldb")
info,tt,ii,mval=calcium.cp_ldb(component, dep, 0.,1., 1, "aa", 3,val)
print (mval,val)

val=numpy.array(["","","",], dtype='S13')
print ("--------> Appel calcium.cp_lch")
info,tt,ii,mval=calcium.cp_lch(component, dep, 0.,1., 1, "ab", 3,val)
print (mval,val)
print (val.dtype)

val=numpy.array(["            ","  ","  ",], dtype='S13')
print ("--------> Appel calcium.cp_lch")
info,tt,ii,mval=calcium.cp_lch(component, dep, 0.,1., 1, "ab", 3,val)
print (mval,val)
print (val.dtype)

val=calcium.stringArray(3,8)
print ("--------> Appel calcium.cp_lch")
info,tt,ii,mval=calcium.cp_lch(component, dep, 0.,1., 1, "ab", 3,val)
print (mval,val)
print (val[0])
print (val[1])
print (val[2])

val=numpy.zeros(10,'i')
print ("--------> Appel calcium.cp_len")
info,tt,ii,mval=calcium.cp_len(component, dep, 0.,1., 1, "ac", 3,val)
print (mval,val)

val=numpy.zeros(10,'F')
print ("--------> Appel calcium.cp_lcp")
info,tt,ii,mval=calcium.cp_lcp(component, dep, 0.,1., 1, "ad", 3,val)
print (mval,val)

val=numpy.zeros(10,'f')
print ("--------> Appel calcium.cp_lre")
info,tt,ii,mval=calcium.cp_lre(component, dep, 0.,1., 1, "ae", 3,val)
print (mval,val)

val=numpy.zeros(10,'i')
print ("--------> Appel calcium.cp_llo")
info,tt,ii,mval=calcium.cp_llo(component, dep, 0.,1., 1, "af", 3,val)
print (mval,val)

val=numpy.zeros(10,'l')
print ("--------> Appel calcium.cp_lln")
info,tt,ii,mval=calcium.cp_lln(component, dep, 0.,1., 1, "ag", 3,val)
print (mval,val)

val=numpy.zeros(10,'i')
print ("--------> Appel calcium.cp_len")
info,tt,ii,mval=calcium.cp_len(component, dep, 0.,1., 1, "ah", 3,val)
print (mval,val)

val=numpy.zeros(10,'l')
print ("--------> Appel calcium.cp_llg")
info,tt,ii,mval=calcium.cp_llg(component, dep, 0.,1., 1, "ai", 3,val)
print ("info=",info)
print (mval,val)

info=calcium.cp_fint(component,"aa",0.5)
print ("info=",info)

info=calcium.cp_efft(component,"aa",1.5)
print ("info=",info)

import time
time.sleep(15)

c=a+b
d=a-b
err=calcium.cp_fin(component,calcium.CP_ARRET)
print ("err=",err)
"""
c2=PYComponent("compo2",services=[
          Service("s1",inport=[("a","double"),("b","double")],
                       outport=[("c","double"),("d","double")],
                       instream=[("aa","CALCIUM_double","T"),
                                 ("ab","CALCIUM_string","T"),
                                 ("ac","CALCIUM_integer","T"),
                                 ("ad","CALCIUM_complex","T"),
                                 ("ae","CALCIUM_real","T"),
                                 ("af","CALCIUM_logical","T"),
                                 ("ag","CALCIUM_long","T"),
                                 ("ah","CALCIUM_integer","T"),
                                 ("ai","CALCIUM_integer","T"),
                                ],
                       outstream=[("ba","CALCIUM_double","T"),
                                  ("bb","CALCIUM_string","T"),
                                  ("bc","CALCIUM_integer","T"),
                                  ("bd","CALCIUM_complex","T"),
                                  ("be","CALCIUM_real","T"),
                                  ("bf","CALCIUM_logical","T"),
                                  ("bg","CALCIUM_long","T"),
                                  ("bh","CALCIUM_integer","T"),
                                  ("bi","CALCIUM_integer","T"),
                                 ],
                       defs=defs,body=body,
                 ),
             ],
         )

#fortran component

cwd=os.getcwd()

c3=F77Component("fcode1", 
                services=[
                          Service("serv1",
                                  inport=[("a","double"),("b","double")],
                                  outport=[("c","double")],
                                  instream=[("aa","CALCIUM_double","T"),
                                            ("ab","CALCIUM_string","T"),
                                            ("ac","CALCIUM_integer","T"),
                                            ("ad","CALCIUM_complex","T"),
                                            ("ae","CALCIUM_real","T"),
                                            ("af","CALCIUM_logical","T"),
                                            ("ag","CALCIUM_long","T"),
                                            ("ah","CALCIUM_integer","T"),
                                            ("ai","CALCIUM_integer","T"),
                                           ],
                                  outstream=[("ba","CALCIUM_double","T"),
                                             ("bb","CALCIUM_string","T"),
                                             ("bc","CALCIUM_integer","T"),
                                             ("bd","CALCIUM_complex","T"),
                                             ("be","CALCIUM_real","T"),
                                             ("bf","CALCIUM_logical","T"),
                                             ("bg","CALCIUM_long","T"),
                                             ("bh","CALCIUM_integer","T"),
                                             ("bi","CALCIUM_integer","T"),
                                            ],
                                 ),
                         ],
                libs=[Library(name="code1", path=cwd)],
                rlibs=cwd,
               )

g=Generator(Module("pycompos",components=[c1,c2,c3],prefix="./install"),context)
g.generate()
g.configure()
g.make()
g.install()
g.make_appli("appli", restrict=["KERNEL"], altmodules={"GUI":GUI_ROOT_DIR,
                      "YACS":YACS_ROOT_DIR}, sys_modules=SYS_MODULES)



