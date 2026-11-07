
import os.path
from xml.etree import ElementTree as ET
from xml.etree.ElementTree import *
from xml.dom import minidom
import re

def get_file_name( theScript, theFileName, theExtension ):
	anExt = '.'+theExtension
	if theFileName=='':
		return theScript+anExt
	if theFileName.lower().endswith( anExt ):
		return theFileName
	else:
		return theFileName + anExt

class TSParser:
	def __init__( self ):
		self.data = {}
		self.check_object = None # the function to check if the object is suitable for translation
		self.translation  = None # the function to translate the object's name
		self.sub_objects  = None # the function to get sub-objects of the given object
		self.not_translated = {}
		
	def add( self, theContext, theSource, theTranslation ):
		if len(theSource)==0 or len(theTranslation)==0:
			return
		if not theContext in self.data:
			self.data[theContext] = {}
		self.data[theContext][theSource] = theTranslation

	def saveXML( self, theFileName, theEncoding, theDocType, theRootElem ):
		aRoughRepr = ET.tostring( theRootElem, theEncoding )
		aDoc = minidom.parseString( aRoughRepr )
		aDocType = minidom.getDOMImplementation( '' ).createDocumentType( theDocType, '', '' )
		aDoc.insertBefore( aDocType, aDoc.documentElement )
		anXmlRepr = aDoc.toprettyxml( indent='  ' )
		anXmlLines = anXmlRepr.split( '\n' )[1:]
		anXmlRepr = '\n'.join( anXmlLines )
		anExpr = re.compile( '>\n\s+([^<>\s].*?)\n\s+</', re.DOTALL )    
		anXmlRepr = anExpr.sub( '>\g<1></', anXmlRepr )
		
		#print anXmlRepr
		aFile = open( theFileName, 'w' )
		aFile.write( anXmlRepr )
		aFile.close()

	def load( self, theFileName ):
		if not os.path.isfile( theFileName ):
			return
			
		aTree = ET.parse( theFileName )
		aRoot = aTree.getroot()
		for aContextElem in aRoot:
			aContext = aContextElem[0].text;
			if not aContext:
				aContext = ''
			#print aContext
			for aMessageElem in aContextElem[1:]:
				aSource = aMessageElem[0].text.strip()
				aTranslation = aMessageElem[1].text.strip()
				#print aSource
				#print aTranslation
				self.add( aContext, aSource, aTranslation )
		
	def save( self, theFileName ):
		aRoot = Element( 'TS' )
		for aContext, aData in self.data.iteritems():
			aContextElem = SubElement( aRoot, 'context' )
			aName = SubElement( aContextElem, 'name' )
			aName.text = aContext
			for aSource, aTranslation in aData.iteritems():
				aMessage = SubElement( aContextElem, 'message' )
				aSourceElem = SubElement( aMessage, 'source' )
				aSourceElem.text = aSource
				aTranslationElem = SubElement( aMessage, 'translation' )
				aTranslationElem.text = aTranslation
		
		self.saveXML( theFileName, 'utf-8', 'TS', aRoot )

	def isOK( self, theName, theObject ):
		if theName.startswith( '__' ):
			return False
		if self.check_object:
			return self.check_object( theName, theObject )
		return True
		
	def parse( self, theScript, theFileName = '' ):
		self.data = {}
		aFileName = get_file_name( theScript, theFileName, 'ts' )
		self.load( aFileName )
		aModule = __import__( theScript )
		self.parseObjects( aModule.__dict__, None, '' )
		self.save( aFileName )
		
	def parseObjects( self, theDict, theParentObj, theParentName ):
		
		for aName, anObject in theDict.iteritems():
			
			if not self.isOK( aName, anObject ):
				continue
				
			if self.translation:
				aContext, aTranslation = self.translation( anObject, aName, theParentObj, theParentName )
			else:
				aContext = ''
				aTranslation = aName
				
			#print "Found:", aName
			if len( aTranslation ) > 0:
				self.add( aContext, aName, aTranslation )
			elif self.isOK( '', anObject ) and len( aName ) > 0:
				#print anObject, aName
				self.not_translated[aName] = ''
				
			aSubObjects = {}
			if self.sub_objects:
				aSubObjects = self.sub_objects( anObject )
			self.parseObjects( aSubObjects, anObject, aName )

	def saveNotTranslated( self, theFileName ):
		aFile = open( theFileName, 'w' )
		aNotTranslated = self.not_translated.keys()
		aNotTranslated.sort()
		for aKey in aNotTranslated:
			aFile.write( aKey + '\n' )
		aFile.close()
