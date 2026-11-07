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

try:
  from string import Template
except:
  from module_generator.compat import Template,set

# CORBA idl

idl="""
#ifndef _${module}_IDL_
#define _${module}_IDL_

#include "SALOME_Exception.idl"
#include "SALOME_Component.idl"
#include "SALOME_Comm.idl"

${idldefs}

module ${module}_ORB
{
typedef sequence<string> stringvec;
typedef sequence<double> dblevec;
typedef sequence<long> intvec;
typedef Engines::dataref dataref;

${interfaces}
};

#endif
"""
idl=Template(idl)

interface="""
  interface ${component}:${inheritedinterface} Engines::Superv_Component
  {
${services}
  };
"""
interface=Template(interface)

parallel_interface="""
interface ${component} : Engines::Parallel_DSC
  {
${services}
  };
"""
parallel_interface=Template(parallel_interface)

xml="""\
<?xml version="1.0"?>
<!-- YACSGEN -->

<PaCO_Interface_description>
  <Module>
    <Name>${module}_ORB</Name>
${interfaces}
  </Module>
</PaCO_Interface_description>
"""
xml = Template(xml)

xml_interface="""\
    <Interface>
      <Name>${component}</Name>
${xml_services}
    </Interface>"""
xml_interface = Template(xml_interface)

xml_service = """\
      <Method>
        <Name>${service_name}</Name>
        <Type>distributed</Type>
      </Method>"""
xml_service = Template(xml_service)

# PACO Part
idlMakefilePaCO_BUILT_SOURCES = "${module}PaCO.cxx "
idlMakefilePaCO_nodist_salomeinclude_HEADERS = "${module}PaCO.hxx "
idlMakefilePaCO_BUILT_SOURCES = Template(idlMakefilePaCO_BUILT_SOURCES)
idlMakefilePaCO_nodist_salomeinclude_HEADERS = Template(idlMakefilePaCO_nodist_salomeinclude_HEADERS)
idlMakefilePACO_INCLUDES = "-I@PACOPATH@/idl"
idlMakefilePACO_salomepython_DATA = "${module}PaCO_idl.py"
idlMakefilePACO_salomepython_DATA = Template(idlMakefilePACO_salomepython_DATA)
idlMakefilePACO_salomeidl_DATA = "${module}PaCO.idl"
idlMakefilePACO_salomeidl_DATA = Template(idlMakefilePACO_salomeidl_DATA)

#SALOME catalog

catalog="""<?xml version='1.0' encoding='us-ascii' ?>

<!-- XML component catalog -->
<begin-catalog>

<!-- Path prefix information -->

<path-prefix-list>
</path-prefix-list>

<!-- Commonly used types  -->
<type-list>
  <objref name="pyobj" id="python:obj:1.0"/>
  <objref name="file" id="file"/>
</type-list>

<!-- Component list -->
<component-list>
${components}
</component-list>
</begin-catalog>
"""
catalog=Template(catalog)

cataCompo="""
  <component>
        <!-- Component identification -->
        <component-name>${component}</component-name>
        <component-username>${component}</component-username>
        <component-type>Data</component-type>
        <component-author>${author}</component-author>
        <component-version>1.0</component-version>
        <component-comment></component-comment>
        <component-multistudy>0</component-multistudy>
        <component-impltype>${impltype}</component-impltype>
        <component-implname>${implname}</component-implname>
        <component-interface-list>
            <component-interface-name>${component}</component-interface-name>
            <component-interface-comment></component-interface-comment>
            <component-service-list>
${services}
            </component-service-list>
        </component-interface-list>
  </component>"""
cataCompo=Template(cataCompo)

cataService="""                <component-service>
                    <!-- service-identification -->
                    <service-name>${service}</service-name>
                    <service-author>${author}</service-author>
                    <service-version>1.0</service-version>
                    <service-comment></service-comment>
                    <service-by-default>0</service-by-default>
                    <!-- service-connexion -->
                    <inParameter-list>
${inparams}
                    </inParameter-list>
                    <outParameter-list>
${outparams}
                    </outParameter-list>
                    <DataStream-list>
${datastreams}
                    </DataStream-list>
                </component-service>"""
cataService=Template(cataService)

cataInparam="""                        <inParameter>
                          <inParameter-name>${name}</inParameter-name>
                          <inParameter-type>${type}</inParameter-type>
                       </inParameter>"""
cataInparam=Template(cataInparam)

cataOutparam="""                        <outParameter>
                          <outParameter-name>${name}</outParameter-name>
                          <outParameter-type>${type}</outParameter-type>
                       </outParameter>"""
cataOutparam=Template(cataOutparam)

cataInStream="""                       <inParameter>
                          <inParameter-name>${name}</inParameter-name>
                          <inParameter-type>${type}</inParameter-type>
                          <inParameter-dependency>${dep}</inParameter-dependency>
                       </inParameter>"""
cataInStream=Template(cataInStream)

cataOutStream="""                       <outParameter>
                          <outParameter-name>${name}</outParameter-name>
                          <outParameter-type>${type}</outParameter-type>
                          <outParameter-dependency>${dep}</outParameter-dependency>
                       </outParameter>"""
cataOutStream=Template(cataOutStream)

cataInParallelStream="""                       <inParameter>
                          <inParameter-name>${name}</inParameter-name>
                          <inParameter-type>${type}</inParameter-type>
                       </inParameter>"""
cataInParallelStream=Template(cataInParallelStream)

cataOutParallelStream="""                       <outParameter>
                          <outParameter-name>${name}</outParameter-name>
                          <outParameter-type>${type}</outParameter-type>
                       </outParameter>"""
cataOutParallelStream=Template(cataOutParallelStream)
