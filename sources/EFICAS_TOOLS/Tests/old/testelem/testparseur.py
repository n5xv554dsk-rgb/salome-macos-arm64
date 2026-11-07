import unittest
import difflib

from convert import parseur_python

def cdiff(text1,text2):
        #return " ".join(difflib.unified_diff(text1.splitlines(1),text2.splitlines(1)))
        return " ".join(difflib.context_diff(text1.splitlines(1),text2.splitlines(1)))
        #return " ".join(difflib.ndiff(text1.splitlines(1),text2.splitlines(1)))

class appli:
      dict_reels={}
      liste_simp_reel=[]

class TestCase(unittest.TestCase):
    def test01(self):
        text="""
MA=LIRE_MAILLAGE()
"""
        expected="""MA=LIRE_MAILLAGE()

"""
        txt = parseur_python.PARSEUR_PYTHON(text).get_texte(appli())
        assert txt == expected, cdiff(expected,txt)

    def test02(self):
        text="""
MA=LIRE_MAILLAGE()
MB=LIRE_MAILLAGE()
"""
        expected="""MA=LIRE_MAILLAGE()

MB=LIRE_MAILLAGE()

"""
        txt = parseur_python.PARSEUR_PYTHON(text).get_texte(appli())
        assert txt == expected, cdiff(expected,txt)

    def test03(self):
        text="""
a=1.2
b=4
c="aa"
d=5 # parametre d
MA=LIRE_MAILLAGE()
MB=LIRE_MAILLAGE()
"""
        expected=r'''a = PARAMETRE(nom='a',valeur=1.2)
b = PARAMETRE(nom='b',valeur=4)
c = PARAMETRE(nom='c',valeur="aa")
COMMENTAIRE(' parametre d\n')
d = PARAMETRE(nom='d',valeur=5 )
MA=LIRE_MAILLAGE()

MB=LIRE_MAILLAGE()

'''
        txt = parseur_python.PARSEUR_PYTHON(text).get_texte(appli())
        assert txt == expected, cdiff(expected,txt)

    def test04(self):
        text='''
DEBUT();
a = 1.0;
b = 3;
c = 15;
d = 5;
x = (1, 2);
y = [3, 4];
y2 = (y * 2);
z = 'a';
zz = 'v';
t = a;
v = """aaaa
bbbb""";
xx = ceil(sqrt(d));
yy = cos(3.1);
ax = sin(2);
bx = cos(xx);
cx = sin(xx);
zy = y[1];
FIN();
'''
        expected='''DEBUT();

a = PARAMETRE(nom='a',valeur= 1.0)
b = PARAMETRE(nom='b',valeur= 3)
c = PARAMETRE(nom='c',valeur= 15)
d = PARAMETRE(nom='d',valeur= 5)
x = PARAMETRE(nom='x',valeur= (1, 2))
y = PARAMETRE(nom='y',valeur= [3, 4])
y2 = PARAMETRE(nom='y2',valeur= (y * 2))
z = PARAMETRE(nom='z',valeur= 'a')
zz = PARAMETRE(nom='zz',valeur= 'v')
t = PARAMETRE(nom='t',valeur= a)
v = PARAMETRE(nom='v',valeur= """aaaa
bbbb""")
xx = PARAMETRE(nom='xx',valeur= ceil(sqrt(d)))
yy = PARAMETRE(nom='yy',valeur= cos(3.1))
ax = PARAMETRE(nom='ax',valeur= sin(2))
bx = PARAMETRE(nom='bx',valeur= cos(xx))
cx = PARAMETRE(nom='cx',valeur= sin(xx))
zy = PARAMETRE(nom='zy',valeur= y[1])
FIN();

'''
        txt = parseur_python.PARSEUR_PYTHON(text).get_texte(appli())
        assert txt == expected, cdiff(expected,txt)
