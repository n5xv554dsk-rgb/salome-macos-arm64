# ./raw/toto.py
# -*- coding: utf-8 -*-
# PyXB bindings for NM:6edffaeea9d56b1698d1f555fb81b70e6e147421
# Generated 2020-10-19 15:46:37.580374 by PyXB version 1.2.5 using Python 3.4.2.final.0
# Namespace http://chercheurs.edf.com/logiciels/Test1

from __future__ import unicode_literals
import pyxb
import pyxb.binding
import pyxb.binding.saxer
import io
import pyxb.utils.utility
import pyxb.utils.domutils
import sys
import pyxb.utils.six as _six
# Unique identifier for bindings created at the same time
_GenerationUID = pyxb.utils.utility.UniqueIdentifier('urn:uuid:8258bf5a-1211-11eb-875b-cc3d82d871d8')

# Version of PyXB used to generate the bindings
_PyXBVersion = '1.2.5'
# Generated bindings are not compatible across PyXB versions
if pyxb.__version__ != _PyXBVersion:
    raise pyxb.PyXBVersionError(_PyXBVersion)

# A holder for module-level binding classes so we can access them from
# inside class definitions where property names may conflict.
_module_typeBindings = pyxb.utils.utility.Object()

# Import bindings for namespaces imported into schema
import pyxb.binding.datatypes

# NOTE: All namespace declarations are reserved within the binding
Namespace = pyxb.namespace.NamespaceForURI('http://chercheurs.edf.com/logiciels/Test1', create_if_missing=True)
Namespace.configureCategories(['typeBinding', 'elementBinding'])

def CreateFromDocument (xml_text, default_namespace=None, location_base=None):
    """Parse the given XML and use the document element to create a
    Python instance.

    @param xml_text An XML document.  This should be data (Python 2
    str or Python 3 bytes), or a text (Python 2 unicode or Python 3
    str) in the L{pyxb._InputEncoding} encoding.

    @keyword default_namespace The L{pyxb.Namespace} instance to use as the
    default namespace where there is no default namespace in scope.
    If unspecified or C{None}, the namespace of the module containing
    this function will be used.

    @keyword location_base: An object to be recorded as the base of all
    L{pyxb.utils.utility.Location} instances associated with events and
    objects handled by the parser.  You might pass the URI from which
    the document was obtained.
    """

    if pyxb.XMLStyle_saxer != pyxb._XMLStyle:
        dom = pyxb.utils.domutils.StringToDOM(xml_text)
        return CreateFromDOM(dom.documentElement, default_namespace=default_namespace)
    if default_namespace is None:
        default_namespace = Namespace.fallbackNamespace()
    saxer = pyxb.binding.saxer.make_parser(fallback_namespace=default_namespace, location_base=location_base)
    handler = saxer.getContentHandler()
    xmld = xml_text
    if isinstance(xmld, _six.text_type):
        xmld = xmld.encode(pyxb._InputEncoding)
    saxer.parse(io.BytesIO(xmld))
    instance = handler.rootObject()
    return instance

def CreateFromDOM (node, default_namespace=None):
    """Create a Python instance from the given DOM node.
    The node tag must correspond to an element declaration in this module.

    @deprecated: Forcing use of DOM interface is unnecessary; use L{CreateFromDocument}."""
    if default_namespace is None:
        default_namespace = Namespace.fallbackNamespace()
    return pyxb.binding.basis.element.AnyCreateFromDOM(node, default_namespace)


# Atomic simple type: {http://chercheurs.edf.com/logiciels/Test1}AccasUserAssd
class AccasUserAssd (pyxb.binding.datatypes.string):

    """An atomic simple type."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'AccasUserAssd')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 7, 1)
    _Documentation = None
AccasUserAssd._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', 'AccasUserAssd', AccasUserAssd)
_module_typeBindings.AccasUserAssd = AccasUserAssd

# Atomic simple type: {http://chercheurs.edf.com/logiciels/Test1}T_dimension
class T_dimension (pyxb.binding.datatypes.int, pyxb.binding.basis.enumeration_mixin):

    """An atomic simple type."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'T_dimension')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 19, 1)
    _Documentation = None
T_dimension._CF_enumeration = pyxb.binding.facets.CF_enumeration(value_datatype=T_dimension, enum_prefix=None)
T_dimension._CF_enumeration.addEnumeration(unicode_value='1', tag=None)
T_dimension._CF_enumeration.addEnumeration(unicode_value='2', tag=None)
T_dimension._CF_enumeration.addEnumeration(unicode_value='3', tag=None)
T_dimension._InitializeFacetMap(T_dimension._CF_enumeration)
Namespace.addCategoryObject('typeBinding', 'T_dimension', T_dimension)
_module_typeBindings.T_dimension = T_dimension

# Atomic simple type: [anonymous]
class STD_ANON (pyxb.binding.datatypes.int):

    """An atomic simple type."""

    _ExpandedName = None
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 30, 5)
    _Documentation = None
STD_ANON._InitializeFacetMap()
_module_typeBindings.STD_ANON = STD_ANON

# Atomic simple type: {http://chercheurs.edf.com/logiciels/Test1}T_meshname_1
class T_meshname_1 (pyxb.binding.datatypes.string):

    """An atomic simple type."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'T_meshname_1')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 38, 1)
    _Documentation = None
T_meshname_1._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', 'T_meshname_1', T_meshname_1)
_module_typeBindings.T_meshname_1 = T_meshname_1

# Atomic simple type: {http://chercheurs.edf.com/logiciels/Test1}PNEFdico_Test1
class PNEFdico_Test1 (pyxb.binding.datatypes.string):

    """{'T_meshname': {'_meshname_CreateMesh': 'T_meshname_1'}}
		"""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'PNEFdico_Test1')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 80, 1)
    _Documentation = "{'T_meshname': {'_meshname_CreateMesh': 'T_meshname_1'}}\n\t\t"
PNEFdico_Test1._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', 'PNEFdico_Test1', PNEFdico_Test1)
_module_typeBindings.PNEFdico_Test1 = PNEFdico_Test1

# Atomic simple type: {http://chercheurs.edf.com/logiciels/Test1}MeshU_C
class MeshU_C (AccasUserAssd):

    """An atomic simple type."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'MeshU_C')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 11, 1)
    _Documentation = None
MeshU_C._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', 'MeshU_C', MeshU_C)
_module_typeBindings.MeshU_C = MeshU_C

# List simple type: [anonymous]
# superclasses pyxb.binding.datatypes.anySimpleType
class STD_ANON_ (pyxb.binding.basis.STD_list):

    """Simple type that is a list of STD_ANON."""

    _ExpandedName = None
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 28, 3)
    _Documentation = None

    _ItemType = STD_ANON
STD_ANON_._InitializeFacetMap()
_module_typeBindings.STD_ANON_ = STD_ANON_

# Atomic simple type: {http://chercheurs.edf.com/logiciels/Test1}T_meshname
class T_meshname (MeshU_C):

    """An atomic simple type."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'T_meshname')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 15, 1)
    _Documentation = None
T_meshname._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', 'T_meshname', T_meshname)
_module_typeBindings.T_meshname = T_meshname

# List simple type: {http://chercheurs.edf.com/logiciels/Test1}T_listOfEntities
# superclasses STD_ANON_
class T_listOfEntities (pyxb.binding.basis.STD_list):

    """Simple type that is a list of STD_ANON."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'T_listOfEntities')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 26, 1)
    _Documentation = None

    _ItemType = STD_ANON
T_listOfEntities._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', 'T_listOfEntities', T_listOfEntities)
_module_typeBindings.T_listOfEntities = T_listOfEntities

# Complex type {http://chercheurs.edf.com/logiciels/Test1}T_step_Test1 with content type EMPTY
class T_step_Test1 (pyxb.binding.basis.complexTypeDefinition):
    """Complex type {http://chercheurs.edf.com/logiciels/Test1}T_step_Test1 with content type EMPTY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_EMPTY
    _Abstract = True
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'T_step_Test1')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 72, 1)
    _ElementMap = {}
    _AttributeMap = {}
    # Base type is pyxb.binding.datatypes.anyType
    _ElementMap.update({
        
    })
    _AttributeMap.update({
        
    })
_module_typeBindings.T_step_Test1 = T_step_Test1
Namespace.addCategoryObject('typeBinding', 'T_step_Test1', T_step_Test1)


# Complex type {http://chercheurs.edf.com/logiciels/Test1}T_Test1 with content type ELEMENT_ONLY
class T_Test1 (pyxb.binding.basis.complexTypeDefinition):
    """Complex type {http://chercheurs.edf.com/logiciels/Test1}T_Test1 with content type ELEMENT_ONLY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_ELEMENT_ONLY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'T_Test1')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 75, 2)
    _ElementMap = {}
    _AttributeMap = {}
    # Base type is pyxb.binding.datatypes.anyType
    
    # Element {http://chercheurs.edf.com/logiciels/Test1}step_Test1 uses Python identifier step_Test1
    __step_Test1 = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, 'step_Test1'), 'step_Test1', '__httpchercheurs_edf_comlogicielsTest1_T_Test1_httpchercheurs_edf_comlogicielsTest1step_Test1', True, pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 73, 1), )

    
    step_Test1 = property(__step_Test1.value, __step_Test1.set, None, None)

    _ElementMap.update({
        __step_Test1.name() : __step_Test1
    })
    _AttributeMap.update({
        
    })
_module_typeBindings.T_Test1 = T_Test1
Namespace.addCategoryObject('typeBinding', 'T_Test1', T_Test1)


# Complex type {http://chercheurs.edf.com/logiciels/Test1}T_CreateBoth with content type ELEMENT_ONLY
class T_CreateBoth (T_step_Test1):
    """Complex type {http://chercheurs.edf.com/logiciels/Test1}T_CreateBoth with content type ELEMENT_ONLY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_ELEMENT_ONLY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'T_CreateBoth')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 42, 1)
    _ElementMap = T_step_Test1._ElementMap.copy()
    _AttributeMap = T_step_Test1._AttributeMap.copy()
    # Base type is T_step_Test1
    
    # Element {http://chercheurs.edf.com/logiciels/Test1}meshname uses Python identifier meshname
    __meshname = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, 'meshname'), 'meshname', '__httpchercheurs_edf_comlogicielsTest1_T_CreateBoth_httpchercheurs_edf_comlogicielsTest1meshname', False, pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 46, 3), )

    
    meshname = property(__meshname.value, __meshname.set, None, None)

    
    # Element {http://chercheurs.edf.com/logiciels/Test1}dimension uses Python identifier dimension
    __dimension = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, 'dimension'), 'dimension', '__httpchercheurs_edf_comlogicielsTest1_T_CreateBoth_httpchercheurs_edf_comlogicielsTest1dimension', False, pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 47, 3), )

    
    dimension = property(__dimension.value, __dimension.set, None, None)

    
    # Element {http://chercheurs.edf.com/logiciels/Test1}listOfEntities uses Python identifier listOfEntities
    __listOfEntities = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, 'listOfEntities'), 'listOfEntities', '__httpchercheurs_edf_comlogicielsTest1_T_CreateBoth_httpchercheurs_edf_comlogicielsTest1listOfEntities', False, pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 48, 3), )

    
    listOfEntities = property(__listOfEntities.value, __listOfEntities.set, None, None)

    
    # Attribute accasName uses Python identifier accasName
    __accasName = pyxb.binding.content.AttributeUse(pyxb.namespace.ExpandedName(None, 'accasName'), 'accasName', '__httpchercheurs_edf_comlogicielsTest1_T_CreateBoth_accasName', pyxb.binding.datatypes.string)
    __accasName._DeclarationLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 50, 2)
    __accasName._UseLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 50, 2)
    
    accasName = property(__accasName.value, __accasName.set, None, None)

    
    # Attribute accasType uses Python identifier accasType
    __accasType = pyxb.binding.content.AttributeUse(pyxb.namespace.ExpandedName(None, 'accasType'), 'accasType', '__httpchercheurs_edf_comlogicielsTest1_T_CreateBoth_accasType', pyxb.binding.datatypes.string, fixed=True, unicode_default='ASSD')
    __accasType._DeclarationLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 51, 2)
    __accasType._UseLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 51, 2)
    
    accasType = property(__accasType.value, __accasType.set, None, None)

    
    # Attribute typeUtilisateur uses Python identifier typeUtilisateur
    __typeUtilisateur = pyxb.binding.content.AttributeUse(pyxb.namespace.ExpandedName(None, 'typeUtilisateur'), 'typeUtilisateur', '__httpchercheurs_edf_comlogicielsTest1_T_CreateBoth_typeUtilisateur', pyxb.binding.datatypes.string, fixed=True, unicode_default='Mesh')
    __typeUtilisateur._DeclarationLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 52, 2)
    __typeUtilisateur._UseLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 52, 2)
    
    typeUtilisateur = property(__typeUtilisateur.value, __typeUtilisateur.set, None, None)

    _ElementMap.update({
        __meshname.name() : __meshname,
        __dimension.name() : __dimension,
        __listOfEntities.name() : __listOfEntities
    })
    _AttributeMap.update({
        __accasName.name() : __accasName,
        __accasType.name() : __accasType,
        __typeUtilisateur.name() : __typeUtilisateur
    })
_module_typeBindings.T_CreateBoth = T_CreateBoth
Namespace.addCategoryObject('typeBinding', 'T_CreateBoth', T_CreateBoth)


# Complex type {http://chercheurs.edf.com/logiciels/Test1}T_CreateMesh with content type ELEMENT_ONLY
class T_CreateMesh (T_step_Test1):
    """Complex type {http://chercheurs.edf.com/logiciels/Test1}T_CreateMesh with content type ELEMENT_ONLY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_ELEMENT_ONLY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'T_CreateMesh')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 56, 1)
    _ElementMap = T_step_Test1._ElementMap.copy()
    _AttributeMap = T_step_Test1._AttributeMap.copy()
    # Base type is T_step_Test1
    
    # Element {http://chercheurs.edf.com/logiciels/Test1}meshname uses Python identifier meshname
    __meshname = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, 'meshname'), 'meshname', '__httpchercheurs_edf_comlogicielsTest1_T_CreateMesh_httpchercheurs_edf_comlogicielsTest1meshname', False, pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 60, 3), )

    
    meshname = property(__meshname.value, __meshname.set, None, None)

    
    # Element {http://chercheurs.edf.com/logiciels/Test1}dimension uses Python identifier dimension
    __dimension = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, 'dimension'), 'dimension', '__httpchercheurs_edf_comlogicielsTest1_T_CreateMesh_httpchercheurs_edf_comlogicielsTest1dimension', False, pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 61, 3), )

    
    dimension = property(__dimension.value, __dimension.set, None, None)

    
    # Element {http://chercheurs.edf.com/logiciels/Test1}listOfEntities uses Python identifier listOfEntities
    __listOfEntities = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, 'listOfEntities'), 'listOfEntities', '__httpchercheurs_edf_comlogicielsTest1_T_CreateMesh_httpchercheurs_edf_comlogicielsTest1listOfEntities', False, pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 62, 3), )

    
    listOfEntities = property(__listOfEntities.value, __listOfEntities.set, None, None)

    
    # Attribute accasName uses Python identifier accasName
    __accasName = pyxb.binding.content.AttributeUse(pyxb.namespace.ExpandedName(None, 'accasName'), 'accasName', '__httpchercheurs_edf_comlogicielsTest1_T_CreateMesh_accasName', pyxb.binding.datatypes.string)
    __accasName._DeclarationLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 64, 2)
    __accasName._UseLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 64, 2)
    
    accasName = property(__accasName.value, __accasName.set, None, None)

    
    # Attribute accasType uses Python identifier accasType
    __accasType = pyxb.binding.content.AttributeUse(pyxb.namespace.ExpandedName(None, 'accasType'), 'accasType', '__httpchercheurs_edf_comlogicielsTest1_T_CreateMesh_accasType', pyxb.binding.datatypes.string, fixed=True, unicode_default='ASSD')
    __accasType._DeclarationLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 65, 2)
    __accasType._UseLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 65, 2)
    
    accasType = property(__accasType.value, __accasType.set, None, None)

    
    # Attribute typeUtilisateur uses Python identifier typeUtilisateur
    __typeUtilisateur = pyxb.binding.content.AttributeUse(pyxb.namespace.ExpandedName(None, 'typeUtilisateur'), 'typeUtilisateur', '__httpchercheurs_edf_comlogicielsTest1_T_CreateMesh_typeUtilisateur', pyxb.binding.datatypes.string, fixed=True, unicode_default='Mesh')
    __typeUtilisateur._DeclarationLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 66, 2)
    __typeUtilisateur._UseLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 66, 2)
    
    typeUtilisateur = property(__typeUtilisateur.value, __typeUtilisateur.set, None, None)

    _ElementMap.update({
        __meshname.name() : __meshname,
        __dimension.name() : __dimension,
        __listOfEntities.name() : __listOfEntities
    })
    _AttributeMap.update({
        __accasName.name() : __accasName,
        __accasType.name() : __accasType,
        __typeUtilisateur.name() : __typeUtilisateur
    })
_module_typeBindings.T_CreateMesh = T_CreateMesh
Namespace.addCategoryObject('typeBinding', 'T_CreateMesh', T_CreateMesh)


step_Test1 = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'step_Test1'), T_step_Test1, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 73, 1))
Namespace.addCategoryObject('elementBinding', step_Test1.name().localName(), step_Test1)

Test1 = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'Test1'), T_Test1, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 74, 1))
Namespace.addCategoryObject('elementBinding', Test1.name().localName(), Test1)

CreateBoth = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'CreateBoth'), T_CreateBoth, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 70, 1))
Namespace.addCategoryObject('elementBinding', CreateBoth.name().localName(), CreateBoth)

CreateMesh = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'CreateMesh'), T_CreateMesh, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 71, 1))
Namespace.addCategoryObject('elementBinding', CreateMesh.name().localName(), CreateMesh)



T_Test1._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'step_Test1'), T_step_Test1, scope=T_Test1, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 73, 1)))

def _BuildAutomaton ():
    # Remove this helper function from the namespace after it is invoked
    global _BuildAutomaton
    del _BuildAutomaton
    import pyxb.utils.fac as fac

    counters = set()
    cc_0 = fac.CounterCondition(min=0, max=None, metadata=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 76, 4))
    counters.add(cc_0)
    cc_1 = fac.CounterCondition(min=0, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 77, 3))
    counters.add(cc_1)
    states = []
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_0, False))
    final_update.add(fac.UpdateInstruction(cc_1, False))
    symbol = pyxb.binding.content.ElementUse(T_Test1._UseForTag(pyxb.namespace.ExpandedName(Namespace, 'step_Test1')), pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 77, 3))
    st_0 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_0)
    transitions = []
    transitions.append(fac.Transition(st_0, [
        fac.UpdateInstruction(cc_0, True),
        fac.UpdateInstruction(cc_1, False) ]))
    transitions.append(fac.Transition(st_0, [
        fac.UpdateInstruction(cc_1, True) ]))
    st_0._set_transitionSet(transitions)
    return fac.Automaton(states, counters, True, containing_state=None)
T_Test1._Automaton = _BuildAutomaton()




T_CreateBoth._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'meshname'), T_meshname, scope=T_CreateBoth, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 46, 3)))

T_CreateBoth._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'dimension'), T_dimension, scope=T_CreateBoth, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 47, 3)))

T_CreateBoth._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'listOfEntities'), T_listOfEntities, scope=T_CreateBoth, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 48, 3)))

def _BuildAutomaton_ ():
    # Remove this helper function from the namespace after it is invoked
    global _BuildAutomaton_
    del _BuildAutomaton_
    import pyxb.utils.fac as fac

    counters = set()
    cc_0 = fac.CounterCondition(min=0, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 46, 3))
    counters.add(cc_0)
    cc_1 = fac.CounterCondition(min=0, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 47, 3))
    counters.add(cc_1)
    cc_2 = fac.CounterCondition(min=0, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 48, 3))
    counters.add(cc_2)
    states = []
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_0, False))
    symbol = pyxb.binding.content.ElementUse(T_CreateBoth._UseForTag(pyxb.namespace.ExpandedName(Namespace, 'meshname')), pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 46, 3))
    st_0 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_0)
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_1, False))
    symbol = pyxb.binding.content.ElementUse(T_CreateBoth._UseForTag(pyxb.namespace.ExpandedName(Namespace, 'dimension')), pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 47, 3))
    st_1 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_1)
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_2, False))
    symbol = pyxb.binding.content.ElementUse(T_CreateBoth._UseForTag(pyxb.namespace.ExpandedName(Namespace, 'listOfEntities')), pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 48, 3))
    st_2 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_2)
    transitions = []
    transitions.append(fac.Transition(st_0, [
        fac.UpdateInstruction(cc_0, True) ]))
    transitions.append(fac.Transition(st_1, [
        fac.UpdateInstruction(cc_0, False) ]))
    transitions.append(fac.Transition(st_2, [
        fac.UpdateInstruction(cc_0, False) ]))
    st_0._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_1, [
        fac.UpdateInstruction(cc_1, True) ]))
    transitions.append(fac.Transition(st_2, [
        fac.UpdateInstruction(cc_1, False) ]))
    st_1._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_2, [
        fac.UpdateInstruction(cc_2, True) ]))
    st_2._set_transitionSet(transitions)
    return fac.Automaton(states, counters, True, containing_state=None)
T_CreateBoth._Automaton = _BuildAutomaton_()




T_CreateMesh._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'meshname'), T_meshname_1, scope=T_CreateMesh, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 60, 3)))

T_CreateMesh._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'dimension'), T_dimension, scope=T_CreateMesh, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 61, 3)))

T_CreateMesh._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'listOfEntities'), T_listOfEntities, scope=T_CreateMesh, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 62, 3)))

def _BuildAutomaton_2 ():
    # Remove this helper function from the namespace after it is invoked
    global _BuildAutomaton_2
    del _BuildAutomaton_2
    import pyxb.utils.fac as fac

    counters = set()
    cc_0 = fac.CounterCondition(min=0, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 60, 3))
    counters.add(cc_0)
    cc_1 = fac.CounterCondition(min=0, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 61, 3))
    counters.add(cc_1)
    cc_2 = fac.CounterCondition(min=0, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 62, 3))
    counters.add(cc_2)
    states = []
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_0, False))
    symbol = pyxb.binding.content.ElementUse(T_CreateMesh._UseForTag(pyxb.namespace.ExpandedName(Namespace, 'meshname')), pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 60, 3))
    st_0 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_0)
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_1, False))
    symbol = pyxb.binding.content.ElementUse(T_CreateMesh._UseForTag(pyxb.namespace.ExpandedName(Namespace, 'dimension')), pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 61, 3))
    st_1 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_1)
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_2, False))
    symbol = pyxb.binding.content.ElementUse(T_CreateMesh._UseForTag(pyxb.namespace.ExpandedName(Namespace, 'listOfEntities')), pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_1.xsd', 62, 3))
    st_2 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_2)
    transitions = []
    transitions.append(fac.Transition(st_0, [
        fac.UpdateInstruction(cc_0, True) ]))
    transitions.append(fac.Transition(st_1, [
        fac.UpdateInstruction(cc_0, False) ]))
    transitions.append(fac.Transition(st_2, [
        fac.UpdateInstruction(cc_0, False) ]))
    st_0._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_1, [
        fac.UpdateInstruction(cc_1, True) ]))
    transitions.append(fac.Transition(st_2, [
        fac.UpdateInstruction(cc_1, False) ]))
    st_1._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_2, [
        fac.UpdateInstruction(cc_2, True) ]))
    st_2._set_transitionSet(transitions)
    return fac.Automaton(states, counters, True, containing_state=None)
T_CreateMesh._Automaton = _BuildAutomaton_2()


CreateBoth._setSubstitutionGroup(step_Test1)

CreateMesh._setSubstitutionGroup(step_Test1)
