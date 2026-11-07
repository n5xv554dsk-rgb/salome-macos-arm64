
import copy
from tsparser import *
from Accas import *
from Accas.processing import *
from dicoparser import *

def normalize( theTranslation ):
	aTranslation = theTranslation
	if '_' in aTranslation:
		aTranslation = '__'.join( aTranslation.split( '_' ) )
	
	aTranslation = aTranslation.replace( ' ', '_' )
	return aTranslation

def translate( theDicoFile, theCataFile, theTSFile, theNotTranslatedFile = '' ):
	
	SPECIAL = ['into', 'defaut']
	DICO = DicoParser( theDicoFile, 'NOM', 'NOM1' )
	PARSER = TSParser()
	
	def is_ok( theName, theObject ):
		ok = isinstance( theObject, P_ENTITE.ENTITE ) or theName in SPECIAL
		return ok

	def name_to_attr( theName ):
		if theName=='into':
			return 'CHOIX'
		else:
			return theName.upper()
		
	def dico_tr( theObject, theName, theParentObj, theParentName ):
		#print "dicotr:", theObject, theName, theParentObj, theParentName
		aTrans = ''
		if theName in SPECIAL:
			if theObject!=None:
				#print theName, theObject
				anAttrTr = name_to_attr( theName )
				anAttr = anAttrTr + '1'
				if isinstance( theObject, basestring ):
					#print theParentName, theName, theObject, '=>',
					aTrans = DICO.translate( theParentName, '', theObject, anAttr, anAttrTr )
					#print aTrans
				elif isinstance( theObject, tuple ):
					#print theParentName, theName
					for anItem in theObject:
						#print anItem
						if isinstance( anItem, basestring ) and '=' in anItem:
							aList = DICO.convert_to_tuples( DICO.parse_tokens( anItem ) )
							#print "   ", aList
							for aListItem in aList:
								if isinstance( aListItem, tuple ):
									aKey, aValue = aListItem
									#print "     ", aValue, '=>', 
									aTrans = DICO.translate( theParentName, '', aValue, anAttr, anAttrTr )
									#print aTrans
					#print
					pass
					
		else:
			#print theName, '=>',
			aTrans = DICO.translate( theName, 'NOM' )
			#print aTrans
			
		aTrans = normalize( aTrans )
		return '', aTrans

	def sub( theObject ):
		aDict = {}
		if hasattr( theObject, 'entites' ):
			aDict = copy.copy( theObject.entites );
		for s in SPECIAL:
			if hasattr( theObject, s ):
				aDict[s] = getattr( theObject, s )
		return aDict
	
	PARSER.check_object = is_ok
	PARSER.translation = dico_tr
	PARSER.sub_objects = sub
	PARSER.parse( theCataFile, theTSFile )
	
	if len( theNotTranslatedFile ) > 0:
		PARSER.saveNotTranslated( theNotTranslatedFile )
	
	#print
	#print "Translations:"
	#for key, value in p.data[''].iteritems():
	#	print key, "=>", value

