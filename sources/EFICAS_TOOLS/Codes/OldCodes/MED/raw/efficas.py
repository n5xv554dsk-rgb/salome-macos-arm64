# ./raw/efficas.py
# -*- coding: utf-8 -*-
# PyXB bindings for NM:759f40938b7670cd6d5941e706557eb2115fb17f
# Generated 2016-11-23 16:51:37.568270 by PyXB version 1.2.3
# Namespace http://chercheurs.edf.com/logiciels/efficas

import pyxb
import pyxb.binding
import pyxb.binding.saxer
import io
import pyxb.utils.utility
import pyxb.utils.domutils
import sys

# Unique identifier for bindings created at the same time
_GenerationUID = pyxb.utils.utility.UniqueIdentifier('urn:uuid:b79c3f70-b194-11e6-bb0f-b05adafd94d6')

# Version of PyXB used to generate the bindings
_PyXBVersion = '1.2.3'
# Generated bindings are not compatible across PyXB versions
if pyxb.__version__ != _PyXBVersion:
    raise pyxb.PyXBVersionError(_PyXBVersion)

# Import bindings for namespaces imported into schema
import pyxb.binding.datatypes

# NOTE: All namespace declarations are reserved within the binding
Namespace = pyxb.namespace.NamespaceForURI(u'http://chercheurs.edf.com/logiciels/efficas', create_if_missing=True)
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
        return CreateFromDOM(dom.documentElement)
    if default_namespace is None:
        default_namespace = Namespace.fallbackNamespace()
    saxer = pyxb.binding.saxer.make_parser(fallback_namespace=default_namespace, location_base=location_base)
    handler = saxer.getContentHandler()
    xmld = xml_text
    if isinstance(xmld, unicode):
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


# Atomic simple type: {http://chercheurs.edf.com/logiciels/efficas}T_fonction_python
class T_fonction_python (pyxb.binding.datatypes.string):

    """An atomic simple type."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_fonction_python')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 154, 1)
    _Documentation = None
T_fonction_python._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', u'T_fonction_python', T_fonction_python)

# Atomic simple type: {http://chercheurs.edf.com/logiciels/efficas}AT_statut
class AT_statut (pyxb.binding.datatypes.string, pyxb.binding.basis.enumeration_mixin):

    """An atomic simple type."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'AT_statut')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 190, 1)
    _Documentation = None
AT_statut._CF_enumeration = pyxb.binding.facets.CF_enumeration(value_datatype=AT_statut, enum_prefix=None)
AT_statut.f = AT_statut._CF_enumeration.addEnumeration(unicode_value=u'f', tag=u'f')
AT_statut.o = AT_statut._CF_enumeration.addEnumeration(unicode_value=u'o', tag=u'o')
AT_statut._InitializeFacetMap(AT_statut._CF_enumeration)
Namespace.addCategoryObject('typeBinding', u'AT_statut', AT_statut)

# Atomic simple type: {http://chercheurs.edf.com/logiciels/efficas}T_portee
class T_portee (pyxb.binding.datatypes.string, pyxb.binding.basis.enumeration_mixin):

    """An atomic simple type."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_portee')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 202, 1)
    _Documentation = None
T_portee._CF_enumeration = pyxb.binding.facets.CF_enumeration(value_datatype=T_portee, enum_prefix=None)
T_portee.None_ = T_portee._CF_enumeration.addEnumeration(unicode_value=u'None', tag=u'None_')
T_portee.Global = T_portee._CF_enumeration.addEnumeration(unicode_value=u'Global', tag=u'Global')
T_portee._InitializeFacetMap(T_portee._CF_enumeration)
Namespace.addCategoryObject('typeBinding', u'T_portee', T_portee)

# Atomic simple type: {http://chercheurs.edf.com/logiciels/efficas}AT_max_occurs
class AT_max_occurs (pyxb.binding.datatypes.long):

    """An atomic simple type."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'AT_max_occurs')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 208, 1)
    _Documentation = None
AT_max_occurs._CF_minInclusive = pyxb.binding.facets.CF_minInclusive(value_datatype=AT_max_occurs, value=pyxb.binding.datatypes.long(-1L))
AT_max_occurs._InitializeFacetMap(AT_max_occurs._CF_minInclusive)
Namespace.addCategoryObject('typeBinding', u'AT_max_occurs', AT_max_occurs)

# Atomic simple type: {http://chercheurs.edf.com/logiciels/efficas}AT_min_occurs
class AT_min_occurs (pyxb.binding.datatypes.long):

    """An atomic simple type."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'AT_min_occurs')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 213, 1)
    _Documentation = None
AT_min_occurs._CF_minExclusive = pyxb.binding.facets.CF_minExclusive(value_datatype=pyxb.binding.datatypes.long, value=pyxb.binding.datatypes.integer(0L))
AT_min_occurs._InitializeFacetMap(AT_min_occurs._CF_minExclusive)
Namespace.addCategoryObject('typeBinding', u'AT_min_occurs', AT_min_occurs)

# Atomic simple type: {http://chercheurs.edf.com/logiciels/efficas}AT_ag
class AT_ag (pyxb.binding.datatypes.string, pyxb.binding.basis.enumeration_mixin):

    """An atomic simple type."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'AT_ag')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 226, 1)
    _Documentation = None
AT_ag._CF_enumeration = pyxb.binding.facets.CF_enumeration(value_datatype=AT_ag, enum_prefix=None)
AT_ag.No_comment = AT_ag._CF_enumeration.addEnumeration(unicode_value=u'No comment', tag=u'No_comment')
AT_ag._InitializeFacetMap(AT_ag._CF_enumeration)
Namespace.addCategoryObject('typeBinding', u'AT_ag', AT_ag)

# Atomic simple type: {http://chercheurs.edf.com/logiciels/efficas}AT_docu
class AT_docu (pyxb.binding.datatypes.string):

    """Référence une position dans un fichier maître contenant une liste de références à des pages de documentations"""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'AT_docu')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 231, 1)
    _Documentation = u'R\xe9f\xe9rence une position dans un fichier ma\xeetre contenant une liste de r\xe9f\xe9rences \xe0 des pages de documentations'
AT_docu._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', u'AT_docu', AT_docu)

# Atomic simple type: {http://chercheurs.edf.com/logiciels/efficas}AT_valeur_sugg
class AT_valeur_sugg (pyxb.binding.datatypes.string):

    """An atomic simple type."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'AT_valeur_sugg')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 237, 1)
    _Documentation = None
AT_valeur_sugg._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', u'AT_valeur_sugg', AT_valeur_sugg)

# Atomic simple type: {http://chercheurs.edf.com/logiciels/efficas}AT_nom
class AT_nom (pyxb.binding.datatypes.string):

    """An atomic simple type."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'AT_nom')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 241, 1)
    _Documentation = None
AT_nom._CF_pattern = pyxb.binding.facets.CF_pattern()
AT_nom._CF_pattern.addPattern(pattern=u'([A-Z]|[a-z]|_)([A-Z]|[a-z]|_|[0-9])*')
AT_nom._InitializeFacetMap(AT_nom._CF_pattern)
Namespace.addCategoryObject('typeBinding', u'AT_nom', AT_nom)

# Atomic simple type: {http://chercheurs.edf.com/logiciels/efficas}T_validators
class T_validators (pyxb.binding.datatypes.string, pyxb.binding.basis.enumeration_mixin):

    """An atomic simple type."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_validators')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 303, 1)
    _Documentation = None
T_validators._CF_enumeration = pyxb.binding.facets.CF_enumeration(value_datatype=T_validators, enum_prefix=None)
T_validators.NoRepeat = T_validators._CF_enumeration.addEnumeration(unicode_value=u'NoRepeat', tag=u'NoRepeat')
T_validators.OnlyStr = T_validators._CF_enumeration.addEnumeration(unicode_value=u'OnlyStr', tag=u'OnlyStr')
T_validators.VerifExiste = T_validators._CF_enumeration.addEnumeration(unicode_value=u'VerifExiste', tag=u'VerifExiste')
T_validators.VerifTypeTuple = T_validators._CF_enumeration.addEnumeration(unicode_value=u'VerifTypeTuple', tag=u'VerifTypeTuple')
T_validators._InitializeFacetMap(T_validators._CF_enumeration)
Namespace.addCategoryObject('typeBinding', u'T_validators', T_validators)

# Atomic simple type: {http://chercheurs.edf.com/logiciels/efficas}T_Bool
class T_Bool (pyxb.binding.datatypes.boolean):

    """An atomic simple type."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_Bool')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 311, 1)
    _Documentation = None
T_Bool._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', u'T_Bool', T_Bool)

# Atomic simple type: {http://chercheurs.edf.com/logiciels/efficas}T_I
class T_I (pyxb.binding.datatypes.int):

    """An atomic simple type."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_I')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 317, 1)
    _Documentation = None
T_I._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', u'T_I', T_I)

# Atomic simple type: {http://chercheurs.edf.com/logiciels/efficas}T_R
class T_R (pyxb.binding.datatypes.double):

    """An atomic simple type."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_R')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 323, 1)
    _Documentation = None
T_R._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', u'T_R', T_R)

# List simple type: [anonymous]
# superclasses pyxb.binding.datatypes.anySimpleType
class STD_ANON (pyxb.binding.basis.STD_list):

    """Simple type that is a list of pyxb.binding.datatypes.double."""

    _ExpandedName = None
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 338, 3)
    _Documentation = None

    _ItemType = pyxb.binding.datatypes.double
STD_ANON._InitializeFacetMap()

# List simple type: {http://chercheurs.edf.com/logiciels/efficas}T_list_C
# superclasses pyxb.binding.datatypes.anySimpleType
class T_list_C (pyxb.binding.basis.STD_list):

    """Simple type that is a list of pyxb.binding.datatypes.double."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_list_C')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 347, 1)
    _Documentation = None

    _ItemType = pyxb.binding.datatypes.double
T_list_C._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', u'T_list_C', T_list_C)

# Atomic simple type: [anonymous]
class STD_ANON_ (pyxb.binding.datatypes.string):

    """An atomic simple type."""

    _ExpandedName = None
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 402, 3)
    _Documentation = None
STD_ANON_._CF_whiteSpace = pyxb.binding.facets.CF_whiteSpace(value=pyxb.binding.facets._WhiteSpace_enum.preserve)
STD_ANON_._InitializeFacetMap(STD_ANON_._CF_whiteSpace)

# List simple type: {http://chercheurs.edf.com/logiciels/efficas}T_list_double
# superclasses pyxb.binding.datatypes.anySimpleType
class T_list_double (pyxb.binding.basis.STD_list):

    """Simple type that is a list of pyxb.binding.datatypes.double."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_list_double')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 428, 1)
    _Documentation = None

    _ItemType = pyxb.binding.datatypes.double
T_list_double._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', u'T_list_double', T_list_double)

# List simple type: {http://chercheurs.edf.com/logiciels/efficas}T_predicat1
# superclasses pyxb.binding.datatypes.anySimpleType
class T_predicat1 (pyxb.binding.basis.STD_list):

    """Simple type that is a list of AT_nom."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_predicat1')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 246, 1)
    _Documentation = None

    _ItemType = AT_nom
T_predicat1._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', u'T_predicat1', T_predicat1)

# Atomic simple type: {http://chercheurs.edf.com/logiciels/efficas}AT_subroutine
class AT_subroutine (AT_nom):

    """An atomic simple type."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'AT_subroutine')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 300, 1)
    _Documentation = None
AT_subroutine._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', u'AT_subroutine', AT_subroutine)

# List simple type: {http://chercheurs.edf.com/logiciels/efficas}T_list_Bool
# superclasses pyxb.binding.datatypes.anySimpleType
class T_list_Bool (pyxb.binding.basis.STD_list):

    """Simple type that is a list of T_Bool."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_list_Bool')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 314, 1)
    _Documentation = None

    _ItemType = T_Bool
T_list_Bool._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', u'T_list_Bool', T_list_Bool)

# List simple type: {http://chercheurs.edf.com/logiciels/efficas}T_list_I
# superclasses pyxb.binding.datatypes.anySimpleType
class T_list_I (pyxb.binding.basis.STD_list):

    """Simple type that is a list of T_I."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_list_I')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 320, 1)
    _Documentation = None

    _ItemType = T_I
T_list_I._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', u'T_list_I', T_list_I)

# List simple type: {http://chercheurs.edf.com/logiciels/efficas}T_list_R
# superclasses pyxb.binding.datatypes.anySimpleType
class T_list_R (pyxb.binding.basis.STD_list):

    """Simple type that is a list of T_R."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_list_R')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 326, 1)
    _Documentation = None

    _ItemType = T_R
T_list_R._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', u'T_list_R', T_list_R)

# Atomic simple type: {http://chercheurs.edf.com/logiciels/efficas}T_TXM
class T_TXM (AT_nom):

    """An atomic simple type."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_TXM')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 329, 1)
    _Documentation = None
T_TXM._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', u'T_TXM', T_TXM)

# List simple type: {http://chercheurs.edf.com/logiciels/efficas}T_C
# superclasses STD_ANON
class T_C (pyxb.binding.basis.STD_list):

    """Simple type that is a list of pyxb.binding.datatypes.double."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_C')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 336, 1)
    _Documentation = None

    _ItemType = pyxb.binding.datatypes.double
T_C._CF_maxLength = pyxb.binding.facets.CF_maxLength(value=pyxb.binding.datatypes.nonNegativeInteger(2L))
T_C._CF_minLength = pyxb.binding.facets.CF_minLength(value=pyxb.binding.datatypes.nonNegativeInteger(2L))
T_C._InitializeFacetMap(T_C._CF_maxLength,
   T_C._CF_minLength)
Namespace.addCategoryObject('typeBinding', u'T_C', T_C)

# Atomic simple type: {http://chercheurs.edf.com/logiciels/efficas}T_name_base
class T_name_base (AT_nom):

    """An atomic simple type."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_name_base')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 350, 1)
    _Documentation = None
T_name_base._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', u'T_name_base', T_name_base)

# Atomic simple type: [anonymous]
class STD_ANON_2 (AT_nom, pyxb.binding.basis.enumeration_mixin):

    """An atomic simple type."""

    _ExpandedName = None
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 385, 3)
    _Documentation = None
STD_ANON_2._CF_enumeration = pyxb.binding.facets.CF_enumeration(value_datatype=STD_ANON_2, enum_prefix=None)
STD_ANON_2.T_Matrice_double = STD_ANON_2._CF_enumeration.addEnumeration(unicode_value=u'T_Matrice_double', tag=u'T_Matrice_double')
STD_ANON_2.T_Matrice_Symetrique_double = STD_ANON_2._CF_enumeration.addEnumeration(unicode_value=u'T_Matrice_Symetrique_double', tag=u'T_Matrice_Symetrique_double')
STD_ANON_2.T_tuple = STD_ANON_2._CF_enumeration.addEnumeration(unicode_value=u'T_tuple', tag=u'T_tuple')
STD_ANON_2.T_classe_utilisateur = STD_ANON_2._CF_enumeration.addEnumeration(unicode_value=u'T_classe_utilisateur', tag=u'T_classe_utilisateur')
STD_ANON_2._InitializeFacetMap(STD_ANON_2._CF_enumeration)

# List simple type: {http://chercheurs.edf.com/logiciels/efficas}T_Repertoire
# superclasses pyxb.binding.datatypes.anySimpleType
class T_Repertoire (pyxb.binding.basis.STD_list):

    """Simple type that is a list of STD_ANON_."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_Repertoire')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 400, 1)
    _Documentation = None

    _ItemType = STD_ANON_
T_Repertoire._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', u'T_Repertoire', T_Repertoire)

# Atomic simple type: {http://chercheurs.edf.com/logiciels/efficas}T_classe_utilisateur
class T_classe_utilisateur (AT_nom):

    """An atomic simple type."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_classe_utilisateur')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 461, 1)
    _Documentation = None
T_classe_utilisateur._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', u'T_classe_utilisateur', T_classe_utilisateur)

# List simple type: {http://chercheurs.edf.com/logiciels/efficas}T_list_TXM
# superclasses pyxb.binding.datatypes.anySimpleType
class T_list_TXM (pyxb.binding.basis.STD_list):

    """Simple type that is a list of T_TXM."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_list_TXM')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 332, 1)
    _Documentation = None

    _ItemType = T_TXM
T_list_TXM._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', u'T_list_TXM', T_list_TXM)

# Atomic simple type: {http://chercheurs.edf.com/logiciels/efficas}T_simple_name
class T_simple_name (T_name_base, pyxb.binding.basis.enumeration_mixin):

    """An atomic simple type."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_simple_name')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 353, 1)
    _Documentation = None
T_simple_name._CF_enumeration = pyxb.binding.facets.CF_enumeration(value_datatype=T_simple_name, enum_prefix=None)
T_simple_name.Fichier = T_simple_name._CF_enumeration.addEnumeration(unicode_value=u'Fichier', tag=u'Fichier')
T_simple_name.Repertoire = T_simple_name._CF_enumeration.addEnumeration(unicode_value=u'Repertoire', tag=u'Repertoire')
T_simple_name.TXM = T_simple_name._CF_enumeration.addEnumeration(unicode_value=u'TXM', tag=u'TXM')
T_simple_name.I = T_simple_name._CF_enumeration.addEnumeration(unicode_value=u'I', tag=u'I')
T_simple_name.R = T_simple_name._CF_enumeration.addEnumeration(unicode_value=u'R', tag=u'R')
T_simple_name.C = T_simple_name._CF_enumeration.addEnumeration(unicode_value=u'C', tag=u'C')
T_simple_name.Bool = T_simple_name._CF_enumeration.addEnumeration(unicode_value=u'Bool', tag=u'Bool')
T_simple_name.grma = T_simple_name._CF_enumeration.addEnumeration(unicode_value=u'grma', tag=u'grma')
T_simple_name.grno = T_simple_name._CF_enumeration.addEnumeration(unicode_value=u'grno', tag=u'grno')
T_simple_name.SalomeEntry = T_simple_name._CF_enumeration.addEnumeration(unicode_value=u'SalomeEntry', tag=u'SalomeEntry')
T_simple_name._InitializeFacetMap(T_simple_name._CF_enumeration)
Namespace.addCategoryObject('typeBinding', u'T_simple_name', T_simple_name)

# Union simple type: {http://chercheurs.edf.com/logiciels/efficas}T_name
# superclasses pyxb.binding.datatypes.anySimpleType
class T_name (pyxb.binding.basis.STD_union):

    """Simple type that is a union of T_simple_name, STD_ANON_2."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_name')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 383, 1)
    _Documentation = None

    _MemberTypes = ( T_simple_name, STD_ANON_2, )
T_name._CF_pattern = pyxb.binding.facets.CF_pattern()
T_name._CF_enumeration = pyxb.binding.facets.CF_enumeration(value_datatype=T_name)
T_name.Fichier = u'Fichier'                       # originally T_simple_name.Fichier
T_name.Repertoire = u'Repertoire'                 # originally T_simple_name.Repertoire
T_name.TXM = u'TXM'                               # originally T_simple_name.TXM
T_name.I = u'I'                                   # originally T_simple_name.I
T_name.R = u'R'                                   # originally T_simple_name.R
T_name.C = u'C'                                   # originally T_simple_name.C
T_name.Bool = u'Bool'                             # originally T_simple_name.Bool
T_name.grma = u'grma'                             # originally T_simple_name.grma
T_name.grno = u'grno'                             # originally T_simple_name.grno
T_name.SalomeEntry = u'SalomeEntry'               # originally T_simple_name.SalomeEntry
T_name.T_Matrice_double = u'T_Matrice_double'     # originally STD_ANON_2.T_Matrice_double
T_name.T_Matrice_Symetrique_double = u'T_Matrice_Symetrique_double'# originally STD_ANON_2.T_Matrice_Symetrique_double
T_name.T_tuple = u'T_tuple'                       # originally STD_ANON_2.T_tuple
T_name.T_classe_utilisateur = u'T_classe_utilisateur'# originally STD_ANON_2.T_classe_utilisateur
T_name._InitializeFacetMap(T_name._CF_pattern,
   T_name._CF_enumeration)
Namespace.addCategoryObject('typeBinding', u'T_name', T_name)

# Union simple type: {http://chercheurs.edf.com/logiciels/efficas}T_simple
# superclasses pyxb.binding.datatypes.anySimpleType
class T_simple (pyxb.binding.basis.STD_union):

    """Simple type that is a union of T_I, T_list_I, T_R, T_list_R, T_C, T_list_C, T_TXM, T_list_TXM, T_Bool, T_list_Bool, T_Repertoire."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_simple')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 409, 1)
    _Documentation = None

    _MemberTypes = ( T_I, T_list_I, T_R, T_list_R, T_C, T_list_C, T_TXM, T_list_TXM, T_Bool, T_list_Bool, T_Repertoire, )
T_simple._CF_pattern = pyxb.binding.facets.CF_pattern()
T_simple._CF_enumeration = pyxb.binding.facets.CF_enumeration(value_datatype=T_simple)
T_simple._InitializeFacetMap(T_simple._CF_pattern,
   T_simple._CF_enumeration)
Namespace.addCategoryObject('typeBinding', u'T_simple', T_simple)

# Union simple type: {http://chercheurs.edf.com/logiciels/efficas}T_classe_utilisateur_name
# superclasses T_name, pyxb.binding.basis.enumeration_mixin
class T_classe_utilisateur_name (pyxb.binding.basis.STD_union):

    """Simple type that is a union of T_simple_name, STD_ANON_2."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_classe_utilisateur_name')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 371, 1)
    _Documentation = None

    _MemberTypes = ( T_simple_name, STD_ANON_2, )
T_classe_utilisateur_name._CF_enumeration = pyxb.binding.facets.CF_enumeration(value_datatype=T_classe_utilisateur_name, enum_prefix=None)
T_classe_utilisateur_name.T_classe_utilisateur = T_classe_utilisateur_name._CF_enumeration.addEnumeration(unicode_value=u'T_classe_utilisateur', tag=u'T_classe_utilisateur')
T_classe_utilisateur_name._InitializeFacetMap(T_classe_utilisateur_name._CF_enumeration)
Namespace.addCategoryObject('typeBinding', u'T_classe_utilisateur_name', T_classe_utilisateur_name)

# Complex type {http://chercheurs.edf.com/logiciels/efficas}T_cata with content type ELEMENT_ONLY
class T_cata (pyxb.binding.basis.complexTypeDefinition):
    """Complex type {http://chercheurs.edf.com/logiciels/efficas}T_cata with content type ELEMENT_ONLY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_ELEMENT_ONLY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_cata')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 66, 1)
    _ElementMap = {}
    _AttributeMap = {}
    # Base type is pyxb.binding.datatypes.anyType
    
    # Element {http://chercheurs.edf.com/logiciels/efficas}commandes uses Python identifier commandes
    __commandes = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'commandes'), 'commandes', '__httpchercheurs_edf_comlogicielsefficas_T_cata_httpchercheurs_edf_comlogicielsefficascommandes', True, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 11, 1), )

    
    commandes = property(__commandes.value, __commandes.set, None, None)

    _ElementMap.update({
        __commandes.name() : __commandes
    })
    _AttributeMap.update({
        
    })
Namespace.addCategoryObject('typeBinding', u'T_cata', T_cata)


# Complex type {http://chercheurs.edf.com/logiciels/efficas}T_commandes with content type ELEMENT_ONLY
class T_commandes (pyxb.binding.basis.complexTypeDefinition):
    """Complex type {http://chercheurs.edf.com/logiciels/efficas}T_commandes with content type ELEMENT_ONLY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_ELEMENT_ONLY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_commandes')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 71, 1)
    _ElementMap = {}
    _AttributeMap = {}
    # Base type is pyxb.binding.datatypes.anyType
    
    # Element {http://chercheurs.edf.com/logiciels/efficas}OPER uses Python identifier OPER
    __OPER = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'OPER'), 'OPER', '__httpchercheurs_edf_comlogicielsefficas_T_commandes_httpchercheurs_edf_comlogicielsefficasOPER', True, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 99, 1), )

    
    OPER = property(__OPER.value, __OPER.set, None, None)

    
    # Element {http://chercheurs.edf.com/logiciels/efficas}PROC uses Python identifier PROC
    __PROC = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'PROC'), 'PROC', '__httpchercheurs_edf_comlogicielsefficas_T_commandes_httpchercheurs_edf_comlogicielsefficasPROC', True, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 110, 1), )

    
    PROC = property(__PROC.value, __PROC.set, None, None)

    _ElementMap.update({
        __OPER.name() : __OPER,
        __PROC.name() : __PROC
    })
    _AttributeMap.update({
        
    })
Namespace.addCategoryObject('typeBinding', u'T_commandes', T_commandes)


# Complex type {http://chercheurs.edf.com/logiciels/efficas}T_Cardinalite with content type EMPTY
class T_Cardinalite (pyxb.binding.basis.complexTypeDefinition):
    """Complex type {http://chercheurs.edf.com/logiciels/efficas}T_Cardinalite with content type EMPTY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_EMPTY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_Cardinalite')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 77, 1)
    _ElementMap = {}
    _AttributeMap = {}
    # Base type is pyxb.binding.datatypes.anyType
    _ElementMap.update({
        
    })
    _AttributeMap.update({
        
    })
Namespace.addCategoryObject('typeBinding', u'T_Cardinalite', T_Cardinalite)


# Complex type {http://chercheurs.edf.com/logiciels/efficas}T_PlageValeur with content type ELEMENT_ONLY
class T_PlageValeur (pyxb.binding.basis.complexTypeDefinition):
    """Complex type {http://chercheurs.edf.com/logiciels/efficas}T_PlageValeur with content type ELEMENT_ONLY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_ELEMENT_ONLY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_PlageValeur')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 78, 1)
    _ElementMap = {}
    _AttributeMap = {}
    # Base type is pyxb.binding.datatypes.anyType
    
    # Element {http://chercheurs.edf.com/logiciels/efficas}borne_sup uses Python identifier borne_sup
    __borne_sup = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'borne_sup'), 'borne_sup', '__httpchercheurs_edf_comlogicielsefficas_T_PlageValeur_httpchercheurs_edf_comlogicielsefficasborne_sup', False, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 46, 1), )

    
    borne_sup = property(__borne_sup.value, __borne_sup.set, None, None)

    
    # Element {http://chercheurs.edf.com/logiciels/efficas}borne_inf uses Python identifier borne_inf
    __borne_inf = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'borne_inf'), 'borne_inf', '__httpchercheurs_edf_comlogicielsefficas_T_PlageValeur_httpchercheurs_edf_comlogicielsefficasborne_inf', False, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 47, 1), )

    
    borne_inf = property(__borne_inf.value, __borne_inf.set, None, None)

    
    # Element {http://chercheurs.edf.com/logiciels/efficas}into uses Python identifier into
    __into = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'into'), 'into', '__httpchercheurs_edf_comlogicielsefficas_T_PlageValeur_httpchercheurs_edf_comlogicielsefficasinto', False, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 49, 1), )

    
    into = property(__into.value, __into.set, None, None)

    _ElementMap.update({
        __borne_sup.name() : __borne_sup,
        __borne_inf.name() : __borne_inf,
        __into.name() : __into
    })
    _AttributeMap.update({
        
    })
Namespace.addCategoryObject('typeBinding', u'T_PlageValeur', T_PlageValeur)


# Complex type {http://chercheurs.edf.com/logiciels/efficas}T_predicat2 with content type ELEMENT_ONLY
class T_predicat2 (pyxb.binding.basis.complexTypeDefinition):
    """Complex type {http://chercheurs.edf.com/logiciels/efficas}T_predicat2 with content type ELEMENT_ONLY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_ELEMENT_ONLY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_predicat2')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 250, 1)
    _ElementMap = {}
    _AttributeMap = {}
    # Base type is pyxb.binding.datatypes.anyType
    
    # Element {http://chercheurs.edf.com/logiciels/efficas}p1 uses Python identifier p1
    __p1 = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'p1'), 'p1', '__httpchercheurs_edf_comlogicielsefficas_T_predicat2_httpchercheurs_edf_comlogicielsefficasp1', False, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 252, 3), )

    
    p1 = property(__p1.value, __p1.set, None, None)

    
    # Element {http://chercheurs.edf.com/logiciels/efficas}p2 uses Python identifier p2
    __p2 = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'p2'), 'p2', '__httpchercheurs_edf_comlogicielsefficas_T_predicat2_httpchercheurs_edf_comlogicielsefficasp2', False, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 253, 3), )

    
    p2 = property(__p2.value, __p2.set, None, None)

    _ElementMap.update({
        __p1.name() : __p1,
        __p2.name() : __p2
    })
    _AttributeMap.update({
        
    })
Namespace.addCategoryObject('typeBinding', u'T_predicat2', T_predicat2)


# Complex type {http://chercheurs.edf.com/logiciels/efficas}T_regles with content type ELEMENT_ONLY
class T_regles (pyxb.binding.basis.complexTypeDefinition):
    """Complex type {http://chercheurs.edf.com/logiciels/efficas}T_regles with content type ELEMENT_ONLY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_ELEMENT_ONLY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_regles')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 291, 1)
    _ElementMap = {}
    _AttributeMap = {}
    # Base type is pyxb.binding.datatypes.anyType
    
    # Element {http://chercheurs.edf.com/logiciels/efficas}A_CLASSER uses Python identifier A_CLASSER
    __A_CLASSER = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'A_CLASSER'), 'A_CLASSER', '__httpchercheurs_edf_comlogicielsefficas_T_regles_httpchercheurs_edf_comlogicielsefficasA_CLASSER', True, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 257, 1), )

    
    A_CLASSER = property(__A_CLASSER.value, __A_CLASSER.set, None, None)

    
    # Element {http://chercheurs.edf.com/logiciels/efficas}AU_MOINS_UN uses Python identifier AU_MOINS_UN
    __AU_MOINS_UN = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'AU_MOINS_UN'), 'AU_MOINS_UN', '__httpchercheurs_edf_comlogicielsefficas_T_regles_httpchercheurs_edf_comlogicielsefficasAU_MOINS_UN', True, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 258, 1), )

    
    AU_MOINS_UN = property(__AU_MOINS_UN.value, __AU_MOINS_UN.set, None, None)

    
    # Element {http://chercheurs.edf.com/logiciels/efficas}AU_PLUS_UN uses Python identifier AU_PLUS_UN
    __AU_PLUS_UN = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'AU_PLUS_UN'), 'AU_PLUS_UN', '__httpchercheurs_edf_comlogicielsefficas_T_regles_httpchercheurs_edf_comlogicielsefficasAU_PLUS_UN', True, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 259, 1), )

    
    AU_PLUS_UN = property(__AU_PLUS_UN.value, __AU_PLUS_UN.set, None, None)

    
    # Element {http://chercheurs.edf.com/logiciels/efficas}ENSEMBLE uses Python identifier ENSEMBLE
    __ENSEMBLE = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'ENSEMBLE'), 'ENSEMBLE', '__httpchercheurs_edf_comlogicielsefficas_T_regles_httpchercheurs_edf_comlogicielsefficasENSEMBLE', True, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 260, 1), )

    
    ENSEMBLE = property(__ENSEMBLE.value, __ENSEMBLE.set, None, None)

    
    # Element {http://chercheurs.edf.com/logiciels/efficas}EXCLUS uses Python identifier EXCLUS
    __EXCLUS = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'EXCLUS'), 'EXCLUS', '__httpchercheurs_edf_comlogicielsefficas_T_regles_httpchercheurs_edf_comlogicielsefficasEXCLUS', True, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 261, 1), )

    
    EXCLUS = property(__EXCLUS.value, __EXCLUS.set, None, None)

    
    # Element {http://chercheurs.edf.com/logiciels/efficas}PRESENT_ABSENT uses Python identifier PRESENT_ABSENT
    __PRESENT_ABSENT = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'PRESENT_ABSENT'), 'PRESENT_ABSENT', '__httpchercheurs_edf_comlogicielsefficas_T_regles_httpchercheurs_edf_comlogicielsefficasPRESENT_ABSENT', True, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 269, 1), )

    
    PRESENT_ABSENT = property(__PRESENT_ABSENT.value, __PRESENT_ABSENT.set, None, None)

    
    # Element {http://chercheurs.edf.com/logiciels/efficas}PRESENT_PRESENT uses Python identifier PRESENT_PRESENT
    __PRESENT_PRESENT = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'PRESENT_PRESENT'), 'PRESENT_PRESENT', '__httpchercheurs_edf_comlogicielsefficas_T_regles_httpchercheurs_edf_comlogicielsefficasPRESENT_PRESENT', True, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 270, 1), )

    
    PRESENT_PRESENT = property(__PRESENT_PRESENT.value, __PRESENT_PRESENT.set, None, None)

    
    # Element {http://chercheurs.edf.com/logiciels/efficas}UN_PARMI uses Python identifier UN_PARMI
    __UN_PARMI = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'UN_PARMI'), 'UN_PARMI', '__httpchercheurs_edf_comlogicielsefficas_T_regles_httpchercheurs_edf_comlogicielsefficasUN_PARMI', True, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 271, 1), )

    
    UN_PARMI = property(__UN_PARMI.value, __UN_PARMI.set, None, None)

    _ElementMap.update({
        __A_CLASSER.name() : __A_CLASSER,
        __AU_MOINS_UN.name() : __AU_MOINS_UN,
        __AU_PLUS_UN.name() : __AU_PLUS_UN,
        __ENSEMBLE.name() : __ENSEMBLE,
        __EXCLUS.name() : __EXCLUS,
        __PRESENT_ABSENT.name() : __PRESENT_ABSENT,
        __PRESENT_PRESENT.name() : __PRESENT_PRESENT,
        __UN_PARMI.name() : __UN_PARMI
    })
    _AttributeMap.update({
        
    })
Namespace.addCategoryObject('typeBinding', u'T_regles', T_regles)


# Complex type {http://chercheurs.edf.com/logiciels/efficas}T_grma with content type EMPTY
class T_grma (pyxb.binding.basis.complexTypeDefinition):
    """Complex type {http://chercheurs.edf.com/logiciels/efficas}T_grma with content type EMPTY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_EMPTY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_grma')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 395, 1)
    _ElementMap = {}
    _AttributeMap = {}
    # Base type is pyxb.binding.datatypes.anyType
    _ElementMap.update({
        
    })
    _AttributeMap.update({
        
    })
Namespace.addCategoryObject('typeBinding', u'T_grma', T_grma)


# Complex type {http://chercheurs.edf.com/logiciels/efficas}T_grno with content type EMPTY
class T_grno (pyxb.binding.basis.complexTypeDefinition):
    """Complex type {http://chercheurs.edf.com/logiciels/efficas}T_grno with content type EMPTY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_EMPTY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_grno')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 396, 1)
    _ElementMap = {}
    _AttributeMap = {}
    # Base type is pyxb.binding.datatypes.anyType
    _ElementMap.update({
        
    })
    _AttributeMap.update({
        
    })
Namespace.addCategoryObject('typeBinding', u'T_grno', T_grno)


# Complex type {http://chercheurs.edf.com/logiciels/efficas}T_SalomeEntry with content type EMPTY
class T_SalomeEntry (pyxb.binding.basis.complexTypeDefinition):
    """Complex type {http://chercheurs.edf.com/logiciels/efficas}T_SalomeEntry with content type EMPTY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_EMPTY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_SalomeEntry')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 397, 1)
    _ElementMap = {}
    _AttributeMap = {}
    # Base type is pyxb.binding.datatypes.anyType
    _ElementMap.update({
        
    })
    _AttributeMap.update({
        
    })
Namespace.addCategoryObject('typeBinding', u'T_SalomeEntry', T_SalomeEntry)


# Complex type {http://chercheurs.edf.com/logiciels/efficas}T_Fichier with content type EMPTY
class T_Fichier (pyxb.binding.basis.complexTypeDefinition):
    """Complex type {http://chercheurs.edf.com/logiciels/efficas}T_Fichier with content type EMPTY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_EMPTY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_Fichier')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 398, 1)
    _ElementMap = {}
    _AttributeMap = {}
    # Base type is pyxb.binding.datatypes.anyType
    _ElementMap.update({
        
    })
    _AttributeMap.update({
        
    })
Namespace.addCategoryObject('typeBinding', u'T_Fichier', T_Fichier)


# Complex type {http://chercheurs.edf.com/logiciels/efficas}T_tuple with content type SIMPLE
class T_tuple (pyxb.binding.basis.complexTypeDefinition):
    """Complex type {http://chercheurs.edf.com/logiciels/efficas}T_tuple with content type SIMPLE"""
    _TypeDefinition = pyxb.binding.datatypes.anySimpleType
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_SIMPLE
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_tuple')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 454, 1)
    _ElementMap = {}
    _AttributeMap = {}
    # Base type is pyxb.binding.datatypes.anySimpleType
    
    # Attribute n uses Python identifier n
    __n = pyxb.binding.content.AttributeUse(pyxb.namespace.ExpandedName(None, u'n'), 'n', '__httpchercheurs_edf_comlogicielsefficas_T_tuple_n', pyxb.binding.datatypes.int, required=True)
    __n._DeclarationLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 457, 4)
    __n._UseLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 457, 4)
    
    n = property(__n.value, __n.set, None, None)

    _ElementMap.update({
        
    })
    _AttributeMap.update({
        __n.name() : __n
    })
Namespace.addCategoryObject('typeBinding', u'T_tuple', T_tuple)


# Complex type {http://chercheurs.edf.com/logiciels/efficas}T_into with content type ELEMENT_ONLY
class T_into (pyxb.binding.basis.complexTypeDefinition):
    """Complex type {http://chercheurs.edf.com/logiciels/efficas}T_into with content type ELEMENT_ONLY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_ELEMENT_ONLY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_into')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 501, 1)
    _ElementMap = {}
    _AttributeMap = {}
    # Base type is pyxb.binding.datatypes.anyType
    
    # Element {http://chercheurs.edf.com/logiciels/efficas}fonction_utilisateur uses Python identifier fonction_utilisateur
    __fonction_utilisateur = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'fonction_utilisateur'), 'fonction_utilisateur', '__httpchercheurs_edf_comlogicielsefficas_T_into_httpchercheurs_edf_comlogicielsefficasfonction_utilisateur', True, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 10, 1), )

    
    fonction_utilisateur = property(__fonction_utilisateur.value, __fonction_utilisateur.set, None, None)

    
    # Element {http://chercheurs.edf.com/logiciels/efficas}typesimple uses Python identifier typesimple
    __typesimple = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'typesimple'), 'typesimple', '__httpchercheurs_edf_comlogicielsefficas_T_into_httpchercheurs_edf_comlogicielsefficastypesimple', True, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 464, 1), )

    
    typesimple = property(__typesimple.value, __typesimple.set, None, None)

    
    # Element {http://chercheurs.edf.com/logiciels/efficas}matrice_double uses Python identifier matrice_double
    __matrice_double = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'matrice_double'), 'matrice_double', '__httpchercheurs_edf_comlogicielsefficas_T_into_httpchercheurs_edf_comlogicielsefficasmatrice_double', True, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 465, 1), )

    
    matrice_double = property(__matrice_double.value, __matrice_double.set, None, None)

    
    # Element {http://chercheurs.edf.com/logiciels/efficas}matrice_symetrique_double uses Python identifier matrice_symetrique_double
    __matrice_symetrique_double = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'matrice_symetrique_double'), 'matrice_symetrique_double', '__httpchercheurs_edf_comlogicielsefficas_T_into_httpchercheurs_edf_comlogicielsefficasmatrice_symetrique_double', True, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 466, 1), )

    
    matrice_symetrique_double = property(__matrice_symetrique_double.value, __matrice_symetrique_double.set, None, None)

    
    # Element {http://chercheurs.edf.com/logiciels/efficas}tuple uses Python identifier tuple
    __tuple = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'tuple'), 'tuple', '__httpchercheurs_edf_comlogicielsefficas_T_into_httpchercheurs_edf_comlogicielsefficastuple', True, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 467, 1), )

    
    tuple = property(__tuple.value, __tuple.set, None, None)

    
    # Element {http://chercheurs.edf.com/logiciels/efficas}classe_utilisateur uses Python identifier classe_utilisateur
    __classe_utilisateur = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'classe_utilisateur'), 'classe_utilisateur', '__httpchercheurs_edf_comlogicielsefficas_T_into_httpchercheurs_edf_comlogicielsefficasclasse_utilisateur', True, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 468, 1), )

    
    classe_utilisateur = property(__classe_utilisateur.value, __classe_utilisateur.set, None, None)

    _ElementMap.update({
        __fonction_utilisateur.name() : __fonction_utilisateur,
        __typesimple.name() : __typesimple,
        __matrice_double.name() : __matrice_double,
        __matrice_symetrique_double.name() : __matrice_symetrique_double,
        __tuple.name() : __tuple,
        __classe_utilisateur.name() : __classe_utilisateur
    })
    _AttributeMap.update({
        
    })
Namespace.addCategoryObject('typeBinding', u'T_into', T_into)


# Complex type {http://chercheurs.edf.com/logiciels/efficas}T_doc with content type EMPTY
class T_doc (pyxb.binding.basis.complexTypeDefinition):
    """Complex type {http://chercheurs.edf.com/logiciels/efficas}T_doc with content type EMPTY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_EMPTY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_doc')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 61, 1)
    _ElementMap = {}
    _AttributeMap = {}
    # Base type is pyxb.binding.datatypes.anyType
    
    # Attribute {http://chercheurs.edf.com/logiciels/efficas}fr uses Python identifier fr
    __fr = pyxb.binding.content.AttributeUse(pyxb.namespace.ExpandedName(Namespace, u'fr'), 'fr', '__httpchercheurs_edf_comlogicielsefficas_T_doc_httpchercheurs_edf_comlogicielsefficasfr', pyxb.binding.datatypes.string)
    __fr._DeclarationLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 53, 1)
    __fr._UseLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 62, 2)
    
    fr = property(__fr.value, __fr.set, None, None)

    
    # Attribute {http://chercheurs.edf.com/logiciels/efficas}ang uses Python identifier ang
    __ang = pyxb.binding.content.AttributeUse(pyxb.namespace.ExpandedName(Namespace, u'ang'), 'ang', '__httpchercheurs_edf_comlogicielsefficas_T_doc_httpchercheurs_edf_comlogicielsefficasang', pyxb.binding.datatypes.string)
    __ang._DeclarationLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 54, 1)
    __ang._UseLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 63, 2)
    
    ang = property(__ang.value, __ang.set, None, None)

    
    # Attribute {http://chercheurs.edf.com/logiciels/efficas}docu uses Python identifier docu
    __docu = pyxb.binding.content.AttributeUse(pyxb.namespace.ExpandedName(Namespace, u'docu'), 'docu', '__httpchercheurs_edf_comlogicielsefficas_T_doc_httpchercheurs_edf_comlogicielsefficasdocu', AT_docu)
    __docu._DeclarationLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 55, 1)
    __docu._UseLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 64, 2)
    
    docu = property(__docu.value, __docu.set, None, None)

    _ElementMap.update({
        
    })
    _AttributeMap.update({
        __fr.name() : __fr,
        __ang.name() : __ang,
        __docu.name() : __docu
    })
Namespace.addCategoryObject('typeBinding', u'T_doc', T_doc)


# Complex type {http://chercheurs.edf.com/logiciels/efficas}T_Accas.Common with content type ELEMENT_ONLY
class T_Accas_Common (pyxb.binding.basis.complexTypeDefinition):
    """Complex type {http://chercheurs.edf.com/logiciels/efficas}T_Accas.Common with content type ELEMENT_ONLY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_ELEMENT_ONLY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_Accas.Common')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 87, 1)
    _ElementMap = {}
    _AttributeMap = {}
    # Base type is pyxb.binding.datatypes.anyType
    
    # Element {http://chercheurs.edf.com/logiciels/efficas}doc uses Python identifier doc
    __doc = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'doc'), 'doc', '__httpchercheurs_edf_comlogicielsefficas_T_Accas_Common_httpchercheurs_edf_comlogicielsefficasdoc', False, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 4, 1), )

    
    doc = property(__doc.value, __doc.set, None, None)

    
    # Element {http://chercheurs.edf.com/logiciels/efficas}regles uses Python identifier regles
    __regles = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'regles'), 'regles', '__httpchercheurs_edf_comlogicielsefficas_T_Accas_Common_httpchercheurs_edf_comlogicielsefficasregles', False, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 6, 1), )

    
    regles = property(__regles.value, __regles.set, None, None)

    
    # Element {http://chercheurs.edf.com/logiciels/efficas}SIMP uses Python identifier SIMP
    __SIMP = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'SIMP'), 'SIMP', '__httpchercheurs_edf_comlogicielsefficas_T_Accas_Common_httpchercheurs_edf_comlogicielsefficasSIMP', True, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 43, 1), )

    
    SIMP = property(__SIMP.value, __SIMP.set, None, None)

    
    # Element {http://chercheurs.edf.com/logiciels/efficas}FACT uses Python identifier FACT
    __FACT = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'FACT'), 'FACT', '__httpchercheurs_edf_comlogicielsefficas_T_Accas_Common_httpchercheurs_edf_comlogicielsefficasFACT', True, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 123, 1), )

    
    FACT = property(__FACT.value, __FACT.set, None, None)

    
    # Element {http://chercheurs.edf.com/logiciels/efficas}BLOC uses Python identifier BLOC
    __BLOC = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'BLOC'), 'BLOC', '__httpchercheurs_edf_comlogicielsefficas_T_Accas_Common_httpchercheurs_edf_comlogicielsefficasBLOC', True, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 157, 1), )

    
    BLOC = property(__BLOC.value, __BLOC.set, None, None)

    
    # Attribute {http://chercheurs.edf.com/logiciels/efficas}nom uses Python identifier nom
    __nom = pyxb.binding.content.AttributeUse(pyxb.namespace.ExpandedName(Namespace, u'nom'), 'nom', '__httpchercheurs_edf_comlogicielsefficas_T_Accas_Common_httpchercheurs_edf_comlogicielsefficasnom', AT_nom, required=True)
    __nom._DeclarationLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 51, 1)
    __nom._UseLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 97, 2)
    
    nom = property(__nom.value, __nom.set, None, None)

    _ElementMap.update({
        __doc.name() : __doc,
        __regles.name() : __regles,
        __SIMP.name() : __SIMP,
        __FACT.name() : __FACT,
        __BLOC.name() : __BLOC
    })
    _AttributeMap.update({
        __nom.name() : __nom
    })
Namespace.addCategoryObject('typeBinding', u'T_Accas.Common', T_Accas_Common)


# Complex type {http://chercheurs.edf.com/logiciels/efficas}T_SIMP with content type ELEMENT_ONLY
class T_SIMP (pyxb.binding.basis.complexTypeDefinition):
    """Complex type {http://chercheurs.edf.com/logiciels/efficas}T_SIMP with content type ELEMENT_ONLY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_ELEMENT_ONLY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_SIMP')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 167, 1)
    _ElementMap = {}
    _AttributeMap = {}
    # Base type is pyxb.binding.datatypes.anyType
    
    # Element {http://chercheurs.edf.com/logiciels/efficas}doc uses Python identifier doc
    __doc = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'doc'), 'doc', '__httpchercheurs_edf_comlogicielsefficas_T_SIMP_httpchercheurs_edf_comlogicielsefficasdoc', False, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 4, 1), )

    
    doc = property(__doc.value, __doc.set, None, None)

    
    # Element {http://chercheurs.edf.com/logiciels/efficas}ValeurDef uses Python identifier ValeurDef
    __ValeurDef = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'ValeurDef'), 'ValeurDef', '__httpchercheurs_edf_comlogicielsefficas_T_SIMP_httpchercheurs_edf_comlogicielsefficasValeurDef', False, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 8, 1), )

    
    ValeurDef = property(__ValeurDef.value, __ValeurDef.set, None, None)

    
    # Element {http://chercheurs.edf.com/logiciels/efficas}ValeurSugg uses Python identifier ValeurSugg
    __ValeurSugg = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'ValeurSugg'), 'ValeurSugg', '__httpchercheurs_edf_comlogicielsefficas_T_SIMP_httpchercheurs_edf_comlogicielsefficasValeurSugg', False, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 9, 1), )

    
    ValeurSugg = property(__ValeurSugg.value, __ValeurSugg.set, None, None)

    
    # Element {http://chercheurs.edf.com/logiciels/efficas}validators uses Python identifier validators
    __validators = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'validators'), 'validators', '__httpchercheurs_edf_comlogicielsefficas_T_SIMP_httpchercheurs_edf_comlogicielsefficasvalidators', False, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 39, 1), )

    
    validators = property(__validators.value, __validators.set, None, None)

    
    # Element {http://chercheurs.edf.com/logiciels/efficas}PlageValeur uses Python identifier PlageValeur
    __PlageValeur = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'PlageValeur'), 'PlageValeur', '__httpchercheurs_edf_comlogicielsefficas_T_SIMP_httpchercheurs_edf_comlogicielsefficasPlageValeur', False, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 40, 1), )

    
    PlageValeur = property(__PlageValeur.value, __PlageValeur.set, None, None)

    
    # Element {http://chercheurs.edf.com/logiciels/efficas}typeAttendu uses Python identifier typeAttendu
    __typeAttendu = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'typeAttendu'), 'typeAttendu', '__httpchercheurs_edf_comlogicielsefficas_T_SIMP_httpchercheurs_edf_comlogicielsefficastypeAttendu', False, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 41, 1), )

    
    typeAttendu = property(__typeAttendu.value, __typeAttendu.set, None, None)

    
    # Element {http://chercheurs.edf.com/logiciels/efficas}portee uses Python identifier portee
    __portee = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'portee'), 'portee', '__httpchercheurs_edf_comlogicielsefficas_T_SIMP_httpchercheurs_edf_comlogicielsefficasportee', False, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 44, 1), )

    
    portee = property(__portee.value, __portee.set, None, None)

    
    # Attribute {http://chercheurs.edf.com/logiciels/efficas}nom uses Python identifier nom
    __nom = pyxb.binding.content.AttributeUse(pyxb.namespace.ExpandedName(Namespace, u'nom'), 'nom', '__httpchercheurs_edf_comlogicielsefficas_T_SIMP_httpchercheurs_edf_comlogicielsefficasnom', AT_nom, required=True)
    __nom._DeclarationLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 51, 1)
    __nom._UseLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 181, 2)
    
    nom = property(__nom.value, __nom.set, None, None)

    
    # Attribute {http://chercheurs.edf.com/logiciels/efficas}statut uses Python identifier statut
    __statut = pyxb.binding.content.AttributeUse(pyxb.namespace.ExpandedName(Namespace, u'statut'), 'statut', '__httpchercheurs_edf_comlogicielsefficas_T_SIMP_httpchercheurs_edf_comlogicielsefficasstatut', AT_statut, unicode_default=u'o')
    __statut._DeclarationLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 57, 1)
    __statut._UseLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 182, 2)
    
    statut = property(__statut.value, __statut.set, None, None)

    
    # Attribute {http://chercheurs.edf.com/logiciels/efficas}max_occurs uses Python identifier max_occurs
    __max_occurs = pyxb.binding.content.AttributeUse(pyxb.namespace.ExpandedName(Namespace, u'max_occurs'), 'max_occurs', '__httpchercheurs_edf_comlogicielsefficas_T_SIMP_httpchercheurs_edf_comlogicielsefficasmax_occurs', AT_max_occurs, unicode_default=u'1')
    __max_occurs._DeclarationLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 58, 1)
    __max_occurs._UseLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 184, 2)
    
    max_occurs = property(__max_occurs.value, __max_occurs.set, None, None)

    
    # Attribute {http://chercheurs.edf.com/logiciels/efficas}min_occurs uses Python identifier min_occurs
    __min_occurs = pyxb.binding.content.AttributeUse(pyxb.namespace.ExpandedName(Namespace, u'min_occurs'), 'min_occurs', '__httpchercheurs_edf_comlogicielsefficas_T_SIMP_httpchercheurs_edf_comlogicielsefficasmin_occurs', AT_min_occurs, unicode_default=u'1')
    __min_occurs._DeclarationLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 59, 1)
    __min_occurs._UseLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 183, 2)
    
    min_occurs = property(__min_occurs.value, __min_occurs.set, None, None)

    _ElementMap.update({
        __doc.name() : __doc,
        __ValeurDef.name() : __ValeurDef,
        __ValeurSugg.name() : __ValeurSugg,
        __validators.name() : __validators,
        __PlageValeur.name() : __PlageValeur,
        __typeAttendu.name() : __typeAttendu,
        __portee.name() : __portee
    })
    _AttributeMap.update({
        __nom.name() : __nom,
        __statut.name() : __statut,
        __max_occurs.name() : __max_occurs,
        __min_occurs.name() : __min_occurs
    })
Namespace.addCategoryObject('typeBinding', u'T_SIMP', T_SIMP)


# Complex type {http://chercheurs.edf.com/logiciels/efficas}T_Matrice_double with content type SIMPLE
class T_Matrice_double (pyxb.binding.basis.complexTypeDefinition):
    """Complex type {http://chercheurs.edf.com/logiciels/efficas}T_Matrice_double with content type SIMPLE"""
    _TypeDefinition = T_list_double
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_SIMPLE
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_Matrice_double')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 432, 1)
    _ElementMap = {}
    _AttributeMap = {}
    # Base type is T_list_double
    
    # Attribute n uses Python identifier n
    __n = pyxb.binding.content.AttributeUse(pyxb.namespace.ExpandedName(None, u'n'), 'n', '__httpchercheurs_edf_comlogicielsefficas_T_Matrice_double_n', pyxb.binding.datatypes.integer, required=True)
    __n._DeclarationLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 435, 4)
    __n._UseLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 435, 4)
    
    n = property(__n.value, __n.set, None, None)

    
    # Attribute m uses Python identifier m
    __m = pyxb.binding.content.AttributeUse(pyxb.namespace.ExpandedName(None, u'm'), 'm', '__httpchercheurs_edf_comlogicielsefficas_T_Matrice_double_m', pyxb.binding.datatypes.integer, required=True)
    __m._DeclarationLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 436, 4)
    __m._UseLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 436, 4)
    
    m = property(__m.value, __m.set, None, None)

    _ElementMap.update({
        
    })
    _AttributeMap.update({
        __n.name() : __n,
        __m.name() : __m
    })
Namespace.addCategoryObject('typeBinding', u'T_Matrice_double', T_Matrice_double)


# Complex type {http://chercheurs.edf.com/logiciels/efficas}T_Matrice_Symetrique_double with content type SIMPLE
class T_Matrice_Symetrique_double (pyxb.binding.basis.complexTypeDefinition):
    """Complex type {http://chercheurs.edf.com/logiciels/efficas}T_Matrice_Symetrique_double with content type SIMPLE"""
    _TypeDefinition = T_list_double
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_SIMPLE
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_Matrice_Symetrique_double')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 441, 1)
    _ElementMap = {}
    _AttributeMap = {}
    # Base type is T_list_double
    
    # Attribute n uses Python identifier n
    __n = pyxb.binding.content.AttributeUse(pyxb.namespace.ExpandedName(None, u'n'), 'n', '__httpchercheurs_edf_comlogicielsefficas_T_Matrice_Symetrique_double_n', pyxb.binding.datatypes.int, required=True)
    __n._DeclarationLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 444, 4)
    __n._UseLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 444, 4)
    
    n = property(__n.value, __n.set, None, None)

    _ElementMap.update({
        
    })
    _AttributeMap.update({
        __n.name() : __n
    })
Namespace.addCategoryObject('typeBinding', u'T_Matrice_Symetrique_double', T_Matrice_Symetrique_double)


# Complex type {http://chercheurs.edf.com/logiciels/efficas}T_typeAttendu with content type ELEMENT_ONLY
class T_typeAttendu (T_into):
    """Complex type {http://chercheurs.edf.com/logiciels/efficas}T_typeAttendu with content type ELEMENT_ONLY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_ELEMENT_ONLY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_typeAttendu')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 512, 1)
    _ElementMap = T_into._ElementMap.copy()
    _AttributeMap = T_into._AttributeMap.copy()
    # Base type is T_into
    
    # Element typesimple ({http://chercheurs.edf.com/logiciels/efficas}typesimple) inherited from {http://chercheurs.edf.com/logiciels/efficas}T_into
    
    # Element matrice_double ({http://chercheurs.edf.com/logiciels/efficas}matrice_double) inherited from {http://chercheurs.edf.com/logiciels/efficas}T_into
    
    # Element matrice_symetrique_double ({http://chercheurs.edf.com/logiciels/efficas}matrice_symetrique_double) inherited from {http://chercheurs.edf.com/logiciels/efficas}T_into
    
    # Element tuple ({http://chercheurs.edf.com/logiciels/efficas}tuple) inherited from {http://chercheurs.edf.com/logiciels/efficas}T_into
    
    # Element classe_utilisateur ({http://chercheurs.edf.com/logiciels/efficas}classe_utilisateur) inherited from {http://chercheurs.edf.com/logiciels/efficas}T_into
    _ElementMap.update({
        
    })
    _AttributeMap.update({
        
    })
Namespace.addCategoryObject('typeBinding', u'T_typeAttendu', T_typeAttendu)


# Complex type {http://chercheurs.edf.com/logiciels/efficas}T_OPER with content type ELEMENT_ONLY
class T_OPER (T_Accas_Common):
    """Complex type {http://chercheurs.edf.com/logiciels/efficas}T_OPER with content type ELEMENT_ONLY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_ELEMENT_ONLY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_OPER')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 100, 1)
    _ElementMap = T_Accas_Common._ElementMap.copy()
    _AttributeMap = T_Accas_Common._AttributeMap.copy()
    # Base type is T_Accas_Common
    
    # Element doc ({http://chercheurs.edf.com/logiciels/efficas}doc) inherited from {http://chercheurs.edf.com/logiciels/efficas}T_Accas.Common
    
    # Element regles ({http://chercheurs.edf.com/logiciels/efficas}regles) inherited from {http://chercheurs.edf.com/logiciels/efficas}T_Accas.Common
    
    # Element {http://chercheurs.edf.com/logiciels/efficas}typeCree uses Python identifier typeCree
    __typeCree = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'typeCree'), 'typeCree', '__httpchercheurs_edf_comlogicielsefficas_T_OPER_httpchercheurs_edf_comlogicielsefficastypeCree', False, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 7, 1), )

    
    typeCree = property(__typeCree.value, __typeCree.set, None, None)

    
    # Element SIMP ({http://chercheurs.edf.com/logiciels/efficas}SIMP) inherited from {http://chercheurs.edf.com/logiciels/efficas}T_Accas.Common
    
    # Element FACT ({http://chercheurs.edf.com/logiciels/efficas}FACT) inherited from {http://chercheurs.edf.com/logiciels/efficas}T_Accas.Common
    
    # Element BLOC ({http://chercheurs.edf.com/logiciels/efficas}BLOC) inherited from {http://chercheurs.edf.com/logiciels/efficas}T_Accas.Common
    
    # Attribute nom inherited from {http://chercheurs.edf.com/logiciels/efficas}T_Accas.Common
    
    # Attribute {http://chercheurs.edf.com/logiciels/efficas}subroutine uses Python identifier subroutine
    __subroutine = pyxb.binding.content.AttributeUse(pyxb.namespace.ExpandedName(Namespace, u'subroutine'), 'subroutine', '__httpchercheurs_edf_comlogicielsefficas_T_OPER_httpchercheurs_edf_comlogicielsefficassubroutine', AT_subroutine, unicode_default=u'None')
    __subroutine._DeclarationLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 60, 1)
    __subroutine._UseLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 106, 4)
    
    subroutine = property(__subroutine.value, __subroutine.set, None, None)

    _ElementMap.update({
        __typeCree.name() : __typeCree
    })
    _AttributeMap.update({
        __subroutine.name() : __subroutine
    })
Namespace.addCategoryObject('typeBinding', u'T_OPER', T_OPER)


# Complex type {http://chercheurs.edf.com/logiciels/efficas}T_PROC with content type ELEMENT_ONLY
class T_PROC (T_Accas_Common):
    """Complex type {http://chercheurs.edf.com/logiciels/efficas}T_PROC with content type ELEMENT_ONLY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_ELEMENT_ONLY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_PROC')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 116, 1)
    _ElementMap = T_Accas_Common._ElementMap.copy()
    _AttributeMap = T_Accas_Common._AttributeMap.copy()
    # Base type is T_Accas_Common
    
    # Element doc ({http://chercheurs.edf.com/logiciels/efficas}doc) inherited from {http://chercheurs.edf.com/logiciels/efficas}T_Accas.Common
    
    # Element regles ({http://chercheurs.edf.com/logiciels/efficas}regles) inherited from {http://chercheurs.edf.com/logiciels/efficas}T_Accas.Common
    
    # Element SIMP ({http://chercheurs.edf.com/logiciels/efficas}SIMP) inherited from {http://chercheurs.edf.com/logiciels/efficas}T_Accas.Common
    
    # Element FACT ({http://chercheurs.edf.com/logiciels/efficas}FACT) inherited from {http://chercheurs.edf.com/logiciels/efficas}T_Accas.Common
    
    # Element BLOC ({http://chercheurs.edf.com/logiciels/efficas}BLOC) inherited from {http://chercheurs.edf.com/logiciels/efficas}T_Accas.Common
    
    # Attribute nom inherited from {http://chercheurs.edf.com/logiciels/efficas}T_Accas.Common
    
    # Attribute {http://chercheurs.edf.com/logiciels/efficas}subroutine uses Python identifier subroutine
    __subroutine = pyxb.binding.content.AttributeUse(pyxb.namespace.ExpandedName(Namespace, u'subroutine'), 'subroutine', '__httpchercheurs_edf_comlogicielsefficas_T_PROC_httpchercheurs_edf_comlogicielsefficassubroutine', AT_subroutine, unicode_default=u'None')
    __subroutine._DeclarationLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 60, 1)
    __subroutine._UseLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 119, 4)
    
    subroutine = property(__subroutine.value, __subroutine.set, None, None)

    _ElementMap.update({
        
    })
    _AttributeMap.update({
        __subroutine.name() : __subroutine
    })
Namespace.addCategoryObject('typeBinding', u'T_PROC', T_PROC)


# Complex type {http://chercheurs.edf.com/logiciels/efficas}T_FACT with content type ELEMENT_ONLY
class T_FACT (T_Accas_Common):
    """Complex type {http://chercheurs.edf.com/logiciels/efficas}T_FACT with content type ELEMENT_ONLY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_ELEMENT_ONLY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_FACT')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 139, 1)
    _ElementMap = T_Accas_Common._ElementMap.copy()
    _AttributeMap = T_Accas_Common._AttributeMap.copy()
    # Base type is T_Accas_Common
    
    # Element doc ({http://chercheurs.edf.com/logiciels/efficas}doc) inherited from {http://chercheurs.edf.com/logiciels/efficas}T_Accas.Common
    
    # Element regles ({http://chercheurs.edf.com/logiciels/efficas}regles) inherited from {http://chercheurs.edf.com/logiciels/efficas}T_Accas.Common
    
    # Element SIMP ({http://chercheurs.edf.com/logiciels/efficas}SIMP) inherited from {http://chercheurs.edf.com/logiciels/efficas}T_Accas.Common
    
    # Element FACT ({http://chercheurs.edf.com/logiciels/efficas}FACT) inherited from {http://chercheurs.edf.com/logiciels/efficas}T_Accas.Common
    
    # Element BLOC ({http://chercheurs.edf.com/logiciels/efficas}BLOC) inherited from {http://chercheurs.edf.com/logiciels/efficas}T_Accas.Common
    
    # Attribute nom inherited from {http://chercheurs.edf.com/logiciels/efficas}T_Accas.Common
    
    # Attribute {http://chercheurs.edf.com/logiciels/efficas}statut uses Python identifier statut
    __statut = pyxb.binding.content.AttributeUse(pyxb.namespace.ExpandedName(Namespace, u'statut'), 'statut', '__httpchercheurs_edf_comlogicielsefficas_T_FACT_httpchercheurs_edf_comlogicielsefficasstatut', AT_statut, unicode_default=u'o')
    __statut._DeclarationLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 57, 1)
    __statut._UseLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 142, 4)
    
    statut = property(__statut.value, __statut.set, None, None)

    
    # Attribute {http://chercheurs.edf.com/logiciels/efficas}max_occurs uses Python identifier max_occurs
    __max_occurs = pyxb.binding.content.AttributeUse(pyxb.namespace.ExpandedName(Namespace, u'max_occurs'), 'max_occurs', '__httpchercheurs_edf_comlogicielsefficas_T_FACT_httpchercheurs_edf_comlogicielsefficasmax_occurs', AT_max_occurs, unicode_default=u'1')
    __max_occurs._DeclarationLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 58, 1)
    __max_occurs._UseLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 144, 4)
    
    max_occurs = property(__max_occurs.value, __max_occurs.set, None, None)

    
    # Attribute {http://chercheurs.edf.com/logiciels/efficas}min_occurs uses Python identifier min_occurs
    __min_occurs = pyxb.binding.content.AttributeUse(pyxb.namespace.ExpandedName(Namespace, u'min_occurs'), 'min_occurs', '__httpchercheurs_edf_comlogicielsefficas_T_FACT_httpchercheurs_edf_comlogicielsefficasmin_occurs', AT_min_occurs, unicode_default=u'1')
    __min_occurs._DeclarationLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 59, 1)
    __min_occurs._UseLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 143, 4)
    
    min_occurs = property(__min_occurs.value, __min_occurs.set, None, None)

    _ElementMap.update({
        
    })
    _AttributeMap.update({
        __statut.name() : __statut,
        __max_occurs.name() : __max_occurs,
        __min_occurs.name() : __min_occurs
    })
Namespace.addCategoryObject('typeBinding', u'T_FACT', T_FACT)


# Complex type {http://chercheurs.edf.com/logiciels/efficas}T_BLOC with content type ELEMENT_ONLY
class T_BLOC (T_Accas_Common):
    """Complex type {http://chercheurs.edf.com/logiciels/efficas}T_BLOC with content type ELEMENT_ONLY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_ELEMENT_ONLY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_BLOC')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 158, 1)
    _ElementMap = T_Accas_Common._ElementMap.copy()
    _AttributeMap = T_Accas_Common._AttributeMap.copy()
    # Base type is T_Accas_Common
    
    # Element doc ({http://chercheurs.edf.com/logiciels/efficas}doc) inherited from {http://chercheurs.edf.com/logiciels/efficas}T_Accas.Common
    
    # Element regles ({http://chercheurs.edf.com/logiciels/efficas}regles) inherited from {http://chercheurs.edf.com/logiciels/efficas}T_Accas.Common
    
    # Element SIMP ({http://chercheurs.edf.com/logiciels/efficas}SIMP) inherited from {http://chercheurs.edf.com/logiciels/efficas}T_Accas.Common
    
    # Element {http://chercheurs.edf.com/logiciels/efficas}condition uses Python identifier condition
    __condition = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, u'condition'), 'condition', '__httpchercheurs_edf_comlogicielsefficas_T_BLOC_httpchercheurs_edf_comlogicielsefficascondition', False, pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 45, 1), )

    
    condition = property(__condition.value, __condition.set, None, None)

    
    # Element FACT ({http://chercheurs.edf.com/logiciels/efficas}FACT) inherited from {http://chercheurs.edf.com/logiciels/efficas}T_Accas.Common
    
    # Element BLOC ({http://chercheurs.edf.com/logiciels/efficas}BLOC) inherited from {http://chercheurs.edf.com/logiciels/efficas}T_Accas.Common
    
    # Attribute nom inherited from {http://chercheurs.edf.com/logiciels/efficas}T_Accas.Common
    _ElementMap.update({
        __condition.name() : __condition
    })
    _AttributeMap.update({
        
    })
Namespace.addCategoryObject('typeBinding', u'T_BLOC', T_BLOC)


# Complex type {http://chercheurs.edf.com/logiciels/efficas}T_classe_utilisateur_username with content type SIMPLE
class T_classe_utilisateur_username (pyxb.binding.basis.complexTypeDefinition):
    """Complex type {http://chercheurs.edf.com/logiciels/efficas}T_classe_utilisateur_username with content type SIMPLE"""
    _TypeDefinition = T_classe_utilisateur_name
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_SIMPLE
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, u'T_classe_utilisateur_username')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 376, 1)
    _ElementMap = {}
    _AttributeMap = {}
    # Base type is T_classe_utilisateur_name
    
    # Attribute {http://chercheurs.edf.com/logiciels/efficas}nom uses Python identifier nom
    __nom = pyxb.binding.content.AttributeUse(pyxb.namespace.ExpandedName(Namespace, u'nom'), 'nom', '__httpchercheurs_edf_comlogicielsefficas_T_classe_utilisateur_username_httpchercheurs_edf_comlogicielsefficasnom', AT_nom, required=True)
    __nom._DeclarationLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 51, 1)
    __nom._UseLocation = pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 379, 4)
    
    nom = property(__nom.value, __nom.set, None, None)

    _ElementMap.update({
        
    })
    _AttributeMap.update({
        __nom.name() : __nom
    })
Namespace.addCategoryObject('typeBinding', u'T_classe_utilisateur_username', T_classe_utilisateur_username)


cata = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'cata'), T_cata, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 5, 1))
Namespace.addCategoryObject('elementBinding', cata.name().localName(), cata)

regles = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'regles'), T_regles, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 6, 1))
Namespace.addCategoryObject('elementBinding', regles.name().localName(), regles)

fonction_utilisateur = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'fonction_utilisateur'), T_fonction_python, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 10, 1))
Namespace.addCategoryObject('elementBinding', fonction_utilisateur.name().localName(), fonction_utilisateur)

commandes = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'commandes'), T_commandes, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 11, 1))
Namespace.addCategoryObject('elementBinding', commandes.name().localName(), commandes)

validators = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'validators'), T_validators, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 39, 1))
Namespace.addCategoryObject('elementBinding', validators.name().localName(), validators)

PlageValeur = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'PlageValeur'), T_PlageValeur, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 40, 1))
Namespace.addCategoryObject('elementBinding', PlageValeur.name().localName(), PlageValeur)

portee = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'portee'), T_portee, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 44, 1), unicode_default=u'None')
Namespace.addCategoryObject('elementBinding', portee.name().localName(), portee)

condition = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'condition'), T_fonction_python, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 45, 1))
Namespace.addCategoryObject('elementBinding', condition.name().localName(), condition)

into = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'into'), T_into, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 49, 1))
Namespace.addCategoryObject('elementBinding', into.name().localName(), into)

A_CLASSER = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'A_CLASSER'), T_predicat2, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 257, 1))
Namespace.addCategoryObject('elementBinding', A_CLASSER.name().localName(), A_CLASSER)

tuple = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'tuple'), T_tuple, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 467, 1))
Namespace.addCategoryObject('elementBinding', tuple.name().localName(), tuple)

doc = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'doc'), T_doc, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 4, 1))
Namespace.addCategoryObject('elementBinding', doc.name().localName(), doc)

typeCree = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'typeCree'), T_classe_utilisateur, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 7, 1))
Namespace.addCategoryObject('elementBinding', typeCree.name().localName(), typeCree)

ValeurDef = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'ValeurDef'), T_typeAttendu, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 8, 1))
Namespace.addCategoryObject('elementBinding', ValeurDef.name().localName(), ValeurDef)

ValeurSugg = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'ValeurSugg'), T_typeAttendu, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 9, 1))
Namespace.addCategoryObject('elementBinding', ValeurSugg.name().localName(), ValeurSugg)

SIMP = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'SIMP'), T_SIMP, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 43, 1))
Namespace.addCategoryObject('elementBinding', SIMP.name().localName(), SIMP)

borne_sup = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'borne_sup'), T_typeAttendu, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 46, 1))
Namespace.addCategoryObject('elementBinding', borne_sup.name().localName(), borne_sup)

borne_inf = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'borne_inf'), T_typeAttendu, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 47, 1))
Namespace.addCategoryObject('elementBinding', borne_inf.name().localName(), borne_inf)

AU_MOINS_UN = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'AU_MOINS_UN'), T_predicat1, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 258, 1))
Namespace.addCategoryObject('elementBinding', AU_MOINS_UN.name().localName(), AU_MOINS_UN)

AU_PLUS_UN = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'AU_PLUS_UN'), T_predicat1, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 259, 1))
Namespace.addCategoryObject('elementBinding', AU_PLUS_UN.name().localName(), AU_PLUS_UN)

ENSEMBLE = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'ENSEMBLE'), T_predicat1, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 260, 1))
Namespace.addCategoryObject('elementBinding', ENSEMBLE.name().localName(), ENSEMBLE)

EXCLUS = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'EXCLUS'), T_predicat1, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 261, 1))
Namespace.addCategoryObject('elementBinding', EXCLUS.name().localName(), EXCLUS)

PRESENT_ABSENT = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'PRESENT_ABSENT'), T_predicat1, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 269, 1))
Namespace.addCategoryObject('elementBinding', PRESENT_ABSENT.name().localName(), PRESENT_ABSENT)

PRESENT_PRESENT = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'PRESENT_PRESENT'), T_predicat1, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 270, 1))
Namespace.addCategoryObject('elementBinding', PRESENT_PRESENT.name().localName(), PRESENT_PRESENT)

UN_PARMI = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'UN_PARMI'), T_predicat1, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 271, 1))
Namespace.addCategoryObject('elementBinding', UN_PARMI.name().localName(), UN_PARMI)

matrice_double = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'matrice_double'), T_Matrice_double, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 465, 1))
Namespace.addCategoryObject('elementBinding', matrice_double.name().localName(), matrice_double)

matrice_symetrique_double = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'matrice_symetrique_double'), T_Matrice_Symetrique_double, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 466, 1))
Namespace.addCategoryObject('elementBinding', matrice_symetrique_double.name().localName(), matrice_symetrique_double)

classe_utilisateur = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'classe_utilisateur'), T_classe_utilisateur, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 468, 1))
Namespace.addCategoryObject('elementBinding', classe_utilisateur.name().localName(), classe_utilisateur)

OPER = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'OPER'), T_OPER, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 99, 1))
Namespace.addCategoryObject('elementBinding', OPER.name().localName(), OPER)

PROC = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'PROC'), T_PROC, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 110, 1))
Namespace.addCategoryObject('elementBinding', PROC.name().localName(), PROC)

FACT = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'FACT'), T_FACT, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 123, 1))
Namespace.addCategoryObject('elementBinding', FACT.name().localName(), FACT)

BLOC = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'BLOC'), T_BLOC, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 157, 1))
Namespace.addCategoryObject('elementBinding', BLOC.name().localName(), BLOC)

typeAttendu = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'typeAttendu'), T_name, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 41, 1))
Namespace.addCategoryObject('elementBinding', typeAttendu.name().localName(), typeAttendu)

typesimple = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'typesimple'), T_simple, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 464, 1))
Namespace.addCategoryObject('elementBinding', typesimple.name().localName(), typesimple)

classeUtilisateurName = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'classeUtilisateurName'), T_classe_utilisateur_username, abstract=pyxb.binding.datatypes.boolean(1), location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 42, 1))
Namespace.addCategoryObject('elementBinding', classeUtilisateurName.name().localName(), classeUtilisateurName)



T_cata._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'commandes'), T_commandes, scope=T_cata, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 11, 1)))

def _BuildAutomaton ():
    # Remove this helper function from the namespace after it is invoked
    global _BuildAutomaton
    del _BuildAutomaton
    import pyxb.utils.fac as fac

    counters = set()
    cc_0 = fac.CounterCondition(min=0L, max=None, metadata=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 68, 3))
    counters.add(cc_0)
    states = []
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_0, False))
    symbol = pyxb.binding.content.ElementUse(T_cata._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'commandes')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 68, 3))
    st_0 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_0)
    transitions = []
    transitions.append(fac.Transition(st_0, [
        fac.UpdateInstruction(cc_0, True) ]))
    st_0._set_transitionSet(transitions)
    return fac.Automaton(states, counters, True, containing_state=None)
T_cata._Automaton = _BuildAutomaton()




T_commandes._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'OPER'), T_OPER, scope=T_commandes, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 99, 1)))

T_commandes._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'PROC'), T_PROC, scope=T_commandes, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 110, 1)))

def _BuildAutomaton_ ():
    # Remove this helper function from the namespace after it is invoked
    global _BuildAutomaton_
    del _BuildAutomaton_
    import pyxb.utils.fac as fac

    counters = set()
    cc_0 = fac.CounterCondition(min=0L, max=None, metadata=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 72, 2))
    counters.add(cc_0)
    states = []
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_0, False))
    symbol = pyxb.binding.content.ElementUse(T_commandes._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'OPER')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 73, 3))
    st_0 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_0)
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_0, False))
    symbol = pyxb.binding.content.ElementUse(T_commandes._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'PROC')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 74, 3))
    st_1 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_1)
    transitions = []
    transitions.append(fac.Transition(st_0, [
        fac.UpdateInstruction(cc_0, True) ]))
    transitions.append(fac.Transition(st_1, [
        fac.UpdateInstruction(cc_0, True) ]))
    st_0._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_0, [
        fac.UpdateInstruction(cc_0, True) ]))
    transitions.append(fac.Transition(st_1, [
        fac.UpdateInstruction(cc_0, True) ]))
    st_1._set_transitionSet(transitions)
    return fac.Automaton(states, counters, True, containing_state=None)
T_commandes._Automaton = _BuildAutomaton_()




T_PlageValeur._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'borne_sup'), T_typeAttendu, scope=T_PlageValeur, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 46, 1)))

T_PlageValeur._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'borne_inf'), T_typeAttendu, scope=T_PlageValeur, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 47, 1)))

T_PlageValeur._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'into'), T_into, scope=T_PlageValeur, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 49, 1)))

def _BuildAutomaton_2 ():
    # Remove this helper function from the namespace after it is invoked
    global _BuildAutomaton_2
    del _BuildAutomaton_2
    import pyxb.utils.fac as fac

    counters = set()
    cc_0 = fac.CounterCondition(min=0L, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 81, 4))
    counters.add(cc_0)
    cc_1 = fac.CounterCondition(min=0L, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 82, 4))
    counters.add(cc_1)
    states = []
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_0, False))
    symbol = pyxb.binding.content.ElementUse(T_PlageValeur._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'borne_sup')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 81, 4))
    st_0 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_0)
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_1, False))
    symbol = pyxb.binding.content.ElementUse(T_PlageValeur._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'borne_inf')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 82, 4))
    st_1 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_1)
    final_update = set()
    symbol = pyxb.binding.content.ElementUse(T_PlageValeur._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'into')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 84, 3))
    st_2 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_2)
    transitions = []
    transitions.append(fac.Transition(st_0, [
        fac.UpdateInstruction(cc_0, True) ]))
    transitions.append(fac.Transition(st_1, [
        fac.UpdateInstruction(cc_0, False) ]))
    st_0._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_1, [
        fac.UpdateInstruction(cc_1, True) ]))
    st_1._set_transitionSet(transitions)
    transitions = []
    st_2._set_transitionSet(transitions)
    return fac.Automaton(states, counters, True, containing_state=None)
T_PlageValeur._Automaton = _BuildAutomaton_2()




T_predicat2._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'p1'), T_predicat1, scope=T_predicat2, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 252, 3)))

T_predicat2._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'p2'), AT_nom, scope=T_predicat2, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 253, 3)))

def _BuildAutomaton_3 ():
    # Remove this helper function from the namespace after it is invoked
    global _BuildAutomaton_3
    del _BuildAutomaton_3
    import pyxb.utils.fac as fac

    counters = set()
    states = []
    final_update = None
    symbol = pyxb.binding.content.ElementUse(T_predicat2._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'p1')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 252, 3))
    st_0 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_0)
    final_update = set()
    symbol = pyxb.binding.content.ElementUse(T_predicat2._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'p2')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 253, 3))
    st_1 = fac.State(symbol, is_initial=False, final_update=final_update, is_unordered_catenation=False)
    states.append(st_1)
    transitions = []
    transitions.append(fac.Transition(st_1, [
         ]))
    st_0._set_transitionSet(transitions)
    transitions = []
    st_1._set_transitionSet(transitions)
    return fac.Automaton(states, counters, False, containing_state=None)
T_predicat2._Automaton = _BuildAutomaton_3()




T_regles._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'A_CLASSER'), T_predicat2, scope=T_regles, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 257, 1)))

T_regles._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'AU_MOINS_UN'), T_predicat1, scope=T_regles, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 258, 1)))

T_regles._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'AU_PLUS_UN'), T_predicat1, scope=T_regles, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 259, 1)))

T_regles._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'ENSEMBLE'), T_predicat1, scope=T_regles, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 260, 1)))

T_regles._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'EXCLUS'), T_predicat1, scope=T_regles, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 261, 1)))

T_regles._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'PRESENT_ABSENT'), T_predicat1, scope=T_regles, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 269, 1)))

T_regles._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'PRESENT_PRESENT'), T_predicat1, scope=T_regles, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 270, 1)))

T_regles._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'UN_PARMI'), T_predicat1, scope=T_regles, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 271, 1)))

def _BuildAutomaton_4 ():
    # Remove this helper function from the namespace after it is invoked
    global _BuildAutomaton_4
    del _BuildAutomaton_4
    import pyxb.utils.fac as fac

    counters = set()
    states = []
    final_update = set()
    symbol = pyxb.binding.content.ElementUse(T_regles._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'A_CLASSER')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 274, 3))
    st_0 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_0)
    final_update = set()
    symbol = pyxb.binding.content.ElementUse(T_regles._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'AU_MOINS_UN')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 275, 3))
    st_1 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_1)
    final_update = set()
    symbol = pyxb.binding.content.ElementUse(T_regles._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'AU_PLUS_UN')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 276, 3))
    st_2 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_2)
    final_update = set()
    symbol = pyxb.binding.content.ElementUse(T_regles._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'ENSEMBLE')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 277, 3))
    st_3 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_3)
    final_update = set()
    symbol = pyxb.binding.content.ElementUse(T_regles._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'EXCLUS')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 278, 3))
    st_4 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_4)
    final_update = set()
    symbol = pyxb.binding.content.ElementUse(T_regles._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'PRESENT_ABSENT')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 286, 3))
    st_5 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_5)
    final_update = set()
    symbol = pyxb.binding.content.ElementUse(T_regles._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'PRESENT_PRESENT')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 287, 3))
    st_6 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_6)
    final_update = set()
    symbol = pyxb.binding.content.ElementUse(T_regles._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'UN_PARMI')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 288, 3))
    st_7 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_7)
    transitions = []
    transitions.append(fac.Transition(st_0, [
         ]))
    transitions.append(fac.Transition(st_1, [
         ]))
    transitions.append(fac.Transition(st_2, [
         ]))
    transitions.append(fac.Transition(st_3, [
         ]))
    transitions.append(fac.Transition(st_4, [
         ]))
    transitions.append(fac.Transition(st_5, [
         ]))
    transitions.append(fac.Transition(st_6, [
         ]))
    transitions.append(fac.Transition(st_7, [
         ]))
    st_0._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_0, [
         ]))
    transitions.append(fac.Transition(st_1, [
         ]))
    transitions.append(fac.Transition(st_2, [
         ]))
    transitions.append(fac.Transition(st_3, [
         ]))
    transitions.append(fac.Transition(st_4, [
         ]))
    transitions.append(fac.Transition(st_5, [
         ]))
    transitions.append(fac.Transition(st_6, [
         ]))
    transitions.append(fac.Transition(st_7, [
         ]))
    st_1._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_0, [
         ]))
    transitions.append(fac.Transition(st_1, [
         ]))
    transitions.append(fac.Transition(st_2, [
         ]))
    transitions.append(fac.Transition(st_3, [
         ]))
    transitions.append(fac.Transition(st_4, [
         ]))
    transitions.append(fac.Transition(st_5, [
         ]))
    transitions.append(fac.Transition(st_6, [
         ]))
    transitions.append(fac.Transition(st_7, [
         ]))
    st_2._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_0, [
         ]))
    transitions.append(fac.Transition(st_1, [
         ]))
    transitions.append(fac.Transition(st_2, [
         ]))
    transitions.append(fac.Transition(st_3, [
         ]))
    transitions.append(fac.Transition(st_4, [
         ]))
    transitions.append(fac.Transition(st_5, [
         ]))
    transitions.append(fac.Transition(st_6, [
         ]))
    transitions.append(fac.Transition(st_7, [
         ]))
    st_3._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_0, [
         ]))
    transitions.append(fac.Transition(st_1, [
         ]))
    transitions.append(fac.Transition(st_2, [
         ]))
    transitions.append(fac.Transition(st_3, [
         ]))
    transitions.append(fac.Transition(st_4, [
         ]))
    transitions.append(fac.Transition(st_5, [
         ]))
    transitions.append(fac.Transition(st_6, [
         ]))
    transitions.append(fac.Transition(st_7, [
         ]))
    st_4._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_0, [
         ]))
    transitions.append(fac.Transition(st_1, [
         ]))
    transitions.append(fac.Transition(st_2, [
         ]))
    transitions.append(fac.Transition(st_3, [
         ]))
    transitions.append(fac.Transition(st_4, [
         ]))
    transitions.append(fac.Transition(st_5, [
         ]))
    transitions.append(fac.Transition(st_6, [
         ]))
    transitions.append(fac.Transition(st_7, [
         ]))
    st_5._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_0, [
         ]))
    transitions.append(fac.Transition(st_1, [
         ]))
    transitions.append(fac.Transition(st_2, [
         ]))
    transitions.append(fac.Transition(st_3, [
         ]))
    transitions.append(fac.Transition(st_4, [
         ]))
    transitions.append(fac.Transition(st_5, [
         ]))
    transitions.append(fac.Transition(st_6, [
         ]))
    transitions.append(fac.Transition(st_7, [
         ]))
    st_6._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_0, [
         ]))
    transitions.append(fac.Transition(st_1, [
         ]))
    transitions.append(fac.Transition(st_2, [
         ]))
    transitions.append(fac.Transition(st_3, [
         ]))
    transitions.append(fac.Transition(st_4, [
         ]))
    transitions.append(fac.Transition(st_5, [
         ]))
    transitions.append(fac.Transition(st_6, [
         ]))
    transitions.append(fac.Transition(st_7, [
         ]))
    st_7._set_transitionSet(transitions)
    return fac.Automaton(states, counters, False, containing_state=None)
T_regles._Automaton = _BuildAutomaton_4()




T_into._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'fonction_utilisateur'), T_fonction_python, scope=T_into, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 10, 1)))

T_into._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'typesimple'), T_simple, scope=T_into, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 464, 1)))

T_into._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'matrice_double'), T_Matrice_double, scope=T_into, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 465, 1)))

T_into._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'matrice_symetrique_double'), T_Matrice_Symetrique_double, scope=T_into, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 466, 1)))

T_into._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'tuple'), T_tuple, scope=T_into, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 467, 1)))

T_into._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'classe_utilisateur'), T_classe_utilisateur, scope=T_into, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 468, 1)))

def _BuildAutomaton_5 ():
    # Remove this helper function from the namespace after it is invoked
    global _BuildAutomaton_5
    del _BuildAutomaton_5
    import pyxb.utils.fac as fac

    counters = set()
    cc_0 = fac.CounterCondition(min=0L, max=None, metadata=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 504, 3))
    counters.add(cc_0)
    cc_1 = fac.CounterCondition(min=0L, max=None, metadata=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 505, 3))
    counters.add(cc_1)
    cc_2 = fac.CounterCondition(min=0L, max=None, metadata=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 506, 3))
    counters.add(cc_2)
    cc_3 = fac.CounterCondition(min=0L, max=None, metadata=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 507, 3))
    counters.add(cc_3)
    cc_4 = fac.CounterCondition(min=0L, max=None, metadata=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 508, 3))
    counters.add(cc_4)
    states = []
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_0, False))
    symbol = pyxb.binding.content.ElementUse(T_into._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'typesimple')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 504, 3))
    st_0 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_0)
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_1, False))
    symbol = pyxb.binding.content.ElementUse(T_into._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'matrice_double')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 505, 3))
    st_1 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_1)
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_2, False))
    symbol = pyxb.binding.content.ElementUse(T_into._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'matrice_symetrique_double')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 506, 3))
    st_2 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_2)
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_3, False))
    symbol = pyxb.binding.content.ElementUse(T_into._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'tuple')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 507, 3))
    st_3 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_3)
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_4, False))
    symbol = pyxb.binding.content.ElementUse(T_into._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'classe_utilisateur')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 508, 3))
    st_4 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_4)
    final_update = set()
    symbol = pyxb.binding.content.ElementUse(T_into._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'fonction_utilisateur')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 509, 3))
    st_5 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_5)
    transitions = []
    transitions.append(fac.Transition(st_0, [
        fac.UpdateInstruction(cc_0, True) ]))
    st_0._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_1, [
        fac.UpdateInstruction(cc_1, True) ]))
    st_1._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_2, [
        fac.UpdateInstruction(cc_2, True) ]))
    st_2._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_3, [
        fac.UpdateInstruction(cc_3, True) ]))
    st_3._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_4, [
        fac.UpdateInstruction(cc_4, True) ]))
    st_4._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_5, [
         ]))
    st_5._set_transitionSet(transitions)
    return fac.Automaton(states, counters, True, containing_state=None)
T_into._Automaton = _BuildAutomaton_5()




T_Accas_Common._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'doc'), T_doc, scope=T_Accas_Common, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 4, 1)))

T_Accas_Common._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'regles'), T_regles, scope=T_Accas_Common, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 6, 1)))

T_Accas_Common._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'SIMP'), T_SIMP, scope=T_Accas_Common, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 43, 1)))

T_Accas_Common._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'FACT'), T_FACT, scope=T_Accas_Common, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 123, 1)))

T_Accas_Common._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'BLOC'), T_BLOC, scope=T_Accas_Common, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 157, 1)))

def _BuildAutomaton_6 ():
    # Remove this helper function from the namespace after it is invoked
    global _BuildAutomaton_6
    del _BuildAutomaton_6
    import pyxb.utils.fac as fac

    counters = set()
    cc_0 = fac.CounterCondition(min=0L, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 89, 3))
    counters.add(cc_0)
    cc_1 = fac.CounterCondition(min=0L, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 90, 3))
    counters.add(cc_1)
    states = []
    final_update = None
    symbol = pyxb.binding.content.ElementUse(T_Accas_Common._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'regles')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 89, 3))
    st_0 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_0)
    final_update = None
    symbol = pyxb.binding.content.ElementUse(T_Accas_Common._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'doc')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 90, 3))
    st_1 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_1)
    final_update = set()
    symbol = pyxb.binding.content.ElementUse(T_Accas_Common._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'BLOC')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 92, 4))
    st_2 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_2)
    final_update = set()
    symbol = pyxb.binding.content.ElementUse(T_Accas_Common._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'FACT')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 93, 4))
    st_3 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_3)
    final_update = set()
    symbol = pyxb.binding.content.ElementUse(T_Accas_Common._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'SIMP')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 94, 4))
    st_4 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_4)
    transitions = []
    transitions.append(fac.Transition(st_0, [
        fac.UpdateInstruction(cc_0, True) ]))
    transitions.append(fac.Transition(st_1, [
        fac.UpdateInstruction(cc_0, False) ]))
    transitions.append(fac.Transition(st_2, [
        fac.UpdateInstruction(cc_0, False) ]))
    transitions.append(fac.Transition(st_3, [
        fac.UpdateInstruction(cc_0, False) ]))
    transitions.append(fac.Transition(st_4, [
        fac.UpdateInstruction(cc_0, False) ]))
    st_0._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_1, [
        fac.UpdateInstruction(cc_1, True) ]))
    transitions.append(fac.Transition(st_2, [
        fac.UpdateInstruction(cc_1, False) ]))
    transitions.append(fac.Transition(st_3, [
        fac.UpdateInstruction(cc_1, False) ]))
    transitions.append(fac.Transition(st_4, [
        fac.UpdateInstruction(cc_1, False) ]))
    st_1._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_2, [
         ]))
    transitions.append(fac.Transition(st_3, [
         ]))
    transitions.append(fac.Transition(st_4, [
         ]))
    st_2._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_2, [
         ]))
    transitions.append(fac.Transition(st_3, [
         ]))
    transitions.append(fac.Transition(st_4, [
         ]))
    st_3._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_2, [
         ]))
    transitions.append(fac.Transition(st_3, [
         ]))
    transitions.append(fac.Transition(st_4, [
         ]))
    st_4._set_transitionSet(transitions)
    return fac.Automaton(states, counters, False, containing_state=None)
T_Accas_Common._Automaton = _BuildAutomaton_6()




T_SIMP._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'doc'), T_doc, scope=T_SIMP, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 4, 1)))

T_SIMP._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'ValeurDef'), T_typeAttendu, scope=T_SIMP, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 8, 1)))

T_SIMP._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'ValeurSugg'), T_typeAttendu, scope=T_SIMP, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 9, 1)))

T_SIMP._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'validators'), T_validators, scope=T_SIMP, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 39, 1)))

T_SIMP._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'PlageValeur'), T_PlageValeur, scope=T_SIMP, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 40, 1)))

T_SIMP._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'typeAttendu'), T_name, scope=T_SIMP, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 41, 1)))

T_SIMP._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'portee'), T_portee, scope=T_SIMP, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 44, 1), unicode_default=u'None'))

def _BuildAutomaton_7 ():
    # Remove this helper function from the namespace after it is invoked
    global _BuildAutomaton_7
    del _BuildAutomaton_7
    import pyxb.utils.fac as fac

    counters = set()
    cc_0 = fac.CounterCondition(min=0L, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 169, 3))
    counters.add(cc_0)
    cc_1 = fac.CounterCondition(min=0L, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 170, 3))
    counters.add(cc_1)
    cc_2 = fac.CounterCondition(min=0L, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 175, 3))
    counters.add(cc_2)
    cc_3 = fac.CounterCondition(min=0L, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 176, 3))
    counters.add(cc_3)
    cc_4 = fac.CounterCondition(min=0L, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 177, 3))
    counters.add(cc_4)
    cc_5 = fac.CounterCondition(min=0L, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 179, 3))
    counters.add(cc_5)
    states = []
    final_update = None
    symbol = pyxb.binding.content.ElementUse(T_SIMP._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'doc')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 169, 3))
    st_0 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_0)
    final_update = None
    symbol = pyxb.binding.content.ElementUse(T_SIMP._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'portee')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 170, 3))
    st_1 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_1)
    final_update = None
    symbol = pyxb.binding.content.ElementUse(T_SIMP._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'ValeurDef')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 175, 3))
    st_2 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_2)
    final_update = None
    symbol = pyxb.binding.content.ElementUse(T_SIMP._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'ValeurSugg')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 176, 3))
    st_3 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_3)
    final_update = None
    symbol = pyxb.binding.content.ElementUse(T_SIMP._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'PlageValeur')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 177, 3))
    st_4 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_4)
    final_update = set()
    symbol = pyxb.binding.content.ElementUse(T_SIMP._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'typeAttendu')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 178, 3))
    st_5 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_5)
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_5, False))
    symbol = pyxb.binding.content.ElementUse(T_SIMP._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'validators')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 179, 3))
    st_6 = fac.State(symbol, is_initial=False, final_update=final_update, is_unordered_catenation=False)
    states.append(st_6)
    transitions = []
    transitions.append(fac.Transition(st_0, [
        fac.UpdateInstruction(cc_0, True) ]))
    transitions.append(fac.Transition(st_1, [
        fac.UpdateInstruction(cc_0, False) ]))
    transitions.append(fac.Transition(st_2, [
        fac.UpdateInstruction(cc_0, False) ]))
    transitions.append(fac.Transition(st_3, [
        fac.UpdateInstruction(cc_0, False) ]))
    transitions.append(fac.Transition(st_4, [
        fac.UpdateInstruction(cc_0, False) ]))
    transitions.append(fac.Transition(st_5, [
        fac.UpdateInstruction(cc_0, False) ]))
    st_0._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_1, [
        fac.UpdateInstruction(cc_1, True) ]))
    transitions.append(fac.Transition(st_2, [
        fac.UpdateInstruction(cc_1, False) ]))
    transitions.append(fac.Transition(st_3, [
        fac.UpdateInstruction(cc_1, False) ]))
    transitions.append(fac.Transition(st_4, [
        fac.UpdateInstruction(cc_1, False) ]))
    transitions.append(fac.Transition(st_5, [
        fac.UpdateInstruction(cc_1, False) ]))
    st_1._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_2, [
        fac.UpdateInstruction(cc_2, True) ]))
    transitions.append(fac.Transition(st_3, [
        fac.UpdateInstruction(cc_2, False) ]))
    transitions.append(fac.Transition(st_4, [
        fac.UpdateInstruction(cc_2, False) ]))
    transitions.append(fac.Transition(st_5, [
        fac.UpdateInstruction(cc_2, False) ]))
    st_2._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_3, [
        fac.UpdateInstruction(cc_3, True) ]))
    transitions.append(fac.Transition(st_4, [
        fac.UpdateInstruction(cc_3, False) ]))
    transitions.append(fac.Transition(st_5, [
        fac.UpdateInstruction(cc_3, False) ]))
    st_3._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_4, [
        fac.UpdateInstruction(cc_4, True) ]))
    transitions.append(fac.Transition(st_5, [
        fac.UpdateInstruction(cc_4, False) ]))
    st_4._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_6, [
         ]))
    st_5._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_6, [
        fac.UpdateInstruction(cc_5, True) ]))
    st_6._set_transitionSet(transitions)
    return fac.Automaton(states, counters, False, containing_state=None)
T_SIMP._Automaton = _BuildAutomaton_7()




def _BuildAutomaton_8 ():
    # Remove this helper function from the namespace after it is invoked
    global _BuildAutomaton_8
    del _BuildAutomaton_8
    import pyxb.utils.fac as fac

    counters = set()
    cc_0 = fac.CounterCondition(min=0L, max=None, metadata=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 516, 5))
    counters.add(cc_0)
    cc_1 = fac.CounterCondition(min=0L, max=None, metadata=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 517, 5))
    counters.add(cc_1)
    cc_2 = fac.CounterCondition(min=0L, max=None, metadata=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 518, 5))
    counters.add(cc_2)
    cc_3 = fac.CounterCondition(min=0L, max=None, metadata=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 519, 5))
    counters.add(cc_3)
    cc_4 = fac.CounterCondition(min=0L, max=None, metadata=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 520, 5))
    counters.add(cc_4)
    states = []
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_0, False))
    symbol = pyxb.binding.content.ElementUse(T_typeAttendu._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'typesimple')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 516, 5))
    st_0 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_0)
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_1, False))
    symbol = pyxb.binding.content.ElementUse(T_typeAttendu._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'matrice_double')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 517, 5))
    st_1 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_1)
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_2, False))
    symbol = pyxb.binding.content.ElementUse(T_typeAttendu._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'matrice_symetrique_double')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 518, 5))
    st_2 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_2)
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_3, False))
    symbol = pyxb.binding.content.ElementUse(T_typeAttendu._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'tuple')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 519, 5))
    st_3 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_3)
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_4, False))
    symbol = pyxb.binding.content.ElementUse(T_typeAttendu._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'classe_utilisateur')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 520, 5))
    st_4 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_4)
    transitions = []
    transitions.append(fac.Transition(st_0, [
        fac.UpdateInstruction(cc_0, True) ]))
    st_0._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_1, [
        fac.UpdateInstruction(cc_1, True) ]))
    st_1._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_2, [
        fac.UpdateInstruction(cc_2, True) ]))
    st_2._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_3, [
        fac.UpdateInstruction(cc_3, True) ]))
    st_3._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_4, [
        fac.UpdateInstruction(cc_4, True) ]))
    st_4._set_transitionSet(transitions)
    return fac.Automaton(states, counters, True, containing_state=None)
T_typeAttendu._Automaton = _BuildAutomaton_8()




T_OPER._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'typeCree'), T_classe_utilisateur, scope=T_OPER, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 7, 1)))

def _BuildAutomaton_9 ():
    # Remove this helper function from the namespace after it is invoked
    global _BuildAutomaton_9
    del _BuildAutomaton_9
    import pyxb.utils.fac as fac

    counters = set()
    cc_0 = fac.CounterCondition(min=0L, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 89, 3))
    counters.add(cc_0)
    cc_1 = fac.CounterCondition(min=0L, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 90, 3))
    counters.add(cc_1)
    states = []
    final_update = None
    symbol = pyxb.binding.content.ElementUse(T_OPER._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'regles')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 89, 3))
    st_0 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_0)
    final_update = None
    symbol = pyxb.binding.content.ElementUse(T_OPER._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'doc')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 90, 3))
    st_1 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_1)
    final_update = None
    symbol = pyxb.binding.content.ElementUse(T_OPER._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'BLOC')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 92, 4))
    st_2 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_2)
    final_update = None
    symbol = pyxb.binding.content.ElementUse(T_OPER._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'FACT')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 93, 4))
    st_3 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_3)
    final_update = None
    symbol = pyxb.binding.content.ElementUse(T_OPER._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'SIMP')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 94, 4))
    st_4 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_4)
    final_update = set()
    symbol = pyxb.binding.content.ElementUse(T_OPER._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'typeCree')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 104, 5))
    st_5 = fac.State(symbol, is_initial=False, final_update=final_update, is_unordered_catenation=False)
    states.append(st_5)
    transitions = []
    transitions.append(fac.Transition(st_0, [
        fac.UpdateInstruction(cc_0, True) ]))
    transitions.append(fac.Transition(st_1, [
        fac.UpdateInstruction(cc_0, False) ]))
    transitions.append(fac.Transition(st_2, [
        fac.UpdateInstruction(cc_0, False) ]))
    transitions.append(fac.Transition(st_3, [
        fac.UpdateInstruction(cc_0, False) ]))
    transitions.append(fac.Transition(st_4, [
        fac.UpdateInstruction(cc_0, False) ]))
    st_0._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_1, [
        fac.UpdateInstruction(cc_1, True) ]))
    transitions.append(fac.Transition(st_2, [
        fac.UpdateInstruction(cc_1, False) ]))
    transitions.append(fac.Transition(st_3, [
        fac.UpdateInstruction(cc_1, False) ]))
    transitions.append(fac.Transition(st_4, [
        fac.UpdateInstruction(cc_1, False) ]))
    st_1._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_2, [
         ]))
    transitions.append(fac.Transition(st_3, [
         ]))
    transitions.append(fac.Transition(st_4, [
         ]))
    transitions.append(fac.Transition(st_5, [
         ]))
    st_2._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_2, [
         ]))
    transitions.append(fac.Transition(st_3, [
         ]))
    transitions.append(fac.Transition(st_4, [
         ]))
    transitions.append(fac.Transition(st_5, [
         ]))
    st_3._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_2, [
         ]))
    transitions.append(fac.Transition(st_3, [
         ]))
    transitions.append(fac.Transition(st_4, [
         ]))
    transitions.append(fac.Transition(st_5, [
         ]))
    st_4._set_transitionSet(transitions)
    transitions = []
    st_5._set_transitionSet(transitions)
    return fac.Automaton(states, counters, False, containing_state=None)
T_OPER._Automaton = _BuildAutomaton_9()




def _BuildAutomaton_10 ():
    # Remove this helper function from the namespace after it is invoked
    global _BuildAutomaton_10
    del _BuildAutomaton_10
    import pyxb.utils.fac as fac

    counters = set()
    cc_0 = fac.CounterCondition(min=0L, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 89, 3))
    counters.add(cc_0)
    cc_1 = fac.CounterCondition(min=0L, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 90, 3))
    counters.add(cc_1)
    states = []
    final_update = None
    symbol = pyxb.binding.content.ElementUse(T_PROC._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'regles')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 89, 3))
    st_0 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_0)
    final_update = None
    symbol = pyxb.binding.content.ElementUse(T_PROC._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'doc')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 90, 3))
    st_1 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_1)
    final_update = set()
    symbol = pyxb.binding.content.ElementUse(T_PROC._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'BLOC')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 92, 4))
    st_2 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_2)
    final_update = set()
    symbol = pyxb.binding.content.ElementUse(T_PROC._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'FACT')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 93, 4))
    st_3 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_3)
    final_update = set()
    symbol = pyxb.binding.content.ElementUse(T_PROC._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'SIMP')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 94, 4))
    st_4 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_4)
    transitions = []
    transitions.append(fac.Transition(st_0, [
        fac.UpdateInstruction(cc_0, True) ]))
    transitions.append(fac.Transition(st_1, [
        fac.UpdateInstruction(cc_0, False) ]))
    transitions.append(fac.Transition(st_2, [
        fac.UpdateInstruction(cc_0, False) ]))
    transitions.append(fac.Transition(st_3, [
        fac.UpdateInstruction(cc_0, False) ]))
    transitions.append(fac.Transition(st_4, [
        fac.UpdateInstruction(cc_0, False) ]))
    st_0._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_1, [
        fac.UpdateInstruction(cc_1, True) ]))
    transitions.append(fac.Transition(st_2, [
        fac.UpdateInstruction(cc_1, False) ]))
    transitions.append(fac.Transition(st_3, [
        fac.UpdateInstruction(cc_1, False) ]))
    transitions.append(fac.Transition(st_4, [
        fac.UpdateInstruction(cc_1, False) ]))
    st_1._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_2, [
         ]))
    transitions.append(fac.Transition(st_3, [
         ]))
    transitions.append(fac.Transition(st_4, [
         ]))
    st_2._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_2, [
         ]))
    transitions.append(fac.Transition(st_3, [
         ]))
    transitions.append(fac.Transition(st_4, [
         ]))
    st_3._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_2, [
         ]))
    transitions.append(fac.Transition(st_3, [
         ]))
    transitions.append(fac.Transition(st_4, [
         ]))
    st_4._set_transitionSet(transitions)
    return fac.Automaton(states, counters, False, containing_state=None)
T_PROC._Automaton = _BuildAutomaton_10()




def _BuildAutomaton_11 ():
    # Remove this helper function from the namespace after it is invoked
    global _BuildAutomaton_11
    del _BuildAutomaton_11
    import pyxb.utils.fac as fac

    counters = set()
    cc_0 = fac.CounterCondition(min=0L, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 89, 3))
    counters.add(cc_0)
    cc_1 = fac.CounterCondition(min=0L, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 90, 3))
    counters.add(cc_1)
    states = []
    final_update = None
    symbol = pyxb.binding.content.ElementUse(T_FACT._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'regles')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 89, 3))
    st_0 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_0)
    final_update = None
    symbol = pyxb.binding.content.ElementUse(T_FACT._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'doc')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 90, 3))
    st_1 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_1)
    final_update = set()
    symbol = pyxb.binding.content.ElementUse(T_FACT._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'BLOC')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 92, 4))
    st_2 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_2)
    final_update = set()
    symbol = pyxb.binding.content.ElementUse(T_FACT._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'FACT')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 93, 4))
    st_3 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_3)
    final_update = set()
    symbol = pyxb.binding.content.ElementUse(T_FACT._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'SIMP')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 94, 4))
    st_4 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_4)
    transitions = []
    transitions.append(fac.Transition(st_0, [
        fac.UpdateInstruction(cc_0, True) ]))
    transitions.append(fac.Transition(st_1, [
        fac.UpdateInstruction(cc_0, False) ]))
    transitions.append(fac.Transition(st_2, [
        fac.UpdateInstruction(cc_0, False) ]))
    transitions.append(fac.Transition(st_3, [
        fac.UpdateInstruction(cc_0, False) ]))
    transitions.append(fac.Transition(st_4, [
        fac.UpdateInstruction(cc_0, False) ]))
    st_0._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_1, [
        fac.UpdateInstruction(cc_1, True) ]))
    transitions.append(fac.Transition(st_2, [
        fac.UpdateInstruction(cc_1, False) ]))
    transitions.append(fac.Transition(st_3, [
        fac.UpdateInstruction(cc_1, False) ]))
    transitions.append(fac.Transition(st_4, [
        fac.UpdateInstruction(cc_1, False) ]))
    st_1._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_2, [
         ]))
    transitions.append(fac.Transition(st_3, [
         ]))
    transitions.append(fac.Transition(st_4, [
         ]))
    st_2._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_2, [
         ]))
    transitions.append(fac.Transition(st_3, [
         ]))
    transitions.append(fac.Transition(st_4, [
         ]))
    st_3._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_2, [
         ]))
    transitions.append(fac.Transition(st_3, [
         ]))
    transitions.append(fac.Transition(st_4, [
         ]))
    st_4._set_transitionSet(transitions)
    return fac.Automaton(states, counters, False, containing_state=None)
T_FACT._Automaton = _BuildAutomaton_11()




T_BLOC._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, u'condition'), T_fonction_python, scope=T_BLOC, location=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 45, 1)))

def _BuildAutomaton_12 ():
    # Remove this helper function from the namespace after it is invoked
    global _BuildAutomaton_12
    del _BuildAutomaton_12
    import pyxb.utils.fac as fac

    counters = set()
    cc_0 = fac.CounterCondition(min=0L, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 89, 3))
    counters.add(cc_0)
    cc_1 = fac.CounterCondition(min=0L, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 90, 3))
    counters.add(cc_1)
    states = []
    final_update = None
    symbol = pyxb.binding.content.ElementUse(T_BLOC._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'regles')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 89, 3))
    st_0 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_0)
    final_update = None
    symbol = pyxb.binding.content.ElementUse(T_BLOC._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'doc')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 90, 3))
    st_1 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_1)
    final_update = None
    symbol = pyxb.binding.content.ElementUse(T_BLOC._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'BLOC')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 92, 4))
    st_2 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_2)
    final_update = None
    symbol = pyxb.binding.content.ElementUse(T_BLOC._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'FACT')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 93, 4))
    st_3 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_3)
    final_update = None
    symbol = pyxb.binding.content.ElementUse(T_BLOC._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'SIMP')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 94, 4))
    st_4 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_4)
    final_update = set()
    symbol = pyxb.binding.content.ElementUse(T_BLOC._UseForTag(pyxb.namespace.ExpandedName(Namespace, u'condition')), pyxb.utils.utility.Location('/home/A96028/EchangesEric/EssaiExt/model.xsd', 162, 5))
    st_5 = fac.State(symbol, is_initial=False, final_update=final_update, is_unordered_catenation=False)
    states.append(st_5)
    transitions = []
    transitions.append(fac.Transition(st_0, [
        fac.UpdateInstruction(cc_0, True) ]))
    transitions.append(fac.Transition(st_1, [
        fac.UpdateInstruction(cc_0, False) ]))
    transitions.append(fac.Transition(st_2, [
        fac.UpdateInstruction(cc_0, False) ]))
    transitions.append(fac.Transition(st_3, [
        fac.UpdateInstruction(cc_0, False) ]))
    transitions.append(fac.Transition(st_4, [
        fac.UpdateInstruction(cc_0, False) ]))
    st_0._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_1, [
        fac.UpdateInstruction(cc_1, True) ]))
    transitions.append(fac.Transition(st_2, [
        fac.UpdateInstruction(cc_1, False) ]))
    transitions.append(fac.Transition(st_3, [
        fac.UpdateInstruction(cc_1, False) ]))
    transitions.append(fac.Transition(st_4, [
        fac.UpdateInstruction(cc_1, False) ]))
    st_1._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_2, [
         ]))
    transitions.append(fac.Transition(st_3, [
         ]))
    transitions.append(fac.Transition(st_4, [
         ]))
    transitions.append(fac.Transition(st_5, [
         ]))
    st_2._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_2, [
         ]))
    transitions.append(fac.Transition(st_3, [
         ]))
    transitions.append(fac.Transition(st_4, [
         ]))
    transitions.append(fac.Transition(st_5, [
         ]))
    st_3._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_2, [
         ]))
    transitions.append(fac.Transition(st_3, [
         ]))
    transitions.append(fac.Transition(st_4, [
         ]))
    transitions.append(fac.Transition(st_5, [
         ]))
    st_4._set_transitionSet(transitions)
    transitions = []
    st_5._set_transitionSet(transitions)
    return fac.Automaton(states, counters, False, containing_state=None)
T_BLOC._Automaton = _BuildAutomaton_12()


classeUtilisateurName._setSubstitutionGroup(typeAttendu)
