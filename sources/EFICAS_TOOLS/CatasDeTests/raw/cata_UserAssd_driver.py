# ./raw/cata_UserAssd_driver.py
# -*- coding: utf-8 -*-
# PyXB bindings for NM:9c3bd166183fcfc95687f415bcc4a066eb33ac79
# Generated 2020-10-19 16:07:37.824784 by PyXB version 1.2.5 using Python 3.4.2.final.0
# Namespace http://chercheurs.edf.com/logiciels/Essai

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
_GenerationUID = pyxb.utils.utility.UniqueIdentifier('urn:uuid:7181a702-1214-11eb-a804-cc3d82d871d8')

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
Namespace = pyxb.namespace.NamespaceForURI('http://chercheurs.edf.com/logiciels/Essai', create_if_missing=True)
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


# Atomic simple type: {http://chercheurs.edf.com/logiciels/Essai}AccasUserAssd
class AccasUserAssd (pyxb.binding.datatypes.string):

    """An atomic simple type."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'AccasUserAssd')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 7, 1)
    _Documentation = None
AccasUserAssd._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', 'AccasUserAssd', AccasUserAssd)
_module_typeBindings.AccasUserAssd = AccasUserAssd

# Atomic simple type: {http://chercheurs.edf.com/logiciels/Essai}PNEFdico_Essai
class PNEFdico_Essai (pyxb.binding.datatypes.string):

    """{'T_creeUserAssd': {'_creeUserAssd_DefinitionDsSimpDsOper': 'T_creeUserAssd_2', '_creeUserAssd_DefinitionDsSimpListe': 'T_creeUserAssd_4'}}
		"""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'PNEFdico_Essai')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 154, 1)
    _Documentation = "{'T_creeUserAssd': {'_creeUserAssd_DefinitionDsSimpDsOper': 'T_creeUserAssd_2', '_creeUserAssd_DefinitionDsSimpListe': 'T_creeUserAssd_4'}}\n\t\t"
PNEFdico_Essai._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', 'PNEFdico_Essai', PNEFdico_Essai)
_module_typeBindings.PNEFdico_Essai = PNEFdico_Essai

# Atomic simple type: {http://chercheurs.edf.com/logiciels/Essai}laClasseUser_C
class laClasseUser_C (AccasUserAssd):

    """An atomic simple type."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'laClasseUser_C')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 11, 1)
    _Documentation = None
laClasseUser_C._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', 'laClasseUser_C', laClasseUser_C)
_module_typeBindings.laClasseUser_C = laClasseUser_C

# Atomic simple type: {http://chercheurs.edf.com/logiciels/Essai}laClasseUserDerive_C
class laClasseUserDerive_C (AccasUserAssd):

    """An atomic simple type."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'laClasseUserDerive_C')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 19, 1)
    _Documentation = None
laClasseUserDerive_C._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', 'laClasseUserDerive_C', laClasseUserDerive_C)
_module_typeBindings.laClasseUserDerive_C = laClasseUserDerive_C

# Atomic simple type: {http://chercheurs.edf.com/logiciels/Essai}laClasseUser_U
class laClasseUser_U (AccasUserAssd):

    """An atomic simple type."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'laClasseUser_U')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 39, 1)
    _Documentation = None
laClasseUser_U._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', 'laClasseUser_U', laClasseUser_U)
_module_typeBindings.laClasseUser_U = laClasseUser_U

# Atomic simple type: {http://chercheurs.edf.com/logiciels/Essai}T_creeUserAssd
class T_creeUserAssd (laClasseUser_C):

    """An atomic simple type."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'T_creeUserAssd')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 15, 1)
    _Documentation = None
T_creeUserAssd._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', 'T_creeUserAssd', T_creeUserAssd)
_module_typeBindings.T_creeUserAssd = T_creeUserAssd

# Atomic simple type: {http://chercheurs.edf.com/logiciels/Essai}T_creeUserAssd_2
class T_creeUserAssd_2 (laClasseUserDerive_C):

    """An atomic simple type."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'T_creeUserAssd_2')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 23, 1)
    _Documentation = None
T_creeUserAssd_2._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', 'T_creeUserAssd_2', T_creeUserAssd_2)
_module_typeBindings.T_creeUserAssd_2 = T_creeUserAssd_2

# Atomic simple type: [anonymous]
class STD_ANON (laClasseUser_C):

    """An atomic simple type."""

    _ExpandedName = None
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 31, 5)
    _Documentation = None
STD_ANON._InitializeFacetMap()
_module_typeBindings.STD_ANON = STD_ANON

# Atomic simple type: [anonymous]
class STD_ANON_ (laClasseUser_U):

    """An atomic simple type."""

    _ExpandedName = None
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 47, 5)
    _Documentation = None
STD_ANON_._InitializeFacetMap()
_module_typeBindings.STD_ANON_ = STD_ANON_

# Atomic simple type: {http://chercheurs.edf.com/logiciels/Essai}T_utiliseUnUserAssd
class T_utiliseUnUserAssd (laClasseUser_U):

    """An atomic simple type."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'T_utiliseUnUserAssd')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 55, 1)
    _Documentation = None
T_utiliseUnUserAssd._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', 'T_utiliseUnUserAssd', T_utiliseUnUserAssd)
_module_typeBindings.T_utiliseUnUserAssd = T_utiliseUnUserAssd

# List simple type: [anonymous]
# superclasses pyxb.binding.datatypes.anySimpleType
class STD_ANON_2 (pyxb.binding.basis.STD_list):

    """Simple type that is a list of STD_ANON."""

    _ExpandedName = None
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 29, 3)
    _Documentation = None

    _ItemType = STD_ANON
STD_ANON_2._InitializeFacetMap()
_module_typeBindings.STD_ANON_2 = STD_ANON_2

# List simple type: [anonymous]
# superclasses pyxb.binding.datatypes.anySimpleType
class STD_ANON_3 (pyxb.binding.basis.STD_list):

    """Simple type that is a list of STD_ANON_."""

    _ExpandedName = None
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 45, 3)
    _Documentation = None

    _ItemType = STD_ANON_
STD_ANON_3._InitializeFacetMap()
_module_typeBindings.STD_ANON_3 = STD_ANON_3

# List simple type: {http://chercheurs.edf.com/logiciels/Essai}T_creeUserAssd_4
# superclasses STD_ANON_2
class T_creeUserAssd_4 (pyxb.binding.basis.STD_list):

    """Simple type that is a list of STD_ANON."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'T_creeUserAssd_4')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 27, 1)
    _Documentation = None

    _ItemType = STD_ANON
T_creeUserAssd_4._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', 'T_creeUserAssd_4', T_creeUserAssd_4)
_module_typeBindings.T_creeUserAssd_4 = T_creeUserAssd_4

# List simple type: {http://chercheurs.edf.com/logiciels/Essai}T_utiliseUserAssd
# superclasses STD_ANON_3
class T_utiliseUserAssd (pyxb.binding.basis.STD_list):

    """Simple type that is a list of STD_ANON_."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'T_utiliseUserAssd')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 43, 1)
    _Documentation = None

    _ItemType = STD_ANON_
T_utiliseUserAssd._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', 'T_utiliseUserAssd', T_utiliseUserAssd)
_module_typeBindings.T_utiliseUserAssd = T_utiliseUserAssd

# Complex type {http://chercheurs.edf.com/logiciels/Essai}T_unFact1 with content type ELEMENT_ONLY
class T_unFact1 (pyxb.binding.basis.complexTypeDefinition):
    """Complex type {http://chercheurs.edf.com/logiciels/Essai}T_unFact1 with content type ELEMENT_ONLY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_ELEMENT_ONLY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'T_unFact1')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 59, 1)
    _ElementMap = {}
    _AttributeMap = {}
    # Base type is pyxb.binding.datatypes.anyType
    
    # Element {http://chercheurs.edf.com/logiciels/Essai}creeUserAssd uses Python identifier creeUserAssd
    __creeUserAssd = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, 'creeUserAssd'), 'creeUserAssd', '__httpchercheurs_edf_comlogicielsEssai_T_unFact1_httpchercheurs_edf_comlogicielsEssaicreeUserAssd', False, pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 61, 3), )

    
    creeUserAssd = property(__creeUserAssd.value, __creeUserAssd.set, None, None)

    _ElementMap.update({
        __creeUserAssd.name() : __creeUserAssd
    })
    _AttributeMap.update({
        
    })
_module_typeBindings.T_unFact1 = T_unFact1
Namespace.addCategoryObject('typeBinding', 'T_unFact1', T_unFact1)


# Complex type {http://chercheurs.edf.com/logiciels/Essai}T_unFact with content type ELEMENT_ONLY
class T_unFact (pyxb.binding.basis.complexTypeDefinition):
    """Complex type {http://chercheurs.edf.com/logiciels/Essai}T_unFact with content type ELEMENT_ONLY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_ELEMENT_ONLY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'T_unFact')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 76, 1)
    _ElementMap = {}
    _AttributeMap = {}
    # Base type is pyxb.binding.datatypes.anyType
    
    # Element {http://chercheurs.edf.com/logiciels/Essai}creeUserAssd uses Python identifier creeUserAssd
    __creeUserAssd = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, 'creeUserAssd'), 'creeUserAssd', '__httpchercheurs_edf_comlogicielsEssai_T_unFact_httpchercheurs_edf_comlogicielsEssaicreeUserAssd', False, pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 78, 3), )

    
    creeUserAssd = property(__creeUserAssd.value, __creeUserAssd.set, None, None)

    _ElementMap.update({
        __creeUserAssd.name() : __creeUserAssd
    })
    _AttributeMap.update({
        
    })
_module_typeBindings.T_unFact = T_unFact
Namespace.addCategoryObject('typeBinding', 'T_unFact', T_unFact)


# Complex type {http://chercheurs.edf.com/logiciels/Essai}T_step_Essai with content type EMPTY
class T_step_Essai (pyxb.binding.basis.complexTypeDefinition):
    """Complex type {http://chercheurs.edf.com/logiciels/Essai}T_step_Essai with content type EMPTY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_EMPTY
    _Abstract = True
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'T_step_Essai')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 146, 1)
    _ElementMap = {}
    _AttributeMap = {}
    # Base type is pyxb.binding.datatypes.anyType
    _ElementMap.update({
        
    })
    _AttributeMap.update({
        
    })
_module_typeBindings.T_step_Essai = T_step_Essai
Namespace.addCategoryObject('typeBinding', 'T_step_Essai', T_step_Essai)


# Complex type {http://chercheurs.edf.com/logiciels/Essai}T_Essai with content type ELEMENT_ONLY
class T_Essai (pyxb.binding.basis.complexTypeDefinition):
    """Complex type {http://chercheurs.edf.com/logiciels/Essai}T_Essai with content type ELEMENT_ONLY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_ELEMENT_ONLY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'T_Essai')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 149, 2)
    _ElementMap = {}
    _AttributeMap = {}
    # Base type is pyxb.binding.datatypes.anyType
    
    # Element {http://chercheurs.edf.com/logiciels/Essai}step_Essai uses Python identifier step_Essai
    __step_Essai = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, 'step_Essai'), 'step_Essai', '__httpchercheurs_edf_comlogicielsEssai_T_Essai_httpchercheurs_edf_comlogicielsEssaistep_Essai', True, pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 147, 1), )

    
    step_Essai = property(__step_Essai.value, __step_Essai.set, None, None)

    _ElementMap.update({
        __step_Essai.name() : __step_Essai
    })
    _AttributeMap.update({
        
    })
_module_typeBindings.T_Essai = T_Essai
Namespace.addCategoryObject('typeBinding', 'T_Essai', T_Essai)


# Complex type {http://chercheurs.edf.com/logiciels/Essai}T_DefinitionDsFactDsOper with content type ELEMENT_ONLY
class T_DefinitionDsFactDsOper (T_step_Essai):
    """Complex type {http://chercheurs.edf.com/logiciels/Essai}T_DefinitionDsFactDsOper with content type ELEMENT_ONLY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_ELEMENT_ONLY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'T_DefinitionDsFactDsOper')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 64, 1)
    _ElementMap = T_step_Essai._ElementMap.copy()
    _AttributeMap = T_step_Essai._AttributeMap.copy()
    # Base type is T_step_Essai
    
    # Element {http://chercheurs.edf.com/logiciels/Essai}unFact1 uses Python identifier unFact1
    __unFact1 = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, 'unFact1'), 'unFact1', '__httpchercheurs_edf_comlogicielsEssai_T_DefinitionDsFactDsOper_httpchercheurs_edf_comlogicielsEssaiunFact1', True, pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 68, 3), )

    
    unFact1 = property(__unFact1.value, __unFact1.set, None, None)

    
    # Attribute accasName uses Python identifier accasName
    __accasName = pyxb.binding.content.AttributeUse(pyxb.namespace.ExpandedName(None, 'accasName'), 'accasName', '__httpchercheurs_edf_comlogicielsEssai_T_DefinitionDsFactDsOper_accasName', pyxb.binding.datatypes.string)
    __accasName._DeclarationLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 70, 2)
    __accasName._UseLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 70, 2)
    
    accasName = property(__accasName.value, __accasName.set, None, None)

    
    # Attribute accasType uses Python identifier accasType
    __accasType = pyxb.binding.content.AttributeUse(pyxb.namespace.ExpandedName(None, 'accasType'), 'accasType', '__httpchercheurs_edf_comlogicielsEssai_T_DefinitionDsFactDsOper_accasType', pyxb.binding.datatypes.string, fixed=True, unicode_default='ASSD')
    __accasType._DeclarationLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 71, 2)
    __accasType._UseLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 71, 2)
    
    accasType = property(__accasType.value, __accasType.set, None, None)

    
    # Attribute typeUtilisateur uses Python identifier typeUtilisateur
    __typeUtilisateur = pyxb.binding.content.AttributeUse(pyxb.namespace.ExpandedName(None, 'typeUtilisateur'), 'typeUtilisateur', '__httpchercheurs_edf_comlogicielsEssai_T_DefinitionDsFactDsOper_typeUtilisateur', pyxb.binding.datatypes.string, fixed=True, unicode_default='lASSD')
    __typeUtilisateur._DeclarationLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 72, 2)
    __typeUtilisateur._UseLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 72, 2)
    
    typeUtilisateur = property(__typeUtilisateur.value, __typeUtilisateur.set, None, None)

    _ElementMap.update({
        __unFact1.name() : __unFact1
    })
    _AttributeMap.update({
        __accasName.name() : __accasName,
        __accasType.name() : __accasType,
        __typeUtilisateur.name() : __typeUtilisateur
    })
_module_typeBindings.T_DefinitionDsFactDsOper = T_DefinitionDsFactDsOper
Namespace.addCategoryObject('typeBinding', 'T_DefinitionDsFactDsOper', T_DefinitionDsFactDsOper)


# Complex type {http://chercheurs.edf.com/logiciels/Essai}T_DefinitionDsFactDsProc with content type ELEMENT_ONLY
class T_DefinitionDsFactDsProc (T_step_Essai):
    """Complex type {http://chercheurs.edf.com/logiciels/Essai}T_DefinitionDsFactDsProc with content type ELEMENT_ONLY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_ELEMENT_ONLY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'T_DefinitionDsFactDsProc')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 81, 1)
    _ElementMap = T_step_Essai._ElementMap.copy()
    _AttributeMap = T_step_Essai._AttributeMap.copy()
    # Base type is T_step_Essai
    
    # Element {http://chercheurs.edf.com/logiciels/Essai}unFact uses Python identifier unFact
    __unFact = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, 'unFact'), 'unFact', '__httpchercheurs_edf_comlogicielsEssai_T_DefinitionDsFactDsProc_httpchercheurs_edf_comlogicielsEssaiunFact', False, pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 85, 3), )

    
    unFact = property(__unFact.value, __unFact.set, None, None)

    _ElementMap.update({
        __unFact.name() : __unFact
    })
    _AttributeMap.update({
        
    })
_module_typeBindings.T_DefinitionDsFactDsProc = T_DefinitionDsFactDsProc
Namespace.addCategoryObject('typeBinding', 'T_DefinitionDsFactDsProc', T_DefinitionDsFactDsProc)


# Complex type {http://chercheurs.edf.com/logiciels/Essai}T_DefinitionDsSimpDsOper with content type ELEMENT_ONLY
class T_DefinitionDsSimpDsOper (T_step_Essai):
    """Complex type {http://chercheurs.edf.com/logiciels/Essai}T_DefinitionDsSimpDsOper with content type ELEMENT_ONLY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_ELEMENT_ONLY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'T_DefinitionDsSimpDsOper')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 90, 1)
    _ElementMap = T_step_Essai._ElementMap.copy()
    _AttributeMap = T_step_Essai._AttributeMap.copy()
    # Base type is T_step_Essai
    
    # Element {http://chercheurs.edf.com/logiciels/Essai}creeUserAssd uses Python identifier creeUserAssd
    __creeUserAssd = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, 'creeUserAssd'), 'creeUserAssd', '__httpchercheurs_edf_comlogicielsEssai_T_DefinitionDsSimpDsOper_httpchercheurs_edf_comlogicielsEssaicreeUserAssd', False, pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 94, 3), )

    
    creeUserAssd = property(__creeUserAssd.value, __creeUserAssd.set, None, None)

    
    # Attribute accasName uses Python identifier accasName
    __accasName = pyxb.binding.content.AttributeUse(pyxb.namespace.ExpandedName(None, 'accasName'), 'accasName', '__httpchercheurs_edf_comlogicielsEssai_T_DefinitionDsSimpDsOper_accasName', pyxb.binding.datatypes.string)
    __accasName._DeclarationLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 96, 2)
    __accasName._UseLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 96, 2)
    
    accasName = property(__accasName.value, __accasName.set, None, None)

    
    # Attribute accasType uses Python identifier accasType
    __accasType = pyxb.binding.content.AttributeUse(pyxb.namespace.ExpandedName(None, 'accasType'), 'accasType', '__httpchercheurs_edf_comlogicielsEssai_T_DefinitionDsSimpDsOper_accasType', pyxb.binding.datatypes.string, fixed=True, unicode_default='ASSD')
    __accasType._DeclarationLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 97, 2)
    __accasType._UseLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 97, 2)
    
    accasType = property(__accasType.value, __accasType.set, None, None)

    
    # Attribute typeUtilisateur uses Python identifier typeUtilisateur
    __typeUtilisateur = pyxb.binding.content.AttributeUse(pyxb.namespace.ExpandedName(None, 'typeUtilisateur'), 'typeUtilisateur', '__httpchercheurs_edf_comlogicielsEssai_T_DefinitionDsSimpDsOper_typeUtilisateur', pyxb.binding.datatypes.string, fixed=True, unicode_default='lASSD')
    __typeUtilisateur._DeclarationLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 98, 2)
    __typeUtilisateur._UseLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 98, 2)
    
    typeUtilisateur = property(__typeUtilisateur.value, __typeUtilisateur.set, None, None)

    _ElementMap.update({
        __creeUserAssd.name() : __creeUserAssd
    })
    _AttributeMap.update({
        __accasName.name() : __accasName,
        __accasType.name() : __accasType,
        __typeUtilisateur.name() : __typeUtilisateur
    })
_module_typeBindings.T_DefinitionDsSimpDsOper = T_DefinitionDsSimpDsOper
Namespace.addCategoryObject('typeBinding', 'T_DefinitionDsSimpDsOper', T_DefinitionDsSimpDsOper)


# Complex type {http://chercheurs.edf.com/logiciels/Essai}T_DefinitionDsSimpDsProc with content type ELEMENT_ONLY
class T_DefinitionDsSimpDsProc (T_step_Essai):
    """Complex type {http://chercheurs.edf.com/logiciels/Essai}T_DefinitionDsSimpDsProc with content type ELEMENT_ONLY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_ELEMENT_ONLY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'T_DefinitionDsSimpDsProc')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 102, 1)
    _ElementMap = T_step_Essai._ElementMap.copy()
    _AttributeMap = T_step_Essai._AttributeMap.copy()
    # Base type is T_step_Essai
    
    # Element {http://chercheurs.edf.com/logiciels/Essai}creeUserAssd uses Python identifier creeUserAssd
    __creeUserAssd = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, 'creeUserAssd'), 'creeUserAssd', '__httpchercheurs_edf_comlogicielsEssai_T_DefinitionDsSimpDsProc_httpchercheurs_edf_comlogicielsEssaicreeUserAssd', False, pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 106, 3), )

    
    creeUserAssd = property(__creeUserAssd.value, __creeUserAssd.set, None, None)

    _ElementMap.update({
        __creeUserAssd.name() : __creeUserAssd
    })
    _AttributeMap.update({
        
    })
_module_typeBindings.T_DefinitionDsSimpDsProc = T_DefinitionDsSimpDsProc
Namespace.addCategoryObject('typeBinding', 'T_DefinitionDsSimpDsProc', T_DefinitionDsSimpDsProc)


# Complex type {http://chercheurs.edf.com/logiciels/Essai}T_DefinitionDsSimpListe with content type ELEMENT_ONLY
class T_DefinitionDsSimpListe (T_step_Essai):
    """Complex type {http://chercheurs.edf.com/logiciels/Essai}T_DefinitionDsSimpListe with content type ELEMENT_ONLY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_ELEMENT_ONLY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'T_DefinitionDsSimpListe')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 111, 1)
    _ElementMap = T_step_Essai._ElementMap.copy()
    _AttributeMap = T_step_Essai._AttributeMap.copy()
    # Base type is T_step_Essai
    
    # Element {http://chercheurs.edf.com/logiciels/Essai}creeUserAssd uses Python identifier creeUserAssd
    __creeUserAssd = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, 'creeUserAssd'), 'creeUserAssd', '__httpchercheurs_edf_comlogicielsEssai_T_DefinitionDsSimpListe_httpchercheurs_edf_comlogicielsEssaicreeUserAssd', False, pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 115, 3), )

    
    creeUserAssd = property(__creeUserAssd.value, __creeUserAssd.set, None, None)

    _ElementMap.update({
        __creeUserAssd.name() : __creeUserAssd
    })
    _AttributeMap.update({
        
    })
_module_typeBindings.T_DefinitionDsSimpListe = T_DefinitionDsSimpListe
Namespace.addCategoryObject('typeBinding', 'T_DefinitionDsSimpListe', T_DefinitionDsSimpListe)


# Complex type {http://chercheurs.edf.com/logiciels/Essai}T_UtiliseEtDefinitDsLeMemeProc with content type ELEMENT_ONLY
class T_UtiliseEtDefinitDsLeMemeProc (T_step_Essai):
    """Complex type {http://chercheurs.edf.com/logiciels/Essai}T_UtiliseEtDefinitDsLeMemeProc with content type ELEMENT_ONLY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_ELEMENT_ONLY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'T_UtiliseEtDefinitDsLeMemeProc')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 120, 1)
    _ElementMap = T_step_Essai._ElementMap.copy()
    _AttributeMap = T_step_Essai._AttributeMap.copy()
    # Base type is T_step_Essai
    
    # Element {http://chercheurs.edf.com/logiciels/Essai}utiliseUserAssd uses Python identifier utiliseUserAssd
    __utiliseUserAssd = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, 'utiliseUserAssd'), 'utiliseUserAssd', '__httpchercheurs_edf_comlogicielsEssai_T_UtiliseEtDefinitDsLeMemeProc_httpchercheurs_edf_comlogicielsEssaiutiliseUserAssd', False, pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 124, 3), )

    
    utiliseUserAssd = property(__utiliseUserAssd.value, __utiliseUserAssd.set, None, None)

    
    # Element {http://chercheurs.edf.com/logiciels/Essai}creeUserAssd uses Python identifier creeUserAssd
    __creeUserAssd = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, 'creeUserAssd'), 'creeUserAssd', '__httpchercheurs_edf_comlogicielsEssai_T_UtiliseEtDefinitDsLeMemeProc_httpchercheurs_edf_comlogicielsEssaicreeUserAssd', False, pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 125, 3), )

    
    creeUserAssd = property(__creeUserAssd.value, __creeUserAssd.set, None, None)

    _ElementMap.update({
        __utiliseUserAssd.name() : __utiliseUserAssd,
        __creeUserAssd.name() : __creeUserAssd
    })
    _AttributeMap.update({
        
    })
_module_typeBindings.T_UtiliseEtDefinitDsLeMemeProc = T_UtiliseEtDefinitDsLeMemeProc
Namespace.addCategoryObject('typeBinding', 'T_UtiliseEtDefinitDsLeMemeProc', T_UtiliseEtDefinitDsLeMemeProc)


# Complex type {http://chercheurs.edf.com/logiciels/Essai}T_UtiliseUnUserAssD with content type ELEMENT_ONLY
class T_UtiliseUnUserAssD (T_step_Essai):
    """Complex type {http://chercheurs.edf.com/logiciels/Essai}T_UtiliseUnUserAssD with content type ELEMENT_ONLY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_ELEMENT_ONLY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'T_UtiliseUnUserAssD')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 130, 1)
    _ElementMap = T_step_Essai._ElementMap.copy()
    _AttributeMap = T_step_Essai._AttributeMap.copy()
    # Base type is T_step_Essai
    
    # Element {http://chercheurs.edf.com/logiciels/Essai}utiliseUnUserAssd uses Python identifier utiliseUnUserAssd
    __utiliseUnUserAssd = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, 'utiliseUnUserAssd'), 'utiliseUnUserAssd', '__httpchercheurs_edf_comlogicielsEssai_T_UtiliseUnUserAssD_httpchercheurs_edf_comlogicielsEssaiutiliseUnUserAssd', False, pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 134, 3), )

    
    utiliseUnUserAssd = property(__utiliseUnUserAssd.value, __utiliseUnUserAssd.set, None, None)

    _ElementMap.update({
        __utiliseUnUserAssd.name() : __utiliseUnUserAssd
    })
    _AttributeMap.update({
        
    })
_module_typeBindings.T_UtiliseUnUserAssD = T_UtiliseUnUserAssD
Namespace.addCategoryObject('typeBinding', 'T_UtiliseUnUserAssD', T_UtiliseUnUserAssD)


step_Essai = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'step_Essai'), T_step_Essai, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 147, 1))
Namespace.addCategoryObject('elementBinding', step_Essai.name().localName(), step_Essai)

Essai = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'Essai'), T_Essai, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 148, 1))
Namespace.addCategoryObject('elementBinding', Essai.name().localName(), Essai)

DefinitionDsFactDsOper = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'DefinitionDsFactDsOper'), T_DefinitionDsFactDsOper, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 139, 1))
Namespace.addCategoryObject('elementBinding', DefinitionDsFactDsOper.name().localName(), DefinitionDsFactDsOper)

DefinitionDsFactDsProc = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'DefinitionDsFactDsProc'), T_DefinitionDsFactDsProc, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 140, 1))
Namespace.addCategoryObject('elementBinding', DefinitionDsFactDsProc.name().localName(), DefinitionDsFactDsProc)

DefinitionDsSimpDsOper = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'DefinitionDsSimpDsOper'), T_DefinitionDsSimpDsOper, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 141, 1))
Namespace.addCategoryObject('elementBinding', DefinitionDsSimpDsOper.name().localName(), DefinitionDsSimpDsOper)

DefinitionDsSimpDsProc = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'DefinitionDsSimpDsProc'), T_DefinitionDsSimpDsProc, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 142, 1))
Namespace.addCategoryObject('elementBinding', DefinitionDsSimpDsProc.name().localName(), DefinitionDsSimpDsProc)

DefinitionDsSimpListe = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'DefinitionDsSimpListe'), T_DefinitionDsSimpListe, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 143, 1))
Namespace.addCategoryObject('elementBinding', DefinitionDsSimpListe.name().localName(), DefinitionDsSimpListe)

UtiliseEtDefinitDsLeMemeProc = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'UtiliseEtDefinitDsLeMemeProc'), T_UtiliseEtDefinitDsLeMemeProc, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 144, 1))
Namespace.addCategoryObject('elementBinding', UtiliseEtDefinitDsLeMemeProc.name().localName(), UtiliseEtDefinitDsLeMemeProc)

UtiliseUnUserAssD = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'UtiliseUnUserAssD'), T_UtiliseUnUserAssD, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 145, 1))
Namespace.addCategoryObject('elementBinding', UtiliseUnUserAssD.name().localName(), UtiliseUnUserAssD)



T_unFact1._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'creeUserAssd'), T_creeUserAssd, scope=T_unFact1, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 61, 3)))

def _BuildAutomaton ():
    # Remove this helper function from the namespace after it is invoked
    global _BuildAutomaton
    del _BuildAutomaton
    import pyxb.utils.fac as fac

    counters = set()
    cc_0 = fac.CounterCondition(min=0, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 61, 3))
    counters.add(cc_0)
    states = []
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_0, False))
    symbol = pyxb.binding.content.ElementUse(T_unFact1._UseForTag(pyxb.namespace.ExpandedName(Namespace, 'creeUserAssd')), pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 61, 3))
    st_0 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_0)
    transitions = []
    transitions.append(fac.Transition(st_0, [
        fac.UpdateInstruction(cc_0, True) ]))
    st_0._set_transitionSet(transitions)
    return fac.Automaton(states, counters, True, containing_state=None)
T_unFact1._Automaton = _BuildAutomaton()




T_unFact._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'creeUserAssd'), T_creeUserAssd, scope=T_unFact, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 78, 3)))

def _BuildAutomaton_ ():
    # Remove this helper function from the namespace after it is invoked
    global _BuildAutomaton_
    del _BuildAutomaton_
    import pyxb.utils.fac as fac

    counters = set()
    cc_0 = fac.CounterCondition(min=0, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 78, 3))
    counters.add(cc_0)
    states = []
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_0, False))
    symbol = pyxb.binding.content.ElementUse(T_unFact._UseForTag(pyxb.namespace.ExpandedName(Namespace, 'creeUserAssd')), pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 78, 3))
    st_0 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_0)
    transitions = []
    transitions.append(fac.Transition(st_0, [
        fac.UpdateInstruction(cc_0, True) ]))
    st_0._set_transitionSet(transitions)
    return fac.Automaton(states, counters, True, containing_state=None)
T_unFact._Automaton = _BuildAutomaton_()




T_Essai._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'step_Essai'), T_step_Essai, scope=T_Essai, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 147, 1)))

def _BuildAutomaton_2 ():
    # Remove this helper function from the namespace after it is invoked
    global _BuildAutomaton_2
    del _BuildAutomaton_2
    import pyxb.utils.fac as fac

    counters = set()
    cc_0 = fac.CounterCondition(min=0, max=None, metadata=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 150, 4))
    counters.add(cc_0)
    cc_1 = fac.CounterCondition(min=0, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 151, 3))
    counters.add(cc_1)
    states = []
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_0, False))
    final_update.add(fac.UpdateInstruction(cc_1, False))
    symbol = pyxb.binding.content.ElementUse(T_Essai._UseForTag(pyxb.namespace.ExpandedName(Namespace, 'step_Essai')), pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 151, 3))
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
T_Essai._Automaton = _BuildAutomaton_2()




T_DefinitionDsFactDsOper._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'unFact1'), T_unFact1, scope=T_DefinitionDsFactDsOper, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 68, 3)))

def _BuildAutomaton_3 ():
    # Remove this helper function from the namespace after it is invoked
    global _BuildAutomaton_3
    del _BuildAutomaton_3
    import pyxb.utils.fac as fac

    counters = set()
    cc_0 = fac.CounterCondition(min=0, max=None, metadata=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 68, 3))
    counters.add(cc_0)
    states = []
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_0, False))
    symbol = pyxb.binding.content.ElementUse(T_DefinitionDsFactDsOper._UseForTag(pyxb.namespace.ExpandedName(Namespace, 'unFact1')), pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 68, 3))
    st_0 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_0)
    transitions = []
    transitions.append(fac.Transition(st_0, [
        fac.UpdateInstruction(cc_0, True) ]))
    st_0._set_transitionSet(transitions)
    return fac.Automaton(states, counters, True, containing_state=None)
T_DefinitionDsFactDsOper._Automaton = _BuildAutomaton_3()




T_DefinitionDsFactDsProc._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'unFact'), T_unFact, scope=T_DefinitionDsFactDsProc, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 85, 3)))

def _BuildAutomaton_4 ():
    # Remove this helper function from the namespace after it is invoked
    global _BuildAutomaton_4
    del _BuildAutomaton_4
    import pyxb.utils.fac as fac

    counters = set()
    cc_0 = fac.CounterCondition(min=0, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 85, 3))
    counters.add(cc_0)
    states = []
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_0, False))
    symbol = pyxb.binding.content.ElementUse(T_DefinitionDsFactDsProc._UseForTag(pyxb.namespace.ExpandedName(Namespace, 'unFact')), pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 85, 3))
    st_0 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_0)
    transitions = []
    transitions.append(fac.Transition(st_0, [
        fac.UpdateInstruction(cc_0, True) ]))
    st_0._set_transitionSet(transitions)
    return fac.Automaton(states, counters, True, containing_state=None)
T_DefinitionDsFactDsProc._Automaton = _BuildAutomaton_4()




T_DefinitionDsSimpDsOper._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'creeUserAssd'), T_creeUserAssd_2, scope=T_DefinitionDsSimpDsOper, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 94, 3)))

def _BuildAutomaton_5 ():
    # Remove this helper function from the namespace after it is invoked
    global _BuildAutomaton_5
    del _BuildAutomaton_5
    import pyxb.utils.fac as fac

    counters = set()
    cc_0 = fac.CounterCondition(min=0, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 94, 3))
    counters.add(cc_0)
    states = []
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_0, False))
    symbol = pyxb.binding.content.ElementUse(T_DefinitionDsSimpDsOper._UseForTag(pyxb.namespace.ExpandedName(Namespace, 'creeUserAssd')), pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 94, 3))
    st_0 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_0)
    transitions = []
    transitions.append(fac.Transition(st_0, [
        fac.UpdateInstruction(cc_0, True) ]))
    st_0._set_transitionSet(transitions)
    return fac.Automaton(states, counters, True, containing_state=None)
T_DefinitionDsSimpDsOper._Automaton = _BuildAutomaton_5()




T_DefinitionDsSimpDsProc._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'creeUserAssd'), T_creeUserAssd, scope=T_DefinitionDsSimpDsProc, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 106, 3)))

def _BuildAutomaton_6 ():
    # Remove this helper function from the namespace after it is invoked
    global _BuildAutomaton_6
    del _BuildAutomaton_6
    import pyxb.utils.fac as fac

    counters = set()
    cc_0 = fac.CounterCondition(min=0, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 106, 3))
    counters.add(cc_0)
    states = []
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_0, False))
    symbol = pyxb.binding.content.ElementUse(T_DefinitionDsSimpDsProc._UseForTag(pyxb.namespace.ExpandedName(Namespace, 'creeUserAssd')), pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 106, 3))
    st_0 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_0)
    transitions = []
    transitions.append(fac.Transition(st_0, [
        fac.UpdateInstruction(cc_0, True) ]))
    st_0._set_transitionSet(transitions)
    return fac.Automaton(states, counters, True, containing_state=None)
T_DefinitionDsSimpDsProc._Automaton = _BuildAutomaton_6()




T_DefinitionDsSimpListe._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'creeUserAssd'), T_creeUserAssd_4, scope=T_DefinitionDsSimpListe, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 115, 3)))

def _BuildAutomaton_7 ():
    # Remove this helper function from the namespace after it is invoked
    global _BuildAutomaton_7
    del _BuildAutomaton_7
    import pyxb.utils.fac as fac

    counters = set()
    cc_0 = fac.CounterCondition(min=0, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 115, 3))
    counters.add(cc_0)
    states = []
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_0, False))
    symbol = pyxb.binding.content.ElementUse(T_DefinitionDsSimpListe._UseForTag(pyxb.namespace.ExpandedName(Namespace, 'creeUserAssd')), pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 115, 3))
    st_0 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_0)
    transitions = []
    transitions.append(fac.Transition(st_0, [
        fac.UpdateInstruction(cc_0, True) ]))
    st_0._set_transitionSet(transitions)
    return fac.Automaton(states, counters, True, containing_state=None)
T_DefinitionDsSimpListe._Automaton = _BuildAutomaton_7()




T_UtiliseEtDefinitDsLeMemeProc._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'utiliseUserAssd'), T_utiliseUserAssd, scope=T_UtiliseEtDefinitDsLeMemeProc, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 124, 3)))

T_UtiliseEtDefinitDsLeMemeProc._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'creeUserAssd'), T_creeUserAssd, scope=T_UtiliseEtDefinitDsLeMemeProc, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 125, 3)))

def _BuildAutomaton_8 ():
    # Remove this helper function from the namespace after it is invoked
    global _BuildAutomaton_8
    del _BuildAutomaton_8
    import pyxb.utils.fac as fac

    counters = set()
    cc_0 = fac.CounterCondition(min=0, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 125, 3))
    counters.add(cc_0)
    states = []
    final_update = set()
    symbol = pyxb.binding.content.ElementUse(T_UtiliseEtDefinitDsLeMemeProc._UseForTag(pyxb.namespace.ExpandedName(Namespace, 'utiliseUserAssd')), pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 124, 3))
    st_0 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_0)
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_0, False))
    symbol = pyxb.binding.content.ElementUse(T_UtiliseEtDefinitDsLeMemeProc._UseForTag(pyxb.namespace.ExpandedName(Namespace, 'creeUserAssd')), pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 125, 3))
    st_1 = fac.State(symbol, is_initial=False, final_update=final_update, is_unordered_catenation=False)
    states.append(st_1)
    transitions = []
    transitions.append(fac.Transition(st_1, [
         ]))
    st_0._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_1, [
        fac.UpdateInstruction(cc_0, True) ]))
    st_1._set_transitionSet(transitions)
    return fac.Automaton(states, counters, False, containing_state=None)
T_UtiliseEtDefinitDsLeMemeProc._Automaton = _BuildAutomaton_8()




T_UtiliseUnUserAssD._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'utiliseUnUserAssd'), T_utiliseUnUserAssd, scope=T_UtiliseUnUserAssD, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 134, 3)))

def _BuildAutomaton_9 ():
    # Remove this helper function from the namespace after it is invoked
    global _BuildAutomaton_9
    del _BuildAutomaton_9
    import pyxb.utils.fac as fac

    counters = set()
    states = []
    final_update = set()
    symbol = pyxb.binding.content.ElementUse(T_UtiliseUnUserAssD._UseForTag(pyxb.namespace.ExpandedName(Namespace, 'utiliseUnUserAssd')), pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_UserAssd.xsd', 134, 3))
    st_0 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_0)
    transitions = []
    st_0._set_transitionSet(transitions)
    return fac.Automaton(states, counters, False, containing_state=None)
T_UtiliseUnUserAssD._Automaton = _BuildAutomaton_9()


DefinitionDsFactDsOper._setSubstitutionGroup(step_Essai)

DefinitionDsFactDsProc._setSubstitutionGroup(step_Essai)

DefinitionDsSimpDsOper._setSubstitutionGroup(step_Essai)

DefinitionDsSimpDsProc._setSubstitutionGroup(step_Essai)

DefinitionDsSimpListe._setSubstitutionGroup(step_Essai)

UtiliseEtDefinitDsLeMemeProc._setSubstitutionGroup(step_Essai)

UtiliseUnUserAssD._setSubstitutionGroup(step_Essai)
