
import shlex

DICO_EXT = '.dico'

class DicoParser:
	def __init__( self, theFileName, theStartAttr, theIndexAttr ):
		if theFileName=='':
			return
		if not theFileName.endswith( DICO_EXT ):
			theFileName += DICO_EXT
		aFile = open( theFileName )
		self.data = self.parse( aFile.read(), theStartAttr, theIndexAttr )
		aFile.close()
		
	def parse( self, theText, theStartAttr, theIndexAttr ):
		aTokenList = self.parse_tokens( theText )
		self.expand_values( aTokenList )
		aList = self.convert_to_tuples( aTokenList )
		return self.convert_to_blocks( aList, theStartAttr, theIndexAttr )
		
	def parse_tokens( self, theText ):
		theText = theText.replace( "''", "`" )
		aLexer = shlex.shlex( theText )
		aLexer.commenters = '/'
		aLexer.quotes = '\'"'
		aLexer.wordchars = aLexer.wordchars + '-.'
		aTokenList = []
		for aToken in aLexer:
			#print aToken
			if aToken[0]=="'" and aToken[-1]=="'":
				aToken = aToken[1:-1]
			elif aToken[0]=='"' and aToken[-1]=='"':
				aToken = aToken[1:-1]
			if aToken=='`':
				aToken = ''
			aToken = aToken.replace( "`", "'" )
			aToken = aToken.replace( "\n", "" )
			aToken = self.simplify_spaces( aToken )
			#print aToken
			aTokenList.append( aToken )
		return aTokenList

	def simplify_spaces( self, theToken ):
		return ' '.join( theToken.split() )

	def expand_values( self, theList ):
		for i in xrange( 0, len( theList ) ):
			if '=' in theList[i] and theList[i]!='=':
				aTokenList = self.parse_tokens( theList[i] )
				aSubItemsList = self.convert_to_tuples( aTokenList )
				if( len( aSubItemsList ) == 0 ):
					print theList[i]
				theList[i] = aSubItemsList[0] # we assume that only one '=' in the subitem

	def convert_to_tuples( self, theList ):
		aPairsList = []
		aKey = ''
		i = 0
		n = len( theList )
		while i<n:
			if theList[i]=='=' and i<n-1:
				aPairsList.append( (aKey, theList[i+1]) )
				i = i + 1
			elif theList[i]==';' and len( aPairsList ) > 0 and i<n-1:
				aKey, aValue = aPairsList[-1]
				if isinstance( aValue, list ):
					aValue.append( theList[i+1] )
				else:
					aValue = [aValue, theList[i+1]]
				aPairsList[-1] = ( aKey, aValue )
				i = i + 1
			else:
				aKey = theList[i]
			i = i + 1
		return aPairsList

	def convert_to_blocks( self, theTuples, theStartAttr, theIndexAttr ):
		aData = {}
		aBlockKey = ''
		aBlock = {}
		for aKey, aValue in theTuples:
			#print aKey
			if aKey==theStartAttr:
				#print "__start__"
				if len(aBlock)>0:
					aData[aBlockKey] = aBlock
				aBlockKey = ''
				aBlock = {}
			elif aKey==theIndexAttr:
				#print "__index__"
				aBlockKey = aValue
				#print aBlockKey
			aBlock[aKey] = aValue
			#print aData
		if len(aBlock)>0:
			aData[aBlockKey] = aBlock
		return aData

	def are_equal( self, theStrDico, theStrCata ):
		return theStrDico == self.to_dico_str( theStrCata )
		
	def to_dico_str( self, theStrCata ):
		aCata = theStrCata.replace( '_', ' ' )
		aCata = aCata.upper()
		return aCata

	def to_cata_str( self, theStrDico ):
		aWordsList = theStrDico.split()
		aCata = []
		for aWord in aWordsList:
			aWord = aWord.lower()
			aWord = aWord[0].upper() + aWord[1:]
			aCata.append( aWord )
		return ' '.join( aCata )
		
	def search_in_block( self, theBlock, theAttrTr ):
		#print 'search_in_block:', theAttrTr
		return theBlock[theAttrTr]
		
	def search( self, theIndexText, theAttrTr, theChoiceText, theAttrCh, theAttrChTr ):
		anIndexText = self.to_dico_str( theIndexText )
		if not anIndexText in self.data:
			return ''
		
		if theAttrCh=='':
			return self.search_in_block( self.data[anIndexText], theAttrTr )
			
		aDataCh = self.search_in_block( self.data[anIndexText], theAttrCh )
		aDataChTr = self.search_in_block( self.data[anIndexText], theAttrChTr )
		if isinstance( theChoiceText, basestring ):
			aChoiceText = self.to_dico_str( theChoiceText )
		else:
			aChoiceText = theChoiceText
		#print 'Choice text:', aChoiceText
		#print 'Choice data:', aDataCh
		#print 'Choice tr data:', aDataChTr
		if isinstance( aDataCh, basestring ) and aDataCh==aChoiceText:
			return aDataChTr
		
		for i in xrange( 0, len(aDataCh) ):
			if isinstance( aDataCh[i], tuple ):
				aKey, aValue = aDataCh[i]
			elif isinstance( aDataCh[i], basestring ):
				aKey = ''
				aValue = aDataCh[i]
			#print aKey, aValue
			if aValue==aChoiceText:
				if isinstance( aDataChTr[i], tuple ):
					aKeyTr, aValueTr = aDataChTr[i]
				elif isinstance( aDataChTr[i], basestring ):
					aKeyTr = ''
					aValueTr = aDataChTr[i]
				return aValueTr
		return ''

	def translate( self, theIndexText, theAttrTr, theChoiceText='', theAttrCh='', theAttrChTr='' ):
		aTrText = self.search( theIndexText, theAttrTr, theChoiceText, theAttrCh, theAttrChTr )
		#print aTrText
		return self.to_cata_str( aTrText )
