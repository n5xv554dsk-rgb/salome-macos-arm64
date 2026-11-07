# ./raw/cata_FactFreresMemesNoms_driver.py
# -*- coding: utf-8 -*-
# PyXB bindings for NM:9c3bd166183fcfc95687f415bcc4a066eb33ac79
# Generated 2020-10-22 12:32:22.612163 by PyXB version 1.2.5 using Python 3.4.2.final.0
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
_GenerationUID = pyxb.utils.utility.UniqueIdentifier('urn:uuid:deafbfb4-1451-11eb-b347-cc3d82d871d8')

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


# Atomic simple type: {http://chercheurs.edf.com/logiciels/Essai}T_unSimp
class T_unSimp (pyxb.binding.datatypes.int):

    """An atomic simple type."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'T_unSimp')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_FactFreresMemesNoms.xsd', 7, 1)
    _Documentation = None
T_unSimp._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', 'T_unSimp', T_unSimp)
_module_typeBindings.T_unSimp = T_unSimp

# Atomic simple type: {http://chercheurs.edf.com/logiciels/Essai}T_Name
class T_Name (pyxb.binding.datatypes.string):

    """An atomic simple type."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'T_Name')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_FactFreresMemesNoms.xsd', 11, 1)
    _Documentation = None
T_Name._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', 'T_Name', T_Name)
_module_typeBindings.T_Name = T_Name

# Atomic simple type: {http://chercheurs.edf.com/logiciels/Essai}T_ScalarFluxModel
class T_ScalarFluxModel (pyxb.binding.datatypes.string):

    """An atomic simple type."""

    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'T_ScalarFluxModel')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_FactFreresMemesNoms.xsd', 15, 1)
    _Documentation = None
T_ScalarFluxModel._InitializeFacetMap()
Namespace.addCategoryObject('typeBinding', 'T_ScalarFluxModel', T_ScalarFluxModel)
_module_typeBindings.T_ScalarFluxModel = T_ScalarFluxModel

# Complex type {http://chercheurs.edf.com/logiciels/Essai}T_leFact1 with content type ELEMENT_ONLY
class T_leFact1 (pyxb.binding.basis.complexTypeDefinition):
    """Complex type {http://chercheurs.edf.com/logiciels/Essai}T_leFact1 with content type ELEMENT_ONLY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_ELEMENT_ONLY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'T_leFact1')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_FactFreresMemesNoms.xsd', 24, 1)
    _ElementMap = {}
    _AttributeMap = {}
    # Base type is pyxb.binding.datatypes.anyType
    
    # Element {http://chercheurs.edf.com/logiciels/Essai}Name uses Python identifier Name
    __Name = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, 'Name'), 'Name', '__httpchercheurs_edf_comlogicielsEssai_T_leFact1_httpchercheurs_edf_comlogicielsEssaiName', False, pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_FactFreresMemesNoms.xsd', 27, 3), )

    
    Name = property(__Name.value, __Name.set, None, None)

    
    # Element {http://chercheurs.edf.com/logiciels/Essai}ScalarFluxModel uses Python identifier ScalarFluxModel
    __ScalarFluxModel = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, 'ScalarFluxModel'), 'ScalarFluxModel', '__httpchercheurs_edf_comlogicielsEssai_T_leFact1_httpchercheurs_edf_comlogicielsEssaiScalarFluxModel', False, pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_FactFreresMemesNoms.xsd', 28, 3), )

    
    ScalarFluxModel = property(__ScalarFluxModel.value, __ScalarFluxModel.set, None, None)

    _ElementMap.update({
        __Name.name() : __Name,
        __ScalarFluxModel.name() : __ScalarFluxModel
    })
    _AttributeMap.update({
        
    })
_module_typeBindings.T_leFact1 = T_leFact1
Namespace.addCategoryObject('typeBinding', 'T_leFact1', T_leFact1)


# Complex type {http://chercheurs.edf.com/logiciels/Essai}T_step_Essai with content type EMPTY
class T_step_Essai (pyxb.binding.basis.complexTypeDefinition):
    """Complex type {http://chercheurs.edf.com/logiciels/Essai}T_step_Essai with content type EMPTY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_EMPTY
    _Abstract = True
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'T_step_Essai')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_FactFreresMemesNoms.xsd', 46, 1)
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
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_FactFreresMemesNoms.xsd', 49, 2)
    _ElementMap = {}
    _AttributeMap = {}
    # Base type is pyxb.binding.datatypes.anyType
    
    # Element {http://chercheurs.edf.com/logiciels/Essai}step_Essai uses Python identifier step_Essai
    __step_Essai = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, 'step_Essai'), 'step_Essai', '__httpchercheurs_edf_comlogicielsEssai_T_Essai_httpchercheurs_edf_comlogicielsEssaistep_Essai', True, pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_FactFreresMemesNoms.xsd', 47, 1), )

    
    step_Essai = property(__step_Essai.value, __step_Essai.set, None, None)

    _ElementMap.update({
        __step_Essai.name() : __step_Essai
    })
    _AttributeMap.update({
        
    })
_module_typeBindings.T_Essai = T_Essai
Namespace.addCategoryObject('typeBinding', 'T_Essai', T_Essai)


# Complex type {http://chercheurs.edf.com/logiciels/Essai}T_leProc with content type ELEMENT_ONLY
class T_leProc (T_step_Essai):
    """Complex type {http://chercheurs.edf.com/logiciels/Essai}T_leProc with content type ELEMENT_ONLY"""
    _TypeDefinition = None
    _ContentTypeTag = pyxb.binding.basis.complexTypeDefinition._CT_ELEMENT_ONLY
    _Abstract = False
    _ExpandedName = pyxb.namespace.ExpandedName(Namespace, 'T_leProc')
    _XSDLocation = pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_FactFreresMemesNoms.xsd', 35, 1)
    _ElementMap = T_step_Essai._ElementMap.copy()
    _AttributeMap = T_step_Essai._AttributeMap.copy()
    # Base type is T_step_Essai
    
    # Element {http://chercheurs.edf.com/logiciels/Essai}leFact1 uses Python identifier leFact1
    __leFact1 = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, 'leFact1'), 'leFact1', '__httpchercheurs_edf_comlogicielsEssai_T_leProc_httpchercheurs_edf_comlogicielsEssaileFact1', False, pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_FactFreresMemesNoms.xsd', 21, 3), )

    
    leFact1 = property(__leFact1.value, __leFact1.set, None, None)

    
    # Element {http://chercheurs.edf.com/logiciels/Essai}unSimp uses Python identifier unSimp
    __unSimp = pyxb.binding.content.ElementDeclaration(pyxb.namespace.ExpandedName(Namespace, 'unSimp'), 'unSimp', '__httpchercheurs_edf_comlogicielsEssai_T_leProc_httpchercheurs_edf_comlogicielsEssaiunSimp', False, pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_FactFreresMemesNoms.xsd', 39, 3), )

    
    unSimp = property(__unSimp.value, __unSimp.set, None, None)

    _ElementMap.update({
        __leFact1.name() : __leFact1,
        __unSimp.name() : __unSimp
    })
    _AttributeMap.update({
        
    })
_module_typeBindings.T_leProc = T_leProc
Namespace.addCategoryObject('typeBinding', 'T_leProc', T_leProc)


step_Essai = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'step_Essai'), T_step_Essai, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_FactFreresMemesNoms.xsd', 47, 1))
Namespace.addCategoryObject('elementBinding', step_Essai.name().localName(), step_Essai)

Essai = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'Essai'), T_Essai, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_FactFreresMemesNoms.xsd', 48, 1))
Namespace.addCategoryObject('elementBinding', Essai.name().localName(), Essai)

leProc = pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'leProc'), T_leProc, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_FactFreresMemesNoms.xsd', 45, 1))
Namespace.addCategoryObject('elementBinding', leProc.name().localName(), leProc)



T_leFact1._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'Name'), T_Name, scope=T_leFact1, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_FactFreresMemesNoms.xsd', 27, 3)))

T_leFact1._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'ScalarFluxModel'), T_ScalarFluxModel, scope=T_leFact1, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_FactFreresMemesNoms.xsd', 28, 3)))

def _BuildAutomaton ():
    # Remove this helper function from the namespace after it is invoked
    global _BuildAutomaton
    del _BuildAutomaton
    import pyxb.utils.fac as fac

    counters = set()
    states = []
    final_update = None
    symbol = pyxb.binding.content.ElementUse(T_leFact1._UseForTag(pyxb.namespace.ExpandedName(Namespace, 'Name')), pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_FactFreresMemesNoms.xsd', 27, 3))
    st_0 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_0)
    final_update = set()
    symbol = pyxb.binding.content.ElementUse(T_leFact1._UseForTag(pyxb.namespace.ExpandedName(Namespace, 'ScalarFluxModel')), pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_FactFreresMemesNoms.xsd', 28, 3))
    st_1 = fac.State(symbol, is_initial=False, final_update=final_update, is_unordered_catenation=False)
    states.append(st_1)
    final_update = set()
    symbol = pyxb.binding.content.ElementUse(T_leFact1._UseForTag(pyxb.namespace.ExpandedName(Namespace, 'Name')), pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_FactFreresMemesNoms.xsd', 31, 3))
    st_2 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_2)
    transitions = []
    transitions.append(fac.Transition(st_1, [
         ]))
    st_0._set_transitionSet(transitions)
    transitions = []
    st_1._set_transitionSet(transitions)
    transitions = []
    st_2._set_transitionSet(transitions)
    return fac.Automaton(states, counters, False, containing_state=None)
T_leFact1._Automaton = _BuildAutomaton()




T_Essai._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'step_Essai'), T_step_Essai, scope=T_Essai, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_FactFreresMemesNoms.xsd', 47, 1)))

def _BuildAutomaton_ ():
    # Remove this helper function from the namespace after it is invoked
    global _BuildAutomaton_
    del _BuildAutomaton_
    import pyxb.utils.fac as fac

    counters = set()
    cc_0 = fac.CounterCondition(min=0, max=None, metadata=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_FactFreresMemesNoms.xsd', 50, 4))
    counters.add(cc_0)
    cc_1 = fac.CounterCondition(min=0, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_FactFreresMemesNoms.xsd', 51, 3))
    counters.add(cc_1)
    states = []
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_0, False))
    final_update.add(fac.UpdateInstruction(cc_1, False))
    symbol = pyxb.binding.content.ElementUse(T_Essai._UseForTag(pyxb.namespace.ExpandedName(Namespace, 'step_Essai')), pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_FactFreresMemesNoms.xsd', 51, 3))
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
T_Essai._Automaton = _BuildAutomaton_()




T_leProc._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'leFact1'), T_leFact1, scope=T_leProc, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_FactFreresMemesNoms.xsd', 21, 3)))

T_leProc._AddElement(pyxb.binding.basis.element(pyxb.namespace.ExpandedName(Namespace, 'unSimp'), T_unSimp, scope=T_leProc, location=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_FactFreresMemesNoms.xsd', 39, 3)))

def _BuildAutomaton_2 ():
    # Remove this helper function from the namespace after it is invoked
    global _BuildAutomaton_2
    del _BuildAutomaton_2
    import pyxb.utils.fac as fac

    counters = set()
    cc_0 = fac.CounterCondition(min=0, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_FactFreresMemesNoms.xsd', 40, 3))
    counters.add(cc_0)
    cc_1 = fac.CounterCondition(min=0, max=1, metadata=pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_FactFreresMemesNoms.xsd', 21, 3))
    counters.add(cc_1)
    states = []
    final_update = set()
    symbol = pyxb.binding.content.ElementUse(T_leProc._UseForTag(pyxb.namespace.ExpandedName(Namespace, 'unSimp')), pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_FactFreresMemesNoms.xsd', 39, 3))
    st_0 = fac.State(symbol, is_initial=True, final_update=final_update, is_unordered_catenation=False)
    states.append(st_0)
    final_update = set()
    final_update.add(fac.UpdateInstruction(cc_0, False))
    final_update.add(fac.UpdateInstruction(cc_1, False))
    symbol = pyxb.binding.content.ElementUse(T_leProc._UseForTag(pyxb.namespace.ExpandedName(Namespace, 'leFact1')), pyxb.utils.utility.Location('/home/A96028/QT5GitEficasTravail/eficas/CatasDeTests/cata_FactFreresMemesNoms.xsd', 21, 3))
    st_1 = fac.State(symbol, is_initial=False, final_update=final_update, is_unordered_catenation=False)
    states.append(st_1)
    transitions = []
    transitions.append(fac.Transition(st_1, [
         ]))
    st_0._set_transitionSet(transitions)
    transitions = []
    transitions.append(fac.Transition(st_1, [
        fac.UpdateInstruction(cc_0, True),
        fac.UpdateInstruction(cc_1, False) ]))
    transitions.append(fac.Transition(st_1, [
        fac.UpdateInstruction(cc_1, True) ]))
    st_1._set_transitionSet(transitions)
    return fac.Automaton(states, counters, False, containing_state=None)
T_leProc._Automaton = _BuildAutomaton_2()


leProc._setSubstitutionGroup(step_Essai)
