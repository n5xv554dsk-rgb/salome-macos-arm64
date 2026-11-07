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
"""
  Module that generates SALOME c++ Component from a non SALOME c++ component (its header and its shares library)
"""

debug=1
import os
from module_generator.gener import Component, Invalid
from module_generator.hxx_para_tmpl import cxxService, hxxCompo, cxxCompo, cmake_src_compo_hxxpara
from module_generator import Service
from tempfile import mkstemp
from module_generator.yacstypes import corba_rtn_type,moduleTypes
from module_generator.gener import Library

class HXX2SALOMEParaComponent(Component):
  def __init__(self, hxxfile , cpplib , cpp_path ):
    # search a file within a directory tree
    import fnmatch
    def search_file(pattern, root):
        matches = []
        for path, dirs, files in os.walk(os.path.abspath(root)):
            for filename in fnmatch.filter(files, pattern):
                 matches.append(os.path.join(path, filename))
        return matches

    hxxfileful=search_file(hxxfile,cpp_path)
    cpplibful=search_file(cpplib,cpp_path)
    assert len(hxxfileful) > 0  ,'Error in HXX2SALOMEComponent : file ' + hxxfile + ' not found in ' + cpp_path
    assert len(cpplibful) > 0   ,'Error in HXX2SALOMEComponent : file ' + cpplib + ' not found in ' + cpp_path

    self.hxxfile=hxxfile  # to include it in servant implementation

    # grab name of c++ component
    from .hxx_awk import parse01,parse1,parse2,parse3
    cmd1="""awk '$1 == "class" && $0 !~ /;/ {print $2}' """ + hxxfileful[0] + """|awk -F: '{printf "%s",$1}' """
    f=os.popen(cmd1)
    class_name=f.readlines()[0]
    name=class_name
    print("classname=",class_name)

    if cpplib[:3]=="lib" and cpplib[-3:]==".so":
        cpplibname=cpplib[3:-3]  # get rid of lib and .so, to use within makefile.am
    else:
        cpplibname=class_name+"CXX"  # the default name

    f.close()

    # create temporary awk files
    (fd01,p01n)=mkstemp()
    f01=os.fdopen(fd01,"w")
    f01.write(parse01)
    f01.close()

    (fd1,p1n)=mkstemp()
    f1=os.fdopen(fd1,"w")
    f1.write(parse1)
    f1.close()

    (fd2,p2n)=mkstemp()
    f2=os.fdopen(fd2,"w")
    f2.write(parse2)
    f2.close()

    (fd3,p3n)=mkstemp()
    f3=os.fdopen(fd3,"w")
    f3.write(parse3)
    f3.close()

    # awk parsing of hxx files - result written in file parse_type_result
    cmd2="cat " + hxxfileful[0] + " | awk -f " + p01n + """ | sed 's/virtual //g' | sed 's/MEDMEM_EXPORT//g' | sed 's/throw.*;/;/g' | awk -f """ + p1n + " | awk -f " + p2n + " | awk -v class_name=" + class_name + " -f " + p3n
    os.system(cmd2)
    os.remove(p01n)
    os.remove(p1n)
    os.remove(p2n)
    os.remove(p3n)

    # Retrieve the information which was generated in the file parse_type_result.
    # The structure of the file is :
    #
    #   Function  return_type   function_name
    #   [arg1_type  arg1_name]
    #   [arg2_type  arg2_name]
    #   ...
    # The service names are stored in list_of_services
    # The information relative to a service (called service_name) is stored in the dictionnary service_definition[service_name]
    from .hxx_awk import cpp2idl_mapping
    from .hxx_awk import cpp2yacs_mapping
    cpp2yacs_mapping["const MEDCoupling::MEDCouplingFieldDouble*"]="SALOME_MED/MPIMEDCouplingFieldDoubleCorbaInterface"
    cpp2yacs_mapping["const MEDCoupling::MEDCouplingFieldDouble&"]="SALOME_MED/MPIMEDCouplingFieldDoubleCorbaInterface"
    cpp2yacs_mapping["MEDCoupling::MEDCouplingFieldDouble*&"]="SALOME_MED/MPIMEDCouplingFieldDoubleCorbaInterface"
    cpp2yacs_mapping["MEDCoupling::MEDCouplingFieldDouble*"]="SALOME_MED/MPIMEDCouplingFieldDoubleCorbaInterface"
    list_of_services=[]
    service_definition={}
    result_parsing=open("parse_type_result","r")
    for line in result_parsing.readlines():
        line=line[0:-1] # get rid of trailing \n
        words = line.split(';')

        if len(words) >=3 and words[0] == "Function": # detect a new service
            function_name=words[2]
            if function_name != "getInputFieldTemplate":
                list_of_services.append(function_name)
            service_definition[function_name]={}
            service_definition[function_name]["ret"]=words[1]  # return type
            service_definition[function_name]["inports"]=[]
            service_definition[function_name]["outports"]=[]
            service_definition[function_name]["ports"]=[]
            service_definition[function_name]["impl"]=[]
            service_definition[function_name]["thread_func_decl"]=[]
            service_definition[function_name]["thread_str_decl"]=[]

        if len(words) == 2 and function_name != "getInputFieldTemplate":  # an argument type and argument name of a previous service
            typename=words[0]
            argname=words[1]
            service_definition[list_of_services[-1]]["ports"].append( (argname,typename) ) # store in c++ order the arg names

            # separate in from out parameters
            inout=cpp2idl_mapping[typename][0:2]
            assert inout=="in" or inout=="ou",'Error in table cpp2idl_mapping'
            if inout == "in":
                service_definition[list_of_services[-1]]["inports"].append( (argname,typename) )
            else:
                service_definition[list_of_services[-1]]["outports"].append( (argname,typename) )

    if 'getInputFieldTemplate' in service_definition:
        del service_definition['getInputFieldTemplate']
    #
    # generate implementation of c++ servant
    # store it in service_definition[serv]["impl"]
    #
    from .hxx_awk import cpp_impl_a,cpp_impl_b,cpp_impl_c  # these tables contain the part of code which depends upon c++ types
    cpp_impl_b["MEDCoupling::MEDCouplingFieldDouble*"]="""\tMEDCoupling::MPIMEDCouplingFieldDoubleServant * _rtn_field_i = new MEDCoupling::MPIMEDCouplingFieldDoubleServant(_orb,_poa,this,_rtn_cpp);
\t_rtn_cpp->decrRef();
\tSALOME_MED::MPIMEDCouplingFieldDoubleCorbaInterface_ptr _rtn_ior = _rtn_field_i->_this();\n"""
    cpp_impl_a["const MEDCoupling::MEDCouplingFieldDouble*"]="\tMEDCoupling::MEDCouplingFieldDouble* _%(arg)s=cppCompo_->getInputFieldTemplate();\n\t_setInputField(%(arg)s,_%(arg)s);\n\t_initializeCoupling(%(arg)s);\n"

    from .yacstypes import corbaTypes,corbaOutTypes
    format_thread_signature="void * th_%s(void * st);" # this thread declaration will be included in servant's header
    format_thread_struct="typedef struct {\n  int ip;\n  Engines::IORTab* tior;\n%(arg_decl)s} thread_%(serv_name)s_str;" # this thread declaration will be included in servant's header
    format_thread_create="""
//      create threads to forward to other processes the service invocation
        if(_numproc == 0)
        {
            th = new pthread_t[_nbproc];
            for(int ip=1;ip<_nbproc;ip++)
            {
                %(init_thread_str)s
                pthread_create(&(th[ip]),NULL,th_%(serv_name)s,(void*)st);
            }
        }
"""
    s_thread_join="""
//      waiting for all threads to complete
        if(_numproc == 0)
        {
            for(int ip=1;ip<_nbproc;ip++)
            {
                pthread_join(th[ip],&ret_th);
                est = (except_st*)ret_th;
                if(est->exception)
                {
                    ostringstream msg;
                    msg << "[" << ip << "] " << est->msg;
                    THROW_SALOME_CORBA_EXCEPTION(msg.str().c_str(),SALOME::INTERNAL_ERROR);
                }
                delete est;
            }
          delete[] th;
        }
"""
    format_thread_impl="""
void *th_%(serv_name)s(void *s)
{
  ostringstream msg;
  thread_%(serv_name)s_str *st = (thread_%(serv_name)s_str*)s;
  except_st *est = new except_st;
  est->exception = false;

  try
    {
      %(module)s_ORB::%(component_name)s_Gen_var compo = %(module)s_ORB::%(component_name)s_Gen::_narrow((*(st->tior))[st->ip]);
      compo->%(serv_name)s(%(arg_thread_invocation)s);
    }
  catch(const SALOME::SALOME_Exception &ex)
    {
      est->exception = true;
      est->msg = ex.details.text;
    }
  catch(const CORBA::Exception &ex)
    {
      est->exception = true;
      msg << "CORBA::Exception: " << ex;
      est->msg = msg.str();
    }
  delete st;
  return((void*)est);
}

"""

    self.thread_impl=""  # the implementation of the thread functions used to invoque services on slave processors 
    for serv in list_of_services:
        if debug:
            print("service : ",serv)
            print("  inports  -> ",service_definition[serv]["inports"])
            print("  outports -> ",service_definition[serv]["outports"])
            print("  return   -> ",service_definition[serv]["ret"])

        # Part 0 : specific treatments for parallel components (call threads to forward the invocation to the service to all processes)
        service_definition[serv]["thread_func_decl"]=format_thread_signature % serv
        arg_declaration=""
        arg_thread_invocation=""
        init_thread_str="thread_%s_str *st = new thread_%s_str;" % (serv,serv) 
        init_thread_str+="\n                st->ip = ip;"
        init_thread_str+="\n                st->tior = _tior;"
        for (argname,argtype) in service_definition[serv]["inports"]:
            arg_declaration+="  "+corbaTypes[cpp2yacs_mapping[argtype]]+" "+argname+";\n"
            init_thread_str+="\n                st->"+argname+" = "+argname+";"
        for (argname,argtype) in service_definition[serv]["outports"]:
            arg_declaration+="  "+corbaOutTypes[cpp2yacs_mapping[argtype]]+" "+argname+";\n"
            init_thread_str+="\n                st->"+argname+" = "+argname+";"
        for (argname,argtype) in service_definition[serv]["ports"]:
            arg_thread_invocation+="st->"+argname+", "
        if len(arg_thread_invocation)>0:
            arg_thread_invocation=arg_thread_invocation[0:-2] # get rid of trailing comma
        service_definition[serv]["thread_str_decl"]=format_thread_struct % { "serv_name" : serv, "arg_decl" : arg_declaration }
        s_thread_call=format_thread_create % { "serv_name" : serv , "init_thread_str" : init_thread_str}
        # within format_thread_impl the treatment of %(module) is postponed in makecxx() because we don't know here the module name
        self.thread_impl+=format_thread_impl % {"serv_name" : serv , "arg_thread_invocation" : arg_thread_invocation , "component_name" : name, "module" : "%(module)s" } 

        # Part 1 : Argument pre-processing
        s_argument_processing="//\tArguments processing\n"
        for (argname,argtype) in service_definition[serv]["inports"] + service_definition[serv]["outports"]:
            format=cpp_impl_a[argtype]
            s_argument_processing += format % {"arg" : argname }
        if s_argument_processing=="//\tArguments processing\n": # if there was no args
            s_argument_processing=""

        # if an argument called name is of type const char*, this argument is transmitted to getInputFieldTemplate()
        # => we insert "name" between the bracket of getInputFieldTemplate()
        indice_getInputFieldTemplate=s_argument_processing.find ("cppCompo_->getInputFieldTemplate();")
        if s_argument_processing.find ("const std::string _name") != -1  and  indice_getInputFieldTemplate != -1:
            ind_insertion=indice_getInputFieldTemplate+33
            s_argument_processing=s_argument_processing[:ind_insertion]+"name"+s_argument_processing[ind_insertion:-1]

        # Part 2 : Call to the underlying c++ function
        s_call_cpp_function="//\tCall cpp component\n\t"
        rtn_type=service_definition[serv]["ret"]
        if rtn_type == "void" : # if return type is void, the call syntax is different
            s_call_cpp_function += "cppCompo_->%s(" % serv
        else:
            s_call_cpp_function += "%s _rtn_cpp = cppCompo_->%s(" % (rtn_type ,serv )

        for (argname,argtype) in service_definition[serv]["ports"]:
              # special treatment for some arguments
              post=""
              pre=""
              if cpp_impl_a[argtype].find("auto_ptr" ) != -1 :
                  post=".get()" # for auto_ptr argument, retrieve the raw pointer behind
              if  argtype == "const MEDMEM::MESH&"  or  argtype == "const MEDMEM::SUPPORT&" : 
                  pre="*"  # we cannot create MESHClient on the stack (private constructor), so we create it on the heap and dereference it
              post+="," # separator between arguments
              s_call_cpp_function += " %s_%s%s" % ( pre,argname,post)
        if s_call_cpp_function[-1]==',':
            s_call_cpp_function=s_call_cpp_function[0:-1] # get rid of trailing comma
        s_call_cpp_function=s_call_cpp_function+');\n'

        # Part 3.a : Out Argument Post-processing
        s_argument_postprocessing="//\tPost-processing & return\n"
        for (argname,argtype) in service_definition[serv]["outports"]:
            format=cpp_impl_c[argtype]
            s_argument_postprocessing += format % {"arg" : argname, "module" : "%(module)s" } # the treatment of %(module) is postponed in makecxx() 
                                                                                              # because we don't know here the module name
        # Part 3.b : In Argument Post-processing
        for (argname,argtype) in service_definition[serv]["inports"]:
            if argtype in cpp_impl_c: # not all in types require a treatment
                format=cpp_impl_c[argtype]
                s_argument_postprocessing += format % {"arg" : argname, "module" : "%(module)s" } # id : treatment of %(module) is postponed in makecxx

        # Part 3.c : return processing
        s_rtn_processing=cpp_impl_b[rtn_type]
        if  rtn_type != "void":
            s_rtn_processing += "\treturn _rtn_ior;"

        service_definition[serv]["impl"] = s_thread_call + s_argument_processing + s_call_cpp_function + s_thread_join  + s_argument_postprocessing + s_rtn_processing
        if debug:
            print("implementation :\n",service_definition[serv]["impl"])

    #
    # Create a list of Service objects (called services), and give it to Component constructor
    #
    services=[]
    self.use_medmem=False
    self.use_medcoupling=False
    self.thread_func_decl=[]
    self.thread_str_decl=[]
    for serv in list_of_services:
        # for inports and outports, Service class expects a list of tuples, each tuple containing the name and the yacs type of the port
        # thus we need to convert c++ types to yacs types  (we use for that the cpp2yacs_mapping table
        inports=[]
        for i in range( len(service_definition[serv]["inports"]) ):
            inports.append( [service_definition[serv]["inports"][i][0], cpp2yacs_mapping[service_definition[serv]["inports"][i][1]] ] )
        outports=[]
        for i in range( len(service_definition[serv]["outports"]) ):
            outports.append( [service_definition[serv]["outports"][i][0], cpp2yacs_mapping[service_definition[serv]["outports"][i][1]] ] )

        Return="void"
        if service_definition[serv]["ret"] != "void":
            Return=cpp2yacs_mapping[service_definition[serv]["ret"]]

        # find out if component uses medmem types and/or medcoupling types
        for (argname,argtype) in inports + outports + [("return",Return)]:
            if moduleTypes[argtype]=="MED":
                if argtype.count("Coupling")>0:
                    self.use_medcoupling=True
                else:
                    self.use_medmem=True
                break

        code=service_definition[serv]["impl"]
        if debug:
            print("service : ",serv)
            print("  inports  -> ",service_definition[serv]["inports"])
            print("  converted inports  -> ",inports)
            print("  outports -> ",service_definition[serv]["outports"])
            print("  converted outports  -> ",outports)
            print("  Return  -> ",service_definition[serv]["ret"])
            print("  converted Return  -> ",Return)

        services.append(Service(serv, 
           inport=inports, 
           outport=outports,
           ret=Return, 
           defs="", 
           body=code,
           ) )
        self.thread_func_decl.append(service_definition[serv]["thread_func_decl"])
        self.thread_str_decl.append(service_definition[serv]["thread_str_decl"])
#    Includes="-I${"+name+"CPP_ROOT_DIR}/include"
    Includes = os.path.join(cpp_path, "include")
#    Libs="-L${"+name+"CPP_ROOT_DIR}/lib -l"+cpplibname
#    Libs=[cpplibname+" PATH "+ os.path.join(cpp_path, "lib") ]
    Libs = [ Library( name=cpplibname, path=os.path.join(cpp_path, "lib"))]
    Compodefs=""
    Inheritedclass=""
    self.inheritedconstructor=""
    Compodefs="""
#include CORBA_SERVER_HEADER(MEDCouplingCorbaServantTest)
#include "MPIMEDCouplingFieldDoubleServant.hxx"
"""

    Component.__init__(self, name, services, impl="CPP", libs=Libs,
                             rlibs="", includes=Includes, kind="lib",
                             sources=None,inheritedclass=Inheritedclass,
                             compodefs=Compodefs)

# -----------------------------------------------------------------------------      
  def libraryName(self):
    """ Name of the target library
    """
    return self.name + "Engine"
    
# ------------------------------------------------------------------------------
  def targetProperties(self):
    """ define the rpath property of the target using self.rlibs
    return
      string containing the commands to add to cmake
    """
    text=""
    if self.rlibs.strip() :
      text="SET_TARGET_PROPERTIES( %sEngine PROPERTIES INSTALL_RPATH %s)\n" % (self.name, self.rlibs)
    return text

# ------------------------------------------------------------------------------
  def makeCompo(self, gen):
    """generate files for C++ component

       return a dict where key is the file name and value is the content of the file
    """
    cxxfile = "%s_i.cxx" % self.name
    hxxfile = "%s_i.hxx" % self.name
    (cmake_text, cmake_vars) = self.additionalLibraries()
    
    cmakelist_content = cmake_src_compo_hxxpara.substitute(
                        module = gen.module.name,
                        component = self.name,
                        componentlib = self.libraryName(),
                        includes = self.includes,
                        libs = cmake_vars,
                        find_libs = cmake_text,
                        target_properties = self.targetProperties()
                        )
    
    return {"CMakeLists.txt":cmakelist_content,
            cxxfile:self.makecxx(gen),
            hxxfile:self.makehxx(gen)
           }

#  def getMakefileItems(self,gen):
#      makefileItems={"header":"""
#include $(top_srcdir)/adm_local/make_common_starter.am
#
#"""}
#      makefileItems["lib_LTLIBRARIES"]=["lib"+self.name+"Engine.la"]
#      makefileItems["salomeinclude_HEADERS"]=["%s_i.hxx" % self.name]
#      makefileItems["body"]=compoMakefile.substitute(module=gen.module.name,
#                                                     component=self.name,
#                                                     libs=self.libs,
#                                                     includes=self.includes)
#      return makefileItems

  def makehxx(self, gen):
    """return a string that is the content of .hxx file
    """
    services = []
    for serv in self.services:
      service = "    %s %s(" % (corba_rtn_type(serv.ret,gen.module.name),serv.name)
      service = service+gen.makeArgs(serv)+") throw (SALOME::SALOME_Exception);"
      services.append(service)
    servicesdef = "\n".join(services)

    inheritedclass=self.inheritedclass
    thread_func_decl="\n".join(self.thread_func_decl)
    thread_str_decl="\n".join(self.thread_str_decl)
    if debug:
        print("thread_func_decl : ")
        print(thread_func_decl)
        print("thread_str_decl : ")
        print(thread_str_decl)

    if self.inheritedclass:
      inheritedclass= " public virtual " + self.inheritedclass + ","

    return hxxCompo.substitute(component=self.name, module=gen.module.name, thread_func_decl=thread_func_decl,
                               thread_str_decl=thread_str_decl, servicesdef=servicesdef, inheritedclass=inheritedclass,
                               compodefs=self.compodefs)

  def makecxx(self, gen, exe=0):
    """return a string that is the content of .cxx file
    """
    services = []
    inits = []
    defs = []
    for serv in self.services:
      defs.append(serv.defs)
      service = cxxService.substitute(component=self.name, service=serv.name,ret=corba_rtn_type(serv.ret,gen.module.name),
                                      parameters=gen.makeArgs(serv),
                                      body=serv.body % {"module":gen.module.name+"_ORB"} )
      services.append(service)
    return cxxCompo.substitute(component=self.name, cxx_include_file=self.hxxfile,
                               inheritedconstructor=self.inheritedconstructor,
                               servicesdef="\n".join(defs),
                               servicesimpl="\n".join(services),
                               thread_impl=self.thread_impl % {"module":gen.module.name} )

  def getIdlInterfaces(self):
    services = self.getIdlServices()
    from .hxx_tmpl import interfaceidlhxx
    Inherited=""
    Inherited="SALOME_MED::ParaMEDMEMComponent"
    return interfaceidlhxx.substitute(component=self.name,inherited=Inherited, services="\n".join(services))

  def getIdlDefs(self):
    idldefs="""#include "ParaMEDMEMComponent.idl"\n"""
    if self.interfacedefs:
      idldefs = idldefs + self.interfacedefs
    return idldefs

  def getDependentModules(self):
    """ This component depends on "MED" because it inherits from ParaMEDMEMComponent
    """
    depend_modules = Component.getDependentModules(self)
    depend_modules.add("MED")
    return depend_modules
