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
  Module that generates SALOME c++ Component from a non SALOME c++ component 
  (its header and its shares library)
"""

debug=1
import os
import fnmatch
from tempfile import mkstemp
from module_generator.gener import Component, Invalid
from module_generator.hxx_tmpl import cxxService, hxxCompo, cxxCompo, cmake_src_compo_hxx
from module_generator import Service
from module_generator.yacstypes import corba_rtn_type,moduleTypes
from module_generator.hxx_awk import parse01,parse1,parse2,parse3
from module_generator.hxx_awk import cpp2idl_mapping
# these tables contain the part of code which depends upon c++ types
from module_generator.hxx_awk import cpp_impl_a,cpp_impl_b,cpp_impl_c  
from module_generator.hxx_awk import cpp2yacs_mapping
from tempfile import mkdtemp
from module_generator.hxx_tmpl_gui import hxxgui_cxx, hxxgui_h, hxxgui_icon_ts
from module_generator.hxx_tmpl_gui import hxxgui_message_en, hxxgui_message_fr
from module_generator.hxx_tmpl_gui import hxxgui_config, hxxgui_xml_fr, hxxgui_xml_en
from module_generator.gener import Library
from module_generator.gui_tmpl import cppsalomeapp

# ------------------------------------------------------------------------------

class HXX2SALOMEComponent(Component):
  def __init__(self, hxxfile , cpplib , cpp_path ):
    # search a file within a directory tree
    def search_file(pattern, root):
        matches = []
        for path, dirs, files in os.walk(os.path.abspath(root)):
            for filename in fnmatch.filter(files, pattern):
                 matches.append(os.path.join(path, filename))
        return matches

    hxxfileful = search_file(hxxfile,cpp_path)
    cpplibful = search_file(cpplib,cpp_path)
    format_error = 'Error in HXX2SALOMEComponent : file %s not found in %s'
    assert len(hxxfileful) > 0, format_error %  (hxxfile, cpp_path)
    assert len(cpplibful) > 0, format_error % (cpplib, cpp_path)
    hxxfile = hxxfileful[0]
    cpplib = cpplibful[0]

    # grab name of c++ component
    cmd1="""awk '$1 == "class" && $0 !~ /;/ {print $2}' """ + hxxfile +\
         """|awk -F: '{printf "%s",$1}' """
    f=os.popen(cmd1)
    class_name=f.readlines()[0]
    name=class_name
    print("classname=",class_name)
    f.close()

    # create temporary awk files for the parsing
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

    # awk parsing of hxx files - 
    # result written in file parse_type_result
    cmd2 = [
        "cat %s" % hxxfile,
        "awk -f %s" % p01n,
        "sed 's/virtual //g'",
        "sed 's/MEDMEM_EXPORT//g'",
        "sed 's/throw.*;/;/g'",
        "awk -f %s" % p1n,
        "awk -f %s" % p2n,
        "awk -v class_name=%s -f %s" % (class_name, p3n) ]
    cmd2 = ' | '.join(cmd2)

    #os.system(cmd2)
    import subprocess, sys
    subprocess.call(cmd2, shell=True, stdout=sys.stdout, stderr=subprocess.STDOUT)
    os.remove(p01n)
    os.remove(p1n)
    os.remove(p2n)
    os.remove(p3n)

    # Retrieve the information which was generated in 
    # the file parse_type_result.
    # The structure of the file is :
    #
    #   Function  return_type   function_name
    #   [arg1_type  arg1_name]
    #   [arg2_type  arg2_name]
    #   ...
    # The service names are stored in list_of_services
    # The information relative to a service (called service_name) is stored in
    # the dictionnary service_definition[service_name]
    list_of_services=[]
    service_definition={}
    result_parsing=open("parse_type_result","r")
    for line in result_parsing.readlines():
        line=line[0:-1] # get rid of trailing \n
        words = line.split(';')

        if len(words) >=3 and words[0] == "Function": # detect a new service
            function_name=words[2]
            # store the name of new service
            list_of_services.append(function_name) 
            # create a dict to store informations relative to this service
            service_definition[function_name]={} 
            service_definition[function_name]["ret"]=words[1]  # return type
            service_definition[function_name]["inports"]=[]
            service_definition[function_name]["outports"]=[]
            service_definition[function_name]["ports"]=[]
            service_definition[function_name]["impl"]=[]

        # an argument type and argument name of the current service
        if len(words) == 2:  
            current_service=list_of_services[-1]
            current_service_dict=service_definition[current_service]
            typename=words[0]
            argname=words[1]
            # store in c++ order the arg names
            current_service_dict["ports"].append( (argname,typename) ) 

            # separate in from out parameters
            inout=cpp2idl_mapping[typename][0:2]
            assert inout=="in" or inout=="ou",'Error in table cpp2idl_mapping'
            if inout == "in":
                current_service_dict["inports"].append((argname, typename) )
            else:
                current_service_dict["outports"].append((argname, typename) )
    #
    # For each service : 
    #  - generate implementation of c++ servant
    #  - store it in service_definition[serv]["impl"]
    for serv in list_of_services:
        if debug:
            print("service : ",serv)
            print("  inports  -> ",service_definition[serv]["inports"])
            print("  outports -> ",service_definition[serv]["outports"])
            print("  return   -> ",service_definition[serv]["ret"])


        # Part 1 : Argument pre-processing
        s_argument_processing="//\tArguments processing\n"
        for (argname,argtype) in service_definition[serv]["inports"] + \
                                 service_definition[serv]["outports"]:
            format=cpp_impl_a[argtype]
            s_argument_processing += format % {"arg" : argname }

        # if there was no args
        if s_argument_processing=="//\tArguments processing\n": 
            s_argument_processing=""


        # Part 2 : Call to the underlying c++ function
        s_call_cpp_function="//\tCall cpp component\n\t"
        rtn_type=service_definition[serv]["ret"]

        # if return type is void, the call syntax is different
        if rtn_type == "void" : 
            s_call_cpp_function += "cppCompo_->%s(" % serv
        else:
            s_call_cpp_function +=\
                "%s _rtn_cpp = cppCompo_->%s(" % (rtn_type ,serv )

        for (argname,argtype) in service_definition[serv]["ports"]:
              # special treatment for some arguments
              post=""
              pre=""

              if cpp_impl_a[argtype].find("auto_ptr" ) != -1 :
                  # for auto_ptr argument, retrieve the raw pointer behind
                  post=".get()" 
              if  argtype == "const MEDMEM::MESH&"  or  \
                  argtype == "const MEDMEM::SUPPORT&" : 
                  # we cannot create MESHClient on the stack 
                  # (private constructor!), 
                  # so we create it on the heap and dereference it
                  pre="*"  

              post+="," # separator between arguments
              s_call_cpp_function += " %s_%s%s" % ( pre,argname,post)
        if s_call_cpp_function[-1]==',':
            # get rid of trailing comma
            s_call_cpp_function=s_call_cpp_function[0:-1] 

        s_call_cpp_function=s_call_cpp_function+');\n'

        # Part 3.a : Out Argument Post-processing
        s_argument_postprocessing="//\tPost-processing & return\n"
        for (argname,argtype) in service_definition[serv]["outports"]:
            format=cpp_impl_c[argtype]
            # the treatment of %(module) is postponed in makecxx() 
            # because we don't know here the module name
            s_argument_postprocessing += \
                format % {"arg" : argname, "module" : "%(module)s" } 

        # Part 3.b : In Argument Post-processing
        for (argname,argtype) in service_definition[serv]["inports"]:
            # not all in types require a treatment
            if argtype in cpp_impl_c: 
                format=cpp_impl_c[argtype]
                # id : treatment of %(module) is postponed in makecxx
                s_argument_postprocessing += \
                        format % {"arg" : argname, "module" : "%(module)s" } 

        # Part 3.c : return processing
        s_rtn_processing=cpp_impl_b[rtn_type]

        format_end_serv = "\tendService(\"%(class_name)s_i::%(serv_name)s\");"
        format_end_serv += "\n\tEND_OF(\"%(class_name)s_i::%(serv_name)s\");\n"
        s_rtn_processing += format_end_serv %\
                { "serv_name" : serv, "class_name" : class_name }

        if  rtn_type != "void":
            s_rtn_processing += "\treturn _rtn_ior;"

        service_definition[serv]["impl"] = s_argument_processing + \
                                           s_call_cpp_function + \
                                           s_argument_postprocessing + \
                                           s_rtn_processing
        if debug:
            print("implementation :\n",service_definition[serv]["impl"])

    #
    # Create a list of Service objects (called services), 
    # and give it to Component constructor
    #
    services=[]
    self.use_medmem=False
    self.use_medcoupling=False
    for serv in list_of_services:
        # for inports and outports, Service class expects a list of tuples, 
        # each tuple containing the name and the yacs type of the port
        # thus we need to convert c++ types to yacs types  
        # (we use for that the cpp2yacs_mapping table)
        inports=[]
        for op in service_definition[serv]["inports"]:
            inports.append([op[0], cpp2yacs_mapping[op[1]] ] )

        outports = []
        for op in service_definition[serv]["outports"]:
            outports.append([op[0], cpp2yacs_mapping[op[1]] ] )

        Return="void"
        if service_definition[serv]["ret"] != "void":
            Return=cpp2yacs_mapping[service_definition[serv]["ret"]]

        # find out if component uses medmem types and/or medcoupling types
        for (argname,argtype) in inports + outports + [("return",Return)]:
            if moduleTypes[argtype]=="MED":
                if argtype.count("CorbaInterface")>0:
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

    Includes = os.path.join(cpp_path, "include")
    Libs = [ Library( name=name+"CXX", path=os.path.join(cpp_path, "lib"))]
    Compodefs=""
    Inheritedclass=""
    self.inheritedconstructor=""
    if self.use_medmem:
        Compodefs="""
#include CORBA_CLIENT_HEADER(MED)
#include CORBA_CLIENT_HEADER(MED_Gen)
#include "FIELDClient.hxx"
#include "MESHClient.hxx"
#include "MEDMEM_Support_i.hxx"
#include "MEDMEM_Mesh_i.hxx"
#include "MEDMEM_FieldTemplate_i.hxx"
#include "Med_Gen_Driver_i.hxx"
"""
        Inheritedclass="Med_Gen_Driver_i, public SALOMEMultiComm"
        self.inheritedconstructor="Med_Gen_Driver_i(orb),"

    if self.use_medcoupling:
        Compodefs+="""
#include CORBA_CLIENT_HEADER(MEDCouplingCorbaServant)
#include "MEDCouplingFieldDoubleServant.hxx"
#include "MEDCouplingUMeshServant.hxx"
#include "DataArrayDoubleServant.hxx"
#include "MEDCouplingFieldDouble.hxx"
#include "MEDCouplingUMesh.hxx"
#include "MEDCouplingUMeshClient.hxx"
#include "MEDCouplingFieldDouble.hxx"
#include "MEDCouplingFieldDoubleClient.hxx"
#include "MEDCouplingMemArray.hxx"
#include "DataArrayDoubleClient.hxx"
"""

    Component.__init__(self, name, services, impl="CPP", libs=Libs,
                             rlibs=os.path.dirname(cpplib), includes=Includes,
                             kind="lib", sources=None,
                             inheritedclass=Inheritedclass,compodefs=Compodefs)

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
       return a dict where key is the file name and 
       value is the content of the file
    """
    cxxfile = "%s_i.cxx" % self.name
    hxxfile = "%s_i.hxx" % self.name
    (cmake_text, cmake_vars) = self.additionalLibraries()
    
    cmakelist_content = cmake_src_compo_hxx.substitute(
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

# ------------------------------------------------------------------------------
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

# ------------------------------------------------------------------------------
  def makehxx(self, gen):
    """return a string that is the content of .hxx file
    """
    services = []
    for serv in self.services:
      service = "    %s %s(" % (corba_rtn_type(serv.ret,gen.module.name),
                                serv.name)
      service = service+gen.makeArgs(serv)+") throw (SALOME::SALOME_Exception);"
      services.append(service)
    servicesdef = "\n".join(services)

    inheritedclass=self.inheritedclass
    if self.inheritedclass:
      inheritedclass= " public virtual " + self.inheritedclass + ","

    return hxxCompo.substitute(component=self.name, 
                               module=gen.module.name,
                               servicesdef=servicesdef, 
                               inheritedclass=inheritedclass,
                               compodefs=self.compodefs)

# ------------------------------------------------------------------------------
  def makecxx(self, gen, exe=0):
    """return a string that is the content of .cxx file
    """
    services = []
    inits = []
    defs = []
    for serv in self.services:
      defs.append(serv.defs)
      print("CNC bug : ",serv.body)
      service = cxxService.substitute(
                           component=self.name, 
                           service=serv.name,
                           ret=corba_rtn_type(serv.ret,gen.module.name),
                           parameters=gen.makeArgs(serv),
                           body=serv.body % {"module":gen.module.name+"_ORB"} )
      services.append(service)
    return cxxCompo.substitute(component=self.name, 
                               inheritedconstructor=self.inheritedconstructor,
                               servicesdef="\n".join(defs),
                               servicesimpl="\n".join(services))

# ------------------------------------------------------------------------------
  def getGUIfilesTemplate(self):
      """generate in a temporary directory files for a generic GUI, 
         and return a list with file names.
         it is the responsability of the user to get rid 
         of the temporary directory when finished
      """
      gui_cxx=hxxgui_cxx.substitute(component_name=self.name)
      gui_h=hxxgui_h.substitute(component_name=self.name)
      gui_icon_ts=hxxgui_icon_ts.substitute(component_name=self.name)
      gui_message_en=hxxgui_message_en.substitute(component_name=self.name)
      gui_message_fr=hxxgui_message_fr.substitute(component_name=self.name)
      gui_config=hxxgui_config.substitute(component_name=self.name)
      gui_xml_fr=hxxgui_xml_fr.substitute(component_name=self.name)
      gui_xml_en=hxxgui_xml_en.substitute(component_name=self.name)
      gui_salomeapp_gen=cppsalomeapp.substitute(module=self.name,
                                                lmodule=self.name.lower(),
                                                version="V0")
      # for a salome component generated by hxx2salome from a c++ component, 
      # the documentation points at the c++ component documentation
      salome_doc_path=os.path.join("%"+self.name+"_ROOT_DIR%","share",
                                   "doc","salome","gui",self.name.lower(),
                                   "index.html")
      cpp_doc_path=os.path.join("%"+self.name+"CPP_ROOT_DIR%","share",
                                "doc",self.name,"index.html")
      gui_salomeapp=gui_salomeapp_gen.replace(salome_doc_path,cpp_doc_path)
      temp_dir=mkdtemp()
      gui_cxx_file_name=os.path.join(temp_dir,self.name+"GUI.cxx")
      gui_h_file_name=os.path.join(temp_dir,self.name+"GUI.h")
      gui_icon_ts_file_name=os.path.join(temp_dir,self.name+"_icons.ts")
      gui_message_en_file_name=os.path.join(temp_dir,self.name+"_msg_en.ts")
      gui_message_fr_file_name=os.path.join(temp_dir,self.name+"_msg_fr.ts")
      gui_config_file_name=os.path.join(temp_dir,"config")
      gui_xml_fr_file_name=os.path.join(temp_dir,self.name+"_en.xml")
      gui_xml_en_file_name=os.path.join(temp_dir,self.name+"_fr.xml")
      gui_salomeapp_file_name=os.path.join(temp_dir,"SalomeApp.xml")

      list_of_gui_names=[]

      gui_cxx_file=open(gui_cxx_file_name,"w")
      gui_cxx_file.write(gui_cxx)
      gui_cxx_file.close()
      list_of_gui_names.append(gui_cxx_file_name)

      gui_h_file=open(gui_h_file_name,"w")
      gui_h_file.write(gui_h)
      gui_h_file.close()
      list_of_gui_names.append(gui_h_file_name)

      gui_icon_ts_file=open(gui_icon_ts_file_name,"w")
      gui_icon_ts_file.write(gui_icon_ts)
      gui_icon_ts_file.close()
      list_of_gui_names.append(gui_icon_ts_file_name)

      gui_message_en_file=open(gui_message_en_file_name,"w")
      gui_message_en_file.write(gui_message_en)
      gui_message_en_file.close()
      list_of_gui_names.append(gui_message_en_file_name)

      gui_message_fr_file=open(gui_message_fr_file_name,"w")
      gui_message_fr_file.write(gui_message_fr)
      gui_message_fr_file.close()
      list_of_gui_names.append(gui_message_fr_file_name)

      gui_config_file=open(gui_config_file_name,"w")
      gui_config_file.write(gui_config)
      gui_config_file.close()
      list_of_gui_names.append(gui_config_file_name)

      gui_xml_fr_file=open(gui_xml_fr_file_name,"w")
      gui_xml_fr_file.write(gui_xml_fr)
      gui_xml_fr_file.close()
      list_of_gui_names.append(gui_xml_fr_file_name)

      gui_xml_en_file=open(gui_xml_en_file_name,"w")
      gui_xml_en_file.write(gui_xml_en)
      gui_xml_en_file.close()
      list_of_gui_names.append(gui_xml_en_file_name)

      gui_salomeapp_file=open(gui_salomeapp_file_name,"w")
      gui_salomeapp_file.write(gui_salomeapp)
      gui_salomeapp_file.close()
      list_of_gui_names.append(gui_salomeapp_file_name)
      return list_of_gui_names

  def getIdlInterfaces(self):
    services = self.getIdlServices()
    from .hxx_tmpl import interfaceidlhxx
    Inherited=""
    if self.use_medmem==True:
        Inherited="Engines::EngineComponent,SALOME::MultiCommClass,SALOME_MED::MED_Gen_Driver"
    else:
        Inherited="Engines::EngineComponent"
    return interfaceidlhxx.substitute(component=self.name,inherited=Inherited, services="\n".join(services))

