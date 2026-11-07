
import dicoparser
import unittest

class Test1( unittest.TestCase ):
    def runTest(self):
		d = dicoparser.DicoParser( '', '', '' )
		t = d.parse_tokens( """
  / comment
  TYPE = LOGIQUE
  INDEX = 23 
  MNEMO = 'VERLIM'
  MNEMO1 = ''
  NOM = 'CONTROLE DES LIMITES'
  RUBRIQUE1 = 'ENTREES-SORTIES, GENERALITES';'CONTROLE' 
  CHOIX1 = '0="list of tests"';  
  '1="gradient simple"'; 
  '2="conj gradient"'; 
  '3="Lagrange interp."'
  AIDE = 'UTILISER AVEC LE MOT-CLE : VALEURS LIMITES, LE PROGRAMME 
  S''ARRETE SI LES LIMITES SUR U,V,H OU T SONT DEPASSEES' 
  DEFAUT = -1000.;9000.;-1000. 
""" )
		self.assertEqual( len(t), 39 )
		self.assertEqual( t[0], 'TYPE' )
		self.assertEqual( t[1], '=' )
		self.assertEqual( t[2], 'LOGIQUE' )
		self.assertEqual( t[3], 'INDEX' )
		self.assertEqual( t[4], '=' )
		self.assertEqual( t[5], '23' )
		self.assertEqual( t[6], 'MNEMO' )
		self.assertEqual( t[7], '=' )
		self.assertEqual( t[8], 'VERLIM' )
		self.assertEqual( t[9], 'MNEMO1' )
		self.assertEqual( t[10], '=' )
		self.assertEqual( t[11], '' )
		self.assertEqual( t[12], 'NOM' )
		self.assertEqual( t[13], '=' )
		self.assertEqual( t[14], 'CONTROLE DES LIMITES' )
		self.assertEqual( t[15], 'RUBRIQUE1' )
		self.assertEqual( t[16], '=' )
		self.assertEqual( t[17], 'ENTREES-SORTIES, GENERALITES' )
		self.assertEqual( t[18], ';' )
		self.assertEqual( t[19], 'CONTROLE' )
		self.assertEqual( t[20], 'CHOIX1' )
		self.assertEqual( t[21], '=' )
		self.assertEqual( t[22], '0="list of tests"' )
		self.assertEqual( t[23], ';' )
		self.assertEqual( t[24], '1="gradient simple"' )
		self.assertEqual( t[25], ';' )
		self.assertEqual( t[26], '2="conj gradient"' )
		self.assertEqual( t[27], ';' )
		self.assertEqual( t[28], '3="Lagrange interp."' )
		self.assertEqual( t[29], 'AIDE' )
		self.assertEqual( t[30], '=' )
		self.assertEqual( t[31], 'UTILISER AVEC LE MOT-CLE : VALEURS LIMITES, LE PROGRAMME S\'ARRETE SI LES LIMITES SUR U,V,H OU T SONT DEPASSEES' )
		self.assertEqual( t[32], 'DEFAUT' )
		self.assertEqual( t[33], '=' )
		self.assertEqual( t[34], '-1000.' )
		self.assertEqual( t[35], ';' )
		self.assertEqual( t[36], '9000.' )
		self.assertEqual( t[37], ';' )
		self.assertEqual( t[38], '-1000.' )
		
		d.expand_values( t )
		self.assertEqual( t[24], ( '1', 'gradient simple' ) )
		self.assertEqual( t[26], ( '2', 'conj gradient' ) )
		self.assertEqual( t[28], ( '3', 'Lagrange interp.' ) )
		
		lst = d.convert_to_tuples( t )
		self.assertEqual( len(lst), 9 )
		self.assertEqual( lst[0], ( 'TYPE', 'LOGIQUE' ) )
		self.assertEqual( lst[1], ( 'INDEX', '23' ) )
		self.assertEqual( lst[2], ( 'MNEMO', 'VERLIM' ) )
		self.assertEqual( lst[3], ( 'MNEMO1', '' ) )
		self.assertEqual( lst[4], ( 'NOM', 'CONTROLE DES LIMITES' ) )
		self.assertEqual( lst[5], ( 'RUBRIQUE1', ['ENTREES-SORTIES, GENERALITES', 'CONTROLE'] ) )
		self.assertEqual( lst[6], ( 'CHOIX1', [('0','list of tests'), ('1','gradient simple'), ('2','conj gradient'), ('3','Lagrange interp.') ] ) )
		self.assertEqual( lst[7], ( 'AIDE', 'UTILISER AVEC LE MOT-CLE : VALEURS LIMITES, LE PROGRAMME S\'ARRETE SI LES LIMITES SUR U,V,H OU T SONT DEPASSEES' ) )
		self.assertEqual( lst[8], ( 'DEFAUT', ['-1000.', '9000.', '-1000.' ] ) )

class Test2( unittest.TestCase ):
    def runTest(self):
		d = dicoparser.DicoParser( '', '', '' )
		self.assertEqual( d.are_equal( 'WIND IN SUMMER', 'Wind_In_Summer' ), True )
		self.assertEqual( d.are_equal( 'HELLO', 'Bonjour' ), False )
		self.assertEqual( d.are_equal( 'MAXIMUM NUMBER OF ITERATIONS FOR SOLVER', 'Maximum_Number_Of_Iterations_For_Solver' ), True )
		#self.assertEqual( d.are_equal( 'WIND IN SUMMER', 'Wind' ), True ) #TODO: check the specification about this issue

class Test3( unittest.TestCase ):
    def runTest(self):
		d = dicoparser.DicoParser( 'test', 'NOM', 'NOM1' )
		#print d.data.keys()
		#for aKey, aValue in d.data['TYPE OF ADVECTION'].iteritems():
		#	print aKey, aValue 
		
		self.assertEqual( d.data['TYPE OF ADVECTION'].keys(), ['AIDE', 'NOM', 'DEFAUT1', 'INDEX', 'NIVEAU', 'TAILLE', 'CHOIX1', 'RUBRIQUE1', 'MNEMO', 'NOM1', 'AIDE1', 'COMPORT', 'DEFAUT', 'CHOIX', 'RUBRIQUE', 'TYPE' ] )
		self.assertEqual( d.translate( 'Control_Of_Limits', 'NOM' ), 'Controle Des Limites' )
		self.assertEqual( d.translate( 'Type_Of_Advection', 'NOM' ), 'Forme De La Convection' )
		self.assertEqual( d.translate( 'Type_Of_Advection', '', 'Characteristics', 'CHOIX1', 'CHOIX' ), 'Caracteristiques' )

class Test4( unittest.TestCase ):
    def runTest(self):
		d = dicoparser.DicoParser( 'telemac2dv6p3.dico', 'NOM', 'NOM1' )
		self.assertEqual( d.translate( 'Reference_File_Format', 'NOM' ), 'Format Du Fichier De Reference' )
		self.assertEqual( d.translate( 'Reference_File_Format', '', 'Serafin', 'CHOIX1', 'CHOIX' ), 'Serafin' )
		self.assertEqual( d.translate( 'Reference_File_Format', '', 'Serafin', 'DEFAUT1', 'DEFAUT' ), 'Serafin' )
		self.assertEqual( d.translate( 'Destination', '', 'CHE43A', 'DEFAUT1', 'DEFAUT' ), 'Che43a' )
		self.assertEqual( d.translate( 'Destination', '', 0.0, 'DEFAUT1', 'DEFAUT' ), '' )
		self.assertEqual( d.translate( 'Destination', '', (1,2,3), 'DEFAUT1', 'DEFAUT' ), '' )

class Test5( unittest.TestCase ):
    def runTest(self):
		d = dicoparser.DicoParser( '', '', '' )
		t = d.parse_tokens( """
CHOIX = '" "="pas de biliotheque"';
'"$PVM_ROOT/lib/$PVM_ARCH/libpvm3.a"="bibliotheque PVM1"' 
""" )
		self.assertEqual( len(t), 5 )
		self.assertEqual( t[0], 'CHOIX' )
		self.assertEqual( t[1], '=' )
		self.assertEqual( t[2], '" "="pas de biliotheque"' )
		self.assertEqual( t[3], ';' )
		self.assertEqual( t[4], '"$PVM_ROOT/lib/$PVM_ARCH/libpvm3.a"="bibliotheque PVM1"' )


t1 = Test1()
t1.runTest()

t2 = Test2()
t2.runTest()

t3 = Test3()
t3.runTest()

t4 = Test4()
t4.runTest()

t5 = Test5()
t5.runTest()
