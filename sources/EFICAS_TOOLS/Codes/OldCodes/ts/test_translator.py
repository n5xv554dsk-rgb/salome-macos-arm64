#! /usr/bin/env python
import prefs

from translator import *
import unittest

class Test1( unittest.TestCase ):
    def runTest(self):
		self.assertEqual( normalize( 'a_b' ), 'a__b' )
		self.assertEqual( normalize( 'a b' ), 'a_b'  )
		self.assertEqual( normalize( 'a  b' ), 'a__b'  )
		self.assertEqual( normalize( 'a__b' ), 'a____b' )

t1 = Test1()
t1.runTest()

#translate( 'telemac2dv6p3', 'test_cata', 'test' )
#translate( 'telemac2dv6p3', 'Telemac_Cata_nouveau', 'test' )
translate( 'telemac2dv6p3', 'Telemac_Cata', 'main', 'not_translated.txt' )
