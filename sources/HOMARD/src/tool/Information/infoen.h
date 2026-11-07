40000 format(61('*'))
40001 format(
     >  '*   ',a40,                                 '                *')
40002 format(
     >  '* . ',a50,                                           '      *')
c
40010 format(
     >  '* Maille numero :',i10,   ' dans le calcul                  *')
40030 format(
     >  '*   Il n''existe pas.                                        ',
     >  '*')
40031 format(
     >  '*   Elle n''existe pas.                                      ',
     >  '*')
40040 format(
     >  '*  Il n''existe pas dans le calcul                           ',
     >  '*')
40041 format(
     >  '*  Elle n''existe pas dans le calcul                         ',
     >  '*')
c
41010 format(
     >  '* . Son niveau est :',i7, '                                 *')
c
41011 format(
     >  '* . Son niveau est :',i7, '.5                               *')
c
42000 format(
     >  '* . Famille :      ',i7, '                                  *')
c
43310 format(
     >  '* . Ses faces et leurs codes sont :                         *')
43320 format(
     >  '* ',i10,   ' : ',i2,
     >                   ', ',a40,                                 ' *')
43030 format(
     >  '* . Ses aretes sont :                                       *')
43031 format(
     >  '* ',i10,   ', ',a40,                                 '      *')
43040 format(
     >  '* . Ses sommets sont :                                      *')
43050 format(
     >  '* . Les noeuds au milieu des aretes sont :                  *')
43060 format(
     >  '* . Le noeud central est : ',i10,   '                       *')
c
44010 format(
     >  '* . Pour l''iteration en cours :                             ',
     >  '*')
44020 format(
     >  '* . A l''iteration precedente :                              ',
     >  '*')
44030 format(
     >  '* . Coupe par les aretes',a36,                             '*')
44031 format(
     >  '* . Coupe par l''arete',a36,                            '   *')
c
c                               12345678901234
45010 format(
     >  '* . Il est le pere des ',a14       ,' :                     *')
45011 format(
     >  '* . Il est le pere du ',a14       ,' :                      *')
45012 format(
     >  '* . Il est le pere de l''',a14       ,' :                   *')
45013 format(
     >  '* . Il est le pere de la ',a14       ,' :                   *')
45019 format(
     >  '* . Elle est la mere de :                                   *')
c
45040 format(
     >  '* . Il est le fils du ',a14        ,i10,     '              *')
45041 format(
     >  '* . Il est le fils de l''',a14        ,i10,     '            ',
     >  '*')
45042 format(
     >  '* . Elle est la fille de la ',a14        ,i10,
     >  '            *')
45043 format(
     >  '* . Elle est la fille de l''',a14        ,i10,     '         ',
     >  '*')
45044 format(
     >  '* . Elle est la fille du ',a14        ,i10,     '           *')
45049 format(
     >  '* . Elle est la fille de ',i10,   '                         *')
c
45050 format(
     >  '* . Il est le frere des ',a14       ,' :                    *')
45051 format(
     >  '* . Il est le frere du ',a14       ,' :                     *')
45052 format(
     >  '* . Il est le frere de l''',a14       ,' :                  *')
45053 format(
     >  '* . Il est le frere de la ',a14       ,' :                  *')
45054 format(
     >  '* . Elle est la soeur des ',a14       ,' :                  *')
45059 format(
     >  '* . Elle est la soeur de ',i10,   '                         *')
45070 format(
     >  '*          ',i10,   ' ( inconnu dans le calcul )            *')
45080 format(
     >  '*          ',i10,   ' ( dans le calcul : ',i10,   ' )       *')
#ifdef _DEBUG_HOMARD_
45092 format(
     >  '* . Il est le fils adoptif de ',i10,   '                    *')
#endif
c
46000 format(
     >  '* ',i10,   ' : ',a40,                                 '     *')
46030 format(
     >  '* ',i10,   ' : par les aretes',a27,                    '    *')
46031 format(
     >  '* ',i10,   ' : Coupe par l''arete',a3,
     >  '                         *')
c
48010 format(
     >  '* . Il est homologue de lui-meme : axe de symetrie.         *')
48011 format(
     >  '* . Elle est homologue d''elle-meme : axe de symetrie.       ',
     >  '*')
48020 format(
     >  '* . Il est sur la face homologue ',i7, '                    *')
48021 format(
     >  '* . Elle est sur la face homologue ',i7, '                  *',
     >/,'* . Elle est homologue de l''arete :',i10,   '               ',
     >  '*')
48022 format(
     >  '*   Il est homologue du noeud : ',i10,   '                  *')
48023 format(
     >  '*   Il est homologue du triangle :',i10,   '                *')
48024 format(
     >  '*   Il est homologue du quadrangle :',i10,   '              *')
c
49001 format(
     >  '* . Centre  : ',   g15.5   ,'                               *')
49002 format(
     >  '* . Centre  : ',   g15.5    ,   g15.5     ,'                *')
49003 format(
     >  '* . Centre  : ',   g15.5    ,   g15.5     ,   g15.5      ,' *')
49004 format(
     >  '* . Normale : ',   g15.5    ,   g15.5     ,   g15.5      ,' *')
c
49010 format(
     >  '* . Longueur : ',   g15.5   ,'                              *')
49020 format(
     >  '* . Surface :  ',   g15.5   ,'                              *')
49030 format(
     >  '* . Volume :  ',   g15.5   ,'                               *')
49040 format(
     >  '* . Qualite : ',   f15.5   ,'                               *')
49041 format(
     >  '* . Qualite selon le Jacobien normalise : ',   f15.5   ,'   *')
49143 format(
     >  '* . Qualite selon la sphere inscrite    : ',   f15.5   ,'   *')
49146 format(
     >  '* . Qualite par les tetraedres internes : ',   f15.5   ,'   *')
49050 format(
     >  '* . Diametre : ',   g15.5   ,'                              *')
49060 format(
     >  '* . Torsion : ',   f15.5   ,'                               *')
c
50003 format(
     >  '*  ',i10,   ', ',i10,   ' et ',i10,   '                     *')
50004 format(
     >  '*  ',i10,   ', ',i10,   ', ',i10,   ' et ',i10,   '         *')
50005 format(
     >  '*  ',i10,   ', ',i10,   ', ',i10,   ' ,  ',i10,   '         *'
     >/,'*           et ',i10,   '                                   *')
50006 format(
     >  '*  ',i10,   ', ',i10,   ', ',i10,   ' ,  ',i10,   '         *'
     >/,'*  ',i10,   ' et ',i10,   '                                 *')
50008 format(
     >  '*  ',i10,   ', ',i10,   ', ',i10,   ' ,  ',i10,   '         *'
     >/,'*  ',i10,   ', ',i10,   ', ',i10,   ' et ',i10,   '         *')
50009 format(
     >  '*  ',i10,   ', ',i10,   ', ',i10,   ' ,  ',i10,   '         *'
     >/,'*  ',i10,   ', ',i10,   ', ',i10,   ' ,  ',i10,   '         *'
     >/,'*           et ',i10,   '                                   *')
50012 format(
     >  '*  ',i10,   ', ',i10,   ', ',i10,   ' ,  ',i10,   '         *'
     >/,'*  ',i10,   ', ',i10,   ', ',i10,   ' ,  ',i10,   '         *'
     >/,'*  ',i10,   ', ',i10,   ', ',i10,   ' et ',i10,   '         *')
c
