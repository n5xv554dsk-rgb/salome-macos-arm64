c
c L'indice est le code 'binaire' du decoupage. Pour chaque numero local
c d'arete, on affecte 1 ou 0 selon que l'arete est decoupee ou non.
c Le code binaire est contruit par la somme des puissances de 2 selon
c l'ordre croissant des numeros d'aretes. Par exemple, si les aretes
c 1, 2 et 5 sont coupees, le code vaut 2**0 + 2**1 + 2**4 = 19
c
c chnp1 : nombre de sommets a creer
c chnar : nombre d'aretes a creer
c chnpy : nombre de pyramides a creer
c chnte : nombre de tetraedres a creer
c chnhe : nombre d'hexaedres a creer
c chperm : code de la permutation pour aller sur la reference
c chbirf : code 'binaire' du decoupage de reference de la classe
c chetat : etat de l'hexaedre apres le decoupage
c chtn2i : type des noeuds P2 a interpoler
c charde : liste des aretes decoupees
c chclas : la classe d'equivalence concernee
c
c chbiet : code binaire pour un etat de l'hexaedre
c
      do 12345 , iaux = 0 , 4096
        chnp1(iaux) = -1
        chnar(iaux) = -1
        chnpy(iaux) = -1
        chnte(iaux) = -1
        chnhe(iaux) = -1
        chperm(iaux) = -1
        chbirf(iaux) = -1
        chetat(iaux) = -1
        chtn2i(iaux) = -1
        charde(iaux) = '                                    '
c                       123456789012345678901234567890123456
        chclas(iaux) = '     '
12345 continue
      do 12346 , iaux = 0 , 1000
        chbiet(iaux) = -1
12346 continue
c
c ===========================================
c hexaedre decoupe dont au moins un des fils est decoupe
c
      chbiet(9) = 4095
c
c ===========================================
c Classe d'equivalence  0-00
c
c Pas de decoupage
      chnp1 (0) = 0
      chnar (0) = 0
      chnpy (0) = 0
      chnte (0) = 0
      chnhe (0) = 0
      chperm (0) = 0
      chbirf (0) = 0
      chetat (0) = 0
      chtn2i (0) = 1
      chbiet (0) = 0
c
c ===========================================
c Classe d'equivalence  1-00
c
c Aretes coupees :   1
      chclas (1) = ' 1-00'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      charde (1)(1:3) = '  1'
      chnp1 (1) = 0
      chnar (1) = 2
      chnpy (1) = 4
      chnte (1) = 0
      chnhe (1) = 0
      chperm (1) = 0
      chbirf (1) = 1
      chetat (1) = 11
      chtn2i (1) = 11
      chbiet (11) = 1
c
c Aretes coupees :   2
      chclas (2) = ' 1-00'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      charde (2)(1:3) = '  2'
      chnp1 (2) = 0
      chnar (2) = 2
      chnpy (2) = 4
      chnte (2) = 0
      chnhe (2) = 0
      chperm (2) = 330
      chbirf (2) = 1
      chetat (2) = 12
      chtn2i (2) = 11
      chbiet (12) = 2
c
c Aretes coupees :   3
      chclas (4) = ' 1-00'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
      charde (4)(1:3) = '  3'
      chnp1 (4) = 0
      chnar (4) = 2
      chnpy (4) = 4
      chnte (4) = 0
      chnhe (4) = 0
      chperm (4) = 310
      chbirf (4) = 1
      chetat (4) = 13
      chtn2i (4) = 11
      chbiet (13) = 4
c
c Aretes coupees :   4
      chclas (8) = ' 1-00'
c Code des aretes coupees : 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0
      charde (8)(1:3) = '  4'
      chnp1 (8) = 0
      chnar (8) = 2
      chnpy (8) = 4
      chnte (8) = 0
      chnhe (8) = 0
      chperm (8) = 300
      chbirf (8) = 1
      chetat (8) = 14
      chtn2i (8) = 11
      chbiet (14) = 8
c
c Aretes coupees :   5
      chclas (16) = ' 1-00'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
      charde (16)(1:3) = '  5'
      chnp1 (16) = 0
      chnar (16) = 2
      chnpy (16) = 4
      chnte (16) = 0
      chnhe (16) = 0
      chperm (16) = 30
      chbirf (16) = 1
      chetat (16) = 15
      chtn2i (16) = 11
      chbiet (15) = 16
c
c Aretes coupees :   6
      chclas (32) = ' 1-00'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0
      charde (32)(1:3) = '  6'
      chnp1 (32) = 0
      chnar (32) = 2
      chnpy (32) = 4
      chnte (32) = 0
      chnhe (32) = 0
      chperm (32) = 10
      chbirf (32) = 1
      chetat (32) = 16
      chtn2i (32) = 11
      chbiet (16) = 32
c
c Aretes coupees :   7
      chclas (64) = ' 1-00'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0
      charde (64)(1:3) = '  7'
      chnp1 (64) = 0
      chnar (64) = 2
      chnpy (64) = 4
      chnte (64) = 0
      chnhe (64) = 0
      chperm (64) = 230
      chbirf (64) = 1
      chetat (64) = 17
      chtn2i (64) = 11
      chbiet (17) = 64
c
c Aretes coupees :   8
      chclas (128) = ' 1-00'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0
      charde (128)(1:3) = '  8'
      chnp1 (128) = 0
      chnar (128) = 2
      chnpy (128) = 4
      chnte (128) = 0
      chnhe (128) = 0
      chperm (128) = 210
      chbirf (128) = 1
      chetat (128) = 18
      chtn2i (128) = 11
      chbiet (18) = 128
c
c Aretes coupees :   9
      chclas (256) = ' 1-00'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0
      charde (256)(1:3) = '  9'
      chnp1 (256) = 0
      chnar (256) = 2
      chnpy (256) = 4
      chnte (256) = 0
      chnhe (256) = 0
      chperm (256) = 100
      chbirf (256) = 1
      chetat (256) = 19
      chtn2i (256) = 11
      chbiet (19) = 256
c
c Aretes coupees :  10
      chclas (512) = ' 1-00'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0
      charde (512)(1:3) = ' 10'
      chnp1 (512) = 0
      chnar (512) = 2
      chnpy (512) = 4
      chnte (512) = 0
      chnhe (512) = 0
      chperm (512) = 130
      chbirf (512) = 1
      chetat (512) = 20
      chtn2i (512) = 11
      chbiet (20) = 512
c
c Aretes coupees :  11
      chclas (1024) = ' 1-00'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0
      charde (1024)(1:3) = ' 11'
      chnp1 (1024) = 0
      chnar (1024) = 2
      chnpy (1024) = 4
      chnte (1024) = 0
      chnhe (1024) = 0
      chperm (1024) = 110
      chbirf (1024) = 1
      chetat (1024) = 21
      chtn2i (1024) = 11
      chbiet (21) = 1024
c
c Aretes coupees :  12
      chclas (2048) = ' 1-00'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
      charde (2048)(1:3) = ' 12'
      chnp1 (2048) = 0
      chnar (2048) = 2
      chnpy (2048) = 4
      chnte (2048) = 0
      chnhe (2048) = 0
      chperm (2048) = 200
      chbirf (2048) = 1
      chetat (2048) = 22
      chtn2i (2048) = 11
      chbiet (22) = 2048
c
c ===========================================
c Classe d'equivalence  2-00
c
c Aretes coupees :   1  7
      chclas (65) = ' 2-00'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0
      charde (65)(1:6) = '  1  7'
      chnp1 (65) = 1
      chnar (65) = 10
      chnpy (65) = 2
      chnte (65) = 12
      chnhe (65) = 0
      chperm (65) = 0
      chbirf (65) = 65
      chetat (65) = 23
      chtn2i (65) = 70
      chbiet (23) = 65
c
c Aretes coupees :   1 11
      chclas (1025) = ' 2-00'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0
      charde (1025)(1:6) = '  1 11'
      chnp1 (1025) = 1
      chnar (1025) = 10
      chnpy (1025) = 2
      chnte (1025) = 12
      chnhe (1025) = 0
      chperm (1025) = 110
      chbirf (1025) = 65
      chetat (1025) = 24
      chtn2i (1025) = 70
      chbiet (24) = 1025
c
c Aretes coupees :   2  8
      chclas (130) = ' 2-00'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0
      charde (130)(1:6) = '  2  8'
      chnp1 (130) = 1
      chnar (130) = 10
      chnpy (130) = 2
      chnte (130) = 12
      chnhe (130) = 0
      chperm (130) = 1
      chbirf (130) = 65
      chetat (130) = 25
      chtn2i (130) = 70
      chbiet (25) = 130
c
c Aretes coupees :   2  9
      chclas (258) = ' 2-00'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0
      charde (258)(1:6) = '  2  9'
      chnp1 (258) = 1
      chnar (258) = 10
      chnpy (258) = 2
      chnte (258) = 12
      chnhe (258) = 0
      chperm (258) = 100
      chbirf (258) = 65
      chetat (258) = 26
      chtn2i (258) = 70
      chbiet (26) = 258
c
c Aretes coupees :   3  5
      chclas (20) = ' 2-00'
c Code des aretes coupees : 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0
      charde (20)(1:6) = '  3  5'
      chnp1 (20) = 1
      chnar (20) = 10
      chnpy (20) = 2
      chnte (20) = 12
      chnhe (20) = 0
      chperm (20) = 101
      chbirf (20) = 65
      chetat (20) = 27
      chtn2i (20) = 70
      chbiet (27) = 20
c
c Aretes coupees :   3 12
      chclas (2052) = ' 2-00'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1
      charde (2052)(1:6) = '  3 12'
      chnp1 (2052) = 1
      chnar (2052) = 10
      chnpy (2052) = 2
      chnte (2052) = 12
      chnhe (2052) = 0
      chperm (2052) = 310
      chbirf (2052) = 65
      chetat (2052) = 28
      chtn2i (2052) = 70
      chbiet (28) = 2052
c
c Aretes coupees :   4  6
      chclas (40) = ' 2-00'
c Code des aretes coupees : 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0
      charde (40)(1:6) = '  4  6'
      chnp1 (40) = 1
      chnar (40) = 10
      chnpy (40) = 2
      chnte (40) = 12
      chnhe (40) = 0
      chperm (40) = 10
      chbirf (40) = 65
      chetat (40) = 29
      chtn2i (40) = 70
      chbiet (29) = 40
c
c Aretes coupees :   4 10
      chclas (520) = ' 2-00'
c Code des aretes coupees : 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0
      charde (520)(1:6) = '  4 10'
      chnp1 (520) = 1
      chnar (520) = 10
      chnpy (520) = 2
      chnte (520) = 12
      chnhe (520) = 0
      chperm (520) = 300
      chbirf (520) = 65
      chetat (520) = 30
      chtn2i (520) = 70
      chbiet (30) = 520
c
c Aretes coupees :   5 12
      chclas (2064) = ' 2-00'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1
      charde (2064)(1:6) = '  5 12'
      chnp1 (2064) = 1
      chnar (2064) = 10
      chnpy (2064) = 2
      chnte (2064) = 12
      chnhe (2064) = 0
      chperm (2064) = 200
      chbirf (2064) = 65
      chetat (2064) = 31
      chtn2i (2064) = 70
      chbiet (31) = 2064
c
c Aretes coupees :   6 10
      chclas (544) = ' 2-00'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0
      charde (544)(1:6) = '  6 10'
      chnp1 (544) = 1
      chnar (544) = 10
      chnpy (544) = 2
      chnte (544) = 12
      chnhe (544) = 0
      chperm (544) = 201
      chbirf (544) = 65
      chetat (544) = 32
      chtn2i (544) = 70
      chbiet (32) = 544
c
c Aretes coupees :   7 11
      chclas (1088) = ' 2-00'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0
      charde (1088)(1:6) = '  7 11'
      chnp1 (1088) = 1
      chnar (1088) = 10
      chnpy (1088) = 2
      chnte (1088) = 12
      chnhe (1088) = 0
      chperm (1088) = 301
      chbirf (1088) = 65
      chetat (1088) = 33
      chtn2i (1088) = 70
      chbiet (33) = 1088
c
c Aretes coupees :   8  9
      chclas (384) = ' 2-00'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0
      charde (384)(1:6) = '  8  9'
      chnp1 (384) = 1
      chnar (384) = 10
      chnpy (384) = 2
      chnte (384) = 12
      chnhe (384) = 0
      chperm (384) = 210
      chbirf (384) = 65
      chetat (384) = 34
      chtn2i (384) = 70
      chbiet (34) = 384
c
c ===========================================
c Classe d'equivalence  2-01
c
c Aretes coupees :   1  8
      chclas (129) = ' 2-01'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0
      charde (129)(1:6) = '  1  8'
      chnp1 (129) = 1
      chnar (129) = 10
      chnpy (129) = 2
      chnte (129) = 12
      chnhe (129) = 0
      chperm (129) = 0
      chbirf (129) = 129
      chetat (129) = 35
      chtn2i (129) = 70
      chbiet (35) = 129
c
c Aretes coupees :   1 10
      chclas (513) = ' 2-01'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0
      charde (513)(1:6) = '  1 10'
      chnp1 (513) = 1
      chnar (513) = 10
      chnpy (513) = 2
      chnte (513) = 12
      chnhe (513) = 0
      chperm (513) = 320
      chbirf (513) = 129
      chetat (513) = 36
      chtn2i (513) = 70
      chbiet (36) = 513
c
c Aretes coupees :   2  6
      chclas (34) = ' 2-01'
c Code des aretes coupees : 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0
      charde (34)(1:6) = '  2  6'
      chnp1 (34) = 1
      chnar (34) = 10
      chnpy (34) = 2
      chnte (34) = 12
      chnhe (34) = 0
      chperm (34) = 1
      chbirf (34) = 129
      chetat (34) = 37
      chtn2i (34) = 70
      chbiet (37) = 34
c
c Aretes coupees :   2 12
      chclas (2050) = ' 2-01'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
      charde (2050)(1:6) = '  2 12'
      chnp1 (2050) = 1
      chnar (2050) = 10
      chnpy (2050) = 2
      chnte (2050) = 12
      chnhe (2050) = 0
      chperm (2050) = 120
      chbirf (2050) = 129
      chetat (2050) = 38
      chtn2i (2050) = 70
      chbiet (38) = 2050
c
c Aretes coupees :   3  7
      chclas (68) = ' 2-01'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0
      charde (68)(1:6) = '  3  7'
      chnp1 (68) = 1
      chnar (68) = 10
      chnpy (68) = 2
      chnte (68) = 12
      chnhe (68) = 0
      chperm (68) = 301
      chbirf (68) = 129
      chetat (68) = 39
      chtn2i (68) = 70
      chbiet (39) = 68
c
c Aretes coupees :   3  9
      chclas (260) = ' 2-01'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0
      charde (260)(1:6) = '  3  9'
      chnp1 (260) = 1
      chnar (260) = 10
      chnpy (260) = 2
      chnte (260) = 12
      chnhe (260) = 0
      chperm (260) = 100
      chbirf (260) = 129
      chetat (260) = 40
      chtn2i (260) = 70
      chbiet (40) = 260
c
c Aretes coupees :   4  5
      chclas (24) = ' 2-01'
c Code des aretes coupees : 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0
      charde (24)(1:6) = '  4  5'
      chnp1 (24) = 1
      chnar (24) = 10
      chnpy (24) = 2
      chnte (24) = 12
      chnhe (24) = 0
      chperm (24) = 220
      chbirf (24) = 129
      chetat (24) = 41
      chtn2i (24) = 70
      chbiet (41) = 24
c
c Aretes coupees :   4 11
      chclas (1032) = ' 2-01'
c Code des aretes coupees : 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0
      charde (1032)(1:6) = '  4 11'
      chnp1 (1032) = 1
      chnar (1032) = 10
      chnpy (1032) = 2
      chnte (1032) = 12
      chnhe (1032) = 0
      chperm (1032) = 300
      chbirf (1032) = 129
      chetat (1032) = 42
      chtn2i (1032) = 70
      chbiet (42) = 1032
c
c Aretes coupees :   5 11
      chclas (1040) = ' 2-01'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0
      charde (1040)(1:6) = '  5 11'
      chnp1 (1040) = 1
      chnar (1040) = 10
      chnpy (1040) = 2
      chnte (1040) = 12
      chnhe (1040) = 0
      chperm (1040) = 101
      chbirf (1040) = 129
      chetat (1040) = 43
      chtn2i (1040) = 70
      chbiet (43) = 1040
c
c Aretes coupees :   6 12
      chclas (2080) = ' 2-01'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1
      charde (2080)(1:6) = '  6 12'
      chnp1 (2080) = 1
      chnar (2080) = 10
      chnpy (2080) = 2
      chnte (2080) = 12
      chnhe (2080) = 0
      chperm (2080) = 200
      chbirf (2080) = 129
      chetat (2080) = 44
      chtn2i (2080) = 70
      chbiet (44) = 2080
c
c Aretes coupees :   7  9
      chclas (320) = ' 2-01'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0
      charde (320)(1:6) = '  7  9'
      chnp1 (320) = 1
      chnar (320) = 10
      chnpy (320) = 2
      chnte (320) = 12
      chnhe (320) = 0
      chperm (320) = 20
      chbirf (320) = 129
      chetat (320) = 45
      chtn2i (320) = 70
      chbiet (45) = 320
c
c Aretes coupees :   8 10
      chclas (640) = ' 2-01'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0
      charde (640)(1:6) = '  8 10'
      chnp1 (640) = 1
      chnar (640) = 10
      chnpy (640) = 2
      chnte (640) = 12
      chnhe (640) = 0
      chperm (640) = 201
      chbirf (640) = 129
      chetat (640) = 46
      chtn2i (640) = 70
      chbiet (46) = 640
c
c ===========================================
c Classe d'equivalence  2-02
c
c Aretes coupees :   1 12
      chclas (2049) = ' 2-02'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
      charde (2049)(1:6) = '  1 12'
      chnp1 (2049) = 1
      chnar (2049) = 10
      chnpy (2049) = 2
      chnte (2049) = 12
      chnhe (2049) = 0
      chperm (2049) = 0
      chbirf (2049) = 2049
      chetat (2049) = 47
      chtn2i (2049) = 70
      chbiet (47) = 2049
c
c Aretes coupees :   2 11
      chclas (1026) = ' 2-02'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0
      charde (1026)(1:6) = '  2 11'
      chnp1 (1026) = 1
      chnar (1026) = 10
      chnpy (1026) = 2
      chnte (1026) = 12
      chnhe (1026) = 0
      chperm (1026) = 110
      chbirf (1026) = 2049
      chetat (1026) = 48
      chtn2i (1026) = 70
      chbiet (48) = 1026
c
c Aretes coupees :   3 10
      chclas (516) = ' 2-02'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0
      charde (516)(1:6) = '  3 10'
      chnp1 (516) = 1
      chnar (516) = 10
      chnpy (516) = 2
      chnte (516) = 12
      chnhe (516) = 0
      chperm (516) = 310
      chbirf (516) = 2049
      chetat (516) = 49
      chtn2i (516) = 70
      chbiet (49) = 516
c
c Aretes coupees :   4  9
      chclas (264) = ' 2-02'
c Code des aretes coupees : 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0
      charde (264)(1:6) = '  4  9'
      chnp1 (264) = 1
      chnar (264) = 10
      chnpy (264) = 2
      chnte (264) = 12
      chnhe (264) = 0
      chperm (264) = 100
      chbirf (264) = 2049
      chetat (264) = 50
      chtn2i (264) = 70
      chbiet (50) = 264
c
c Aretes coupees :   5  8
      chclas (144) = ' 2-02'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0
      charde (144)(1:6) = '  5  8'
      chnp1 (144) = 1
      chnar (144) = 10
      chnpy (144) = 2
      chnte (144) = 12
      chnhe (144) = 0
      chperm (144) = 210
      chbirf (144) = 2049
      chetat (144) = 51
      chtn2i (144) = 70
      chbiet (51) = 144
c
c Aretes coupees :   6  7
      chclas (96) = ' 2-02'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0
      charde (96)(1:6) = '  6  7'
      chnp1 (96) = 1
      chnar (96) = 10
      chnpy (96) = 2
      chnte (96) = 12
      chnhe (96) = 0
      chperm (96) = 10
      chbirf (96) = 2049
      chetat (96) = 52
      chtn2i (96) = 70
      chbiet (52) = 96
c
c ===========================================
c Classe d'equivalence  2-03
c
c Aretes coupees :   1  2
      chclas (3) = ' 2-03'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      charde (3)(1:6) = '  1  2'
      chnp1 (3) = 1
      chnar (3) = 11
      chnpy (3) = 6
      chnte (3) = 6
      chnhe (3) = 0
      chperm (3) = 0
      chbirf (3) = 3
      chetat (3) = 53
      chtn2i (3) = 210
      chbiet (53) = 3
c
c Aretes coupees :   1  3
      chclas (5) = ' 2-03'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
      charde (5)(1:6) = '  1  3'
      chnp1 (5) = 1
      chnar (5) = 11
      chnpy (5) = 6
      chnte (5) = 6
      chnhe (5) = 0
      chperm (5) = 221
      chbirf (5) = 3
      chetat (5) = 54
      chtn2i (5) = 210
      chbiet (54) = 5
c
c Aretes coupees :   1  5
      chclas (17) = ' 2-03'
c Code des aretes coupees : 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
      charde (17)(1:6) = '  1  5'
      chnp1 (17) = 1
      chnar (17) = 11
      chnpy (17) = 6
      chnte (17) = 6
      chnhe (17) = 0
      chperm (17) = 101
      chbirf (17) = 3
      chetat (17) = 55
      chtn2i (17) = 210
      chbiet (55) = 17
c
c Aretes coupees :   1  6
      chclas (33) = ' 2-03'
c Code des aretes coupees : 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0
      charde (33)(1:6) = '  1  6'
      chnp1 (33) = 1
      chnar (33) = 11
      chnpy (33) = 6
      chnte (33) = 6
      chnhe (33) = 0
      chperm (33) = 320
      chbirf (33) = 3
      chetat (33) = 56
      chtn2i (33) = 210
      chbiet (56) = 33
c
c Aretes coupees :   2  4
      chclas (10) = ' 2-03'
c Code des aretes coupees : 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0
      charde (10)(1:6) = '  2  4'
      chnp1 (10) = 1
      chnar (10) = 11
      chnpy (10) = 6
      chnte (10) = 6
      chnhe (10) = 0
      chperm (10) = 1
      chbirf (10) = 3
      chetat (10) = 57
      chtn2i (10) = 210
      chbiet (57) = 10
c
c Aretes coupees :   2  5
      chclas (18) = ' 2-03'
c Code des aretes coupees : 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
      charde (18)(1:6) = '  2  5'
      chnp1 (18) = 1
      chnar (18) = 11
      chnpy (18) = 6
      chnte (18) = 6
      chnhe (18) = 0
      chperm (18) = 330
      chbirf (18) = 3
      chetat (18) = 58
      chtn2i (18) = 210
      chbiet (58) = 18
c
c Aretes coupees :   2  7
      chclas (66) = ' 2-03'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0
      charde (66)(1:6) = '  2  7'
      chnp1 (66) = 1
      chnar (66) = 11
      chnpy (66) = 6
      chnte (66) = 6
      chnhe (66) = 0
      chperm (66) = 230
      chbirf (66) = 3
      chetat (66) = 59
      chtn2i (66) = 210
      chbiet (59) = 66
c
c Aretes coupees :   3  4
      chclas (12) = ' 2-03'
c Code des aretes coupees : 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0
      charde (12)(1:6) = '  3  4'
      chnp1 (12) = 1
      chnar (12) = 11
      chnpy (12) = 6
      chnte (12) = 6
      chnhe (12) = 0
      chperm (12) = 220
      chbirf (12) = 3
      chetat (12) = 60
      chtn2i (12) = 210
      chbiet (60) = 12
c
c Aretes coupees :   3  6
      chclas (36) = ' 2-03'
c Code des aretes coupees : 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0
      charde (36)(1:6) = '  3  6'
      chnp1 (36) = 1
      chnar (36) = 11
      chnpy (36) = 6
      chnte (36) = 6
      chnhe (36) = 0
      chperm (36) = 10
      chbirf (36) = 3
      chetat (36) = 61
      chtn2i (36) = 210
      chbiet (61) = 36
c
c Aretes coupees :   3  8
      chclas (132) = ' 2-03'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0
      charde (132)(1:6) = '  3  8'
      chnp1 (132) = 1
      chnar (132) = 11
      chnpy (132) = 6
      chnte (132) = 6
      chnhe (132) = 0
      chperm (132) = 310
      chbirf (132) = 3
      chetat (132) = 62
      chtn2i (132) = 210
      chbiet (62) = 132
c
c Aretes coupees :   4  7
      chclas (72) = ' 2-03'
c Code des aretes coupees : 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0
      charde (72)(1:6) = '  4  7'
      chnp1 (72) = 1
      chnar (72) = 11
      chnpy (72) = 6
      chnte (72) = 6
      chnhe (72) = 0
      chperm (72) = 300
      chbirf (72) = 3
      chetat (72) = 63
      chtn2i (72) = 210
      chbiet (63) = 72
c
c Aretes coupees :   4  8
      chclas (136) = ' 2-03'
c Code des aretes coupees : 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0
      charde (136)(1:6) = '  4  8'
      chnp1 (136) = 1
      chnar (136) = 11
      chnpy (136) = 6
      chnte (136) = 6
      chnhe (136) = 0
      chperm (136) = 121
      chbirf (136) = 3
      chetat (136) = 64
      chtn2i (136) = 210
      chbiet (64) = 136
c
c Aretes coupees :   5  9
      chclas (272) = ' 2-03'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0
      charde (272)(1:6) = '  5  9'
      chnp1 (272) = 1
      chnar (272) = 11
      chnpy (272) = 6
      chnte (272) = 6
      chnhe (272) = 0
      chperm (272) = 100
      chbirf (272) = 3
      chetat (272) = 65
      chtn2i (272) = 210
      chbiet (65) = 272
c
c Aretes coupees :   5 10
      chclas (528) = ' 2-03'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0
      charde (528)(1:6) = '  5 10'
      chnp1 (528) = 1
      chnar (528) = 11
      chnpy (528) = 6
      chnte (528) = 6
      chnhe (528) = 0
      chperm (528) = 30
      chbirf (528) = 3
      chetat (528) = 66
      chtn2i (528) = 210
      chbiet (66) = 528
c
c Aretes coupees :   6  9
      chclas (288) = ' 2-03'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0
      charde (288)(1:6) = '  6  9'
      chnp1 (288) = 1
      chnar (288) = 11
      chnpy (288) = 6
      chnte (288) = 6
      chnhe (288) = 0
      chperm (288) = 321
      chbirf (288) = 3
      chetat (288) = 67
      chtn2i (288) = 210
      chbiet (67) = 288
c
c Aretes coupees :   6 11
      chclas (1056) = ' 2-03'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0
      charde (1056)(1:6) = '  6 11'
      chnp1 (1056) = 1
      chnar (1056) = 11
      chnpy (1056) = 6
      chnte (1056) = 6
      chnhe (1056) = 0
      chperm (1056) = 110
      chbirf (1056) = 3
      chetat (1056) = 68
      chtn2i (1056) = 210
      chbiet (68) = 1056
c
c Aretes coupees :   7 10
      chclas (576) = ' 2-03'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0
      charde (576)(1:6) = '  7 10'
      chnp1 (576) = 1
      chnar (576) = 11
      chnpy (576) = 6
      chnte (576) = 6
      chnhe (576) = 0
      chperm (576) = 130
      chbirf (576) = 3
      chetat (576) = 69
      chtn2i (576) = 210
      chbiet (69) = 576
c
c Aretes coupees :   7 12
      chclas (2112) = ' 2-03'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1
      charde (2112)(1:6) = '  7 12'
      chnp1 (2112) = 1
      chnar (2112) = 11
      chnpy (2112) = 6
      chnte (2112) = 6
      chnhe (2112) = 0
      chperm (2112) = 301
      chbirf (2112) = 3
      chetat (2112) = 70
      chtn2i (2112) = 210
      chbiet (70) = 2112
c
c Aretes coupees :   8 11
      chclas (1152) = ' 2-03'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0
      charde (1152)(1:6) = '  8 11'
      chnp1 (1152) = 1
      chnar (1152) = 11
      chnpy (1152) = 6
      chnte (1152) = 6
      chnhe (1152) = 0
      chperm (1152) = 210
      chbirf (1152) = 3
      chetat (1152) = 71
      chtn2i (1152) = 210
      chbiet (71) = 1152
c
c Aretes coupees :   8 12
      chclas (2176) = ' 2-03'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1
      charde (2176)(1:6) = '  8 12'
      chnp1 (2176) = 1
      chnar (2176) = 11
      chnpy (2176) = 6
      chnte (2176) = 6
      chnhe (2176) = 0
      chperm (2176) = 120
      chbirf (2176) = 3
      chetat (2176) = 72
      chtn2i (2176) = 210
      chbiet (72) = 2176
c
c Aretes coupees :   9 10
      chclas (768) = ' 2-03'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0
      charde (768)(1:6) = '  9 10'
      chnp1 (768) = 1
      chnar (768) = 11
      chnpy (768) = 6
      chnte (768) = 6
      chnhe (768) = 0
      chperm (768) = 201
      chbirf (768) = 3
      chetat (768) = 73
      chtn2i (768) = 210
      chbiet (73) = 768
c
c Aretes coupees :   9 11
      chclas (1280) = ' 2-03'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0
      charde (1280)(1:6) = '  9 11'
      chnp1 (1280) = 1
      chnar (1280) = 11
      chnpy (1280) = 6
      chnte (1280) = 6
      chnhe (1280) = 0
      chperm (1280) = 20
      chbirf (1280) = 3
      chetat (1280) = 74
      chtn2i (1280) = 210
      chbiet (74) = 1280
c
c Aretes coupees :  10 12
      chclas (2560) = ' 2-03'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1
      charde (2560)(1:6) = ' 10 12'
      chnp1 (2560) = 1
      chnar (2560) = 11
      chnpy (2560) = 6
      chnte (2560) = 6
      chnhe (2560) = 0
      chperm (2560) = 200
      chbirf (2560) = 3
      chetat (2560) = 75
      chtn2i (2560) = 210
      chbiet (75) = 2560
c
c Aretes coupees :  11 12
      chclas (3072) = ' 2-03'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1
      charde (3072)(1:6) = ' 11 12'
      chnp1 (3072) = 1
      chnar (3072) = 11
      chnpy (3072) = 6
      chnte (3072) = 6
      chnhe (3072) = 0
      chperm (3072) = 21
      chbirf (3072) = 3
      chetat (3072) = 76
      chtn2i (3072) = 210
      chbiet (76) = 3072
c
c ===========================================
c Classe d'equivalence  2-04
c
c Aretes coupees :   1  4
      chclas (9) = ' 2-04'
c Code des aretes coupees : 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0
      charde (9)(1:6) = '  1  4'
      chnp1 (9) = 1
      chnar (9) = 10
      chnpy (9) = 5
      chnte (9) = 6
      chnhe (9) = 0
      chperm (9) = 0
      chbirf (9) = 9
      chetat (9) = 77
      chtn2i (9) = 10
      chbiet (77) = 9
c
c Aretes coupees :   1  9
      chclas (257) = ' 2-04'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0
      charde (257)(1:6) = '  1  9'
      chnp1 (257) = 1
      chnar (257) = 10
      chnpy (257) = 5
      chnte (257) = 6
      chnhe (257) = 0
      chperm (257) = 100
      chbirf (257) = 9
      chetat (257) = 78
      chtn2i (257) = 10
      chbiet (78) = 257
c
c Aretes coupees :   2  3
      chclas (6) = ' 2-04'
c Code des aretes coupees : 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
      charde (6)(1:6) = '  2  3'
      chnp1 (6) = 1
      chnar (6) = 10
      chnpy (6) = 5
      chnte (6) = 6
      chnhe (6) = 0
      chperm (6) = 1
      chbirf (6) = 9
      chetat (6) = 79
      chtn2i (6) = 10
      chbiet (79) = 6
c
c Aretes coupees :   2 10
      chclas (514) = ' 2-04'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0
      charde (514)(1:6) = '  2 10'
      chnp1 (514) = 1
      chnar (514) = 10
      chnpy (514) = 5
      chnte (514) = 6
      chnhe (514) = 0
      chperm (514) = 130
      chbirf (514) = 9
      chetat (514) = 80
      chtn2i (514) = 10
      chbiet (80) = 514
c
c Aretes coupees :   3 11
      chclas (1028) = ' 2-04'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0
      charde (1028)(1:6) = '  3 11'
      chnp1 (1028) = 1
      chnar (1028) = 10
      chnpy (1028) = 5
      chnte (1028) = 6
      chnhe (1028) = 0
      chperm (1028) = 110
      chbirf (1028) = 9
      chetat (1028) = 81
      chtn2i (1028) = 10
      chbiet (81) = 1028
c
c Aretes coupees :   4 12
      chclas (2056) = ' 2-04'
c Code des aretes coupees : 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1
      charde (2056)(1:6) = '  4 12'
      chnp1 (2056) = 1
      chnar (2056) = 10
      chnpy (2056) = 5
      chnte (2056) = 6
      chnhe (2056) = 0
      chperm (2056) = 300
      chbirf (2056) = 9
      chetat (2056) = 82
      chtn2i (2056) = 10
      chbiet (82) = 2056
c
c Aretes coupees :   5  6
      chclas (48) = ' 2-04'
c Code des aretes coupees : 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0
      charde (48)(1:6) = '  5  6'
      chnp1 (48) = 1
      chnar (48) = 10
      chnpy (48) = 5
      chnte (48) = 6
      chnhe (48) = 0
      chperm (48) = 101
      chbirf (48) = 9
      chetat (48) = 83
      chtn2i (48) = 10
      chbiet (83) = 48
c
c Aretes coupees :   5  7
      chclas (80) = ' 2-04'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0
      charde (80)(1:6) = '  5  7'
      chnp1 (80) = 1
      chnar (80) = 10
      chnpy (80) = 5
      chnte (80) = 6
      chnhe (80) = 0
      chperm (80) = 30
      chbirf (80) = 9
      chetat (80) = 84
      chtn2i (80) = 10
      chbiet (84) = 80
c
c Aretes coupees :   6  8
      chclas (160) = ' 2-04'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0
      charde (160)(1:6) = '  6  8'
      chnp1 (160) = 1
      chnar (160) = 10
      chnpy (160) = 5
      chnte (160) = 6
      chnhe (160) = 0
      chperm (160) = 10
      chbirf (160) = 9
      chetat (160) = 85
      chtn2i (160) = 10
      chbiet (85) = 160
c
c Aretes coupees :   7  8
      chclas (192) = ' 2-04'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0
      charde (192)(1:6) = '  7  8'
      chnp1 (192) = 1
      chnar (192) = 10
      chnpy (192) = 5
      chnte (192) = 6
      chnhe (192) = 0
      chperm (192) = 301
      chbirf (192) = 9
      chetat (192) = 86
      chtn2i (192) = 10
      chbiet (86) = 192
c
c Aretes coupees :   9 12
      chclas (2304) = ' 2-04'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1
      charde (2304)(1:6) = '  9 12'
      chnp1 (2304) = 1
      chnar (2304) = 10
      chnpy (2304) = 5
      chnte (2304) = 6
      chnhe (2304) = 0
      chperm (2304) = 200
      chbirf (2304) = 9
      chetat (2304) = 87
      chtn2i (2304) = 10
      chbiet (87) = 2304
c
c Aretes coupees :  10 11
      chclas (1536) = ' 2-04'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0
      charde (1536)(1:6) = ' 10 11'
      chnp1 (1536) = 1
      chnar (1536) = 10
      chnpy (1536) = 5
      chnte (1536) = 6
      chnhe (1536) = 0
      chperm (1536) = 201
      chbirf (1536) = 9
      chetat (1536) = 88
      chtn2i (1536) = 10
      chbiet (88) = 1536
c
c ===========================================
c Classe d'equivalence  3-00
c
c Aretes coupees :   1  7 11
      chclas (1089) = ' 3-00'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0
      charde (1089)(1:9) = '  1  7 11'
      chnp1 (1089) = 1
      chnar (1089) = 11
      chnpy (1089) = 0
      chnte (1089) = 18
      chnhe (1089) = 0
      chperm (1089) = 0
      chbirf (1089) = 1089
      chetat (1089) = 89
      chtn2i (1089) = 70
      chbiet (89) = 1089
c
c Aretes coupees :   2  8  9
      chclas (386) = ' 3-00'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0
      charde (386)(1:9) = '  2  8  9'
      chnp1 (386) = 1
      chnar (386) = 11
      chnpy (386) = 0
      chnte (386) = 18
      chnhe (386) = 0
      chperm (386) = 100
      chbirf (386) = 1089
      chetat (386) = 90
      chtn2i (386) = 70
      chbiet (90) = 386
c
c Aretes coupees :   3  5 12
      chclas (2068) = ' 3-00'
c Code des aretes coupees : 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1
      charde (2068)(1:9) = '  3  5 12'
      chnp1 (2068) = 1
      chnar (2068) = 11
      chnpy (2068) = 0
      chnte (2068) = 18
      chnhe (2068) = 0
      chperm (2068) = 200
      chbirf (2068) = 1089
      chetat (2068) = 91
      chtn2i (2068) = 70
      chbiet (91) = 2068
c
c Aretes coupees :   4  6 10
      chclas (552) = ' 3-00'
c Code des aretes coupees : 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0
      charde (552)(1:9) = '  4  6 10'
      chnp1 (552) = 1
      chnar (552) = 11
      chnpy (552) = 0
      chnte (552) = 18
      chnhe (552) = 0
      chperm (552) = 300
      chbirf (552) = 1089
      chetat (552) = 92
      chtn2i (552) = 70
      chbiet (92) = 552
c
c ===========================================
c Classe d'equivalence  3-01
c
c Aretes coupees :   1  8 10
      chclas (641) = ' 3-01'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0
      charde (641)(1:9) = '  1  8 10'
      chnp1 (641) = 1
      chnar (641) = 11
      chnpy (641) = 0
      chnte (641) = 18
      chnhe (641) = 0
      chperm (641) = 0
      chbirf (641) = 641
      chetat (641) = 93
      chtn2i (641) = 70
      chbiet (93) = 641
c
c Aretes coupees :   2  6 12
      chclas (2082) = ' 3-01'
c Code des aretes coupees : 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1
      charde (2082)(1:9) = '  2  6 12'
      chnp1 (2082) = 1
      chnar (2082) = 11
      chnpy (2082) = 0
      chnte (2082) = 18
      chnhe (2082) = 0
      chperm (2082) = 200
      chbirf (2082) = 641
      chetat (2082) = 94
      chtn2i (2082) = 70
      chbiet (94) = 2082
c
c Aretes coupees :   3  7  9
      chclas (324) = ' 3-01'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0
      charde (324)(1:9) = '  3  7  9'
      chnp1 (324) = 1
      chnar (324) = 11
      chnpy (324) = 0
      chnte (324) = 18
      chnhe (324) = 0
      chperm (324) = 100
      chbirf (324) = 641
      chetat (324) = 95
      chtn2i (324) = 70
      chbiet (95) = 324
c
c Aretes coupees :   4  5 11
      chclas (1048) = ' 3-01'
c Code des aretes coupees : 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0
      charde (1048)(1:9) = '  4  5 11'
      chnp1 (1048) = 1
      chnar (1048) = 11
      chnpy (1048) = 0
      chnte (1048) = 18
      chnhe (1048) = 0
      chperm (1048) = 300
      chbirf (1048) = 641
      chetat (1048) = 96
      chtn2i (1048) = 70
      chbiet (96) = 1048
c
c ===========================================
c Classe d'equivalence  3-02
c
c Aretes coupees :   1  2  5
      chclas (19) = ' 3-02'
c Code des aretes coupees : 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
      charde (19)(1:9) = '  1  2  5'
      chnp1 (19) = 1
      chnar (19) = 14
      chnpy (19) = 12
      chnte (19) = 0
      chnhe (19) = 0
      chperm (19) = 0
      chbirf (19) = 19
      chetat (19) = 97
      chtn2i (19) = 210
      chbiet (97) = 19
c
c Aretes coupees :   1  3  6
      chclas (37) = ' 3-02'
c Code des aretes coupees : 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0
      charde (37)(1:9) = '  1  3  6'
      chnp1 (37) = 1
      chnar (37) = 14
      chnpy (37) = 12
      chnte (37) = 0
      chnhe (37) = 0
      chperm (37) = 10
      chbirf (37) = 19
      chetat (37) = 98
      chtn2i (37) = 210
      chbiet (98) = 37
c
c Aretes coupees :   2  4  7
      chclas (74) = ' 3-02'
c Code des aretes coupees : 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0
      charde (74)(1:9) = '  2  4  7'
      chnp1 (74) = 1
      chnar (74) = 14
      chnpy (74) = 12
      chnte (74) = 0
      chnhe (74) = 0
      chperm (74) = 300
      chbirf (74) = 19
      chetat (74) = 99
      chtn2i (74) = 210
      chbiet (99) = 74
c
c Aretes coupees :   3  4  8
      chclas (140) = ' 3-02'
c Code des aretes coupees : 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0
      charde (140)(1:9) = '  3  4  8'
      chnp1 (140) = 1
      chnar (140) = 14
      chnpy (140) = 12
      chnte (140) = 0
      chnhe (140) = 0
      chperm (140) = 310
      chbirf (140) = 19
      chetat (140) = 100
      chtn2i (140) = 210
      chbiet (100) = 140
c
c Aretes coupees :   5  9 10
      chclas (784) = ' 3-02'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0
      charde (784)(1:9) = '  5  9 10'
      chnp1 (784) = 1
      chnar (784) = 14
      chnpy (784) = 12
      chnte (784) = 0
      chnhe (784) = 0
      chperm (784) = 100
      chbirf (784) = 19
      chetat (784) = 101
      chtn2i (784) = 210
      chbiet (101) = 784
c
c Aretes coupees :   6  9 11
      chclas (1312) = ' 3-02'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0
      charde (1312)(1:9) = '  6  9 11'
      chnp1 (1312) = 1
      chnar (1312) = 14
      chnpy (1312) = 12
      chnte (1312) = 0
      chnhe (1312) = 0
      chperm (1312) = 110
      chbirf (1312) = 19
      chetat (1312) = 102
      chtn2i (1312) = 210
      chbiet (102) = 1312
c
c Aretes coupees :   7 10 12
      chclas (2624) = ' 3-02'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1
      charde (2624)(1:9) = '  7 10 12'
      chnp1 (2624) = 1
      chnar (2624) = 14
      chnpy (2624) = 12
      chnte (2624) = 0
      chnhe (2624) = 0
      chperm (2624) = 200
      chbirf (2624) = 19
      chetat (2624) = 103
      chtn2i (2624) = 210
      chbiet (103) = 2624
c
c Aretes coupees :   8 11 12
      chclas (3200) = ' 3-02'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1
      charde (3200)(1:9) = '  8 11 12'
      chnp1 (3200) = 1
      chnar (3200) = 14
      chnpy (3200) = 12
      chnte (3200) = 0
      chnhe (3200) = 0
      chperm (3200) = 210
      chbirf (3200) = 19
      chetat (3200) = 104
      chtn2i (3200) = 210
      chbiet (104) = 3200
c
c ===========================================
c Classe d'equivalence  3-03
c
c Aretes coupees :   1  2  9
      chclas (259) = ' 3-03'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0
      charde (259)(1:9) = '  1  2  9'
      chnp1 (259) = 1
      chnar (259) = 12
      chnpy (259) = 7
      chnte (259) = 6
      chnhe (259) = 0
      chperm (259) = 0
      chbirf (259) = 259
      chetat (259) = 105
      chtn2i (259) = 210
      chbiet (105) = 259
c
c Aretes coupees :   1  3 11
      chclas (1029) = ' 3-03'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0
      charde (1029)(1:9) = '  1  3 11'
      chnp1 (1029) = 1
      chnar (1029) = 12
      chnpy (1029) = 7
      chnte (1029) = 6
      chnhe (1029) = 0
      chperm (1029) = 221
      chbirf (1029) = 259
      chetat (1029) = 106
      chtn2i (1029) = 210
      chbiet (106) = 1029
c
c Aretes coupees :   1  4  6
      chclas (41) = ' 3-03'
c Code des aretes coupees : 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0
      charde (41)(1:9) = '  1  4  6'
      chnp1 (41) = 1
      chnar (41) = 12
      chnpy (41) = 7
      chnte (41) = 6
      chnhe (41) = 0
      chperm (41) = 320
      chbirf (41) = 259
      chetat (41) = 107
      chtn2i (41) = 210
      chbiet (107) = 41
c
c Aretes coupees :   1  4  7
      chclas (73) = ' 3-03'
c Code des aretes coupees : 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0
      charde (73)(1:9) = '  1  4  7'
      chnp1 (73) = 1
      chnar (73) = 12
      chnpy (73) = 7
      chnte (73) = 6
      chnhe (73) = 0
      chperm (73) = 300
      chbirf (73) = 259
      chetat (73) = 108
      chtn2i (73) = 210
      chbiet (108) = 73
c
c Aretes coupees :   1  5  7
      chclas (81) = ' 3-03'
c Code des aretes coupees : 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0
      charde (81)(1:9) = '  1  5  7'
      chnp1 (81) = 1
      chnar (81) = 12
      chnpy (81) = 7
      chnte (81) = 6
      chnhe (81) = 0
      chperm (81) = 101
      chbirf (81) = 259
      chetat (81) = 109
      chtn2i (81) = 210
      chbiet (109) = 81
c
c Aretes coupees :   1  9 11
      chclas (1281) = ' 3-03'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0
      charde (1281)(1:9) = '  1  9 11'
      chnp1 (1281) = 1
      chnar (1281) = 12
      chnpy (1281) = 7
      chnte (1281) = 6
      chnhe (1281) = 0
      chperm (1281) = 20
      chbirf (1281) = 259
      chetat (1281) = 110
      chtn2i (1281) = 210
      chbiet (110) = 1281
c
c Aretes coupees :   2  3  5
      chclas (22) = ' 3-03'
c Code des aretes coupees : 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0
      charde (22)(1:9) = '  2  3  5'
      chnp1 (22) = 1
      chnar (22) = 12
      chnpy (22) = 7
      chnte (22) = 6
      chnhe (22) = 0
      chperm (22) = 330
      chbirf (22) = 259
      chetat (22) = 111
      chtn2i (22) = 210
      chbiet (111) = 22
c
c Aretes coupees :   2  3  8
      chclas (134) = ' 3-03'
c Code des aretes coupees : 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0
      charde (134)(1:9) = '  2  3  8'
      chnp1 (134) = 1
      chnar (134) = 12
      chnpy (134) = 7
      chnte (134) = 6
      chnhe (134) = 0
      chperm (134) = 310
      chbirf (134) = 259
      chetat (134) = 112
      chtn2i (134) = 210
      chbiet (112) = 134
c
c Aretes coupees :   2  4 10
      chclas (522) = ' 3-03'
c Code des aretes coupees : 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0
      charde (522)(1:9) = '  2  4 10'
      chnp1 (522) = 1
      chnar (522) = 12
      chnpy (522) = 7
      chnte (522) = 6
      chnhe (522) = 0
      chperm (522) = 1
      chbirf (522) = 259
      chetat (522) = 113
      chtn2i (522) = 210
      chbiet (113) = 522
c
c Aretes coupees :   2  7  8
      chclas (194) = ' 3-03'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0
      charde (194)(1:9) = '  2  7  8'
      chnp1 (194) = 1
      chnar (194) = 12
      chnpy (194) = 7
      chnte (194) = 6
      chnhe (194) = 0
      chperm (194) = 230
      chbirf (194) = 259
      chetat (194) = 114
      chtn2i (194) = 210
      chbiet (114) = 194
c
c Aretes coupees :   2  9 10
      chclas (770) = ' 3-03'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0
      charde (770)(1:9) = '  2  9 10'
      chnp1 (770) = 1
      chnar (770) = 12
      chnpy (770) = 7
      chnte (770) = 6
      chnhe (770) = 0
      chperm (770) = 201
      chbirf (770) = 259
      chetat (770) = 115
      chtn2i (770) = 210
      chbiet (115) = 770
c
c Aretes coupees :   3  4 12
      chclas (2060) = ' 3-03'
c Code des aretes coupees : 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1
      charde (2060)(1:9) = '  3  4 12'
      chnp1 (2060) = 1
      chnar (2060) = 12
      chnpy (2060) = 7
      chnte (2060) = 6
      chnhe (2060) = 0
      chperm (2060) = 220
      chbirf (2060) = 259
      chetat (2060) = 116
      chtn2i (2060) = 210
      chbiet (116) = 2060
c
c Aretes coupees :   3  5  6
      chclas (52) = ' 3-03'
c Code des aretes coupees : 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0
      charde (52)(1:9) = '  3  5  6'
      chnp1 (52) = 1
      chnar (52) = 12
      chnpy (52) = 7
      chnte (52) = 6
      chnhe (52) = 0
      chperm (52) = 10
      chbirf (52) = 259
      chetat (52) = 117
      chtn2i (52) = 210
      chbiet (117) = 52
c
c Aretes coupees :   3 11 12
      chclas (3076) = ' 3-03'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1
      charde (3076)(1:9) = '  3 11 12'
      chnp1 (3076) = 1
      chnar (3076) = 12
      chnpy (3076) = 7
      chnte (3076) = 6
      chnhe (3076) = 0
      chperm (3076) = 21
      chbirf (3076) = 259
      chetat (3076) = 118
      chtn2i (3076) = 210
      chbiet (118) = 3076
c
c Aretes coupees :   4  6  8
      chclas (168) = ' 3-03'
c Code des aretes coupees : 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0
      charde (168)(1:9) = '  4  6  8'
      chnp1 (168) = 1
      chnar (168) = 12
      chnpy (168) = 7
      chnte (168) = 6
      chnhe (168) = 0
      chperm (168) = 121
      chbirf (168) = 259
      chetat (168) = 119
      chtn2i (168) = 210
      chbiet (119) = 168
c
c Aretes coupees :   4 10 12
      chclas (2568) = ' 3-03'
c Code des aretes coupees : 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1
      charde (2568)(1:9) = '  4 10 12'
      chnp1 (2568) = 1
      chnar (2568) = 12
      chnpy (2568) = 7
      chnte (2568) = 6
      chnhe (2568) = 0
      chperm (2568) = 200
      chbirf (2568) = 259
      chetat (2568) = 120
      chtn2i (2568) = 210
      chbiet (120) = 2568
c
c Aretes coupees :   5  6 10
      chclas (560) = ' 3-03'
c Code des aretes coupees : 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0
      charde (560)(1:9) = '  5  6 10'
      chnp1 (560) = 1
      chnar (560) = 12
      chnpy (560) = 7
      chnte (560) = 6
      chnhe (560) = 0
      chperm (560) = 30
      chbirf (560) = 259
      chetat (560) = 121
      chtn2i (560) = 210
      chbiet (121) = 560
c
c Aretes coupees :   5  7 12
      chclas (2128) = ' 3-03'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1
      charde (2128)(1:9) = '  5  7 12'
      chnp1 (2128) = 1
      chnar (2128) = 12
      chnpy (2128) = 7
      chnte (2128) = 6
      chnhe (2128) = 0
      chperm (2128) = 301
      chbirf (2128) = 259
      chetat (2128) = 122
      chtn2i (2128) = 210
      chbiet (122) = 2128
c
c Aretes coupees :   5  9 12
      chclas (2320) = ' 3-03'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1
      charde (2320)(1:9) = '  5  9 12'
      chnp1 (2320) = 1
      chnar (2320) = 12
      chnpy (2320) = 7
      chnte (2320) = 6
      chnhe (2320) = 0
      chperm (2320) = 100
      chbirf (2320) = 259
      chetat (2320) = 123
      chtn2i (2320) = 210
      chbiet (123) = 2320
c
c Aretes coupees :   6  8  9
      chclas (416) = ' 3-03'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0
      charde (416)(1:9) = '  6  8  9'
      chnp1 (416) = 1
      chnar (416) = 12
      chnpy (416) = 7
      chnte (416) = 6
      chnhe (416) = 0
      chperm (416) = 321
      chbirf (416) = 259
      chetat (416) = 124
      chtn2i (416) = 210
      chbiet (124) = 416
c
c Aretes coupees :   6 10 11
      chclas (1568) = ' 3-03'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0
      charde (1568)(1:9) = '  6 10 11'
      chnp1 (1568) = 1
      chnar (1568) = 12
      chnpy (1568) = 7
      chnte (1568) = 6
      chnhe (1568) = 0
      chperm (1568) = 110
      chbirf (1568) = 259
      chetat (1568) = 125
      chtn2i (1568) = 210
      chbiet (125) = 1568
c
c Aretes coupees :   7  8 11
      chclas (1216) = ' 3-03'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0
      charde (1216)(1:9) = '  7  8 11'
      chnp1 (1216) = 1
      chnar (1216) = 12
      chnpy (1216) = 7
      chnte (1216) = 6
      chnhe (1216) = 0
      chperm (1216) = 210
      chbirf (1216) = 259
      chetat (1216) = 126
      chtn2i (1216) = 210
      chbiet (126) = 1216
c
c Aretes coupees :   7 10 11
      chclas (1600) = ' 3-03'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0
      charde (1600)(1:9) = '  7 10 11'
      chnp1 (1600) = 1
      chnar (1600) = 12
      chnpy (1600) = 7
      chnte (1600) = 6
      chnhe (1600) = 0
      chperm (1600) = 130
      chbirf (1600) = 259
      chetat (1600) = 127
      chtn2i (1600) = 210
      chbiet (127) = 1600
c
c Aretes coupees :   8  9 12
      chclas (2432) = ' 3-03'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1
      charde (2432)(1:9) = '  8  9 12'
      chnp1 (2432) = 1
      chnar (2432) = 12
      chnpy (2432) = 7
      chnte (2432) = 6
      chnhe (2432) = 0
      chperm (2432) = 120
      chbirf (2432) = 259
      chetat (2432) = 128
      chtn2i (2432) = 210
      chbiet (128) = 2432
c
c ===========================================
c Classe d'equivalence  3-04
c
c Aretes coupees :   1  2 10
      chclas (515) = ' 3-04'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0
      charde (515)(1:9) = '  1  2 10'
      chnp1 (515) = 1
      chnar (515) = 12
      chnpy (515) = 7
      chnte (515) = 6
      chnhe (515) = 0
      chperm (515) = 0
      chbirf (515) = 515
      chetat (515) = 129
      chtn2i (515) = 210
      chbiet (129) = 515
c
c Aretes coupees :   1  3  9
      chclas (261) = ' 3-04'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0
      charde (261)(1:9) = '  1  3  9'
      chnp1 (261) = 1
      chnar (261) = 12
      chnpy (261) = 7
      chnte (261) = 6
      chnhe (261) = 0
      chperm (261) = 221
      chbirf (261) = 515
      chetat (261) = 130
      chtn2i (261) = 210
      chbiet (130) = 261
c
c Aretes coupees :   1  4  5
      chclas (25) = ' 3-04'
c Code des aretes coupees : 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0
      charde (25)(1:9) = '  1  4  5'
      chnp1 (25) = 1
      chnar (25) = 12
      chnpy (25) = 7
      chnte (25) = 6
      chnhe (25) = 0
      chperm (25) = 101
      chbirf (25) = 515
      chetat (25) = 131
      chtn2i (25) = 210
      chbiet (131) = 25
c
c Aretes coupees :   1  4  8
      chclas (137) = ' 3-04'
c Code des aretes coupees : 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0
      charde (137)(1:9) = '  1  4  8'
      chnp1 (137) = 1
      chnar (137) = 12
      chnpy (137) = 7
      chnte (137) = 6
      chnhe (137) = 0
      chperm (137) = 121
      chbirf (137) = 515
      chetat (137) = 132
      chtn2i (137) = 210
      chbiet (132) = 137
c
c Aretes coupees :   1  6  8
      chclas (161) = ' 3-04'
c Code des aretes coupees : 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0
      charde (161)(1:9) = '  1  6  8'
      chnp1 (161) = 1
      chnar (161) = 12
      chnpy (161) = 7
      chnte (161) = 6
      chnhe (161) = 0
      chperm (161) = 320
      chbirf (161) = 515
      chetat (161) = 133
      chtn2i (161) = 210
      chbiet (133) = 161
c
c Aretes coupees :   1  9 10
      chclas (769) = ' 3-04'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0
      charde (769)(1:9) = '  1  9 10'
      chnp1 (769) = 1
      chnar (769) = 12
      chnpy (769) = 7
      chnte (769) = 6
      chnhe (769) = 0
      chperm (769) = 201
      chbirf (769) = 515
      chetat (769) = 134
      chtn2i (769) = 210
      chbiet (134) = 769
c
c Aretes coupees :   2  3  6
      chclas (38) = ' 3-04'
c Code des aretes coupees : 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0
      charde (38)(1:9) = '  2  3  6'
      chnp1 (38) = 1
      chnar (38) = 12
      chnpy (38) = 7
      chnte (38) = 6
      chnhe (38) = 0
      chperm (38) = 10
      chbirf (38) = 515
      chetat (38) = 135
      chtn2i (38) = 210
      chbiet (135) = 38
c
c Aretes coupees :   2  3  7
      chclas (70) = ' 3-04'
c Code des aretes coupees : 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0
      charde (70)(1:9) = '  2  3  7'
      chnp1 (70) = 1
      chnar (70) = 12
      chnpy (70) = 7
      chnte (70) = 6
      chnhe (70) = 0
      chperm (70) = 230
      chbirf (70) = 515
      chetat (70) = 136
      chtn2i (70) = 210
      chbiet (136) = 70
c
c Aretes coupees :   2  4 12
      chclas (2058) = ' 3-04'
c Code des aretes coupees : 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1
      charde (2058)(1:9) = '  2  4 12'
      chnp1 (2058) = 1
      chnar (2058) = 12
      chnpy (2058) = 7
      chnte (2058) = 6
      chnhe (2058) = 0
      chperm (2058) = 1
      chbirf (2058) = 515
      chetat (2058) = 137
      chtn2i (2058) = 210
      chbiet (137) = 2058
c
c Aretes coupees :   2  5  6
      chclas (50) = ' 3-04'
c Code des aretes coupees : 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0
      charde (50)(1:9) = '  2  5  6'
      chnp1 (50) = 1
      chnar (50) = 12
      chnpy (50) = 7
      chnte (50) = 6
      chnhe (50) = 0
      chperm (50) = 330
      chbirf (50) = 515
      chetat (50) = 138
      chtn2i (50) = 210
      chbiet (138) = 50
c
c Aretes coupees :   2 10 12
      chclas (2562) = ' 3-04'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1
      charde (2562)(1:9) = '  2 10 12'
      chnp1 (2562) = 1
      chnar (2562) = 12
      chnpy (2562) = 7
      chnte (2562) = 6
      chnhe (2562) = 0
      chperm (2562) = 200
      chbirf (2562) = 515
      chetat (2562) = 139
      chtn2i (2562) = 210
      chbiet (139) = 2562
c
c Aretes coupees :   3  4 11
      chclas (1036) = ' 3-04'
c Code des aretes coupees : 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0
      charde (1036)(1:9) = '  3  4 11'
      chnp1 (1036) = 1
      chnar (1036) = 12
      chnpy (1036) = 7
      chnte (1036) = 6
      chnhe (1036) = 0
      chperm (1036) = 220
      chbirf (1036) = 515
      chetat (1036) = 140
      chtn2i (1036) = 210
      chbiet (140) = 1036
c
c Aretes coupees :   3  7  8
      chclas (196) = ' 3-04'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0
      charde (196)(1:9) = '  3  7  8'
      chnp1 (196) = 1
      chnar (196) = 12
      chnpy (196) = 7
      chnte (196) = 6
      chnhe (196) = 0
      chperm (196) = 310
      chbirf (196) = 515
      chetat (196) = 141
      chtn2i (196) = 210
      chbiet (141) = 196
c
c Aretes coupees :   3  9 11
      chclas (1284) = ' 3-04'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0
      charde (1284)(1:9) = '  3  9 11'
      chnp1 (1284) = 1
      chnar (1284) = 12
      chnpy (1284) = 7
      chnte (1284) = 6
      chnhe (1284) = 0
      chperm (1284) = 20
      chbirf (1284) = 515
      chetat (1284) = 142
      chtn2i (1284) = 210
      chbiet (142) = 1284
c
c Aretes coupees :   4  5  7
      chclas (88) = ' 3-04'
c Code des aretes coupees : 0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0
      charde (88)(1:9) = '  4  5  7'
      chnp1 (88) = 1
      chnar (88) = 12
      chnpy (88) = 7
      chnte (88) = 6
      chnhe (88) = 0
      chperm (88) = 300
      chbirf (88) = 515
      chetat (88) = 143
      chtn2i (88) = 210
      chbiet (143) = 88
c
c Aretes coupees :   4 11 12
      chclas (3080) = ' 3-04'
c Code des aretes coupees : 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1
      charde (3080)(1:9) = '  4 11 12'
      chnp1 (3080) = 1
      chnar (3080) = 12
      chnpy (3080) = 7
      chnte (3080) = 6
      chnhe (3080) = 0
      chperm (3080) = 21
      chbirf (3080) = 515
      chetat (3080) = 144
      chtn2i (3080) = 210
      chbiet (144) = 3080
c
c Aretes coupees :   5  6 11
      chclas (1072) = ' 3-04'
c Code des aretes coupees : 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0
      charde (1072)(1:9) = '  5  6 11'
      chnp1 (1072) = 1
      chnar (1072) = 12
      chnpy (1072) = 7
      chnte (1072) = 6
      chnhe (1072) = 0
      chperm (1072) = 110
      chbirf (1072) = 515
      chetat (1072) = 145
      chtn2i (1072) = 210
      chbiet (145) = 1072
c
c Aretes coupees :   5  7  9
      chclas (336) = ' 3-04'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0
      charde (336)(1:9) = '  5  7  9'
      chnp1 (336) = 1
      chnar (336) = 12
      chnpy (336) = 7
      chnte (336) = 6
      chnhe (336) = 0
      chperm (336) = 100
      chbirf (336) = 515
      chetat (336) = 146
      chtn2i (336) = 210
      chbiet (146) = 336
c
c Aretes coupees :   5 10 11
      chclas (1552) = ' 3-04'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0
      charde (1552)(1:9) = '  5 10 11'
      chnp1 (1552) = 1
      chnar (1552) = 12
      chnpy (1552) = 7
      chnte (1552) = 6
      chnhe (1552) = 0
      chperm (1552) = 30
      chbirf (1552) = 515
      chetat (1552) = 147
      chtn2i (1552) = 210
      chbiet (147) = 1552
c
c Aretes coupees :   6  8 12
      chclas (2208) = ' 3-04'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1
      charde (2208)(1:9) = '  6  8 12'
      chnp1 (2208) = 1
      chnar (2208) = 12
      chnpy (2208) = 7
      chnte (2208) = 6
      chnhe (2208) = 0
      chperm (2208) = 120
      chbirf (2208) = 515
      chetat (2208) = 148
      chtn2i (2208) = 210
      chbiet (148) = 2208
c
c Aretes coupees :   6  9 12
      chclas (2336) = ' 3-04'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1
      charde (2336)(1:9) = '  6  9 12'
      chnp1 (2336) = 1
      chnar (2336) = 12
      chnpy (2336) = 7
      chnte (2336) = 6
      chnhe (2336) = 0
      chperm (2336) = 321
      chbirf (2336) = 515
      chetat (2336) = 149
      chtn2i (2336) = 210
      chbiet (149) = 2336
c
c Aretes coupees :   7  8 10
      chclas (704) = ' 3-04'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 0
      charde (704)(1:9) = '  7  8 10'
      chnp1 (704) = 1
      chnar (704) = 12
      chnpy (704) = 7
      chnte (704) = 6
      chnhe (704) = 0
      chperm (704) = 130
      chbirf (704) = 515
      chetat (704) = 150
      chtn2i (704) = 210
      chbiet (150) = 704
c
c Aretes coupees :   7  9 12
      chclas (2368) = ' 3-04'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1
      charde (2368)(1:9) = '  7  9 12'
      chnp1 (2368) = 1
      chnar (2368) = 12
      chnpy (2368) = 7
      chnte (2368) = 6
      chnhe (2368) = 0
      chperm (2368) = 301
      chbirf (2368) = 515
      chetat (2368) = 151
      chtn2i (2368) = 210
      chbiet (151) = 2368
c
c Aretes coupees :   8 10 11
      chclas (1664) = ' 3-04'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0
      charde (1664)(1:9) = '  8 10 11'
      chnp1 (1664) = 1
      chnar (1664) = 12
      chnpy (1664) = 7
      chnte (1664) = 6
      chnhe (1664) = 0
      chperm (1664) = 210
      chbirf (1664) = 515
      chetat (1664) = 152
      chtn2i (1664) = 210
      chbiet (152) = 1664
c
c ===========================================
c Classe d'equivalence  3-05
c
c Aretes coupees :   1  2 11
      chclas (1027) = ' 3-05'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0
      charde (1027)(1:9) = '  1  2 11'
      chnp1 (1027) = 1
      chnar (1027) = 12
      chnpy (1027) = 4
      chnte (1027) = 12
      chnhe (1027) = 0
      chperm (1027) = 0
      chbirf (1027) = 1027
      chetat (1027) = 153
      chtn2i (1027) = 210
      chbiet (153) = 1027
c
c Aretes coupees :   1  3 12
      chclas (2053) = ' 3-05'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1
      charde (2053)(1:9) = '  1  3 12'
      chnp1 (2053) = 1
      chnar (2053) = 12
      chnpy (2053) = 4
      chnte (2053) = 12
      chnhe (2053) = 0
      chperm (2053) = 221
      chbirf (2053) = 1027
      chetat (2053) = 154
      chtn2i (2053) = 210
      chbiet (154) = 2053
c
c Aretes coupees :   1  5 12
      chclas (2065) = ' 3-05'
c Code des aretes coupees : 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1
      charde (2065)(1:9) = '  1  5 12'
      chnp1 (2065) = 1
      chnar (2065) = 12
      chnpy (2065) = 4
      chnte (2065) = 12
      chnhe (2065) = 0
      chperm (2065) = 101
      chbirf (2065) = 1027
      chetat (2065) = 155
      chtn2i (2065) = 210
      chbiet (155) = 2065
c
c Aretes coupees :   1  6  7
      chclas (97) = ' 3-05'
c Code des aretes coupees : 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0
      charde (97)(1:9) = '  1  6  7'
      chnp1 (97) = 1
      chnar (97) = 12
      chnpy (97) = 4
      chnte (97) = 12
      chnhe (97) = 0
      chperm (97) = 320
      chbirf (97) = 1027
      chetat (97) = 156
      chtn2i (97) = 210
      chbiet (156) = 97
c
c Aretes coupees :   1  7 12
      chclas (2113) = ' 3-05'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1
      charde (2113)(1:9) = '  1  7 12'
      chnp1 (2113) = 1
      chnar (2113) = 12
      chnpy (2113) = 4
      chnte (2113) = 12
      chnhe (2113) = 0
      chperm (2113) = 301
      chbirf (2113) = 1027
      chetat (2113) = 157
      chtn2i (2113) = 210
      chbiet (157) = 2113
c
c Aretes coupees :   1 11 12
      chclas (3073) = ' 3-05'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1
      charde (3073)(1:9) = '  1 11 12'
      chnp1 (3073) = 1
      chnar (3073) = 12
      chnpy (3073) = 4
      chnte (3073) = 12
      chnhe (3073) = 0
      chperm (3073) = 21
      chbirf (3073) = 1027
      chetat (3073) = 158
      chtn2i (3073) = 210
      chbiet (158) = 3073
c
c Aretes coupees :   2  4  9
      chclas (266) = ' 3-05'
c Code des aretes coupees : 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0
      charde (266)(1:9) = '  2  4  9'
      chnp1 (266) = 1
      chnar (266) = 12
      chnpy (266) = 4
      chnte (266) = 12
      chnhe (266) = 0
      chperm (266) = 1
      chbirf (266) = 1027
      chetat (266) = 159
      chtn2i (266) = 210
      chbiet (159) = 266
c
c Aretes coupees :   2  5  8
      chclas (146) = ' 3-05'
c Code des aretes coupees : 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0
      charde (146)(1:9) = '  2  5  8'
      chnp1 (146) = 1
      chnar (146) = 12
      chnpy (146) = 4
      chnte (146) = 12
      chnhe (146) = 0
      chperm (146) = 330
      chbirf (146) = 1027
      chetat (146) = 160
      chtn2i (146) = 210
      chbiet (160) = 146
c
c Aretes coupees :   2  7 11
      chclas (1090) = ' 3-05'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0
      charde (1090)(1:9) = '  2  7 11'
      chnp1 (1090) = 1
      chnar (1090) = 12
      chnpy (1090) = 4
      chnte (1090) = 12
      chnhe (1090) = 0
      chperm (1090) = 230
      chbirf (1090) = 1027
      chetat (1090) = 161
      chtn2i (1090) = 210
      chbiet (161) = 1090
c
c Aretes coupees :   2  8 11
      chclas (1154) = ' 3-05'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0
      charde (1154)(1:9) = '  2  8 11'
      chnp1 (1154) = 1
      chnar (1154) = 12
      chnpy (1154) = 4
      chnte (1154) = 12
      chnhe (1154) = 0
      chperm (1154) = 210
      chbirf (1154) = 1027
      chetat (1154) = 162
      chtn2i (1154) = 210
      chbiet (162) = 1154
c
c Aretes coupees :   2  9 11
      chclas (1282) = ' 3-05'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0
      charde (1282)(1:9) = '  2  9 11'
      chnp1 (1282) = 1
      chnar (1282) = 12
      chnpy (1282) = 4
      chnte (1282) = 12
      chnhe (1282) = 0
      chperm (1282) = 20
      chbirf (1282) = 1027
      chetat (1282) = 163
      chtn2i (1282) = 210
      chbiet (163) = 1282
c
c Aretes coupees :   3  4 10
      chclas (524) = ' 3-05'
c Code des aretes coupees : 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0
      charde (524)(1:9) = '  3  4 10'
      chnp1 (524) = 1
      chnar (524) = 12
      chnpy (524) = 4
      chnte (524) = 12
      chnhe (524) = 0
      chperm (524) = 220
      chbirf (524) = 1027
      chetat (524) = 164
      chtn2i (524) = 210
      chbiet (164) = 524
c
c Aretes coupees :   3  5  8
      chclas (148) = ' 3-05'
c Code des aretes coupees : 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0
      charde (148)(1:9) = '  3  5  8'
      chnp1 (148) = 1
      chnar (148) = 12
      chnpy (148) = 4
      chnte (148) = 12
      chnhe (148) = 0
      chperm (148) = 310
      chbirf (148) = 1027
      chetat (148) = 165
      chtn2i (148) = 210
      chbiet (165) = 148
c
c Aretes coupees :   3  5 10
      chclas (532) = ' 3-05'
c Code des aretes coupees : 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0
      charde (532)(1:9) = '  3  5 10'
      chnp1 (532) = 1
      chnar (532) = 12
      chnpy (532) = 4
      chnte (532) = 12
      chnhe (532) = 0
      chperm (532) = 30
      chbirf (532) = 1027
      chetat (532) = 166
      chtn2i (532) = 210
      chbiet (166) = 532
c
c Aretes coupees :   3  6 10
      chclas (548) = ' 3-05'
c Code des aretes coupees : 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0
      charde (548)(1:9) = '  3  6 10'
      chnp1 (548) = 1
      chnar (548) = 12
      chnpy (548) = 4
      chnte (548) = 12
      chnhe (548) = 0
      chperm (548) = 10
      chbirf (548) = 1027
      chetat (548) = 167
      chtn2i (548) = 210
      chbiet (167) = 548
c
c Aretes coupees :   3 10 12
      chclas (2564) = ' 3-05'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1
      charde (2564)(1:9) = '  3 10 12'
      chnp1 (2564) = 1
      chnar (2564) = 12
      chnpy (2564) = 4
      chnte (2564) = 12
      chnhe (2564) = 0
      chperm (2564) = 200
      chbirf (2564) = 1027
      chetat (2564) = 168
      chtn2i (2564) = 210
      chbiet (168) = 2564
c
c Aretes coupees :   4  6  7
      chclas (104) = ' 3-05'
c Code des aretes coupees : 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0
      charde (104)(1:9) = '  4  6  7'
      chnp1 (104) = 1
      chnar (104) = 12
      chnpy (104) = 4
      chnte (104) = 12
      chnhe (104) = 0
      chperm (104) = 300
      chbirf (104) = 1027
      chetat (104) = 169
      chtn2i (104) = 210
      chbiet (169) = 104
c
c Aretes coupees :   4  6  9
      chclas (296) = ' 3-05'
c Code des aretes coupees : 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0
      charde (296)(1:9) = '  4  6  9'
      chnp1 (296) = 1
      chnar (296) = 12
      chnpy (296) = 4
      chnte (296) = 12
      chnhe (296) = 0
      chperm (296) = 321
      chbirf (296) = 1027
      chetat (296) = 170
      chtn2i (296) = 210
      chbiet (170) = 296
c
c Aretes coupees :   4  8  9
      chclas (392) = ' 3-05'
c Code des aretes coupees : 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0
      charde (392)(1:9) = '  4  8  9'
      chnp1 (392) = 1
      chnar (392) = 12
      chnpy (392) = 4
      chnte (392) = 12
      chnhe (392) = 0
      chperm (392) = 121
      chbirf (392) = 1027
      chetat (392) = 171
      chtn2i (392) = 210
      chbiet (171) = 392
c
c Aretes coupees :   4  9 10
      chclas (776) = ' 3-05'
c Code des aretes coupees : 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0
      charde (776)(1:9) = '  4  9 10'
      chnp1 (776) = 1
      chnar (776) = 12
      chnpy (776) = 4
      chnte (776) = 12
      chnhe (776) = 0
      chperm (776) = 201
      chbirf (776) = 1027
      chetat (776) = 172
      chtn2i (776) = 210
      chbiet (172) = 776
c
c Aretes coupees :   5  8  9
      chclas (400) = ' 3-05'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0
      charde (400)(1:9) = '  5  8  9'
      chnp1 (400) = 1
      chnar (400) = 12
      chnpy (400) = 4
      chnte (400) = 12
      chnhe (400) = 0
      chperm (400) = 100
      chbirf (400) = 1027
      chetat (400) = 173
      chtn2i (400) = 210
      chbiet (173) = 400
c
c Aretes coupees :   5  8 12
      chclas (2192) = ' 3-05'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1
      charde (2192)(1:9) = '  5  8 12'
      chnp1 (2192) = 1
      chnar (2192) = 12
      chnpy (2192) = 4
      chnte (2192) = 12
      chnhe (2192) = 0
      chperm (2192) = 120
      chbirf (2192) = 1027
      chetat (2192) = 174
      chtn2i (2192) = 210
      chbiet (174) = 2192
c
c Aretes coupees :   6  7 10
      chclas (608) = ' 3-05'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0
      charde (608)(1:9) = '  6  7 10'
      chnp1 (608) = 1
      chnar (608) = 12
      chnpy (608) = 4
      chnte (608) = 12
      chnhe (608) = 0
      chperm (608) = 130
      chbirf (608) = 1027
      chetat (608) = 175
      chtn2i (608) = 210
      chbiet (175) = 608
c
c Aretes coupees :   6  7 11
      chclas (1120) = ' 3-05'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0
      charde (1120)(1:9) = '  6  7 11'
      chnp1 (1120) = 1
      chnar (1120) = 12
      chnpy (1120) = 4
      chnte (1120) = 12
      chnhe (1120) = 0
      chperm (1120) = 110
      chbirf (1120) = 1027
      chetat (1120) = 176
      chtn2i (1120) = 210
      chbiet (176) = 1120
c
c ===========================================
c Classe d'equivalence  3-06
c
c Aretes coupees :   1  2 12
      chclas (2051) = ' 3-06'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
      charde (2051)(1:9) = '  1  2 12'
      chnp1 (2051) = 1
      chnar (2051) = 12
      chnpy (2051) = 4
      chnte (2051) = 12
      chnhe (2051) = 0
      chperm (2051) = 0
      chbirf (2051) = 2051
      chetat (2051) = 177
      chtn2i (2051) = 210
      chbiet (177) = 2051
c
c Aretes coupees :   1  3 10
      chclas (517) = ' 3-06'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0
      charde (517)(1:9) = '  1  3 10'
      chnp1 (517) = 1
      chnar (517) = 12
      chnpy (517) = 4
      chnte (517) = 12
      chnhe (517) = 0
      chperm (517) = 221
      chbirf (517) = 2051
      chetat (517) = 178
      chtn2i (517) = 210
      chbiet (178) = 517
c
c Aretes coupees :   1  5  8
      chclas (145) = ' 3-06'
c Code des aretes coupees : 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0
      charde (145)(1:9) = '  1  5  8'
      chnp1 (145) = 1
      chnar (145) = 12
      chnpy (145) = 4
      chnte (145) = 12
      chnhe (145) = 0
      chperm (145) = 101
      chbirf (145) = 2051
      chetat (145) = 179
      chtn2i (145) = 210
      chbiet (179) = 145
c
c Aretes coupees :   1  6 12
      chclas (2081) = ' 3-06'
c Code des aretes coupees : 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1
      charde (2081)(1:9) = '  1  6 12'
      chnp1 (2081) = 1
      chnar (2081) = 12
      chnpy (2081) = 4
      chnte (2081) = 12
      chnhe (2081) = 0
      chperm (2081) = 320
      chbirf (2081) = 2051
      chetat (2081) = 180
      chtn2i (2081) = 210
      chbiet (180) = 2081
c
c Aretes coupees :   1  8 12
      chclas (2177) = ' 3-06'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1
      charde (2177)(1:9) = '  1  8 12'
      chnp1 (2177) = 1
      chnar (2177) = 12
      chnpy (2177) = 4
      chnte (2177) = 12
      chnhe (2177) = 0
      chperm (2177) = 120
      chbirf (2177) = 2051
      chetat (2177) = 181
      chtn2i (2177) = 210
      chbiet (181) = 2177
c
c Aretes coupees :   1 10 12
      chclas (2561) = ' 3-06'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1
      charde (2561)(1:9) = '  1 10 12'
      chnp1 (2561) = 1
      chnar (2561) = 12
      chnpy (2561) = 4
      chnte (2561) = 12
      chnhe (2561) = 0
      chperm (2561) = 200
      chbirf (2561) = 2051
      chetat (2561) = 182
      chtn2i (2561) = 210
      chbiet (182) = 2561
c
c Aretes coupees :   2  4 11
      chclas (1034) = ' 3-06'
c Code des aretes coupees : 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0
      charde (1034)(1:9) = '  2  4 11'
      chnp1 (1034) = 1
      chnar (1034) = 12
      chnpy (1034) = 4
      chnte (1034) = 12
      chnhe (1034) = 0
      chperm (1034) = 1
      chbirf (1034) = 2051
      chetat (1034) = 183
      chtn2i (1034) = 210
      chbiet (183) = 1034
c
c Aretes coupees :   2  5 11
      chclas (1042) = ' 3-06'
c Code des aretes coupees : 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0
      charde (1042)(1:9) = '  2  5 11'
      chnp1 (1042) = 1
      chnar (1042) = 12
      chnpy (1042) = 4
      chnte (1042) = 12
      chnhe (1042) = 0
      chperm (1042) = 330
      chbirf (1042) = 2051
      chetat (1042) = 184
      chtn2i (1042) = 210
      chbiet (184) = 1042
c
c Aretes coupees :   2  6  7
      chclas (98) = ' 3-06'
c Code des aretes coupees : 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0
      charde (98)(1:9) = '  2  6  7'
      chnp1 (98) = 1
      chnar (98) = 12
      chnpy (98) = 4
      chnte (98) = 12
      chnhe (98) = 0
      chperm (98) = 230
      chbirf (98) = 2051
      chetat (98) = 185
      chtn2i (98) = 210
      chbiet (185) = 98
c
c Aretes coupees :   2  6 11
      chclas (1058) = ' 3-06'
c Code des aretes coupees : 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0
      charde (1058)(1:9) = '  2  6 11'
      chnp1 (1058) = 1
      chnar (1058) = 12
      chnpy (1058) = 4
      chnte (1058) = 12
      chnhe (1058) = 0
      chperm (1058) = 110
      chbirf (1058) = 2051
      chetat (1058) = 186
      chtn2i (1058) = 210
      chbiet (186) = 1058
c
c Aretes coupees :   2 11 12
      chclas (3074) = ' 3-06'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1
      charde (3074)(1:9) = '  2 11 12'
      chnp1 (3074) = 1
      chnar (3074) = 12
      chnpy (3074) = 4
      chnte (3074) = 12
      chnhe (3074) = 0
      chperm (3074) = 21
      chbirf (3074) = 2051
      chetat (3074) = 187
      chtn2i (3074) = 210
      chbiet (187) = 3074
c
c Aretes coupees :   3  4  9
      chclas (268) = ' 3-06'
c Code des aretes coupees : 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0
      charde (268)(1:9) = '  3  4  9'
      chnp1 (268) = 1
      chnar (268) = 12
      chnpy (268) = 4
      chnte (268) = 12
      chnhe (268) = 0
      chperm (268) = 220
      chbirf (268) = 2051
      chetat (268) = 188
      chtn2i (268) = 210
      chbiet (188) = 268
c
c Aretes coupees :   3  6  7
      chclas (100) = ' 3-06'
c Code des aretes coupees : 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0
      charde (100)(1:9) = '  3  6  7'
      chnp1 (100) = 1
      chnar (100) = 12
      chnpy (100) = 4
      chnte (100) = 12
      chnhe (100) = 0
      chperm (100) = 10
      chbirf (100) = 2051
      chetat (100) = 189
      chtn2i (100) = 210
      chbiet (189) = 100
c
c Aretes coupees :   3  7 10
      chclas (580) = ' 3-06'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0
      charde (580)(1:9) = '  3  7 10'
      chnp1 (580) = 1
      chnar (580) = 12
      chnpy (580) = 4
      chnte (580) = 12
      chnhe (580) = 0
      chperm (580) = 130
      chbirf (580) = 2051
      chetat (580) = 190
      chtn2i (580) = 210
      chbiet (190) = 580
c
c Aretes coupees :   3  8 10
      chclas (644) = ' 3-06'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0
      charde (644)(1:9) = '  3  8 10'
      chnp1 (644) = 1
      chnar (644) = 12
      chnpy (644) = 4
      chnte (644) = 12
      chnhe (644) = 0
      chperm (644) = 310
      chbirf (644) = 2051
      chetat (644) = 191
      chtn2i (644) = 210
      chbiet (191) = 644
c
c Aretes coupees :   3  9 10
      chclas (772) = ' 3-06'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0
      charde (772)(1:9) = '  3  9 10'
      chnp1 (772) = 1
      chnar (772) = 12
      chnpy (772) = 4
      chnte (772) = 12
      chnhe (772) = 0
      chperm (772) = 201
      chbirf (772) = 2051
      chetat (772) = 192
      chtn2i (772) = 210
      chbiet (192) = 772
c
c Aretes coupees :   4  5  8
      chclas (152) = ' 3-06'
c Code des aretes coupees : 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0
      charde (152)(1:9) = '  4  5  8'
      chnp1 (152) = 1
      chnar (152) = 12
      chnpy (152) = 4
      chnte (152) = 12
      chnhe (152) = 0
      chperm (152) = 121
      chbirf (152) = 2051
      chetat (152) = 193
      chtn2i (152) = 210
      chbiet (193) = 152
c
c Aretes coupees :   4  5  9
      chclas (280) = ' 3-06'
c Code des aretes coupees : 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0
      charde (280)(1:9) = '  4  5  9'
      chnp1 (280) = 1
      chnar (280) = 12
      chnpy (280) = 4
      chnte (280) = 12
      chnhe (280) = 0
      chperm (280) = 100
      chbirf (280) = 2051
      chetat (280) = 194
      chtn2i (280) = 210
      chbiet (194) = 280
c
c Aretes coupees :   4  7  9
      chclas (328) = ' 3-06'
c Code des aretes coupees : 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0
      charde (328)(1:9) = '  4  7  9'
      chnp1 (328) = 1
      chnar (328) = 12
      chnpy (328) = 4
      chnte (328) = 12
      chnhe (328) = 0
      chperm (328) = 300
      chbirf (328) = 2051
      chetat (328) = 195
      chtn2i (328) = 210
      chbiet (195) = 328
c
c Aretes coupees :   4  9 11
      chclas (1288) = ' 3-06'
c Code des aretes coupees : 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0
      charde (1288)(1:9) = '  4  9 11'
      chnp1 (1288) = 1
      chnar (1288) = 12
      chnpy (1288) = 4
      chnte (1288) = 12
      chnhe (1288) = 0
      chperm (1288) = 20
      chbirf (1288) = 2051
      chetat (1288) = 196
      chtn2i (1288) = 210
      chbiet (196) = 1288
c
c Aretes coupees :   5  8 10
      chclas (656) = ' 3-06'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0
      charde (656)(1:9) = '  5  8 10'
      chnp1 (656) = 1
      chnar (656) = 12
      chnpy (656) = 4
      chnte (656) = 12
      chnhe (656) = 0
      chperm (656) = 30
      chbirf (656) = 2051
      chetat (656) = 197
      chtn2i (656) = 210
      chbiet (197) = 656
c
c Aretes coupees :   5  8 11
      chclas (1168) = ' 3-06'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0
      charde (1168)(1:9) = '  5  8 11'
      chnp1 (1168) = 1
      chnar (1168) = 12
      chnpy (1168) = 4
      chnte (1168) = 12
      chnhe (1168) = 0
      chperm (1168) = 210
      chbirf (1168) = 2051
      chetat (1168) = 198
      chtn2i (1168) = 210
      chbiet (198) = 1168
c
c Aretes coupees :   6  7  9
      chclas (352) = ' 3-06'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0
      charde (352)(1:9) = '  6  7  9'
      chnp1 (352) = 1
      chnar (352) = 12
      chnpy (352) = 4
      chnte (352) = 12
      chnhe (352) = 0
      chperm (352) = 321
      chbirf (352) = 2051
      chetat (352) = 199
      chtn2i (352) = 210
      chbiet (199) = 352
c
c Aretes coupees :   6  7 12
      chclas (2144) = ' 3-06'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1
      charde (2144)(1:9) = '  6  7 12'
      chnp1 (2144) = 1
      chnar (2144) = 12
      chnpy (2144) = 4
      chnte (2144) = 12
      chnhe (2144) = 0
      chperm (2144) = 301
      chbirf (2144) = 2051
      chetat (2144) = 200
      chtn2i (2144) = 210
      chbiet (200) = 2144
c
c ===========================================
c Classe d'equivalence  3-07
c
c Aretes coupees :   1  2  6
      chclas (35) = ' 3-07'
c Code des aretes coupees : 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0
      charde (35)(1:9) = '  1  2  6'
      chnp1 (35) = 1
      chnar (35) = 13
      chnpy (35) = 8
      chnte (35) = 6
      chnhe (35) = 0
      chperm (35) = 0
      chbirf (35) = 35
      chetat (35) = 201
      chtn2i (35) = 210
      chbiet (201) = 35
c
c Aretes coupees :   1  3  8
      chclas (133) = ' 3-07'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0
      charde (133)(1:9) = '  1  3  8'
      chnp1 (133) = 1
      chnar (133) = 13
      chnpy (133) = 8
      chnte (133) = 6
      chnhe (133) = 0
      chperm (133) = 310
      chbirf (133) = 35
      chetat (133) = 202
      chtn2i (133) = 210
      chbiet (202) = 133
c
c Aretes coupees :   1  5 10
      chclas (529) = ' 3-07'
c Code des aretes coupees : 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0
      charde (529)(1:9) = '  1  5 10'
      chnp1 (529) = 1
      chnar (529) = 13
      chnpy (529) = 8
      chnte (529) = 6
      chnhe (529) = 0
      chperm (529) = 30
      chbirf (529) = 35
      chetat (529) = 203
      chtn2i (529) = 210
      chbiet (203) = 529
c
c Aretes coupees :   2  4  5
      chclas (26) = ' 3-07'
c Code des aretes coupees : 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0
      charde (26)(1:9) = '  2  4  5'
      chnp1 (26) = 1
      chnar (26) = 13
      chnpy (26) = 8
      chnte (26) = 6
      chnhe (26) = 0
      chperm (26) = 330
      chbirf (26) = 35
      chetat (26) = 204
      chtn2i (26) = 210
      chbiet (204) = 26
c
c Aretes coupees :   2  7 12
      chclas (2114) = ' 3-07'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1
      charde (2114)(1:9) = '  2  7 12'
      chnp1 (2114) = 1
      chnar (2114) = 13
      chnpy (2114) = 8
      chnte (2114) = 6
      chnhe (2114) = 0
      chperm (2114) = 230
      chbirf (2114) = 35
      chetat (2114) = 205
      chtn2i (2114) = 210
      chbiet (205) = 2114
c
c Aretes coupees :   3  4  7
      chclas (76) = ' 3-07'
c Code des aretes coupees : 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0
      charde (76)(1:9) = '  3  4  7'
      chnp1 (76) = 1
      chnar (76) = 13
      chnpy (76) = 8
      chnte (76) = 6
      chnhe (76) = 0
      chperm (76) = 300
      chbirf (76) = 35
      chetat (76) = 206
      chtn2i (76) = 210
      chbiet (206) = 76
c
c Aretes coupees :   3  6  9
      chclas (292) = ' 3-07'
c Code des aretes coupees : 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0
      charde (292)(1:9) = '  3  6  9'
      chnp1 (292) = 1
      chnar (292) = 13
      chnpy (292) = 8
      chnte (292) = 6
      chnhe (292) = 0
      chperm (292) = 10
      chbirf (292) = 35
      chetat (292) = 207
      chtn2i (292) = 210
      chbiet (207) = 292
c
c Aretes coupees :   4  8 11
      chclas (1160) = ' 3-07'
c Code des aretes coupees : 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0
      charde (1160)(1:9) = '  4  8 11'
      chnp1 (1160) = 1
      chnar (1160) = 13
      chnpy (1160) = 8
      chnte (1160) = 6
      chnhe (1160) = 0
      chperm (1160) = 210
      chbirf (1160) = 35
      chetat (1160) = 208
      chtn2i (1160) = 210
      chbiet (208) = 1160
c
c Aretes coupees :   5  9 11
      chclas (1296) = ' 3-07'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0
      charde (1296)(1:9) = '  5  9 11'
      chnp1 (1296) = 1
      chnar (1296) = 13
      chnpy (1296) = 8
      chnte (1296) = 6
      chnhe (1296) = 0
      chperm (1296) = 100
      chbirf (1296) = 35
      chetat (1296) = 209
      chtn2i (1296) = 210
      chbiet (209) = 1296
c
c Aretes coupees :   6 11 12
      chclas (3104) = ' 3-07'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1
      charde (3104)(1:9) = '  6 11 12'
      chnp1 (3104) = 1
      chnar (3104) = 13
      chnpy (3104) = 8
      chnte (3104) = 6
      chnhe (3104) = 0
      chperm (3104) = 110
      chbirf (3104) = 35
      chetat (3104) = 210
      chtn2i (3104) = 210
      chbiet (210) = 3104
c
c Aretes coupees :   7  9 10
      chclas (832) = ' 3-07'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 0
      charde (832)(1:9) = '  7  9 10'
      chnp1 (832) = 1
      chnar (832) = 13
      chnpy (832) = 8
      chnte (832) = 6
      chnhe (832) = 0
      chperm (832) = 130
      chbirf (832) = 35
      chetat (832) = 211
      chtn2i (832) = 210
      chbiet (211) = 832
c
c Aretes coupees :   8 10 12
      chclas (2688) = ' 3-07'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1
      charde (2688)(1:9) = '  8 10 12'
      chnp1 (2688) = 1
      chnar (2688) = 13
      chnpy (2688) = 8
      chnte (2688) = 6
      chnhe (2688) = 0
      chperm (2688) = 200
      chbirf (2688) = 35
      chetat (2688) = 212
      chtn2i (2688) = 210
      chbiet (212) = 2688
c
c ===========================================
c Classe d'equivalence  3-08
c
c Aretes coupees :   1  2  7
      chclas (67) = ' 3-08'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0
      charde (67)(1:9) = '  1  2  7'
      chnp1 (67) = 1
      chnar (67) = 13
      chnpy (67) = 8
      chnte (67) = 6
      chnhe (67) = 0
      chperm (67) = 0
      chbirf (67) = 67
      chetat (67) = 213
      chtn2i (67) = 210
      chbiet (213) = 67
c
c Aretes coupees :   1  3  5
      chclas (21) = ' 3-08'
c Code des aretes coupees : 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0
      charde (21)(1:9) = '  1  3  5'
      chnp1 (21) = 1
      chnar (21) = 13
      chnpy (21) = 8
      chnte (21) = 6
      chnhe (21) = 0
      chperm (21) = 101
      chbirf (21) = 67
      chetat (21) = 214
      chtn2i (21) = 210
      chbiet (214) = 21
c
c Aretes coupees :   1  6 11
      chclas (1057) = ' 3-08'
c Code des aretes coupees : 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0
      charde (1057)(1:9) = '  1  6 11'
      chnp1 (1057) = 1
      chnar (1057) = 13
      chnpy (1057) = 8
      chnte (1057) = 6
      chnhe (1057) = 0
      chperm (1057) = 110
      chbirf (1057) = 67
      chetat (1057) = 215
      chtn2i (1057) = 210
      chbiet (215) = 1057
c
c Aretes coupees :   2  4  8
      chclas (138) = ' 3-08'
c Code des aretes coupees : 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0
      charde (138)(1:9) = '  2  4  8'
      chnp1 (138) = 1
      chnar (138) = 13
      chnpy (138) = 8
      chnte (138) = 6
      chnhe (138) = 0
      chperm (138) = 1
      chbirf (138) = 67
      chetat (138) = 216
      chtn2i (138) = 210
      chbiet (216) = 138
c
c Aretes coupees :   2  5  9
      chclas (274) = ' 3-08'
c Code des aretes coupees : 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0
      charde (274)(1:9) = '  2  5  9'
      chnp1 (274) = 1
      chnar (274) = 13
      chnpy (274) = 8
      chnte (274) = 6
      chnhe (274) = 0
      chperm (274) = 100
      chbirf (274) = 67
      chetat (274) = 217
      chtn2i (274) = 210
      chbiet (217) = 274
c
c Aretes coupees :   3  4  6
      chclas (44) = ' 3-08'
c Code des aretes coupees : 0, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0
      charde (44)(1:9) = '  3  4  6'
      chnp1 (44) = 1
      chnar (44) = 13
      chnpy (44) = 8
      chnte (44) = 6
      chnhe (44) = 0
      chperm (44) = 10
      chbirf (44) = 67
      chetat (44) = 218
      chtn2i (44) = 210
      chbiet (218) = 44
c
c Aretes coupees :   3  8 12
      chclas (2180) = ' 3-08'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1
      charde (2180)(1:9) = '  3  8 12'
      chnp1 (2180) = 1
      chnar (2180) = 13
      chnpy (2180) = 8
      chnte (2180) = 6
      chnhe (2180) = 0
      chperm (2180) = 310
      chbirf (2180) = 67
      chetat (2180) = 219
      chtn2i (2180) = 210
      chbiet (219) = 2180
c
c Aretes coupees :   4  7 10
      chclas (584) = ' 3-08'
c Code des aretes coupees : 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0
      charde (584)(1:9) = '  4  7 10'
      chnp1 (584) = 1
      chnar (584) = 13
      chnpy (584) = 8
      chnte (584) = 6
      chnhe (584) = 0
      chperm (584) = 300
      chbirf (584) = 67
      chetat (584) = 220
      chtn2i (584) = 210
      chbiet (220) = 584
c
c Aretes coupees :   5 10 12
      chclas (2576) = ' 3-08'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1
      charde (2576)(1:9) = '  5 10 12'
      chnp1 (2576) = 1
      chnar (2576) = 13
      chnpy (2576) = 8
      chnte (2576) = 6
      chnhe (2576) = 0
      chperm (2576) = 200
      chbirf (2576) = 67
      chetat (2576) = 221
      chtn2i (2576) = 210
      chbiet (221) = 2576
c
c Aretes coupees :   6  9 10
      chclas (800) = ' 3-08'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0
      charde (800)(1:9) = '  6  9 10'
      chnp1 (800) = 1
      chnar (800) = 13
      chnpy (800) = 8
      chnte (800) = 6
      chnhe (800) = 0
      chperm (800) = 201
      chbirf (800) = 67
      chetat (800) = 222
      chtn2i (800) = 210
      chbiet (222) = 800
c
c Aretes coupees :   7 11 12
      chclas (3136) = ' 3-08'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1
      charde (3136)(1:9) = '  7 11 12'
      chnp1 (3136) = 1
      chnar (3136) = 13
      chnpy (3136) = 8
      chnte (3136) = 6
      chnhe (3136) = 0
      chperm (3136) = 301
      chbirf (3136) = 67
      chetat (3136) = 223
      chtn2i (3136) = 210
      chbiet (223) = 3136
c
c Aretes coupees :   8  9 11
      chclas (1408) = ' 3-08'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0
      charde (1408)(1:9) = '  8  9 11'
      chnp1 (1408) = 1
      chnar (1408) = 13
      chnpy (1408) = 8
      chnte (1408) = 6
      chnhe (1408) = 0
      chperm (1408) = 210
      chbirf (1408) = 67
      chetat (1408) = 224
      chtn2i (1408) = 210
      chbiet (224) = 1408
c
c ===========================================
c Classe d'equivalence  3-09
c
c Aretes coupees :   1  2  8
      chclas (131) = ' 3-09'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0
      charde (131)(1:9) = '  1  2  8'
      chnp1 (131) = 1
      chnar (131) = 12
      chnpy (131) = 4
      chnte (131) = 12
      chnhe (131) = 0
      chperm (131) = 0
      chbirf (131) = 131
      chetat (131) = 225
      chtn2i (131) = 210
      chbiet (225) = 131
c
c Aretes coupees :   1  3  7
      chclas (69) = ' 3-09'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0
      charde (69)(1:9) = '  1  3  7'
      chnp1 (69) = 1
      chnar (69) = 12
      chnpy (69) = 4
      chnte (69) = 12
      chnhe (69) = 0
      chperm (69) = 221
      chbirf (69) = 131
      chetat (69) = 226
      chtn2i (69) = 210
      chbiet (226) = 69
c
c Aretes coupees :   1  5 11
      chclas (1041) = ' 3-09'
c Code des aretes coupees : 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0
      charde (1041)(1:9) = '  1  5 11'
      chnp1 (1041) = 1
      chnar (1041) = 12
      chnpy (1041) = 4
      chnte (1041) = 12
      chnhe (1041) = 0
      chperm (1041) = 101
      chbirf (1041) = 131
      chetat (1041) = 227
      chtn2i (1041) = 210
      chbiet (227) = 1041
c
c Aretes coupees :   1  6 10
      chclas (545) = ' 3-09'
c Code des aretes coupees : 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0
      charde (545)(1:9) = '  1  6 10'
      chnp1 (545) = 1
      chnar (545) = 12
      chnpy (545) = 4
      chnte (545) = 12
      chnhe (545) = 0
      chperm (545) = 320
      chbirf (545) = 131
      chetat (545) = 228
      chtn2i (545) = 210
      chbiet (228) = 545
c
c Aretes coupees :   1  7 10
      chclas (577) = ' 3-09'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0
      charde (577)(1:9) = '  1  7 10'
      chnp1 (577) = 1
      chnar (577) = 12
      chnpy (577) = 4
      chnte (577) = 12
      chnhe (577) = 0
      chperm (577) = 130
      chbirf (577) = 131
      chetat (577) = 229
      chtn2i (577) = 210
      chbiet (229) = 577
c
c Aretes coupees :   1  8 11
      chclas (1153) = ' 3-09'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0
      charde (1153)(1:9) = '  1  8 11'
      chnp1 (1153) = 1
      chnar (1153) = 12
      chnpy (1153) = 4
      chnte (1153) = 12
      chnhe (1153) = 0
      chperm (1153) = 210
      chbirf (1153) = 131
      chetat (1153) = 230
      chtn2i (1153) = 210
      chbiet (230) = 1153
c
c Aretes coupees :   2  4  6
      chclas (42) = ' 3-09'
c Code des aretes coupees : 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0
      charde (42)(1:9) = '  2  4  6'
      chnp1 (42) = 1
      chnar (42) = 12
      chnpy (42) = 4
      chnte (42) = 12
      chnhe (42) = 0
      chperm (42) = 1
      chbirf (42) = 131
      chetat (42) = 231
      chtn2i (42) = 210
      chbiet (231) = 42
c
c Aretes coupees :   2  5 12
      chclas (2066) = ' 3-09'
c Code des aretes coupees : 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1
      charde (2066)(1:9) = '  2  5 12'
      chnp1 (2066) = 1
      chnar (2066) = 12
      chnpy (2066) = 4
      chnte (2066) = 12
      chnhe (2066) = 0
      chperm (2066) = 330
      chbirf (2066) = 131
      chetat (2066) = 232
      chtn2i (2066) = 210
      chbiet (232) = 2066
c
c Aretes coupees :   2  6  9
      chclas (290) = ' 3-09'
c Code des aretes coupees : 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0
      charde (290)(1:9) = '  2  6  9'
      chnp1 (290) = 1
      chnar (290) = 12
      chnpy (290) = 4
      chnte (290) = 12
      chnhe (290) = 0
      chperm (290) = 321
      chbirf (290) = 131
      chetat (290) = 233
      chtn2i (290) = 210
      chbiet (233) = 290
c
c Aretes coupees :   2  7  9
      chclas (322) = ' 3-09'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0
      charde (322)(1:9) = '  2  7  9'
      chnp1 (322) = 1
      chnar (322) = 12
      chnpy (322) = 4
      chnte (322) = 12
      chnhe (322) = 0
      chperm (322) = 230
      chbirf (322) = 131
      chetat (322) = 234
      chtn2i (322) = 210
      chbiet (234) = 322
c
c Aretes coupees :   2  8 12
      chclas (2178) = ' 3-09'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1
      charde (2178)(1:9) = '  2  8 12'
      chnp1 (2178) = 1
      chnar (2178) = 12
      chnpy (2178) = 4
      chnte (2178) = 12
      chnhe (2178) = 0
      chperm (2178) = 120
      chbirf (2178) = 131
      chetat (2178) = 235
      chtn2i (2178) = 210
      chbiet (235) = 2178
c
c Aretes coupees :   3  4  5
      chclas (28) = ' 3-09'
c Code des aretes coupees : 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0
      charde (28)(1:9) = '  3  4  5'
      chnp1 (28) = 1
      chnar (28) = 12
      chnpy (28) = 4
      chnte (28) = 12
      chnhe (28) = 0
      chperm (28) = 220
      chbirf (28) = 131
      chetat (28) = 236
      chtn2i (28) = 210
      chbiet (236) = 28
c
c Aretes coupees :   3  5  9
      chclas (276) = ' 3-09'
c Code des aretes coupees : 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0
      charde (276)(1:9) = '  3  5  9'
      chnp1 (276) = 1
      chnar (276) = 12
      chnpy (276) = 4
      chnte (276) = 12
      chnhe (276) = 0
      chperm (276) = 100
      chbirf (276) = 131
      chetat (276) = 237
      chtn2i (276) = 210
      chbiet (237) = 276
c
c Aretes coupees :   3  6 12
      chclas (2084) = ' 3-09'
c Code des aretes coupees : 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1
      charde (2084)(1:9) = '  3  6 12'
      chnp1 (2084) = 1
      chnar (2084) = 12
      chnpy (2084) = 4
      chnte (2084) = 12
      chnhe (2084) = 0
      chperm (2084) = 10
      chbirf (2084) = 131
      chetat (2084) = 238
      chtn2i (2084) = 210
      chbiet (238) = 2084
c
c Aretes coupees :   3  7 12
      chclas (2116) = ' 3-09'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1
      charde (2116)(1:9) = '  3  7 12'
      chnp1 (2116) = 1
      chnar (2116) = 12
      chnpy (2116) = 4
      chnte (2116) = 12
      chnhe (2116) = 0
      chperm (2116) = 301
      chbirf (2116) = 131
      chetat (2116) = 239
      chtn2i (2116) = 210
      chbiet (239) = 2116
c
c Aretes coupees :   3  8  9
      chclas (388) = ' 3-09'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0
      charde (388)(1:9) = '  3  8  9'
      chnp1 (388) = 1
      chnar (388) = 12
      chnpy (388) = 4
      chnte (388) = 12
      chnhe (388) = 0
      chperm (388) = 310
      chbirf (388) = 131
      chetat (388) = 240
      chtn2i (388) = 210
      chbiet (240) = 388
c
c Aretes coupees :   4  5 10
      chclas (536) = ' 3-09'
c Code des aretes coupees : 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0
      charde (536)(1:9) = '  4  5 10'
      chnp1 (536) = 1
      chnar (536) = 12
      chnpy (536) = 4
      chnte (536) = 12
      chnhe (536) = 0
      chperm (536) = 30
      chbirf (536) = 131
      chetat (536) = 241
      chtn2i (536) = 210
      chbiet (241) = 536
c
c Aretes coupees :   4  6 11
      chclas (1064) = ' 3-09'
c Code des aretes coupees : 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0
      charde (1064)(1:9) = '  4  6 11'
      chnp1 (1064) = 1
      chnar (1064) = 12
      chnpy (1064) = 4
      chnte (1064) = 12
      chnhe (1064) = 0
      chperm (1064) = 110
      chbirf (1064) = 131
      chetat (1064) = 242
      chtn2i (1064) = 210
      chbiet (242) = 1064
c
c Aretes coupees :   4  7 11
      chclas (1096) = ' 3-09'
c Code des aretes coupees : 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0
      charde (1096)(1:9) = '  4  7 11'
      chnp1 (1096) = 1
      chnar (1096) = 12
      chnpy (1096) = 4
      chnte (1096) = 12
      chnhe (1096) = 0
      chperm (1096) = 300
      chbirf (1096) = 131
      chetat (1096) = 243
      chtn2i (1096) = 210
      chbiet (243) = 1096
c
c Aretes coupees :   4  8 10
      chclas (648) = ' 3-09'
c Code des aretes coupees : 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0
      charde (648)(1:9) = '  4  8 10'
      chnp1 (648) = 1
      chnar (648) = 12
      chnpy (648) = 4
      chnte (648) = 12
      chnhe (648) = 0
      chperm (648) = 121
      chbirf (648) = 131
      chetat (648) = 244
      chtn2i (648) = 210
      chbiet (244) = 648
c
c Aretes coupees :   5 11 12
      chclas (3088) = ' 3-09'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1
      charde (3088)(1:9) = '  5 11 12'
      chnp1 (3088) = 1
      chnar (3088) = 12
      chnpy (3088) = 4
      chnte (3088) = 12
      chnhe (3088) = 0
      chperm (3088) = 21
      chbirf (3088) = 131
      chetat (3088) = 245
      chtn2i (3088) = 210
      chbiet (245) = 3088
c
c Aretes coupees :   6 10 12
      chclas (2592) = ' 3-09'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1
      charde (2592)(1:9) = '  6 10 12'
      chnp1 (2592) = 1
      chnar (2592) = 12
      chnpy (2592) = 4
      chnte (2592) = 12
      chnhe (2592) = 0
      chperm (2592) = 200
      chbirf (2592) = 131
      chetat (2592) = 246
      chtn2i (2592) = 210
      chbiet (246) = 2592
c
c Aretes coupees :   7  9 11
      chclas (1344) = ' 3-09'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0
      charde (1344)(1:9) = '  7  9 11'
      chnp1 (1344) = 1
      chnar (1344) = 12
      chnpy (1344) = 4
      chnte (1344) = 12
      chnhe (1344) = 0
      chperm (1344) = 20
      chbirf (1344) = 131
      chetat (1344) = 247
      chtn2i (1344) = 210
      chbiet (247) = 1344
c
c Aretes coupees :   8  9 10
      chclas (896) = ' 3-09'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0
      charde (896)(1:9) = '  8  9 10'
      chnp1 (896) = 1
      chnar (896) = 12
      chnpy (896) = 4
      chnte (896) = 12
      chnhe (896) = 0
      chperm (896) = 201
      chbirf (896) = 131
      chetat (896) = 248
      chtn2i (896) = 210
      chbiet (248) = 896
c
c ===========================================
c Classe d'equivalence  3-10
c
c Aretes coupees :   1  4  9
      chclas (265) = ' 3-10'
c Code des aretes coupees : 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0
      charde (265)(1:9) = '  1  4  9'
      chnp1 (265) = 1
      chnar (265) = 11
      chnpy (265) = 6
      chnte (265) = 6
      chnhe (265) = 0
      chperm (265) = 0
      chbirf (265) = 265
      chetat (265) = 249
      chtn2i (265) = 70
      chbiet (249) = 265
c
c Aretes coupees :   1  4 12
      chclas (2057) = ' 3-10'
c Code des aretes coupees : 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1
      charde (2057)(1:9) = '  1  4 12'
      chnp1 (2057) = 1
      chnar (2057) = 11
      chnpy (2057) = 6
      chnte (2057) = 6
      chnhe (2057) = 0
      chperm (2057) = 300
      chbirf (2057) = 265
      chetat (2057) = 250
      chtn2i (2057) = 70
      chbiet (250) = 2057
c
c Aretes coupees :   1  9 12
      chclas (2305) = ' 3-10'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1
      charde (2305)(1:9) = '  1  9 12'
      chnp1 (2305) = 1
      chnar (2305) = 11
      chnpy (2305) = 6
      chnte (2305) = 6
      chnhe (2305) = 0
      chperm (2305) = 100
      chbirf (2305) = 265
      chetat (2305) = 251
      chtn2i (2305) = 70
      chbiet (251) = 2305
c
c Aretes coupees :   2  3 10
      chclas (518) = ' 3-10'
c Code des aretes coupees : 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0
      charde (518)(1:9) = '  2  3 10'
      chnp1 (518) = 1
      chnar (518) = 11
      chnpy (518) = 6
      chnte (518) = 6
      chnhe (518) = 0
      chperm (518) = 330
      chbirf (518) = 265
      chetat (518) = 252
      chtn2i (518) = 70
      chbiet (252) = 518
c
c Aretes coupees :   2  3 11
      chclas (1030) = ' 3-10'
c Code des aretes coupees : 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0
      charde (1030)(1:9) = '  2  3 11'
      chnp1 (1030) = 1
      chnar (1030) = 11
      chnpy (1030) = 6
      chnte (1030) = 6
      chnhe (1030) = 0
      chperm (1030) = 310
      chbirf (1030) = 265
      chetat (1030) = 253
      chtn2i (1030) = 70
      chbiet (253) = 1030
c
c Aretes coupees :   2 10 11
      chclas (1538) = ' 3-10'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0
      charde (1538)(1:9) = '  2 10 11'
      chnp1 (1538) = 1
      chnar (1538) = 11
      chnpy (1538) = 6
      chnte (1538) = 6
      chnhe (1538) = 0
      chperm (1538) = 130
      chbirf (1538) = 265
      chetat (1538) = 254
      chtn2i (1538) = 70
      chbiet (254) = 1538
c
c Aretes coupees :   3 10 11
      chclas (1540) = ' 3-10'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0
      charde (1540)(1:9) = '  3 10 11'
      chnp1 (1540) = 1
      chnar (1540) = 11
      chnpy (1540) = 6
      chnte (1540) = 6
      chnhe (1540) = 0
      chperm (1540) = 110
      chbirf (1540) = 265
      chetat (1540) = 255
      chtn2i (1540) = 70
      chbiet (255) = 1540
c
c Aretes coupees :   4  9 12
      chclas (2312) = ' 3-10'
c Code des aretes coupees : 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1
      charde (2312)(1:9) = '  4  9 12'
      chnp1 (2312) = 1
      chnar (2312) = 11
      chnpy (2312) = 6
      chnte (2312) = 6
      chnhe (2312) = 0
      chperm (2312) = 200
      chbirf (2312) = 265
      chetat (2312) = 256
      chtn2i (2312) = 70
      chbiet (256) = 2312
c
c Aretes coupees :   5  6  7
      chclas (112) = ' 3-10'
c Code des aretes coupees : 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0
      charde (112)(1:9) = '  5  6  7'
      chnp1 (112) = 1
      chnar (112) = 11
      chnpy (112) = 6
      chnte (112) = 6
      chnhe (112) = 0
      chperm (112) = 30
      chbirf (112) = 265
      chetat (112) = 257
      chtn2i (112) = 70
      chbiet (257) = 112
c
c Aretes coupees :   5  6  8
      chclas (176) = ' 3-10'
c Code des aretes coupees : 0, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 0
      charde (176)(1:9) = '  5  6  8'
      chnp1 (176) = 1
      chnar (176) = 11
      chnpy (176) = 6
      chnte (176) = 6
      chnhe (176) = 0
      chperm (176) = 10
      chbirf (176) = 265
      chetat (176) = 258
      chtn2i (176) = 70
      chbiet (258) = 176
c
c Aretes coupees :   5  7  8
      chclas (208) = ' 3-10'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0
      charde (208)(1:9) = '  5  7  8'
      chnp1 (208) = 1
      chnar (208) = 11
      chnpy (208) = 6
      chnte (208) = 6
      chnhe (208) = 0
      chperm (208) = 230
      chbirf (208) = 265
      chetat (208) = 259
      chtn2i (208) = 70
      chbiet (259) = 208
c
c Aretes coupees :   6  7  8
      chclas (224) = ' 3-10'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0
      charde (224)(1:9) = '  6  7  8'
      chnp1 (224) = 1
      chnar (224) = 11
      chnpy (224) = 6
      chnte (224) = 6
      chnhe (224) = 0
      chperm (224) = 210
      chbirf (224) = 265
      chetat (224) = 260
      chtn2i (224) = 70
      chbiet (260) = 224
c
c ===========================================
c Classe d'equivalence  3-11
c
c Aretes coupees :   1  4 10
      chclas (521) = ' 3-11'
c Code des aretes coupees : 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0
      charde (521)(1:9) = '  1  4 10'
      chnp1 (521) = 1
      chnar (521) = 11
      chnpy (521) = 3
      chnte (521) = 12
      chnhe (521) = 0
      chperm (521) = 0
      chbirf (521) = 521
      chetat (521) = 261
      chtn2i (521) = 70
      chbiet (261) = 521
c
c Aretes coupees :   1  4 11
      chclas (1033) = ' 3-11'
c Code des aretes coupees : 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0
      charde (1033)(1:9) = '  1  4 11'
      chnp1 (1033) = 1
      chnar (1033) = 11
      chnpy (1033) = 3
      chnte (1033) = 12
      chnhe (1033) = 0
      chperm (1033) = 220
      chbirf (1033) = 521
      chetat (1033) = 262
      chtn2i (1033) = 70
      chbiet (262) = 1033
c
c Aretes coupees :   1  7  8
      chclas (193) = ' 3-11'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0
      charde (193)(1:9) = '  1  7  8'
      chnp1 (193) = 1
      chnar (193) = 11
      chnpy (193) = 3
      chnte (193) = 12
      chnhe (193) = 0
      chperm (193) = 121
      chbirf (193) = 521
      chetat (193) = 263
      chtn2i (193) = 70
      chbiet (263) = 193
c
c Aretes coupees :   1  7  9
      chclas (321) = ' 3-11'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0
      charde (321)(1:9) = '  1  7  9'
      chnp1 (321) = 1
      chnar (321) = 11
      chnpy (321) = 3
      chnte (321) = 12
      chnhe (321) = 0
      chperm (321) = 100
      chbirf (321) = 521
      chetat (321) = 264
      chtn2i (321) = 70
      chbiet (264) = 321
c
c Aretes coupees :   1  8  9
      chclas (385) = ' 3-11'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0
      charde (385)(1:9) = '  1  8  9'
      chnp1 (385) = 1
      chnar (385) = 11
      chnpy (385) = 3
      chnte (385) = 12
      chnhe (385) = 0
      chperm (385) = 320
      chbirf (385) = 521
      chetat (385) = 265
      chtn2i (385) = 70
      chbiet (265) = 385
c
c Aretes coupees :   1 10 11
      chclas (1537) = ' 3-11'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0
      charde (1537)(1:9) = '  1 10 11'
      chnp1 (1537) = 1
      chnar (1537) = 11
      chnpy (1537) = 3
      chnte (1537) = 12
      chnhe (1537) = 0
      chperm (1537) = 201
      chbirf (1537) = 521
      chetat (1537) = 266
      chtn2i (1537) = 70
      chbiet (266) = 1537
c
c Aretes coupees :   2  3  9
      chclas (262) = ' 3-11'
c Code des aretes coupees : 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0
      charde (262)(1:9) = '  2  3  9'
      chnp1 (262) = 1
      chnar (262) = 11
      chnpy (262) = 3
      chnte (262) = 12
      chnhe (262) = 0
      chperm (262) = 221
      chbirf (262) = 521
      chetat (262) = 267
      chtn2i (262) = 70
      chbiet (267) = 262
c
c Aretes coupees :   2  3 12
      chclas (2054) = ' 3-11'
c Code des aretes coupees : 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1
      charde (2054)(1:9) = '  2  3 12'
      chnp1 (2054) = 1
      chnar (2054) = 11
      chnpy (2054) = 3
      chnte (2054) = 12
      chnhe (2054) = 0
      chperm (2054) = 1
      chbirf (2054) = 521
      chetat (2054) = 268
      chtn2i (2054) = 70
      chbiet (268) = 2054
c
c Aretes coupees :   2  6  8
      chclas (162) = ' 3-11'
c Code des aretes coupees : 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0
      charde (162)(1:9) = '  2  6  8'
      chnp1 (162) = 1
      chnar (162) = 11
      chnpy (162) = 3
      chnte (162) = 12
      chnhe (162) = 0
      chperm (162) = 10
      chbirf (162) = 521
      chetat (162) = 269
      chtn2i (162) = 70
      chbiet (269) = 162
c
c Aretes coupees :   2  6 10
      chclas (546) = ' 3-11'
c Code des aretes coupees : 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0
      charde (546)(1:9) = '  2  6 10'
      chnp1 (546) = 1
      chnar (546) = 11
      chnpy (546) = 3
      chnte (546) = 12
      chnhe (546) = 0
      chperm (546) = 330
      chbirf (546) = 521
      chetat (546) = 270
      chtn2i (546) = 70
      chbiet (270) = 546
c
c Aretes coupees :   2  8 10
      chclas (642) = ' 3-11'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0
      charde (642)(1:9) = '  2  8 10'
      chnp1 (642) = 1
      chnar (642) = 11
      chnpy (642) = 3
      chnte (642) = 12
      chnhe (642) = 0
      chperm (642) = 130
      chbirf (642) = 521
      chetat (642) = 271
      chtn2i (642) = 70
      chbiet (271) = 642
c
c Aretes coupees :   2  9 12
      chclas (2306) = ' 3-11'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1
      charde (2306)(1:9) = '  2  9 12'
      chnp1 (2306) = 1
      chnar (2306) = 11
      chnpy (2306) = 3
      chnte (2306) = 12
      chnhe (2306) = 0
      chperm (2306) = 200
      chbirf (2306) = 521
      chetat (2306) = 272
      chtn2i (2306) = 70
      chbiet (272) = 2306
c
c Aretes coupees :   3  5  7
      chclas (84) = ' 3-11'
c Code des aretes coupees : 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0
      charde (84)(1:9) = '  3  5  7'
      chnp1 (84) = 1
      chnar (84) = 11
      chnpy (84) = 3
      chnte (84) = 12
      chnhe (84) = 0
      chperm (84) = 230
      chbirf (84) = 521
      chetat (84) = 273
      chtn2i (84) = 70
      chbiet (273) = 84
c
c Aretes coupees :   3  5 11
      chclas (1044) = ' 3-11'
c Code des aretes coupees : 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0
      charde (1044)(1:9) = '  3  5 11'
      chnp1 (1044) = 1
      chnar (1044) = 11
      chnpy (1044) = 3
      chnte (1044) = 12
      chnhe (1044) = 0
      chperm (1044) = 110
      chbirf (1044) = 521
      chetat (1044) = 274
      chtn2i (1044) = 70
      chbiet (274) = 1044
c
c Aretes coupees :   3  7 11
      chclas (1092) = ' 3-11'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0
      charde (1092)(1:9) = '  3  7 11'
      chnp1 (1092) = 1
      chnar (1092) = 11
      chnpy (1092) = 3
      chnte (1092) = 12
      chnhe (1092) = 0
      chperm (1092) = 310
      chbirf (1092) = 521
      chetat (1092) = 275
      chtn2i (1092) = 70
      chbiet (275) = 1092
c
c Aretes coupees :   3  9 12
      chclas (2308) = ' 3-11'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1
      charde (2308)(1:9) = '  3  9 12'
      chnp1 (2308) = 1
      chnar (2308) = 11
      chnpy (2308) = 3
      chnte (2308) = 12
      chnhe (2308) = 0
      chperm (2308) = 20
      chbirf (2308) = 521
      chetat (2308) = 276
      chtn2i (2308) = 70
      chbiet (276) = 2308
c
c Aretes coupees :   4  5  6
      chclas (56) = ' 3-11'
c Code des aretes coupees : 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0
      charde (56)(1:9) = '  4  5  6'
      chnp1 (56) = 1
      chnar (56) = 11
      chnpy (56) = 3
      chnte (56) = 12
      chnhe (56) = 0
      chperm (56) = 101
      chbirf (56) = 521
      chetat (56) = 277
      chtn2i (56) = 70
      chbiet (277) = 56
c
c Aretes coupees :   4  5 12
      chclas (2072) = ' 3-11'
c Code des aretes coupees : 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1
      charde (2072)(1:9) = '  4  5 12'
      chnp1 (2072) = 1
      chnar (2072) = 11
      chnpy (2072) = 3
      chnte (2072) = 12
      chnhe (2072) = 0
      chperm (2072) = 300
      chbirf (2072) = 521
      chetat (2072) = 278
      chtn2i (2072) = 70
      chbiet (278) = 2072
c
c Aretes coupees :   4  6 12
      chclas (2088) = ' 3-11'
c Code des aretes coupees : 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1
      charde (2088)(1:9) = '  4  6 12'
      chnp1 (2088) = 1
      chnar (2088) = 11
      chnpy (2088) = 3
      chnte (2088) = 12
      chnhe (2088) = 0
      chperm (2088) = 120
      chbirf (2088) = 521
      chetat (2088) = 279
      chtn2i (2088) = 70
      chbiet (279) = 2088
c
c Aretes coupees :   4 10 11
      chclas (1544) = ' 3-11'
c Code des aretes coupees : 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0
      charde (1544)(1:9) = '  4 10 11'
      chnp1 (1544) = 1
      chnar (1544) = 11
      chnpy (1544) = 3
      chnte (1544) = 12
      chnhe (1544) = 0
      chperm (1544) = 21
      chbirf (1544) = 521
      chetat (1544) = 280
      chtn2i (1544) = 70
      chbiet (280) = 1544
c
c Aretes coupees :   5  6 12
      chclas (2096) = ' 3-11'
c Code des aretes coupees : 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1
      charde (2096)(1:9) = '  5  6 12'
      chnp1 (2096) = 1
      chnar (2096) = 11
      chnpy (2096) = 3
      chnte (2096) = 12
      chnhe (2096) = 0
      chperm (2096) = 321
      chbirf (2096) = 521
      chetat (2096) = 281
      chtn2i (2096) = 70
      chbiet (281) = 2096
c
c Aretes coupees :   5  7 11
      chclas (1104) = ' 3-11'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0
      charde (1104)(1:9) = '  5  7 11'
      chnp1 (1104) = 1
      chnar (1104) = 11
      chnpy (1104) = 3
      chnte (1104) = 12
      chnhe (1104) = 0
      chperm (1104) = 30
      chbirf (1104) = 521
      chetat (1104) = 282
      chtn2i (1104) = 70
      chbiet (282) = 1104
c
c Aretes coupees :   6  8 10
      chclas (672) = ' 3-11'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0
      charde (672)(1:9) = '  6  8 10'
      chnp1 (672) = 1
      chnar (672) = 11
      chnpy (672) = 3
      chnte (672) = 12
      chnhe (672) = 0
      chperm (672) = 210
      chbirf (672) = 521
      chetat (672) = 283
      chtn2i (672) = 70
      chbiet (283) = 672
c
c Aretes coupees :   7  8  9
      chclas (448) = ' 3-11'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0
      charde (448)(1:9) = '  7  8  9'
      chnp1 (448) = 1
      chnar (448) = 11
      chnpy (448) = 3
      chnte (448) = 12
      chnhe (448) = 0
      chperm (448) = 301
      chbirf (448) = 521
      chetat (448) = 284
      chtn2i (448) = 70
      chbiet (284) = 448
c
c ===========================================
c Classe d'equivalence  4-00
c
c Aretes coupees :   1  2  3  4
      chclas (15) = ' 4-00'
c Code des aretes coupees : 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0
      charde (15)(1:12) = '  1  2  3  4'
      chnp1 (15) = 0
      chnar (15) = 4
      chnpy (15) = 5
      chnte (15) = 4
      chnhe (15) = 0
      chperm (15) = 0
      chbirf (15) = 15
      chetat (15) = 285
      chtn2i (15) = 13
      chbiet (285) = 15
c
c Aretes coupees :   1  5  6  9
      chclas (305) = ' 4-00'
c Code des aretes coupees : 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0
      charde (305)(1:12) = '  1  5  6  9'
      chnp1 (305) = 0
      chnar (305) = 4
      chnpy (305) = 5
      chnte (305) = 4
      chnhe (305) = 0
      chperm (305) = 100
      chbirf (305) = 15
      chetat (305) = 286
      chtn2i (305) = 13
      chbiet (286) = 305
c
c Aretes coupees :   2  5  7 10
      chclas (594) = ' 4-00'
c Code des aretes coupees : 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0
      charde (594)(1:12) = '  2  5  7 10'
      chnp1 (594) = 0
      chnar (594) = 4
      chnpy (594) = 5
      chnte (594) = 4
      chnhe (594) = 0
      chperm (594) = 30
      chbirf (594) = 15
      chetat (594) = 287
      chtn2i (594) = 13
      chbiet (287) = 594
c
c Aretes coupees :   3  6  8 11
      chclas (1188) = ' 4-00'
c Code des aretes coupees : 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0
      charde (1188)(1:12) = '  3  6  8 11'
      chnp1 (1188) = 0
      chnar (1188) = 4
      chnpy (1188) = 5
      chnte (1188) = 4
      chnhe (1188) = 0
      chperm (1188) = 10
      chbirf (1188) = 15
      chetat (1188) = 288
      chtn2i (1188) = 13
      chbiet (288) = 1188
c
c Aretes coupees :   4  7  8 12
      chclas (2248) = ' 4-00'
c Code des aretes coupees : 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1
      charde (2248)(1:12) = '  4  7  8 12'
      chnp1 (2248) = 0
      chnar (2248) = 4
      chnpy (2248) = 5
      chnte (2248) = 4
      chnhe (2248) = 0
      chperm (2248) = 300
      chbirf (2248) = 15
      chetat (2248) = 289
      chtn2i (2248) = 13
      chbiet (289) = 2248
c
c Aretes coupees :   9 10 11 12
      chclas (3840) = ' 4-00'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1
      charde (3840)(1:12) = '  9 10 11 12'
      chnp1 (3840) = 0
      chnar (3840) = 4
      chnpy (3840) = 5
      chnte (3840) = 4
      chnhe (3840) = 0
      chperm (3840) = 200
      chbirf (3840) = 15
      chetat (3840) = 290
      chtn2i (3840) = 13
      chbiet (290) = 3840
c
c ===========================================
c Classe d'equivalence  4-01
c
c Aretes coupees :   1  2  9 10
      chclas (771) = ' 4-01'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0
      charde (771)(1:12) = '  1  2  9 10'
      chnp1 (771) = 1
      chnar (771) = 14
      chnpy (771) = 12
      chnte (771) = 0
      chnhe (771) = 0
      chperm (771) = 0
      chbirf (771) = 771
      chetat (771) = 291
      chtn2i (771) = 210
      chbiet (291) = 771
c
c Aretes coupees :   1  3  9 11
      chclas (1285) = ' 4-01'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0
      charde (1285)(1:12) = '  1  3  9 11'
      chnp1 (1285) = 1
      chnar (1285) = 14
      chnpy (1285) = 12
      chnte (1285) = 0
      chnhe (1285) = 0
      chperm (1285) = 20
      chbirf (1285) = 771
      chetat (1285) = 292
      chtn2i (1285) = 210
      chbiet (292) = 1285
c
c Aretes coupees :   1  4  5  7
      chclas (89) = ' 4-01'
c Code des aretes coupees : 1, 0, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0
      charde (89)(1:12) = '  1  4  5  7'
      chnp1 (89) = 1
      chnar (89) = 14
      chnpy (89) = 12
      chnte (89) = 0
      chnhe (89) = 0
      chperm (89) = 300
      chbirf (89) = 771
      chetat (89) = 293
      chtn2i (89) = 210
      chbiet (293) = 89
c
c Aretes coupees :   1  4  6  8
      chclas (169) = ' 4-01'
c Code des aretes coupees : 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0
      charde (169)(1:12) = '  1  4  6  8'
      chnp1 (169) = 1
      chnar (169) = 14
      chnpy (169) = 12
      chnte (169) = 0
      chnhe (169) = 0
      chperm (169) = 320
      chbirf (169) = 771
      chetat (169) = 294
      chtn2i (169) = 210
      chbiet (294) = 169
c
c Aretes coupees :   2  3  5  6
      chclas (54) = ' 4-01'
c Code des aretes coupees : 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0
      charde (54)(1:12) = '  2  3  5  6'
      chnp1 (54) = 1
      chnar (54) = 14
      chnpy (54) = 12
      chnte (54) = 0
      chnhe (54) = 0
      chperm (54) = 10
      chbirf (54) = 771
      chetat (54) = 295
      chtn2i (54) = 210
      chbiet (295) = 54
c
c Aretes coupees :   2  3  7  8
      chclas (198) = ' 4-01'
c Code des aretes coupees : 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0
      charde (198)(1:12) = '  2  3  7  8'
      chnp1 (198) = 1
      chnar (198) = 14
      chnpy (198) = 12
      chnte (198) = 0
      chnhe (198) = 0
      chperm (198) = 310
      chbirf (198) = 771
      chetat (198) = 296
      chtn2i (198) = 210
      chbiet (296) = 198
c
c Aretes coupees :   2  4 10 12
      chclas (2570) = ' 4-01'
c Code des aretes coupees : 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1
      charde (2570)(1:12) = '  2  4 10 12'
      chnp1 (2570) = 1
      chnar (2570) = 14
      chnpy (2570) = 12
      chnte (2570) = 0
      chnhe (2570) = 0
      chperm (2570) = 200
      chbirf (2570) = 771
      chetat (2570) = 297
      chtn2i (2570) = 210
      chbiet (297) = 2570
c
c Aretes coupees :   3  4 11 12
      chclas (3084) = ' 4-01'
c Code des aretes coupees : 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1
      charde (3084)(1:12) = '  3  4 11 12'
      chnp1 (3084) = 1
      chnar (3084) = 14
      chnpy (3084) = 12
      chnte (3084) = 0
      chnhe (3084) = 0
      chperm (3084) = 220
      chbirf (3084) = 771
      chetat (3084) = 298
      chtn2i (3084) = 210
      chbiet (298) = 3084
c
c Aretes coupees :   5  6 10 11
      chclas (1584) = ' 4-01'
c Code des aretes coupees : 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0
      charde (1584)(1:12) = '  5  6 10 11'
      chnp1 (1584) = 1
      chnar (1584) = 14
      chnpy (1584) = 12
      chnte (1584) = 0
      chnhe (1584) = 0
      chperm (1584) = 110
      chbirf (1584) = 771
      chetat (1584) = 299
      chtn2i (1584) = 210
      chbiet (299) = 1584
c
c Aretes coupees :   5  7  9 12
      chclas (2384) = ' 4-01'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1
      charde (2384)(1:12) = '  5  7  9 12'
      chnp1 (2384) = 1
      chnar (2384) = 14
      chnpy (2384) = 12
      chnte (2384) = 0
      chnhe (2384) = 0
      chperm (2384) = 100
      chbirf (2384) = 771
      chetat (2384) = 300
      chtn2i (2384) = 210
      chbiet (300) = 2384
c
c Aretes coupees :   6  8  9 12
      chclas (2464) = ' 4-01'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 0, 1
      charde (2464)(1:12) = '  6  8  9 12'
      chnp1 (2464) = 1
      chnar (2464) = 14
      chnpy (2464) = 12
      chnte (2464) = 0
      chnhe (2464) = 0
      chperm (2464) = 120
      chbirf (2464) = 771
      chetat (2464) = 301
      chtn2i (2464) = 210
      chbiet (301) = 2464
c
c Aretes coupees :   7  8 10 11
      chclas (1728) = ' 4-01'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0
      charde (1728)(1:12) = '  7  8 10 11'
      chnp1 (1728) = 1
      chnar (1728) = 14
      chnpy (1728) = 12
      chnte (1728) = 0
      chnhe (1728) = 0
      chperm (1728) = 210
      chbirf (1728) = 771
      chetat (1728) = 302
      chtn2i (1728) = 210
      chbiet (302) = 1728
c
c ===========================================
c Classe d'equivalence  4-02
c
c Aretes coupees :   1  2  9 11
      chclas (1283) = ' 4-02'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0
      charde (1283)(1:12) = '  1  2  9 11'
      chnp1 (1283) = 1
      chnar (1283) = 14
      chnpy (1283) = 9
      chnte (1283) = 6
      chnhe (1283) = 0
      chperm (1283) = 0
      chbirf (1283) = 1283
      chetat (1283) = 303
      chtn2i (1283) = 210
      chbiet (303) = 1283
c
c Aretes coupees :   1  3 11 12
      chclas (3077) = ' 4-02'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1
      charde (3077)(1:12) = '  1  3 11 12'
      chnp1 (3077) = 1
      chnar (3077) = 14
      chnpy (3077) = 9
      chnte (3077) = 6
      chnhe (3077) = 0
      chperm (3077) = 21
      chbirf (3077) = 1283
      chetat (3077) = 304
      chtn2i (3077) = 210
      chbiet (304) = 3077
c
c Aretes coupees :   1  4  6  7
      chclas (105) = ' 4-02'
c Code des aretes coupees : 1, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0
      charde (105)(1:12) = '  1  4  6  7'
      chnp1 (105) = 1
      chnar (105) = 14
      chnpy (105) = 9
      chnte (105) = 6
      chnhe (105) = 0
      chperm (105) = 300
      chbirf (105) = 1283
      chetat (105) = 305
      chtn2i (105) = 210
      chbiet (305) = 105
c
c Aretes coupees :   1  5  7 12
      chclas (2129) = ' 4-02'
c Code des aretes coupees : 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1
      charde (2129)(1:12) = '  1  5  7 12'
      chnp1 (2129) = 1
      chnar (2129) = 14
      chnpy (2129) = 9
      chnte (2129) = 6
      chnhe (2129) = 0
      chperm (2129) = 101
      chbirf (2129) = 1283
      chetat (2129) = 306
      chtn2i (2129) = 210
      chbiet (306) = 2129
c
c Aretes coupees :   2  3  5  8
      chclas (150) = ' 4-02'
c Code des aretes coupees : 0, 1, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0
      charde (150)(1:12) = '  2  3  5  8'
      chnp1 (150) = 1
      chnar (150) = 14
      chnpy (150) = 9
      chnte (150) = 6
      chnhe (150) = 0
      chperm (150) = 310
      chbirf (150) = 1283
      chetat (150) = 307
      chtn2i (150) = 210
      chbiet (307) = 150
c
c Aretes coupees :   2  4  9 10
      chclas (778) = ' 4-02'
c Code des aretes coupees : 0, 1, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0
      charde (778)(1:12) = '  2  4  9 10'
      chnp1 (778) = 1
      chnar (778) = 14
      chnpy (778) = 9
      chnte (778) = 6
      chnhe (778) = 0
      chperm (778) = 1
      chbirf (778) = 1283
      chetat (778) = 308
      chtn2i (778) = 210
      chbiet (308) = 778
c
c Aretes coupees :   2  7  8 11
      chclas (1218) = ' 4-02'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0
      charde (1218)(1:12) = '  2  7  8 11'
      chnp1 (1218) = 1
      chnar (1218) = 14
      chnpy (1218) = 9
      chnte (1218) = 6
      chnhe (1218) = 0
      chperm (1218) = 210
      chbirf (1218) = 1283
      chetat (1218) = 309
      chtn2i (1218) = 210
      chbiet (309) = 1218
c
c Aretes coupees :   3  4 10 12
      chclas (2572) = ' 4-02'
c Code des aretes coupees : 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1
      charde (2572)(1:12) = '  3  4 10 12'
      chnp1 (2572) = 1
      chnar (2572) = 14
      chnpy (2572) = 9
      chnte (2572) = 6
      chnhe (2572) = 0
      chperm (2572) = 200
      chbirf (2572) = 1283
      chetat (2572) = 310
      chtn2i (2572) = 210
      chbiet (310) = 2572
c
c Aretes coupees :   3  5  6 10
      chclas (564) = ' 4-02'
c Code des aretes coupees : 0, 0, 1, 0, 1, 1, 0, 0, 0, 1, 0, 0
      charde (564)(1:12) = '  3  5  6 10'
      chnp1 (564) = 1
      chnar (564) = 14
      chnpy (564) = 9
      chnte (564) = 6
      chnhe (564) = 0
      chperm (564) = 10
      chbirf (564) = 1283
      chetat (564) = 311
      chtn2i (564) = 210
      chbiet (311) = 564
c
c Aretes coupees :   4  6  8  9
      chclas (424) = ' 4-02'
c Code des aretes coupees : 0, 0, 0, 1, 0, 1, 0, 1, 1, 0, 0, 0
      charde (424)(1:12) = '  4  6  8  9'
      chnp1 (424) = 1
      chnar (424) = 14
      chnpy (424) = 9
      chnte (424) = 6
      chnhe (424) = 0
      chperm (424) = 121
      chbirf (424) = 1283
      chetat (424) = 312
      chtn2i (424) = 210
      chbiet (312) = 424
c
c Aretes coupees :   5  8  9 12
      chclas (2448) = ' 4-02'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1
      charde (2448)(1:12) = '  5  8  9 12'
      chnp1 (2448) = 1
      chnar (2448) = 14
      chnpy (2448) = 9
      chnte (2448) = 6
      chnhe (2448) = 0
      chperm (2448) = 100
      chbirf (2448) = 1283
      chetat (2448) = 313
      chtn2i (2448) = 210
      chbiet (313) = 2448
c
c Aretes coupees :   6  7 10 11
      chclas (1632) = ' 4-02'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0
      charde (1632)(1:12) = '  6  7 10 11'
      chnp1 (1632) = 1
      chnar (1632) = 14
      chnpy (1632) = 9
      chnte (1632) = 6
      chnhe (1632) = 0
      chperm (1632) = 110
      chbirf (1632) = 1283
      chetat (1632) = 314
      chtn2i (1632) = 210
      chbiet (314) = 1632
c
c ===========================================
c Classe d'equivalence  4-03
c
c Aretes coupees :   1  2 10 12
      chclas (2563) = ' 4-03'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1
      charde (2563)(1:12) = '  1  2 10 12'
      chnp1 (2563) = 1
      chnar (2563) = 14
      chnpy (2563) = 9
      chnte (2563) = 6
      chnhe (2563) = 0
      chperm (2563) = 0
      chbirf (2563) = 2563
      chetat (2563) = 315
      chtn2i (2563) = 210
      chbiet (315) = 2563
c
c Aretes coupees :   1  3  9 10
      chclas (773) = ' 4-03'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0
      charde (773)(1:12) = '  1  3  9 10'
      chnp1 (773) = 1
      chnar (773) = 14
      chnpy (773) = 9
      chnte (773) = 6
      chnhe (773) = 0
      chperm (773) = 201
      chbirf (773) = 2563
      chetat (773) = 316
      chtn2i (773) = 210
      chbiet (316) = 773
c
c Aretes coupees :   1  4  5  8
      chclas (153) = ' 4-03'
c Code des aretes coupees : 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0
      charde (153)(1:12) = '  1  4  5  8'
      chnp1 (153) = 1
      chnar (153) = 14
      chnpy (153) = 9
      chnte (153) = 6
      chnhe (153) = 0
      chperm (153) = 101
      chbirf (153) = 2563
      chetat (153) = 317
      chtn2i (153) = 210
      chbiet (317) = 153
c
c Aretes coupees :   1  6  8 12
      chclas (2209) = ' 4-03'
c Code des aretes coupees : 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1
      charde (2209)(1:12) = '  1  6  8 12'
      chnp1 (2209) = 1
      chnar (2209) = 14
      chnpy (2209) = 9
      chnte (2209) = 6
      chnhe (2209) = 0
      chperm (2209) = 120
      chbirf (2209) = 2563
      chetat (2209) = 318
      chtn2i (2209) = 210
      chbiet (318) = 2209
c
c Aretes coupees :   2  3  6  7
      chclas (102) = ' 4-03'
c Code des aretes coupees : 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0
      charde (102)(1:12) = '  2  3  6  7'
      chnp1 (102) = 1
      chnar (102) = 14
      chnpy (102) = 9
      chnte (102) = 6
      chnhe (102) = 0
      chperm (102) = 10
      chbirf (102) = 2563
      chetat (102) = 319
      chtn2i (102) = 210
      chbiet (319) = 102
c
c Aretes coupees :   2  4 11 12
      chclas (3082) = ' 4-03'
c Code des aretes coupees : 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1
      charde (3082)(1:12) = '  2  4 11 12'
      chnp1 (3082) = 1
      chnar (3082) = 14
      chnpy (3082) = 9
      chnte (3082) = 6
      chnhe (3082) = 0
      chperm (3082) = 1
      chbirf (3082) = 2563
      chetat (3082) = 320
      chtn2i (3082) = 210
      chbiet (320) = 3082
c
c Aretes coupees :   2  5  6 11
      chclas (1074) = ' 4-03'
c Code des aretes coupees : 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0
      charde (1074)(1:12) = '  2  5  6 11'
      chnp1 (1074) = 1
      chnar (1074) = 14
      chnpy (1074) = 9
      chnte (1074) = 6
      chnhe (1074) = 0
      chperm (1074) = 110
      chbirf (1074) = 2563
      chetat (1074) = 321
      chtn2i (1074) = 210
      chbiet (321) = 1074
c
c Aretes coupees :   3  4  9 11
      chclas (1292) = ' 4-03'
c Code des aretes coupees : 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 1, 0
      charde (1292)(1:12) = '  3  4  9 11'
      chnp1 (1292) = 1
      chnar (1292) = 14
      chnpy (1292) = 9
      chnte (1292) = 6
      chnhe (1292) = 0
      chperm (1292) = 20
      chbirf (1292) = 2563
      chetat (1292) = 322
      chtn2i (1292) = 210
      chbiet (322) = 1292
c
c Aretes coupees :   3  7  8 10
      chclas (708) = ' 4-03'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 1, 1, 0, 1, 0, 0
      charde (708)(1:12) = '  3  7  8 10'
      chnp1 (708) = 1
      chnar (708) = 14
      chnpy (708) = 9
      chnte (708) = 6
      chnhe (708) = 0
      chperm (708) = 310
      chbirf (708) = 2563
      chetat (708) = 323
      chtn2i (708) = 210
      chbiet (323) = 708
c
c Aretes coupees :   4  5  7  9
      chclas (344) = ' 4-03'
c Code des aretes coupees : 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0
      charde (344)(1:12) = '  4  5  7  9'
      chnp1 (344) = 1
      chnar (344) = 14
      chnpy (344) = 9
      chnte (344) = 6
      chnhe (344) = 0
      chperm (344) = 100
      chbirf (344) = 2563
      chetat (344) = 324
      chtn2i (344) = 210
      chbiet (324) = 344
c
c Aretes coupees :   5  8 10 11
      chclas (1680) = ' 4-03'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0
      charde (1680)(1:12) = '  5  8 10 11'
      chnp1 (1680) = 1
      chnar (1680) = 14
      chnpy (1680) = 9
      chnte (1680) = 6
      chnhe (1680) = 0
      chperm (1680) = 210
      chbirf (1680) = 2563
      chetat (1680) = 325
      chtn2i (1680) = 210
      chbiet (325) = 1680
c
c Aretes coupees :   6  7  9 12
      chclas (2400) = ' 4-03'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 0, 1
      charde (2400)(1:12) = '  6  7  9 12'
      chnp1 (2400) = 1
      chnar (2400) = 14
      chnpy (2400) = 9
      chnte (2400) = 6
      chnhe (2400) = 0
      chperm (2400) = 301
      chbirf (2400) = 2563
      chetat (2400) = 326
      chtn2i (2400) = 210
      chbiet (326) = 2400
c
c ===========================================
c Classe d'equivalence  4-04
c
c Aretes coupees :   1  2 11 12
      chclas (3075) = ' 4-04'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1
      charde (3075)(1:12) = '  1  2 11 12'
      chnp1 (3075) = 1
      chnar (3075) = 14
      chnpy (3075) = 6
      chnte (3075) = 12
      chnhe (3075) = 0
      chperm (3075) = 0
      chbirf (3075) = 3075
      chetat (3075) = 327
      chtn2i (3075) = 210
      chbiet (327) = 3075
c
c Aretes coupees :   1  3 10 12
      chclas (2565) = ' 4-04'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1
      charde (2565)(1:12) = '  1  3 10 12'
      chnp1 (2565) = 1
      chnar (2565) = 14
      chnpy (2565) = 6
      chnte (2565) = 12
      chnhe (2565) = 0
      chperm (2565) = 200
      chbirf (2565) = 3075
      chetat (2565) = 328
      chtn2i (2565) = 210
      chbiet (328) = 2565
c
c Aretes coupees :   1  5  8 12
      chclas (2193) = ' 4-04'
c Code des aretes coupees : 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1
      charde (2193)(1:12) = '  1  5  8 12'
      chnp1 (2193) = 1
      chnar (2193) = 14
      chnpy (2193) = 6
      chnte (2193) = 12
      chnhe (2193) = 0
      chperm (2193) = 120
      chbirf (2193) = 3075
      chetat (2193) = 329
      chtn2i (2193) = 210
      chbiet (329) = 2193
c
c Aretes coupees :   1  6  7 12
      chclas (2145) = ' 4-04'
c Code des aretes coupees : 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1
      charde (2145)(1:12) = '  1  6  7 12'
      chnp1 (2145) = 1
      chnar (2145) = 14
      chnpy (2145) = 6
      chnte (2145) = 12
      chnhe (2145) = 0
      chperm (2145) = 320
      chbirf (2145) = 3075
      chetat (2145) = 330
      chtn2i (2145) = 210
      chbiet (330) = 2145
c
c Aretes coupees :   2  4  9 11
      chclas (1290) = ' 4-04'
c Code des aretes coupees : 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0
      charde (1290)(1:12) = '  2  4  9 11'
      chnp1 (1290) = 1
      chnar (1290) = 14
      chnpy (1290) = 6
      chnte (1290) = 12
      chnhe (1290) = 0
      chperm (1290) = 20
      chbirf (1290) = 3075
      chetat (1290) = 331
      chtn2i (1290) = 210
      chbiet (331) = 1290
c
c Aretes coupees :   2  5  8 11
      chclas (1170) = ' 4-04'
c Code des aretes coupees : 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0
      charde (1170)(1:12) = '  2  5  8 11'
      chnp1 (1170) = 1
      chnar (1170) = 14
      chnpy (1170) = 6
      chnte (1170) = 12
      chnhe (1170) = 0
      chperm (1170) = 210
      chbirf (1170) = 3075
      chetat (1170) = 332
      chtn2i (1170) = 210
      chbiet (332) = 1170
c
c Aretes coupees :   2  6  7 11
      chclas (1122) = ' 4-04'
c Code des aretes coupees : 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0
      charde (1122)(1:12) = '  2  6  7 11'
      chnp1 (1122) = 1
      chnar (1122) = 14
      chnpy (1122) = 6
      chnte (1122) = 12
      chnhe (1122) = 0
      chperm (1122) = 110
      chbirf (1122) = 3075
      chetat (1122) = 333
      chtn2i (1122) = 210
      chbiet (333) = 1122
c
c Aretes coupees :   3  4  9 10
      chclas (780) = ' 4-04'
c Code des aretes coupees : 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0
      charde (780)(1:12) = '  3  4  9 10'
      chnp1 (780) = 1
      chnar (780) = 14
      chnpy (780) = 6
      chnte (780) = 12
      chnhe (780) = 0
      chperm (780) = 220
      chbirf (780) = 3075
      chetat (780) = 334
      chtn2i (780) = 210
      chbiet (334) = 780
c
c Aretes coupees :   3  5  8 10
      chclas (660) = ' 4-04'
c Code des aretes coupees : 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0
      charde (660)(1:12) = '  3  5  8 10'
      chnp1 (660) = 1
      chnar (660) = 14
      chnpy (660) = 6
      chnte (660) = 12
      chnhe (660) = 0
      chperm (660) = 310
      chbirf (660) = 3075
      chetat (660) = 335
      chtn2i (660) = 210
      chbiet (335) = 660
c
c Aretes coupees :   3  6  7 10
      chclas (612) = ' 4-04'
c Code des aretes coupees : 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0
      charde (612)(1:12) = '  3  6  7 10'
      chnp1 (612) = 1
      chnar (612) = 14
      chnpy (612) = 6
      chnte (612) = 12
      chnhe (612) = 0
      chperm (612) = 10
      chbirf (612) = 3075
      chetat (612) = 336
      chtn2i (612) = 210
      chbiet (336) = 612
c
c Aretes coupees :   4  5  8  9
      chclas (408) = ' 4-04'
c Code des aretes coupees : 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0
      charde (408)(1:12) = '  4  5  8  9'
      chnp1 (408) = 1
      chnar (408) = 14
      chnpy (408) = 6
      chnte (408) = 12
      chnhe (408) = 0
      chperm (408) = 100
      chbirf (408) = 3075
      chetat (408) = 337
      chtn2i (408) = 210
      chbiet (337) = 408
c
c Aretes coupees :   4  6  7  9
      chclas (360) = ' 4-04'
c Code des aretes coupees : 0, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 0
      charde (360)(1:12) = '  4  6  7  9'
      chnp1 (360) = 1
      chnar (360) = 14
      chnpy (360) = 6
      chnte (360) = 12
      chnhe (360) = 0
      chperm (360) = 300
      chbirf (360) = 3075
      chetat (360) = 338
      chtn2i (360) = 210
      chbiet (338) = 360
c
c ===========================================
c Classe d'equivalence  4-05
c
c Aretes coupees :   1  2  6  8
      chclas (163) = ' 4-05'
c Code des aretes coupees : 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0
      charde (163)(1:12) = '  1  2  6  8'
      chnp1 (163) = 1
      chnar (163) = 14
      chnpy (163) = 9
      chnte (163) = 6
      chnhe (163) = 0
      chperm (163) = 0
      chbirf (163) = 163
      chetat (163) = 339
      chtn2i (163) = 210
      chbiet (339) = 163
c
c Aretes coupees :   1  2  6 10
      chclas (547) = ' 4-05'
c Code des aretes coupees : 1, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0
      charde (547)(1:12) = '  1  2  6 10'
      chnp1 (547) = 1
      chnar (547) = 14
      chnpy (547) = 9
      chnte (547) = 6
      chnhe (547) = 0
      chperm (547) = 320
      chbirf (547) = 163
      chetat (547) = 340
      chtn2i (547) = 210
      chbiet (340) = 547
c
c Aretes coupees :   1  3  7  8
      chclas (197) = ' 4-05'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0
      charde (197)(1:12) = '  1  3  7  8'
      chnp1 (197) = 1
      chnar (197) = 14
      chnpy (197) = 9
      chnte (197) = 6
      chnhe (197) = 0
      chperm (197) = 221
      chbirf (197) = 163
      chetat (197) = 341
      chtn2i (197) = 210
      chbiet (341) = 197
c
c Aretes coupees :   1  3  8  9
      chclas (389) = ' 4-05'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0
      charde (389)(1:12) = '  1  3  8  9'
      chnp1 (389) = 1
      chnar (389) = 14
      chnpy (389) = 9
      chnte (389) = 6
      chnhe (389) = 0
      chperm (389) = 310
      chbirf (389) = 163
      chetat (389) = 342
      chtn2i (389) = 210
      chbiet (342) = 389
c
c Aretes coupees :   1  4  5 10
      chclas (537) = ' 4-05'
c Code des aretes coupees : 1, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0
      charde (537)(1:12) = '  1  4  5 10'
      chnp1 (537) = 1
      chnar (537) = 14
      chnpy (537) = 9
      chnte (537) = 6
      chnhe (537) = 0
      chperm (537) = 30
      chbirf (537) = 163
      chetat (537) = 343
      chtn2i (537) = 210
      chbiet (343) = 537
c
c Aretes coupees :   1  4  8 11
      chclas (1161) = ' 4-05'
c Code des aretes coupees : 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0
      charde (1161)(1:12) = '  1  4  8 11'
      chnp1 (1161) = 1
      chnar (1161) = 14
      chnpy (1161) = 9
      chnte (1161) = 6
      chnhe (1161) = 0
      chperm (1161) = 210
      chbirf (1161) = 163
      chetat (1161) = 344
      chtn2i (1161) = 210
      chbiet (344) = 1161
c
c Aretes coupees :   1  5 10 11
      chclas (1553) = ' 4-05'
c Code des aretes coupees : 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0
      charde (1553)(1:12) = '  1  5 10 11'
      chnp1 (1553) = 1
      chnar (1553) = 14
      chnpy (1553) = 9
      chnte (1553) = 6
      chnhe (1553) = 0
      chperm (1553) = 101
      chbirf (1553) = 163
      chetat (1553) = 345
      chtn2i (1553) = 210
      chbiet (345) = 1553
c
c Aretes coupees :   1  7  9 10
      chclas (833) = ' 4-05'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 0
      charde (833)(1:12) = '  1  7  9 10'
      chnp1 (833) = 1
      chnar (833) = 14
      chnpy (833) = 9
      chnte (833) = 6
      chnhe (833) = 0
      chperm (833) = 130
      chbirf (833) = 163
      chetat (833) = 346
      chtn2i (833) = 210
      chbiet (346) = 833
c
c Aretes coupees :   2  3  6  9
      chclas (294) = ' 4-05'
c Code des aretes coupees : 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0
      charde (294)(1:12) = '  2  3  6  9'
      chnp1 (294) = 1
      chnar (294) = 14
      chnpy (294) = 9
      chnte (294) = 6
      chnhe (294) = 0
      chperm (294) = 321
      chbirf (294) = 163
      chetat (294) = 347
      chtn2i (294) = 210
      chbiet (347) = 294
c
c Aretes coupees :   2  3  7 12
      chclas (2118) = ' 4-05'
c Code des aretes coupees : 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1
      charde (2118)(1:12) = '  2  3  7 12'
      chnp1 (2118) = 1
      chnar (2118) = 14
      chnpy (2118) = 9
      chnte (2118) = 6
      chnhe (2118) = 0
      chperm (2118) = 301
      chbirf (2118) = 163
      chetat (2118) = 348
      chtn2i (2118) = 210
      chbiet (348) = 2118
c
c Aretes coupees :   2  4  5  6
      chclas (58) = ' 4-05'
c Code des aretes coupees : 0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0
      charde (58)(1:12) = '  2  4  5  6'
      chnp1 (58) = 1
      chnar (58) = 14
      chnpy (58) = 9
      chnte (58) = 6
      chnhe (58) = 0
      chperm (58) = 1
      chbirf (58) = 163
      chetat (58) = 349
      chtn2i (58) = 210
      chbiet (349) = 58
c
c Aretes coupees :   2  4  5 12
      chclas (2074) = ' 4-05'
c Code des aretes coupees : 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1
      charde (2074)(1:12) = '  2  4  5 12'
      chnp1 (2074) = 1
      chnar (2074) = 14
      chnpy (2074) = 9
      chnte (2074) = 6
      chnhe (2074) = 0
      chperm (2074) = 330
      chbirf (2074) = 163
      chetat (2074) = 350
      chtn2i (2074) = 210
      chbiet (350) = 2074
c
c Aretes coupees :   2  7  9 12
      chclas (2370) = ' 4-05'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1
      charde (2370)(1:12) = '  2  7  9 12'
      chnp1 (2370) = 1
      chnar (2370) = 14
      chnpy (2370) = 9
      chnte (2370) = 6
      chnhe (2370) = 0
      chperm (2370) = 230
      chbirf (2370) = 163
      chetat (2370) = 351
      chtn2i (2370) = 210
      chbiet (351) = 2370
c
c Aretes coupees :   2  8 10 12
      chclas (2690) = ' 4-05'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1
      charde (2690)(1:12) = '  2  8 10 12'
      chnp1 (2690) = 1
      chnar (2690) = 14
      chnpy (2690) = 9
      chnte (2690) = 6
      chnhe (2690) = 0
      chperm (2690) = 120
      chbirf (2690) = 163
      chetat (2690) = 352
      chtn2i (2690) = 210
      chbiet (352) = 2690
c
c Aretes coupees :   3  4  5  7
      chclas (92) = ' 4-05'
c Code des aretes coupees : 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0
      charde (92)(1:12) = '  3  4  5  7'
      chnp1 (92) = 1
      chnar (92) = 14
      chnpy (92) = 9
      chnte (92) = 6
      chnhe (92) = 0
      chperm (92) = 220
      chbirf (92) = 163
      chetat (92) = 353
      chtn2i (92) = 210
      chbiet (353) = 92
c
c Aretes coupees :   3  4  7 11
      chclas (1100) = ' 4-05'
c Code des aretes coupees : 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0
      charde (1100)(1:12) = '  3  4  7 11'
      chnp1 (1100) = 1
      chnar (1100) = 14
      chnpy (1100) = 9
      chnte (1100) = 6
      chnhe (1100) = 0
      chperm (1100) = 300
      chbirf (1100) = 163
      chetat (1100) = 354
      chtn2i (1100) = 210
      chbiet (354) = 1100
c
c Aretes coupees :   3  5  9 11
      chclas (1300) = ' 4-05'
c Code des aretes coupees : 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0
      charde (1300)(1:12) = '  3  5  9 11'
      chnp1 (1300) = 1
      chnar (1300) = 14
      chnpy (1300) = 9
      chnte (1300) = 6
      chnhe (1300) = 0
      chperm (1300) = 100
      chbirf (1300) = 163
      chetat (1300) = 355
      chtn2i (1300) = 210
      chbiet (355) = 1300
c
c Aretes coupees :   3  6  9 12
      chclas (2340) = ' 4-05'
c Code des aretes coupees : 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1
      charde (2340)(1:12) = '  3  6  9 12'
      chnp1 (2340) = 1
      chnar (2340) = 14
      chnpy (2340) = 9
      chnte (2340) = 6
      chnhe (2340) = 0
      chperm (2340) = 10
      chbirf (2340) = 163
      chetat (2340) = 356
      chtn2i (2340) = 210
      chbiet (356) = 2340
c
c Aretes coupees :   4  6 11 12
      chclas (3112) = ' 4-05'
c Code des aretes coupees : 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 1
      charde (3112)(1:12) = '  4  6 11 12'
      chnp1 (3112) = 1
      chnar (3112) = 14
      chnpy (3112) = 9
      chnte (3112) = 6
      chnhe (3112) = 0
      chperm (3112) = 110
      chbirf (3112) = 163
      chetat (3112) = 357
      chtn2i (3112) = 210
      chbiet (357) = 3112
c
c Aretes coupees :   4  8 10 11
      chclas (1672) = ' 4-05'
c Code des aretes coupees : 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 1, 0
      charde (1672)(1:12) = '  4  8 10 11'
      chnp1 (1672) = 1
      chnar (1672) = 14
      chnpy (1672) = 9
      chnte (1672) = 6
      chnhe (1672) = 0
      chperm (1672) = 121
      chbirf (1672) = 163
      chetat (1672) = 358
      chtn2i (1672) = 210
      chbiet (358) = 1672
c
c Aretes coupees :   5  6 11 12
      chclas (3120) = ' 4-05'
c Code des aretes coupees : 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1
      charde (3120)(1:12) = '  5  6 11 12'
      chnp1 (3120) = 1
      chnar (3120) = 14
      chnpy (3120) = 9
      chnte (3120) = 6
      chnhe (3120) = 0
      chperm (3120) = 21
      chbirf (3120) = 163
      chetat (3120) = 359
      chtn2i (3120) = 210
      chbiet (359) = 3120
c
c Aretes coupees :   5  7  9 11
      chclas (1360) = ' 4-05'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0
      charde (1360)(1:12) = '  5  7  9 11'
      chnp1 (1360) = 1
      chnar (1360) = 14
      chnpy (1360) = 9
      chnte (1360) = 6
      chnhe (1360) = 0
      chperm (1360) = 20
      chbirf (1360) = 163
      chetat (1360) = 360
      chtn2i (1360) = 210
      chbiet (360) = 1360
c
c Aretes coupees :   6  8 10 12
      chclas (2720) = ' 4-05'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1
      charde (2720)(1:12) = '  6  8 10 12'
      chnp1 (2720) = 1
      chnar (2720) = 14
      chnpy (2720) = 9
      chnte (2720) = 6
      chnhe (2720) = 0
      chperm (2720) = 200
      chbirf (2720) = 163
      chetat (2720) = 361
      chtn2i (2720) = 210
      chbiet (361) = 2720
c
c Aretes coupees :   7  8  9 10
      chclas (960) = ' 4-05'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0
      charde (960)(1:12) = '  7  8  9 10'
      chnp1 (960) = 1
      chnar (960) = 14
      chnpy (960) = 9
      chnte (960) = 6
      chnhe (960) = 0
      chperm (960) = 201
      chbirf (960) = 163
      chetat (960) = 362
      chtn2i (960) = 210
      chbiet (362) = 960
c
c ===========================================
c Classe d'equivalence  4-06
c
c Aretes coupees :   1  2  7  8
      chclas (195) = ' 4-06'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0
      charde (195)(1:12) = '  1  2  7  8'
      chnp1 (195) = 1
      chnar (195) = 14
      chnpy (195) = 9
      chnte (195) = 6
      chnhe (195) = 0
      chperm (195) = 0
      chbirf (195) = 195
      chetat (195) = 363
      chtn2i (195) = 210
      chbiet (363) = 195
c
c Aretes coupees :   1  2  7  9
      chclas (323) = ' 4-06'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0
      charde (323)(1:12) = '  1  2  7  9'
      chnp1 (323) = 1
      chnar (323) = 14
      chnpy (323) = 9
      chnte (323) = 6
      chnhe (323) = 0
      chperm (323) = 230
      chbirf (323) = 195
      chetat (323) = 364
      chtn2i (323) = 210
      chbiet (364) = 323
c
c Aretes coupees :   1  3  5  7
      chclas (85) = ' 4-06'
c Code des aretes coupees : 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0
      charde (85)(1:12) = '  1  3  5  7'
      chnp1 (85) = 1
      chnar (85) = 14
      chnpy (85) = 9
      chnte (85) = 6
      chnhe (85) = 0
      chperm (85) = 221
      chbirf (85) = 195
      chetat (85) = 365
      chtn2i (85) = 210
      chbiet (365) = 85
c
c Aretes coupees :   1  3  5 11
      chclas (1045) = ' 4-06'
c Code des aretes coupees : 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0
      charde (1045)(1:12) = '  1  3  5 11'
      chnp1 (1045) = 1
      chnar (1045) = 14
      chnpy (1045) = 9
      chnte (1045) = 6
      chnhe (1045) = 0
      chperm (1045) = 101
      chbirf (1045) = 195
      chetat (1045) = 366
      chtn2i (1045) = 210
      chbiet (366) = 1045
c
c Aretes coupees :   1  4  6 11
      chclas (1065) = ' 4-06'
c Code des aretes coupees : 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0
      charde (1065)(1:12) = '  1  4  6 11'
      chnp1 (1065) = 1
      chnar (1065) = 14
      chnpy (1065) = 9
      chnte (1065) = 6
      chnhe (1065) = 0
      chperm (1065) = 110
      chbirf (1065) = 195
      chetat (1065) = 367
      chtn2i (1065) = 210
      chbiet (367) = 1065
c
c Aretes coupees :   1  4  7 10
      chclas (585) = ' 4-06'
c Code des aretes coupees : 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0
      charde (585)(1:12) = '  1  4  7 10'
      chnp1 (585) = 1
      chnar (585) = 14
      chnpy (585) = 9
      chnte (585) = 6
      chnhe (585) = 0
      chperm (585) = 130
      chbirf (585) = 195
      chetat (585) = 368
      chtn2i (585) = 210
      chbiet (368) = 585
c
c Aretes coupees :   1  6 10 11
      chclas (1569) = ' 4-06'
c Code des aretes coupees : 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0
      charde (1569)(1:12) = '  1  6 10 11'
      chnp1 (1569) = 1
      chnar (1569) = 14
      chnpy (1569) = 9
      chnte (1569) = 6
      chnhe (1569) = 0
      chperm (1569) = 320
      chbirf (1569) = 195
      chetat (1569) = 369
      chtn2i (1569) = 210
      chbiet (369) = 1569
c
c Aretes coupees :   1  8  9 11
      chclas (1409) = ' 4-06'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0
      charde (1409)(1:12) = '  1  8  9 11'
      chnp1 (1409) = 1
      chnar (1409) = 14
      chnpy (1409) = 9
      chnte (1409) = 6
      chnhe (1409) = 0
      chperm (1409) = 210
      chbirf (1409) = 195
      chetat (1409) = 370
      chtn2i (1409) = 210
      chbiet (370) = 1409
c
c Aretes coupees :   2  3  5  9
      chclas (278) = ' 4-06'
c Code des aretes coupees : 0, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0
      charde (278)(1:12) = '  2  3  5  9'
      chnp1 (278) = 1
      chnar (278) = 14
      chnpy (278) = 9
      chnte (278) = 6
      chnhe (278) = 0
      chperm (278) = 100
      chbirf (278) = 195
      chetat (278) = 371
      chtn2i (278) = 210
      chbiet (371) = 278
c
c Aretes coupees :   2  3  8 12
      chclas (2182) = ' 4-06'
c Code des aretes coupees : 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1
      charde (2182)(1:12) = '  2  3  8 12'
      chnp1 (2182) = 1
      chnar (2182) = 14
      chnpy (2182) = 9
      chnte (2182) = 6
      chnhe (2182) = 0
      chperm (2182) = 120
      chbirf (2182) = 195
      chetat (2182) = 372
      chtn2i (2182) = 210
      chbiet (372) = 2182
c
c Aretes coupees :   2  4  6  8
      chclas (170) = ' 4-06'
c Code des aretes coupees : 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0
      charde (170)(1:12) = '  2  4  6  8'
      chnp1 (170) = 1
      chnar (170) = 14
      chnpy (170) = 9
      chnte (170) = 6
      chnhe (170) = 0
      chperm (170) = 1
      chbirf (170) = 195
      chetat (170) = 373
      chtn2i (170) = 210
      chbiet (373) = 170
c
c Aretes coupees :   2  4  8 10
      chclas (650) = ' 4-06'
c Code des aretes coupees : 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0
      charde (650)(1:12) = '  2  4  8 10'
      chnp1 (650) = 1
      chnar (650) = 14
      chnpy (650) = 9
      chnte (650) = 6
      chnhe (650) = 0
      chperm (650) = 121
      chbirf (650) = 195
      chetat (650) = 374
      chtn2i (650) = 210
      chbiet (374) = 650
c
c Aretes coupees :   2  5  9 12
      chclas (2322) = ' 4-06'
c Code des aretes coupees : 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1
      charde (2322)(1:12) = '  2  5  9 12'
      chnp1 (2322) = 1
      chnar (2322) = 14
      chnpy (2322) = 9
      chnte (2322) = 6
      chnhe (2322) = 0
      chperm (2322) = 330
      chbirf (2322) = 195
      chetat (2322) = 375
      chtn2i (2322) = 210
      chbiet (375) = 2322
c
c Aretes coupees :   2  6  9 10
      chclas (802) = ' 4-06'
c Code des aretes coupees : 0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0
      charde (802)(1:12) = '  2  6  9 10'
      chnp1 (802) = 1
      chnar (802) = 14
      chnpy (802) = 9
      chnte (802) = 6
      chnhe (802) = 0
      chperm (802) = 321
      chbirf (802) = 195
      chetat (802) = 376
      chtn2i (802) = 210
      chbiet (376) = 802
c
c Aretes coupees :   3  4  5  6
      chclas (60) = ' 4-06'
c Code des aretes coupees : 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0
      charde (60)(1:12) = '  3  4  5  6'
      chnp1 (60) = 1
      chnar (60) = 14
      chnpy (60) = 9
      chnte (60) = 6
      chnhe (60) = 0
      chperm (60) = 220
      chbirf (60) = 195
      chetat (60) = 377
      chtn2i (60) = 210
      chbiet (377) = 60
c
c Aretes coupees :   3  4  6 12
      chclas (2092) = ' 4-06'
c Code des aretes coupees : 0, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 1
      charde (2092)(1:12) = '  3  4  6 12'
      chnp1 (2092) = 1
      chnar (2092) = 14
      chnpy (2092) = 9
      chnte (2092) = 6
      chnhe (2092) = 0
      chperm (2092) = 10
      chbirf (2092) = 195
      chetat (2092) = 378
      chtn2i (2092) = 210
      chbiet (378) = 2092
c
c Aretes coupees :   3  7 11 12
      chclas (3140) = ' 4-06'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1
      charde (3140)(1:12) = '  3  7 11 12'
      chnp1 (3140) = 1
      chnar (3140) = 14
      chnpy (3140) = 9
      chnte (3140) = 6
      chnhe (3140) = 0
      chperm (3140) = 301
      chbirf (3140) = 195
      chetat (3140) = 379
      chtn2i (3140) = 210
      chbiet (379) = 3140
c
c Aretes coupees :   3  8  9 12
      chclas (2436) = ' 4-06'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1
      charde (2436)(1:12) = '  3  8  9 12'
      chnp1 (2436) = 1
      chnar (2436) = 14
      chnpy (2436) = 9
      chnte (2436) = 6
      chnhe (2436) = 0
      chperm (2436) = 310
      chbirf (2436) = 195
      chetat (2436) = 380
      chtn2i (2436) = 210
      chbiet (380) = 2436
c
c Aretes coupees :   4  5 10 12
      chclas (2584) = ' 4-06'
c Code des aretes coupees : 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 1
      charde (2584)(1:12) = '  4  5 10 12'
      chnp1 (2584) = 1
      chnar (2584) = 14
      chnpy (2584) = 9
      chnte (2584) = 6
      chnhe (2584) = 0
      chperm (2584) = 30
      chbirf (2584) = 195
      chetat (2584) = 381
      chtn2i (2584) = 210
      chbiet (381) = 2584
c
c Aretes coupees :   4  7 10 11
      chclas (1608) = ' 4-06'
c Code des aretes coupees : 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 0
      charde (1608)(1:12) = '  4  7 10 11'
      chnp1 (1608) = 1
      chnar (1608) = 14
      chnpy (1608) = 9
      chnte (1608) = 6
      chnhe (1608) = 0
      chperm (1608) = 300
      chbirf (1608) = 195
      chetat (1608) = 382
      chtn2i (1608) = 210
      chbiet (382) = 1608
c
c Aretes coupees :   5  6 10 12
      chclas (2608) = ' 4-06'
c Code des aretes coupees : 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 1
      charde (2608)(1:12) = '  5  6 10 12'
      chnp1 (2608) = 1
      chnar (2608) = 14
      chnpy (2608) = 9
      chnte (2608) = 6
      chnhe (2608) = 0
      chperm (2608) = 200
      chbirf (2608) = 195
      chetat (2608) = 383
      chtn2i (2608) = 210
      chbiet (383) = 2608
c
c Aretes coupees :   5  7 11 12
      chclas (3152) = ' 4-06'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1
      charde (3152)(1:12) = '  5  7 11 12'
      chnp1 (3152) = 1
      chnar (3152) = 14
      chnpy (3152) = 9
      chnte (3152) = 6
      chnhe (3152) = 0
      chperm (3152) = 21
      chbirf (3152) = 195
      chetat (3152) = 384
      chtn2i (3152) = 210
      chbiet (384) = 3152
c
c Aretes coupees :   6  8  9 10
      chclas (928) = ' 4-06'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 0, 0
      charde (928)(1:12) = '  6  8  9 10'
      chnp1 (928) = 1
      chnar (928) = 14
      chnpy (928) = 9
      chnte (928) = 6
      chnhe (928) = 0
      chperm (928) = 201
      chbirf (928) = 195
      chetat (928) = 385
      chtn2i (928) = 210
      chbiet (385) = 928
c
c Aretes coupees :   7  8  9 11
      chclas (1472) = ' 4-06'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0
      charde (1472)(1:12) = '  7  8  9 11'
      chnp1 (1472) = 1
      chnar (1472) = 14
      chnpy (1472) = 9
      chnte (1472) = 6
      chnhe (1472) = 0
      chperm (1472) = 20
      chbirf (1472) = 195
      chetat (1472) = 386
      chtn2i (1472) = 210
      chbiet (386) = 1472
c
c ===========================================
c Classe d'equivalence  4-07
c
c Aretes coupees :   1  2  8  9
      chclas (387) = ' 4-07'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0
      charde (387)(1:12) = '  1  2  8  9'
      chnp1 (387) = 1
      chnar (387) = 13
      chnpy (387) = 5
      chnte (387) = 12
      chnhe (387) = 0
      chperm (387) = 0
      chbirf (387) = 387
      chetat (387) = 387
      chtn2i (387) = 210
      chbiet (387) = 387
c
c Aretes coupees :   1  3  7 11
      chclas (1093) = ' 4-07'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0
      charde (1093)(1:12) = '  1  3  7 11'
      chnp1 (1093) = 1
      chnar (1093) = 13
      chnpy (1093) = 5
      chnte (1093) = 12
      chnhe (1093) = 0
      chperm (1093) = 221
      chbirf (1093) = 387
      chetat (1093) = 388
      chtn2i (1093) = 210
      chbiet (388) = 1093
c
c Aretes coupees :   1  4  6 10
      chclas (553) = ' 4-07'
c Code des aretes coupees : 1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0
      charde (553)(1:12) = '  1  4  6 10'
      chnp1 (553) = 1
      chnar (553) = 13
      chnpy (553) = 5
      chnte (553) = 12
      chnhe (553) = 0
      chperm (553) = 320
      chbirf (553) = 387
      chetat (553) = 389
      chtn2i (553) = 210
      chbiet (389) = 553
c
c Aretes coupees :   1  4  7 11
      chclas (1097) = ' 4-07'
c Code des aretes coupees : 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0
      charde (1097)(1:12) = '  1  4  7 11'
      chnp1 (1097) = 1
      chnar (1097) = 13
      chnpy (1097) = 5
      chnte (1097) = 12
      chnhe (1097) = 0
      chperm (1097) = 300
      chbirf (1097) = 387
      chetat (1097) = 390
      chtn2i (1097) = 210
      chbiet (390) = 1097
c
c Aretes coupees :   1  5  7 11
      chclas (1105) = ' 4-07'
c Code des aretes coupees : 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0
      charde (1105)(1:12) = '  1  5  7 11'
      chnp1 (1105) = 1
      chnar (1105) = 13
      chnpy (1105) = 5
      chnte (1105) = 12
      chnhe (1105) = 0
      chperm (1105) = 101
      chbirf (1105) = 387
      chetat (1105) = 391
      chtn2i (1105) = 210
      chbiet (391) = 1105
c
c Aretes coupees :   1  7  8 11
      chclas (1217) = ' 4-07'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0
      charde (1217)(1:12) = '  1  7  8 11'
      chnp1 (1217) = 1
      chnar (1217) = 13
      chnpy (1217) = 5
      chnte (1217) = 12
      chnhe (1217) = 0
      chperm (1217) = 210
      chbirf (1217) = 387
      chetat (1217) = 392
      chtn2i (1217) = 210
      chbiet (392) = 1217
c
c Aretes coupees :   1  7  9 11
      chclas (1345) = ' 4-07'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0
      charde (1345)(1:12) = '  1  7  9 11'
      chnp1 (1345) = 1
      chnar (1345) = 13
      chnpy (1345) = 5
      chnte (1345) = 12
      chnhe (1345) = 0
      chperm (1345) = 20
      chbirf (1345) = 387
      chetat (1345) = 393
      chtn2i (1345) = 210
      chbiet (393) = 1345
c
c Aretes coupees :   1  7 10 11
      chclas (1601) = ' 4-07'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0
      charde (1601)(1:12) = '  1  7 10 11'
      chnp1 (1601) = 1
      chnar (1601) = 13
      chnpy (1601) = 5
      chnte (1601) = 12
      chnhe (1601) = 0
      chperm (1601) = 130
      chbirf (1601) = 387
      chetat (1601) = 394
      chtn2i (1601) = 210
      chbiet (394) = 1601
c
c Aretes coupees :   2  3  5 12
      chclas (2070) = ' 4-07'
c Code des aretes coupees : 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1
      charde (2070)(1:12) = '  2  3  5 12'
      chnp1 (2070) = 1
      chnar (2070) = 13
      chnpy (2070) = 5
      chnte (2070) = 12
      chnhe (2070) = 0
      chperm (2070) = 330
      chbirf (2070) = 387
      chetat (2070) = 395
      chtn2i (2070) = 210
      chbiet (395) = 2070
c
c Aretes coupees :   2  3  8  9
      chclas (390) = ' 4-07'
c Code des aretes coupees : 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0
      charde (390)(1:12) = '  2  3  8  9'
      chnp1 (390) = 1
      chnar (390) = 13
      chnpy (390) = 5
      chnte (390) = 12
      chnhe (390) = 0
      chperm (390) = 310
      chbirf (390) = 387
      chetat (390) = 396
      chtn2i (390) = 210
      chbiet (396) = 390
c
c Aretes coupees :   2  4  6 10
      chclas (554) = ' 4-07'
c Code des aretes coupees : 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0
      charde (554)(1:12) = '  2  4  6 10'
      chnp1 (554) = 1
      chnar (554) = 13
      chnpy (554) = 5
      chnte (554) = 12
      chnhe (554) = 0
      chperm (554) = 1
      chbirf (554) = 387
      chetat (554) = 397
      chtn2i (554) = 210
      chbiet (397) = 554
c
c Aretes coupees :   2  6  8  9
      chclas (418) = ' 4-07'
c Code des aretes coupees : 0, 1, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0
      charde (418)(1:12) = '  2  6  8  9'
      chnp1 (418) = 1
      chnar (418) = 13
      chnpy (418) = 5
      chnte (418) = 12
      chnhe (418) = 0
      chperm (418) = 321
      chbirf (418) = 387
      chetat (418) = 398
      chtn2i (418) = 210
      chbiet (398) = 418
c
c Aretes coupees :   2  7  8  9
      chclas (450) = ' 4-07'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0
      charde (450)(1:12) = '  2  7  8  9'
      chnp1 (450) = 1
      chnar (450) = 13
      chnpy (450) = 5
      chnte (450) = 12
      chnhe (450) = 0
      chperm (450) = 230
      chbirf (450) = 387
      chetat (450) = 399
      chtn2i (450) = 210
      chbiet (399) = 450
c
c Aretes coupees :   2  8  9 10
      chclas (898) = ' 4-07'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0
      charde (898)(1:12) = '  2  8  9 10'
      chnp1 (898) = 1
      chnar (898) = 13
      chnpy (898) = 5
      chnte (898) = 12
      chnhe (898) = 0
      chperm (898) = 201
      chbirf (898) = 387
      chetat (898) = 400
      chtn2i (898) = 210
      chbiet (400) = 898
c
c Aretes coupees :   2  8  9 12
      chclas (2434) = ' 4-07'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1
      charde (2434)(1:12) = '  2  8  9 12'
      chnp1 (2434) = 1
      chnar (2434) = 13
      chnpy (2434) = 5
      chnte (2434) = 12
      chnhe (2434) = 0
      chperm (2434) = 120
      chbirf (2434) = 387
      chetat (2434) = 401
      chtn2i (2434) = 210
      chbiet (401) = 2434
c
c Aretes coupees :   3  4  5 12
      chclas (2076) = ' 4-07'
c Code des aretes coupees : 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1
      charde (2076)(1:12) = '  3  4  5 12'
      chnp1 (2076) = 1
      chnar (2076) = 13
      chnpy (2076) = 5
      chnte (2076) = 12
      chnhe (2076) = 0
      chperm (2076) = 220
      chbirf (2076) = 387
      chetat (2076) = 402
      chtn2i (2076) = 210
      chbiet (402) = 2076
c
c Aretes coupees :   3  5  6 12
      chclas (2100) = ' 4-07'
c Code des aretes coupees : 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 1
      charde (2100)(1:12) = '  3  5  6 12'
      chnp1 (2100) = 1
      chnar (2100) = 13
      chnpy (2100) = 5
      chnte (2100) = 12
      chnhe (2100) = 0
      chperm (2100) = 10
      chbirf (2100) = 387
      chetat (2100) = 403
      chtn2i (2100) = 210
      chbiet (403) = 2100
c
c Aretes coupees :   3  5  7 12
      chclas (2132) = ' 4-07'
c Code des aretes coupees : 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1
      charde (2132)(1:12) = '  3  5  7 12'
      chnp1 (2132) = 1
      chnar (2132) = 13
      chnpy (2132) = 5
      chnte (2132) = 12
      chnhe (2132) = 0
      chperm (2132) = 301
      chbirf (2132) = 387
      chetat (2132) = 404
      chtn2i (2132) = 210
      chbiet (404) = 2132
c
c Aretes coupees :   3  5  9 12
      chclas (2324) = ' 4-07'
c Code des aretes coupees : 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 1
      charde (2324)(1:12) = '  3  5  9 12'
      chnp1 (2324) = 1
      chnar (2324) = 13
      chnpy (2324) = 5
      chnte (2324) = 12
      chnhe (2324) = 0
      chperm (2324) = 100
      chbirf (2324) = 387
      chetat (2324) = 405
      chtn2i (2324) = 210
      chbiet (405) = 2324
c
c Aretes coupees :   3  5 11 12
      chclas (3092) = ' 4-07'
c Code des aretes coupees : 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 1
      charde (3092)(1:12) = '  3  5 11 12'
      chnp1 (3092) = 1
      chnar (3092) = 13
      chnpy (3092) = 5
      chnte (3092) = 12
      chnhe (3092) = 0
      chperm (3092) = 21
      chbirf (3092) = 387
      chetat (3092) = 406
      chtn2i (3092) = 210
      chbiet (406) = 3092
c
c Aretes coupees :   4  5  6 10
      chclas (568) = ' 4-07'
c Code des aretes coupees : 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0
      charde (568)(1:12) = '  4  5  6 10'
      chnp1 (568) = 1
      chnar (568) = 13
      chnpy (568) = 5
      chnte (568) = 12
      chnhe (568) = 0
      chperm (568) = 30
      chbirf (568) = 387
      chetat (568) = 407
      chtn2i (568) = 210
      chbiet (407) = 568
c
c Aretes coupees :   4  6  8 10
      chclas (680) = ' 4-07'
c Code des aretes coupees : 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0
      charde (680)(1:12) = '  4  6  8 10'
      chnp1 (680) = 1
      chnar (680) = 13
      chnpy (680) = 5
      chnte (680) = 12
      chnhe (680) = 0
      chperm (680) = 121
      chbirf (680) = 387
      chetat (680) = 408
      chtn2i (680) = 210
      chbiet (408) = 680
c
c Aretes coupees :   4  6 10 11
      chclas (1576) = ' 4-07'
c Code des aretes coupees : 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1, 0
      charde (1576)(1:12) = '  4  6 10 11'
      chnp1 (1576) = 1
      chnar (1576) = 13
      chnpy (1576) = 5
      chnte (1576) = 12
      chnhe (1576) = 0
      chperm (1576) = 110
      chbirf (1576) = 387
      chetat (1576) = 409
      chtn2i (1576) = 210
      chbiet (409) = 1576
c
c Aretes coupees :   4  6 10 12
      chclas (2600) = ' 4-07'
c Code des aretes coupees : 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1
      charde (2600)(1:12) = '  4  6 10 12'
      chnp1 (2600) = 1
      chnar (2600) = 13
      chnpy (2600) = 5
      chnte (2600) = 12
      chnhe (2600) = 0
      chperm (2600) = 200
      chbirf (2600) = 387
      chetat (2600) = 410
      chtn2i (2600) = 210
      chbiet (410) = 2600
c
c ===========================================
c Classe d'equivalence  4-08
c
c Aretes coupees :   1  2  8 10
      chclas (643) = ' 4-08'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0
      charde (643)(1:12) = '  1  2  8 10'
      chnp1 (643) = 1
      chnar (643) = 13
      chnpy (643) = 5
      chnte (643) = 12
      chnhe (643) = 0
      chperm (643) = 0
      chbirf (643) = 643
      chetat (643) = 411
      chtn2i (643) = 210
      chbiet (411) = 643
c
c Aretes coupees :   1  3  7  9
      chclas (325) = ' 4-08'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0
      charde (325)(1:12) = '  1  3  7  9'
      chnp1 (325) = 1
      chnar (325) = 13
      chnpy (325) = 5
      chnte (325) = 12
      chnhe (325) = 0
      chperm (325) = 221
      chbirf (325) = 643
      chetat (325) = 412
      chtn2i (325) = 210
      chbiet (412) = 325
c
c Aretes coupees :   1  4  5 11
      chclas (1049) = ' 4-08'
c Code des aretes coupees : 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0
      charde (1049)(1:12) = '  1  4  5 11'
      chnp1 (1049) = 1
      chnar (1049) = 13
      chnpy (1049) = 5
      chnte (1049) = 12
      chnhe (1049) = 0
      chperm (1049) = 101
      chbirf (1049) = 643
      chetat (1049) = 413
      chtn2i (1049) = 210
      chbiet (413) = 1049
c
c Aretes coupees :   1  4  8 10
      chclas (649) = ' 4-08'
c Code des aretes coupees : 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0
      charde (649)(1:12) = '  1  4  8 10'
      chnp1 (649) = 1
      chnar (649) = 13
      chnpy (649) = 5
      chnte (649) = 12
      chnhe (649) = 0
      chperm (649) = 121
      chbirf (649) = 643
      chetat (649) = 414
      chtn2i (649) = 210
      chbiet (414) = 649
c
c Aretes coupees :   1  6  8 10
      chclas (673) = ' 4-08'
c Code des aretes coupees : 1, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0
      charde (673)(1:12) = '  1  6  8 10'
      chnp1 (673) = 1
      chnar (673) = 13
      chnpy (673) = 5
      chnte (673) = 12
      chnhe (673) = 0
      chperm (673) = 320
      chbirf (673) = 643
      chetat (673) = 415
      chtn2i (673) = 210
      chbiet (415) = 673
c
c Aretes coupees :   1  7  8 10
      chclas (705) = ' 4-08'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 0
      charde (705)(1:12) = '  1  7  8 10'
      chnp1 (705) = 1
      chnar (705) = 13
      chnpy (705) = 5
      chnte (705) = 12
      chnhe (705) = 0
      chperm (705) = 130
      chbirf (705) = 643
      chetat (705) = 416
      chtn2i (705) = 210
      chbiet (416) = 705
c
c Aretes coupees :   1  8  9 10
      chclas (897) = ' 4-08'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0
      charde (897)(1:12) = '  1  8  9 10'
      chnp1 (897) = 1
      chnar (897) = 13
      chnpy (897) = 5
      chnte (897) = 12
      chnhe (897) = 0
      chperm (897) = 201
      chbirf (897) = 643
      chetat (897) = 417
      chtn2i (897) = 210
      chbiet (417) = 897
c
c Aretes coupees :   1  8 10 11
      chclas (1665) = ' 4-08'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0
      charde (1665)(1:12) = '  1  8 10 11'
      chnp1 (1665) = 1
      chnar (1665) = 13
      chnpy (1665) = 5
      chnte (1665) = 12
      chnhe (1665) = 0
      chperm (1665) = 210
      chbirf (1665) = 643
      chetat (1665) = 418
      chtn2i (1665) = 210
      chbiet (418) = 1665
c
c Aretes coupees :   2  3  6 12
      chclas (2086) = ' 4-08'
c Code des aretes coupees : 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1
      charde (2086)(1:12) = '  2  3  6 12'
      chnp1 (2086) = 1
      chnar (2086) = 13
      chnpy (2086) = 5
      chnte (2086) = 12
      chnhe (2086) = 0
      chperm (2086) = 10
      chbirf (2086) = 643
      chetat (2086) = 419
      chtn2i (2086) = 210
      chbiet (419) = 2086
c
c Aretes coupees :   2  3  7  9
      chclas (326) = ' 4-08'
c Code des aretes coupees : 0, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0
      charde (326)(1:12) = '  2  3  7  9'
      chnp1 (326) = 1
      chnar (326) = 13
      chnpy (326) = 5
      chnte (326) = 12
      chnhe (326) = 0
      chperm (326) = 230
      chbirf (326) = 643
      chetat (326) = 420
      chtn2i (326) = 210
      chbiet (420) = 326
c
c Aretes coupees :   2  4  6 12
      chclas (2090) = ' 4-08'
c Code des aretes coupees : 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1
      charde (2090)(1:12) = '  2  4  6 12'
      chnp1 (2090) = 1
      chnar (2090) = 13
      chnpy (2090) = 5
      chnte (2090) = 12
      chnhe (2090) = 0
      chperm (2090) = 1
      chbirf (2090) = 643
      chetat (2090) = 421
      chtn2i (2090) = 210
      chbiet (421) = 2090
c
c Aretes coupees :   2  5  6 12
      chclas (2098) = ' 4-08'
c Code des aretes coupees : 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1
      charde (2098)(1:12) = '  2  5  6 12'
      chnp1 (2098) = 1
      chnar (2098) = 13
      chnpy (2098) = 5
      chnte (2098) = 12
      chnhe (2098) = 0
      chperm (2098) = 330
      chbirf (2098) = 643
      chetat (2098) = 422
      chtn2i (2098) = 210
      chbiet (422) = 2098
c
c Aretes coupees :   2  6  8 12
      chclas (2210) = ' 4-08'
c Code des aretes coupees : 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1
      charde (2210)(1:12) = '  2  6  8 12'
      chnp1 (2210) = 1
      chnar (2210) = 13
      chnpy (2210) = 5
      chnte (2210) = 12
      chnhe (2210) = 0
      chperm (2210) = 120
      chbirf (2210) = 643
      chetat (2210) = 423
      chtn2i (2210) = 210
      chbiet (423) = 2210
c
c Aretes coupees :   2  6  9 12
      chclas (2338) = ' 4-08'
c Code des aretes coupees : 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1
      charde (2338)(1:12) = '  2  6  9 12'
      chnp1 (2338) = 1
      chnar (2338) = 13
      chnpy (2338) = 5
      chnte (2338) = 12
      chnhe (2338) = 0
      chperm (2338) = 321
      chbirf (2338) = 643
      chetat (2338) = 424
      chtn2i (2338) = 210
      chbiet (424) = 2338
c
c Aretes coupees :   2  6 10 12
      chclas (2594) = ' 4-08'
c Code des aretes coupees : 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1
      charde (2594)(1:12) = '  2  6 10 12'
      chnp1 (2594) = 1
      chnar (2594) = 13
      chnpy (2594) = 5
      chnte (2594) = 12
      chnhe (2594) = 0
      chperm (2594) = 200
      chbirf (2594) = 643
      chetat (2594) = 425
      chtn2i (2594) = 210
      chbiet (425) = 2594
c
c Aretes coupees :   3  4  5 11
      chclas (1052) = ' 4-08'
c Code des aretes coupees : 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0
      charde (1052)(1:12) = '  3  4  5 11'
      chnp1 (1052) = 1
      chnar (1052) = 13
      chnpy (1052) = 5
      chnte (1052) = 12
      chnhe (1052) = 0
      chperm (1052) = 220
      chbirf (1052) = 643
      chetat (1052) = 426
      chtn2i (1052) = 210
      chbiet (426) = 1052
c
c Aretes coupees :   3  5  7  9
      chclas (340) = ' 4-08'
c Code des aretes coupees : 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0
      charde (340)(1:12) = '  3  5  7  9'
      chnp1 (340) = 1
      chnar (340) = 13
      chnpy (340) = 5
      chnte (340) = 12
      chnhe (340) = 0
      chperm (340) = 100
      chbirf (340) = 643
      chetat (340) = 427
      chtn2i (340) = 210
      chbiet (427) = 340
c
c Aretes coupees :   3  7  8  9
      chclas (452) = ' 4-08'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0
      charde (452)(1:12) = '  3  7  8  9'
      chnp1 (452) = 1
      chnar (452) = 13
      chnpy (452) = 5
      chnte (452) = 12
      chnhe (452) = 0
      chperm (452) = 310
      chbirf (452) = 643
      chetat (452) = 428
      chtn2i (452) = 210
      chbiet (428) = 452
c
c Aretes coupees :   3  7  9 11
      chclas (1348) = ' 4-08'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0
      charde (1348)(1:12) = '  3  7  9 11'
      chnp1 (1348) = 1
      chnar (1348) = 13
      chnpy (1348) = 5
      chnte (1348) = 12
      chnhe (1348) = 0
      chperm (1348) = 20
      chbirf (1348) = 643
      chetat (1348) = 429
      chtn2i (1348) = 210
      chbiet (429) = 1348
c
c Aretes coupees :   3  7  9 12
      chclas (2372) = ' 4-08'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1
      charde (2372)(1:12) = '  3  7  9 12'
      chnp1 (2372) = 1
      chnar (2372) = 13
      chnpy (2372) = 5
      chnte (2372) = 12
      chnhe (2372) = 0
      chperm (2372) = 301
      chbirf (2372) = 643
      chetat (2372) = 430
      chtn2i (2372) = 210
      chbiet (430) = 2372
c
c Aretes coupees :   4  5  6 11
      chclas (1080) = ' 4-08'
c Code des aretes coupees : 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 0
      charde (1080)(1:12) = '  4  5  6 11'
      chnp1 (1080) = 1
      chnar (1080) = 13
      chnpy (1080) = 5
      chnte (1080) = 12
      chnhe (1080) = 0
      chperm (1080) = 110
      chbirf (1080) = 643
      chetat (1080) = 431
      chtn2i (1080) = 210
      chbiet (431) = 1080
c
c Aretes coupees :   4  5  7 11
      chclas (1112) = ' 4-08'
c Code des aretes coupees : 0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 1, 0
      charde (1112)(1:12) = '  4  5  7 11'
      chnp1 (1112) = 1
      chnar (1112) = 13
      chnpy (1112) = 5
      chnte (1112) = 12
      chnhe (1112) = 0
      chperm (1112) = 300
      chbirf (1112) = 643
      chetat (1112) = 432
      chtn2i (1112) = 210
      chbiet (432) = 1112
c
c Aretes coupees :   4  5 10 11
      chclas (1560) = ' 4-08'
c Code des aretes coupees : 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0
      charde (1560)(1:12) = '  4  5 10 11'
      chnp1 (1560) = 1
      chnar (1560) = 13
      chnpy (1560) = 5
      chnte (1560) = 12
      chnhe (1560) = 0
      chperm (1560) = 30
      chbirf (1560) = 643
      chetat (1560) = 433
      chtn2i (1560) = 210
      chbiet (433) = 1560
c
c Aretes coupees :   4  5 11 12
      chclas (3096) = ' 4-08'
c Code des aretes coupees : 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1
      charde (3096)(1:12) = '  4  5 11 12'
      chnp1 (3096) = 1
      chnar (3096) = 13
      chnpy (3096) = 5
      chnte (3096) = 12
      chnhe (3096) = 0
      chperm (3096) = 21
      chbirf (3096) = 643
      chetat (3096) = 434
      chtn2i (3096) = 210
      chbiet (434) = 3096
c
c ===========================================
c Classe d'equivalence  4-09
c
c Aretes coupees :   1  2  6 12
      chclas (2083) = ' 4-09'
c Code des aretes coupees : 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1
      charde (2083)(1:12) = '  1  2  6 12'
      chnp1 (2083) = 1
      chnar (2083) = 14
      chnpy (2083) = 6
      chnte (2083) = 12
      chnhe (2083) = 0
      chperm (2083) = 0
      chbirf (2083) = 2083
      chetat (2083) = 435
      chtn2i (2083) = 210
      chbiet (435) = 2083
c
c Aretes coupees :   1  3  8 10
      chclas (645) = ' 4-09'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0
      charde (645)(1:12) = '  1  3  8 10'
      chnp1 (645) = 1
      chnar (645) = 14
      chnpy (645) = 6
      chnte (645) = 12
      chnhe (645) = 0
      chperm (645) = 310
      chbirf (645) = 2083
      chetat (645) = 436
      chtn2i (645) = 210
      chbiet (436) = 645
c
c Aretes coupees :   1  5  8 10
      chclas (657) = ' 4-09'
c Code des aretes coupees : 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0
      charde (657)(1:12) = '  1  5  8 10'
      chnp1 (657) = 1
      chnar (657) = 14
      chnpy (657) = 6
      chnte (657) = 12
      chnhe (657) = 0
      chperm (657) = 30
      chbirf (657) = 2083
      chetat (657) = 437
      chtn2i (657) = 210
      chbiet (437) = 657
c
c Aretes coupees :   1  8 10 12
      chclas (2689) = ' 4-09'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1
      charde (2689)(1:12) = '  1  8 10 12'
      chnp1 (2689) = 1
      chnar (2689) = 14
      chnpy (2689) = 6
      chnte (2689) = 12
      chnhe (2689) = 0
      chperm (2689) = 200
      chbirf (2689) = 2083
      chetat (2689) = 438
      chtn2i (2689) = 210
      chbiet (438) = 2689
c
c Aretes coupees :   2  4  5 11
      chclas (1050) = ' 4-09'
c Code des aretes coupees : 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0
      charde (1050)(1:12) = '  2  4  5 11'
      chnp1 (1050) = 1
      chnar (1050) = 14
      chnpy (1050) = 6
      chnte (1050) = 12
      chnhe (1050) = 0
      chperm (1050) = 330
      chbirf (1050) = 2083
      chetat (1050) = 439
      chtn2i (1050) = 210
      chbiet (439) = 1050
c
c Aretes coupees :   2  6  7 12
      chclas (2146) = ' 4-09'
c Code des aretes coupees : 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1
      charde (2146)(1:12) = '  2  6  7 12'
      chnp1 (2146) = 1
      chnar (2146) = 14
      chnpy (2146) = 6
      chnte (2146) = 12
      chnhe (2146) = 0
      chperm (2146) = 230
      chbirf (2146) = 2083
      chetat (2146) = 440
      chtn2i (2146) = 210
      chbiet (440) = 2146
c
c Aretes coupees :   2  6 11 12
      chclas (3106) = ' 4-09'
c Code des aretes coupees : 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1
      charde (3106)(1:12) = '  2  6 11 12'
      chnp1 (3106) = 1
      chnar (3106) = 14
      chnpy (3106) = 6
      chnte (3106) = 12
      chnhe (3106) = 0
      chperm (3106) = 110
      chbirf (3106) = 2083
      chetat (3106) = 441
      chtn2i (3106) = 210
      chbiet (441) = 3106
c
c Aretes coupees :   3  4  7  9
      chclas (332) = ' 4-09'
c Code des aretes coupees : 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 0
      charde (332)(1:12) = '  3  4  7  9'
      chnp1 (332) = 1
      chnar (332) = 14
      chnpy (332) = 6
      chnte (332) = 12
      chnhe (332) = 0
      chperm (332) = 300
      chbirf (332) = 2083
      chetat (332) = 442
      chtn2i (332) = 210
      chbiet (442) = 332
c
c Aretes coupees :   3  6  7  9
      chclas (356) = ' 4-09'
c Code des aretes coupees : 0, 0, 1, 0, 0, 1, 1, 0, 1, 0, 0, 0
      charde (356)(1:12) = '  3  6  7  9'
      chnp1 (356) = 1
      chnar (356) = 14
      chnpy (356) = 6
      chnte (356) = 12
      chnhe (356) = 0
      chperm (356) = 10
      chbirf (356) = 2083
      chetat (356) = 443
      chtn2i (356) = 210
      chbiet (443) = 356
c
c Aretes coupees :   3  7  9 10
      chclas (836) = ' 4-09'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 1, 0, 1, 1, 0, 0
      charde (836)(1:12) = '  3  7  9 10'
      chnp1 (836) = 1
      chnar (836) = 14
      chnpy (836) = 6
      chnte (836) = 12
      chnhe (836) = 0
      chperm (836) = 130
      chbirf (836) = 2083
      chetat (836) = 444
      chtn2i (836) = 210
      chbiet (444) = 836
c
c Aretes coupees :   4  5  8 11
      chclas (1176) = ' 4-09'
c Code des aretes coupees : 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0
      charde (1176)(1:12) = '  4  5  8 11'
      chnp1 (1176) = 1
      chnar (1176) = 14
      chnpy (1176) = 6
      chnte (1176) = 12
      chnhe (1176) = 0
      chperm (1176) = 210
      chbirf (1176) = 2083
      chetat (1176) = 445
      chtn2i (1176) = 210
      chbiet (445) = 1176
c
c Aretes coupees :   4  5  9 11
      chclas (1304) = ' 4-09'
c Code des aretes coupees : 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 1, 0
      charde (1304)(1:12) = '  4  5  9 11'
      chnp1 (1304) = 1
      chnar (1304) = 14
      chnpy (1304) = 6
      chnte (1304) = 12
      chnhe (1304) = 0
      chperm (1304) = 100
      chbirf (1304) = 2083
      chetat (1304) = 446
      chtn2i (1304) = 210
      chbiet (446) = 1304
c
c ===========================================
c Classe d'equivalence  4-10
c
c Aretes coupees :   1  2  7 11
      chclas (1091) = ' 4-10'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0
      charde (1091)(1:12) = '  1  2  7 11'
      chnp1 (1091) = 1
      chnar (1091) = 14
      chnpy (1091) = 6
      chnte (1091) = 12
      chnhe (1091) = 0
      chperm (1091) = 0
      chbirf (1091) = 1091
      chetat (1091) = 447
      chtn2i (1091) = 210
      chbiet (447) = 1091
c
c Aretes coupees :   1  3  5 12
      chclas (2069) = ' 4-10'
c Code des aretes coupees : 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1
      charde (2069)(1:12) = '  1  3  5 12'
      chnp1 (2069) = 1
      chnar (2069) = 14
      chnpy (2069) = 6
      chnte (2069) = 12
      chnhe (2069) = 0
      chperm (2069) = 101
      chbirf (2069) = 1091
      chetat (2069) = 448
      chtn2i (2069) = 210
      chbiet (448) = 2069
c
c Aretes coupees :   1  6  7 11
      chclas (1121) = ' 4-10'
c Code des aretes coupees : 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0
      charde (1121)(1:12) = '  1  6  7 11'
      chnp1 (1121) = 1
      chnar (1121) = 14
      chnpy (1121) = 6
      chnte (1121) = 12
      chnhe (1121) = 0
      chperm (1121) = 110
      chbirf (1121) = 1091
      chetat (1121) = 449
      chtn2i (1121) = 210
      chbiet (449) = 1121
c
c Aretes coupees :   1  7 11 12
      chclas (3137) = ' 4-10'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1
      charde (3137)(1:12) = '  1  7 11 12'
      chnp1 (3137) = 1
      chnar (3137) = 14
      chnpy (3137) = 6
      chnte (3137) = 12
      chnhe (3137) = 0
      chperm (3137) = 301
      chbirf (3137) = 1091
      chetat (3137) = 450
      chtn2i (3137) = 210
      chbiet (450) = 3137
c
c Aretes coupees :   2  4  8  9
      chclas (394) = ' 4-10'
c Code des aretes coupees : 0, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0
      charde (394)(1:12) = '  2  4  8  9'
      chnp1 (394) = 1
      chnar (394) = 14
      chnpy (394) = 6
      chnte (394) = 12
      chnhe (394) = 0
      chperm (394) = 1
      chbirf (394) = 1091
      chetat (394) = 451
      chtn2i (394) = 210
      chbiet (451) = 394
c
c Aretes coupees :   2  5  8  9
      chclas (402) = ' 4-10'
c Code des aretes coupees : 0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0
      charde (402)(1:12) = '  2  5  8  9'
      chnp1 (402) = 1
      chnar (402) = 14
      chnpy (402) = 6
      chnte (402) = 12
      chnhe (402) = 0
      chperm (402) = 100
      chbirf (402) = 1091
      chetat (402) = 452
      chtn2i (402) = 210
      chbiet (452) = 402
c
c Aretes coupees :   2  8  9 11
      chclas (1410) = ' 4-10'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0
      charde (1410)(1:12) = '  2  8  9 11'
      chnp1 (1410) = 1
      chnar (1410) = 14
      chnpy (1410) = 6
      chnte (1410) = 12
      chnhe (1410) = 0
      chperm (1410) = 210
      chbirf (1410) = 1091
      chetat (1410) = 453
      chtn2i (1410) = 210
      chbiet (453) = 1410
c
c Aretes coupees :   3  4  6 10
      chclas (556) = ' 4-10'
c Code des aretes coupees : 0, 0, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0
      charde (556)(1:12) = '  3  4  6 10'
      chnp1 (556) = 1
      chnar (556) = 14
      chnpy (556) = 6
      chnte (556) = 12
      chnhe (556) = 0
      chperm (556) = 10
      chbirf (556) = 1091
      chetat (556) = 454
      chtn2i (556) = 210
      chbiet (454) = 556
c
c Aretes coupees :   3  5  8 12
      chclas (2196) = ' 4-10'
c Code des aretes coupees : 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 1
      charde (2196)(1:12) = '  3  5  8 12'
      chnp1 (2196) = 1
      chnar (2196) = 14
      chnpy (2196) = 6
      chnte (2196) = 12
      chnhe (2196) = 0
      chperm (2196) = 310
      chbirf (2196) = 1091
      chetat (2196) = 455
      chtn2i (2196) = 210
      chbiet (455) = 2196
c
c Aretes coupees :   3  5 10 12
      chclas (2580) = ' 4-10'
c Code des aretes coupees : 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1
      charde (2580)(1:12) = '  3  5 10 12'
      chnp1 (2580) = 1
      chnar (2580) = 14
      chnpy (2580) = 6
      chnte (2580) = 12
      chnhe (2580) = 0
      chperm (2580) = 200
      chbirf (2580) = 1091
      chetat (2580) = 456
      chtn2i (2580) = 210
      chbiet (456) = 2580
c
c Aretes coupees :   4  6  7 10
      chclas (616) = ' 4-10'
c Code des aretes coupees : 0, 0, 0, 1, 0, 1, 1, 0, 0, 1, 0, 0
      charde (616)(1:12) = '  4  6  7 10'
      chnp1 (616) = 1
      chnar (616) = 14
      chnpy (616) = 6
      chnte (616) = 12
      chnhe (616) = 0
      chperm (616) = 300
      chbirf (616) = 1091
      chetat (616) = 457
      chtn2i (616) = 210
      chbiet (457) = 616
c
c Aretes coupees :   4  6  9 10
      chclas (808) = ' 4-10'
c Code des aretes coupees : 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 0
      charde (808)(1:12) = '  4  6  9 10'
      chnp1 (808) = 1
      chnar (808) = 14
      chnpy (808) = 6
      chnte (808) = 12
      chnhe (808) = 0
      chperm (808) = 201
      chbirf (808) = 1091
      chetat (808) = 458
      chtn2i (808) = 210
      chbiet (458) = 808
c
c ===========================================
c Classe d'equivalence  4-11
c
c Aretes coupees :   1  2  6  7
      chclas (99) = ' 4-11'
c Code des aretes coupees : 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0
      charde (99)(1:12) = '  1  2  6  7'
      chnp1 (99) = 1
      chnar (99) = 15
      chnpy (99) = 10
      chnte (99) = 6
      chnhe (99) = 0
      chperm (99) = 0
      chbirf (99) = 99
      chetat (99) = 459
      chtn2i (99) = 210
      chbiet (459) = 99
c
c Aretes coupees :   1  2  6 11
      chclas (1059) = ' 4-11'
c Code des aretes coupees : 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0
      charde (1059)(1:12) = '  1  2  6 11'
      chnp1 (1059) = 1
      chnar (1059) = 15
      chnpy (1059) = 10
      chnte (1059) = 6
      chnhe (1059) = 0
      chperm (1059) = 320
      chbirf (1059) = 99
      chetat (1059) = 460
      chtn2i (1059) = 210
      chbiet (460) = 1059
c
c Aretes coupees :   1  2  7 12
      chclas (2115) = ' 4-11'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1
      charde (2115)(1:12) = '  1  2  7 12'
      chnp1 (2115) = 1
      chnar (2115) = 15
      chnpy (2115) = 10
      chnte (2115) = 6
      chnhe (2115) = 0
      chperm (2115) = 230
      chbirf (2115) = 99
      chetat (2115) = 461
      chtn2i (2115) = 210
      chbiet (461) = 2115
c
c Aretes coupees :   1  3  5  8
      chclas (149) = ' 4-11'
c Code des aretes coupees : 1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0
      charde (149)(1:12) = '  1  3  5  8'
      chnp1 (149) = 1
      chnar (149) = 15
      chnpy (149) = 10
      chnte (149) = 6
      chnhe (149) = 0
      chperm (149) = 221
      chbirf (149) = 99
      chetat (149) = 462
      chtn2i (149) = 210
      chbiet (462) = 149
c
c Aretes coupees :   1  3  5 10
      chclas (533) = ' 4-11'
c Code des aretes coupees : 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0
      charde (533)(1:12) = '  1  3  5 10'
      chnp1 (533) = 1
      chnar (533) = 15
      chnpy (533) = 10
      chnte (533) = 6
      chnhe (533) = 0
      chperm (533) = 101
      chbirf (533) = 99
      chetat (533) = 463
      chtn2i (533) = 210
      chbiet (463) = 533
c
c Aretes coupees :   1  3  8 12
      chclas (2181) = ' 4-11'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1
      charde (2181)(1:12) = '  1  3  8 12'
      chnp1 (2181) = 1
      chnar (2181) = 15
      chnpy (2181) = 10
      chnte (2181) = 6
      chnhe (2181) = 0
      chperm (2181) = 310
      chbirf (2181) = 99
      chetat (2181) = 464
      chtn2i (2181) = 210
      chbiet (464) = 2181
c
c Aretes coupees :   1  5 10 12
      chclas (2577) = ' 4-11'
c Code des aretes coupees : 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1
      charde (2577)(1:12) = '  1  5 10 12'
      chnp1 (2577) = 1
      chnar (2577) = 15
      chnpy (2577) = 10
      chnte (2577) = 6
      chnhe (2577) = 0
      chperm (2577) = 30
      chbirf (2577) = 99
      chetat (2577) = 465
      chtn2i (2577) = 210
      chbiet (465) = 2577
c
c Aretes coupees :   1  6 11 12
      chclas (3105) = ' 4-11'
c Code des aretes coupees : 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1
      charde (3105)(1:12) = '  1  6 11 12'
      chnp1 (3105) = 1
      chnar (3105) = 15
      chnpy (3105) = 10
      chnte (3105) = 6
      chnhe (3105) = 0
      chperm (3105) = 110
      chbirf (3105) = 99
      chetat (3105) = 466
      chtn2i (3105) = 210
      chbiet (466) = 3105
c
c Aretes coupees :   2  4  5  8
      chclas (154) = ' 4-11'
c Code des aretes coupees : 0, 1, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0
      charde (154)(1:12) = '  2  4  5  8'
      chnp1 (154) = 1
      chnar (154) = 15
      chnpy (154) = 10
      chnte (154) = 6
      chnhe (154) = 0
      chperm (154) = 1
      chbirf (154) = 99
      chetat (154) = 467
      chtn2i (154) = 210
      chbiet (467) = 154
c
c Aretes coupees :   2  4  5  9
      chclas (282) = ' 4-11'
c Code des aretes coupees : 0, 1, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0
      charde (282)(1:12) = '  2  4  5  9'
      chnp1 (282) = 1
      chnar (282) = 15
      chnpy (282) = 10
      chnte (282) = 6
      chnhe (282) = 0
      chperm (282) = 330
      chbirf (282) = 99
      chetat (282) = 468
      chtn2i (282) = 210
      chbiet (468) = 282
c
c Aretes coupees :   2  4  8 11
      chclas (1162) = ' 4-11'
c Code des aretes coupees : 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0
      charde (1162)(1:12) = '  2  4  8 11'
      chnp1 (1162) = 1
      chnar (1162) = 15
      chnpy (1162) = 10
      chnte (1162) = 6
      chnhe (1162) = 0
      chperm (1162) = 121
      chbirf (1162) = 99
      chetat (1162) = 469
      chtn2i (1162) = 210
      chbiet (469) = 1162
c
c Aretes coupees :   2  5  9 11
      chclas (1298) = ' 4-11'
c Code des aretes coupees : 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0
      charde (1298)(1:12) = '  2  5  9 11'
      chnp1 (1298) = 1
      chnar (1298) = 15
      chnpy (1298) = 10
      chnte (1298) = 6
      chnhe (1298) = 0
      chperm (1298) = 100
      chbirf (1298) = 99
      chetat (1298) = 470
      chtn2i (1298) = 210
      chbiet (470) = 1298
c
c Aretes coupees :   2  7 11 12
      chclas (3138) = ' 4-11'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1
      charde (3138)(1:12) = '  2  7 11 12'
      chnp1 (3138) = 1
      chnar (3138) = 15
      chnpy (3138) = 10
      chnte (3138) = 6
      chnhe (3138) = 0
      chperm (3138) = 301
      chbirf (3138) = 99
      chetat (3138) = 471
      chtn2i (3138) = 210
      chbiet (471) = 3138
c
c Aretes coupees :   3  4  6  7
      chclas (108) = ' 4-11'
c Code des aretes coupees : 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0
      charde (108)(1:12) = '  3  4  6  7'
      chnp1 (108) = 1
      chnar (108) = 15
      chnpy (108) = 10
      chnte (108) = 6
      chnhe (108) = 0
      chperm (108) = 220
      chbirf (108) = 99
      chetat (108) = 472
      chtn2i (108) = 210
      chbiet (472) = 108
c
c Aretes coupees :   3  4  6  9
      chclas (300) = ' 4-11'
c Code des aretes coupees : 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0, 0
      charde (300)(1:12) = '  3  4  6  9'
      chnp1 (300) = 1
      chnar (300) = 15
      chnpy (300) = 10
      chnte (300) = 6
      chnhe (300) = 0
      chperm (300) = 10
      chbirf (300) = 99
      chetat (300) = 473
      chtn2i (300) = 210
      chbiet (473) = 300
c
c Aretes coupees :   3  4  7 10
      chclas (588) = ' 4-11'
c Code des aretes coupees : 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0
      charde (588)(1:12) = '  3  4  7 10'
      chnp1 (588) = 1
      chnar (588) = 15
      chnpy (588) = 10
      chnte (588) = 6
      chnhe (588) = 0
      chperm (588) = 300
      chbirf (588) = 99
      chetat (588) = 474
      chtn2i (588) = 210
      chbiet (474) = 588
c
c Aretes coupees :   3  6  9 10
      chclas (804) = ' 4-11'
c Code des aretes coupees : 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0
      charde (804)(1:12) = '  3  6  9 10'
      chnp1 (804) = 1
      chnar (804) = 15
      chnpy (804) = 10
      chnte (804) = 6
      chnhe (804) = 0
      chperm (804) = 321
      chbirf (804) = 99
      chetat (804) = 475
      chtn2i (804) = 210
      chbiet (475) = 804
c
c Aretes coupees :   3  8 10 12
      chclas (2692) = ' 4-11'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 1
      charde (2692)(1:12) = '  3  8 10 12'
      chnp1 (2692) = 1
      chnar (2692) = 15
      chnpy (2692) = 10
      chnte (2692) = 6
      chnhe (2692) = 0
      chperm (2692) = 120
      chbirf (2692) = 99
      chetat (2692) = 476
      chtn2i (2692) = 210
      chbiet (476) = 2692
c
c Aretes coupees :   4  7  9 10
      chclas (840) = ' 4-11'
c Code des aretes coupees : 0, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0
      charde (840)(1:12) = '  4  7  9 10'
      chnp1 (840) = 1
      chnar (840) = 15
      chnpy (840) = 10
      chnte (840) = 6
      chnhe (840) = 0
      chperm (840) = 130
      chbirf (840) = 99
      chetat (840) = 477
      chtn2i (840) = 210
      chbiet (477) = 840
c
c Aretes coupees :   4  8  9 11
      chclas (1416) = ' 4-11'
c Code des aretes coupees : 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 1, 0
      charde (1416)(1:12) = '  4  8  9 11'
      chnp1 (1416) = 1
      chnar (1416) = 15
      chnpy (1416) = 10
      chnte (1416) = 6
      chnhe (1416) = 0
      chperm (1416) = 210
      chbirf (1416) = 99
      chetat (1416) = 478
      chtn2i (1416) = 210
      chbiet (478) = 1416
c
c Aretes coupees :   5  8  9 11
      chclas (1424) = ' 4-11'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 1, 0
      charde (1424)(1:12) = '  5  8  9 11'
      chnp1 (1424) = 1
      chnar (1424) = 15
      chnpy (1424) = 10
      chnte (1424) = 6
      chnhe (1424) = 0
      chperm (1424) = 20
      chbirf (1424) = 99
      chetat (1424) = 479
      chtn2i (1424) = 210
      chbiet (479) = 1424
c
c Aretes coupees :   5  8 10 12
      chclas (2704) = ' 4-11'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1
      charde (2704)(1:12) = '  5  8 10 12'
      chnp1 (2704) = 1
      chnar (2704) = 15
      chnpy (2704) = 10
      chnte (2704) = 6
      chnhe (2704) = 0
      chperm (2704) = 200
      chbirf (2704) = 99
      chetat (2704) = 480
      chtn2i (2704) = 210
      chbiet (480) = 2704
c
c Aretes coupees :   6  7  9 10
      chclas (864) = ' 4-11'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0
      charde (864)(1:12) = '  6  7  9 10'
      chnp1 (864) = 1
      chnar (864) = 15
      chnpy (864) = 10
      chnte (864) = 6
      chnhe (864) = 0
      chperm (864) = 201
      chbirf (864) = 99
      chetat (864) = 481
      chtn2i (864) = 210
      chbiet (481) = 864
c
c Aretes coupees :   6  7 11 12
      chclas (3168) = ' 4-11'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1
      charde (3168)(1:12) = '  6  7 11 12'
      chnp1 (3168) = 1
      chnar (3168) = 15
      chnpy (3168) = 10
      chnte (3168) = 6
      chnhe (3168) = 0
      chperm (3168) = 21
      chbirf (3168) = 99
      chetat (3168) = 482
      chtn2i (3168) = 210
      chbiet (482) = 3168
c
c ===========================================
c Classe d'equivalence  4-12
c
c Aretes coupees :   1  2  9 12
      chclas (2307) = ' 4-12'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1
      charde (2307)(1:12) = '  1  2  9 12'
      chnp1 (2307) = 1
      chnar (2307) = 13
      chnpy (2307) = 8
      chnte (2307) = 6
      chnhe (2307) = 0
      chperm (2307) = 0
      chbirf (2307) = 2307
      chetat (2307) = 483
      chtn2i (2307) = 210
      chbiet (483) = 2307
c
c Aretes coupees :   1  3 10 11
      chclas (1541) = ' 4-12'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0
      charde (1541)(1:12) = '  1  3 10 11'
      chnp1 (1541) = 1
      chnar (1541) = 13
      chnpy (1541) = 8
      chnte (1541) = 6
      chnhe (1541) = 0
      chperm (1541) = 221
      chbirf (1541) = 2307
      chetat (1541) = 484
      chtn2i (1541) = 210
      chbiet (484) = 1541
c
c Aretes coupees :   1  4  6 12
      chclas (2089) = ' 4-12'
c Code des aretes coupees : 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1
      charde (2089)(1:12) = '  1  4  6 12'
      chnp1 (2089) = 1
      chnar (2089) = 13
      chnpy (2089) = 8
      chnte (2089) = 6
      chnhe (2089) = 0
      chperm (2089) = 320
      chbirf (2089) = 2307
      chetat (2089) = 485
      chtn2i (2089) = 210
      chbiet (485) = 2089
c
c Aretes coupees :   1  4  7  9
      chclas (329) = ' 4-12'
c Code des aretes coupees : 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0
      charde (329)(1:12) = '  1  4  7  9'
      chnp1 (329) = 1
      chnar (329) = 13
      chnpy (329) = 8
      chnte (329) = 6
      chnhe (329) = 0
      chperm (329) = 300
      chbirf (329) = 2307
      chetat (329) = 486
      chtn2i (329) = 210
      chbiet (486) = 329
c
c Aretes coupees :   1  4  9 11
      chclas (1289) = ' 4-12'
c Code des aretes coupees : 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0
      charde (1289)(1:12) = '  1  4  9 11'
      chnp1 (1289) = 1
      chnar (1289) = 13
      chnpy (1289) = 8
      chnte (1289) = 6
      chnhe (1289) = 0
      chperm (1289) = 20
      chbirf (1289) = 2307
      chetat (1289) = 487
      chtn2i (1289) = 210
      chbiet (487) = 1289
c
c Aretes coupees :   1  4 10 12
      chclas (2569) = ' 4-12'
c Code des aretes coupees : 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1
      charde (2569)(1:12) = '  1  4 10 12'
      chnp1 (2569) = 1
      chnar (2569) = 13
      chnpy (2569) = 8
      chnte (2569) = 6
      chnhe (2569) = 0
      chperm (2569) = 200
      chbirf (2569) = 2307
      chetat (2569) = 488
      chtn2i (2569) = 210
      chbiet (488) = 2569
c
c Aretes coupees :   1  5  7  8
      chclas (209) = ' 4-12'
c Code des aretes coupees : 1, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0
      charde (209)(1:12) = '  1  5  7  8'
      chnp1 (209) = 1
      chnar (209) = 13
      chnpy (209) = 8
      chnte (209) = 6
      chnhe (209) = 0
      chperm (209) = 101
      chbirf (209) = 2307
      chetat (209) = 489
      chtn2i (209) = 210
      chbiet (489) = 209
c
c Aretes coupees :   1  8  9 12
      chclas (2433) = ' 4-12'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1
      charde (2433)(1:12) = '  1  8  9 12'
      chnp1 (2433) = 1
      chnar (2433) = 13
      chnpy (2433) = 8
      chnte (2433) = 6
      chnhe (2433) = 0
      chperm (2433) = 120
      chbirf (2433) = 2307
      chetat (2433) = 490
      chtn2i (2433) = 210
      chbiet (490) = 2433
c
c Aretes coupees :   2  3  5 11
      chclas (1046) = ' 4-12'
c Code des aretes coupees : 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0
      charde (1046)(1:12) = '  2  3  5 11'
      chnp1 (1046) = 1
      chnar (1046) = 13
      chnpy (1046) = 8
      chnte (1046) = 6
      chnhe (1046) = 0
      chperm (1046) = 330
      chbirf (1046) = 2307
      chetat (1046) = 491
      chtn2i (1046) = 210
      chbiet (491) = 1046
c
c Aretes coupees :   2  3  8 10
      chclas (646) = ' 4-12'
c Code des aretes coupees : 0, 1, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0
      charde (646)(1:12) = '  2  3  8 10'
      chnp1 (646) = 1
      chnar (646) = 13
      chnpy (646) = 8
      chnte (646) = 6
      chnhe (646) = 0
      chperm (646) = 310
      chbirf (646) = 2307
      chetat (646) = 492
      chtn2i (646) = 210
      chbiet (492) = 646
c
c Aretes coupees :   2  3  9 10
      chclas (774) = ' 4-12'
c Code des aretes coupees : 0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0
      charde (774)(1:12) = '  2  3  9 10'
      chnp1 (774) = 1
      chnar (774) = 13
      chnpy (774) = 8
      chnte (774) = 6
      chnhe (774) = 0
      chperm (774) = 201
      chbirf (774) = 2307
      chetat (774) = 493
      chtn2i (774) = 210
      chbiet (493) = 774
c
c Aretes coupees :   2  3 11 12
      chclas (3078) = ' 4-12'
c Code des aretes coupees : 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1
      charde (3078)(1:12) = '  2  3 11 12'
      chnp1 (3078) = 1
      chnar (3078) = 13
      chnpy (3078) = 8
      chnte (3078) = 6
      chnhe (3078) = 0
      chperm (3078) = 21
      chbirf (3078) = 2307
      chetat (3078) = 494
      chtn2i (3078) = 210
      chbiet (494) = 3078
c
c Aretes coupees :   2  4 10 11
      chclas (1546) = ' 4-12'
c Code des aretes coupees : 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0
      charde (1546)(1:12) = '  2  4 10 11'
      chnp1 (1546) = 1
      chnar (1546) = 13
      chnpy (1546) = 8
      chnte (1546) = 6
      chnhe (1546) = 0
      chperm (1546) = 1
      chbirf (1546) = 2307
      chetat (1546) = 495
      chtn2i (1546) = 210
      chbiet (495) = 1546
c
c Aretes coupees :   2  6  7  8
      chclas (226) = ' 4-12'
c Code des aretes coupees : 0, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0
      charde (226)(1:12) = '  2  6  7  8'
      chnp1 (226) = 1
      chnar (226) = 13
      chnpy (226) = 8
      chnte (226) = 6
      chnhe (226) = 0
      chperm (226) = 230
      chbirf (226) = 2307
      chetat (226) = 496
      chtn2i (226) = 210
      chbiet (496) = 226
c
c Aretes coupees :   2  6 10 11
      chclas (1570) = ' 4-12'
c Code des aretes coupees : 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0
      charde (1570)(1:12) = '  2  6 10 11'
      chnp1 (1570) = 1
      chnar (1570) = 13
      chnpy (1570) = 8
      chnte (1570) = 6
      chnhe (1570) = 0
      chperm (1570) = 110
      chbirf (1570) = 2307
      chetat (1570) = 497
      chtn2i (1570) = 210
      chbiet (497) = 1570
c
c Aretes coupees :   3  4  9 12
      chclas (2316) = ' 4-12'
c Code des aretes coupees : 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 1
      charde (2316)(1:12) = '  3  4  9 12'
      chnp1 (2316) = 1
      chnar (2316) = 13
      chnpy (2316) = 8
      chnte (2316) = 6
      chnhe (2316) = 0
      chperm (2316) = 220
      chbirf (2316) = 2307
      chetat (2316) = 498
      chtn2i (2316) = 210
      chbiet (498) = 2316
c
c Aretes coupees :   3  5  6  7
      chclas (116) = ' 4-12'
c Code des aretes coupees : 0, 0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0
      charde (116)(1:12) = '  3  5  6  7'
      chnp1 (116) = 1
      chnar (116) = 13
      chnpy (116) = 8
      chnte (116) = 6
      chnhe (116) = 0
      chperm (116) = 10
      chbirf (116) = 2307
      chetat (116) = 499
      chtn2i (116) = 210
      chbiet (499) = 116
c
c Aretes coupees :   3  7 10 11
      chclas (1604) = ' 4-12'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 0
      charde (1604)(1:12) = '  3  7 10 11'
      chnp1 (1604) = 1
      chnar (1604) = 13
      chnpy (1604) = 8
      chnte (1604) = 6
      chnhe (1604) = 0
      chperm (1604) = 130
      chbirf (1604) = 2307
      chetat (1604) = 500
      chtn2i (1604) = 210
      chbiet (500) = 1604
c
c Aretes coupees :   4  5  6  8
      chclas (184) = ' 4-12'
c Code des aretes coupees : 0, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0
      charde (184)(1:12) = '  4  5  6  8'
      chnp1 (184) = 1
      chnar (184) = 13
      chnpy (184) = 8
      chnte (184) = 6
      chnhe (184) = 0
      chperm (184) = 121
      chbirf (184) = 2307
      chetat (184) = 501
      chtn2i (184) = 210
      chbiet (501) = 184
c
c Aretes coupees :   4  5  9 12
      chclas (2328) = ' 4-12'
c Code des aretes coupees : 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1
      charde (2328)(1:12) = '  4  5  9 12'
      chnp1 (2328) = 1
      chnar (2328) = 13
      chnpy (2328) = 8
      chnte (2328) = 6
      chnhe (2328) = 0
      chperm (2328) = 100
      chbirf (2328) = 2307
      chetat (2328) = 502
      chtn2i (2328) = 210
      chbiet (502) = 2328
c
c Aretes coupees :   5  6  7 12
      chclas (2160) = ' 4-12'
c Code des aretes coupees : 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1
      charde (2160)(1:12) = '  5  6  7 12'
      chnp1 (2160) = 1
      chnar (2160) = 13
      chnpy (2160) = 8
      chnte (2160) = 6
      chnhe (2160) = 0
      chperm (2160) = 301
      chbirf (2160) = 2307
      chetat (2160) = 503
      chtn2i (2160) = 210
      chbiet (503) = 2160
c
c Aretes coupees :   5  6  8 10
      chclas (688) = ' 4-12'
c Code des aretes coupees : 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 0
      charde (688)(1:12) = '  5  6  8 10'
      chnp1 (688) = 1
      chnar (688) = 13
      chnpy (688) = 8
      chnte (688) = 6
      chnhe (688) = 0
      chperm (688) = 30
      chbirf (688) = 2307
      chetat (688) = 504
      chtn2i (688) = 210
      chbiet (504) = 688
c
c Aretes coupees :   5  7  8 11
      chclas (1232) = ' 4-12'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 1, 1, 0, 0, 1, 0
      charde (1232)(1:12) = '  5  7  8 11'
      chnp1 (1232) = 1
      chnar (1232) = 13
      chnpy (1232) = 8
      chnte (1232) = 6
      chnhe (1232) = 0
      chperm (1232) = 210
      chbirf (1232) = 2307
      chetat (1232) = 505
      chtn2i (1232) = 210
      chbiet (505) = 1232
c
c Aretes coupees :   6  7  8  9
      chclas (480) = ' 4-12'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0
      charde (480)(1:12) = '  6  7  8  9'
      chnp1 (480) = 1
      chnar (480) = 13
      chnpy (480) = 8
      chnte (480) = 6
      chnhe (480) = 0
      chperm (480) = 321
      chbirf (480) = 2307
      chetat (480) = 506
      chtn2i (480) = 210
      chbiet (506) = 480
c
c ===========================================
c Classe d'equivalence  4-13
c
c Aretes coupees :   1  2 10 11
      chclas (1539) = ' 4-13'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0
      charde (1539)(1:12) = '  1  2 10 11'
      chnp1 (1539) = 1
      chnar (1539) = 13
      chnpy (1539) = 8
      chnte (1539) = 6
      chnhe (1539) = 0
      chperm (1539) = 0
      chbirf (1539) = 1539
      chetat (1539) = 507
      chtn2i (1539) = 210
      chbiet (507) = 1539
c
c Aretes coupees :   1  3  9 12
      chclas (2309) = ' 4-13'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1
      charde (2309)(1:12) = '  1  3  9 12'
      chnp1 (2309) = 1
      chnar (2309) = 13
      chnpy (2309) = 8
      chnte (2309) = 6
      chnhe (2309) = 0
      chperm (2309) = 221
      chbirf (2309) = 1539
      chetat (2309) = 508
      chtn2i (2309) = 210
      chbiet (508) = 2309
c
c Aretes coupees :   1  4  5 12
      chclas (2073) = ' 4-13'
c Code des aretes coupees : 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1
      charde (2073)(1:12) = '  1  4  5 12'
      chnp1 (2073) = 1
      chnar (2073) = 13
      chnpy (2073) = 8
      chnte (2073) = 6
      chnhe (2073) = 0
      chperm (2073) = 101
      chbirf (2073) = 1539
      chetat (2073) = 509
      chtn2i (2073) = 210
      chbiet (509) = 2073
c
c Aretes coupees :   1  4  8  9
      chclas (393) = ' 4-13'
c Code des aretes coupees : 1, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0
      charde (393)(1:12) = '  1  4  8  9'
      chnp1 (393) = 1
      chnar (393) = 13
      chnpy (393) = 8
      chnte (393) = 6
      chnhe (393) = 0
      chperm (393) = 121
      chbirf (393) = 1539
      chetat (393) = 510
      chtn2i (393) = 210
      chbiet (510) = 393
c
c Aretes coupees :   1  4  9 10
      chclas (777) = ' 4-13'
c Code des aretes coupees : 1, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0
      charde (777)(1:12) = '  1  4  9 10'
      chnp1 (777) = 1
      chnar (777) = 13
      chnpy (777) = 8
      chnte (777) = 6
      chnhe (777) = 0
      chperm (777) = 201
      chbirf (777) = 1539
      chetat (777) = 511
      chtn2i (777) = 210
      chbiet (511) = 777
c
c Aretes coupees :   1  4 11 12
      chclas (3081) = ' 4-13'
c Code des aretes coupees : 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1
      charde (3081)(1:12) = '  1  4 11 12'
      chnp1 (3081) = 1
      chnar (3081) = 13
      chnpy (3081) = 8
      chnte (3081) = 6
      chnhe (3081) = 0
      chperm (3081) = 21
      chbirf (3081) = 1539
      chetat (3081) = 512
      chtn2i (3081) = 210
      chbiet (512) = 3081
c
c Aretes coupees :   1  6  7  8
      chclas (225) = ' 4-13'
c Code des aretes coupees : 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0
      charde (225)(1:12) = '  1  6  7  8'
      chnp1 (225) = 1
      chnar (225) = 13
      chnpy (225) = 8
      chnte (225) = 6
      chnhe (225) = 0
      chperm (225) = 320
      chbirf (225) = 1539
      chetat (225) = 513
      chtn2i (225) = 210
      chbiet (513) = 225
c
c Aretes coupees :   1  7  9 12
      chclas (2369) = ' 4-13'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1
      charde (2369)(1:12) = '  1  7  9 12'
      chnp1 (2369) = 1
      chnar (2369) = 13
      chnpy (2369) = 8
      chnte (2369) = 6
      chnhe (2369) = 0
      chperm (2369) = 301
      chbirf (2369) = 1539
      chetat (2369) = 514
      chtn2i (2369) = 210
      chbiet (514) = 2369
c
c Aretes coupees :   2  3  6 10
      chclas (550) = ' 4-13'
c Code des aretes coupees : 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0
      charde (550)(1:12) = '  2  3  6 10'
      chnp1 (550) = 1
      chnar (550) = 13
      chnpy (550) = 8
      chnte (550) = 6
      chnhe (550) = 0
      chperm (550) = 10
      chbirf (550) = 1539
      chetat (550) = 515
      chtn2i (550) = 210
      chbiet (515) = 550
c
c Aretes coupees :   2  3  7 11
      chclas (1094) = ' 4-13'
c Code des aretes coupees : 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0
      charde (1094)(1:12) = '  2  3  7 11'
      chnp1 (1094) = 1
      chnar (1094) = 13
      chnpy (1094) = 8
      chnte (1094) = 6
      chnhe (1094) = 0
      chperm (1094) = 230
      chbirf (1094) = 1539
      chetat (1094) = 516
      chtn2i (1094) = 210
      chbiet (516) = 1094
c
c Aretes coupees :   2  3  9 11
      chclas (1286) = ' 4-13'
c Code des aretes coupees : 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0
      charde (1286)(1:12) = '  2  3  9 11'
      chnp1 (1286) = 1
      chnar (1286) = 13
      chnpy (1286) = 8
      chnte (1286) = 6
      chnhe (1286) = 0
      chperm (1286) = 20
      chbirf (1286) = 1539
      chetat (1286) = 517
      chtn2i (1286) = 210
      chbiet (517) = 1286
c
c Aretes coupees :   2  3 10 12
      chclas (2566) = ' 4-13'
c Code des aretes coupees : 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1
      charde (2566)(1:12) = '  2  3 10 12'
      chnp1 (2566) = 1
      chnar (2566) = 13
      chnpy (2566) = 8
      chnte (2566) = 6
      chnhe (2566) = 0
      chperm (2566) = 200
      chbirf (2566) = 1539
      chetat (2566) = 518
      chtn2i (2566) = 210
      chbiet (518) = 2566
c
c Aretes coupees :   2  4  9 12
      chclas (2314) = ' 4-13'
c Code des aretes coupees : 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1
      charde (2314)(1:12) = '  2  4  9 12'
      chnp1 (2314) = 1
      chnar (2314) = 13
      chnpy (2314) = 8
      chnte (2314) = 6
      chnhe (2314) = 0
      chperm (2314) = 1
      chbirf (2314) = 1539
      chetat (2314) = 519
      chtn2i (2314) = 210
      chbiet (519) = 2314
c
c Aretes coupees :   2  5  6  8
      chclas (178) = ' 4-13'
c Code des aretes coupees : 0, 1, 0, 0, 1, 1, 0, 1, 0, 0, 0, 0
      charde (178)(1:12) = '  2  5  6  8'
      chnp1 (178) = 1
      chnar (178) = 13
      chnpy (178) = 8
      chnte (178) = 6
      chnhe (178) = 0
      chperm (178) = 330
      chbirf (178) = 1539
      chetat (178) = 520
      chtn2i (178) = 210
      chbiet (520) = 178
c
c Aretes coupees :   2  8 10 11
      chclas (1666) = ' 4-13'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0
      charde (1666)(1:12) = '  2  8 10 11'
      chnp1 (1666) = 1
      chnar (1666) = 13
      chnpy (1666) = 8
      chnte (1666) = 6
      chnhe (1666) = 0
      chperm (1666) = 210
      chbirf (1666) = 1539
      chetat (1666) = 521
      chtn2i (1666) = 210
      chbiet (521) = 1666
c
c Aretes coupees :   3  4 10 11
      chclas (1548) = ' 4-13'
c Code des aretes coupees : 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 0
      charde (1548)(1:12) = '  3  4 10 11'
      chnp1 (1548) = 1
      chnar (1548) = 13
      chnpy (1548) = 8
      chnte (1548) = 6
      chnhe (1548) = 0
      chperm (1548) = 220
      chbirf (1548) = 1539
      chetat (1548) = 522
      chtn2i (1548) = 210
      chbiet (522) = 1548
c
c Aretes coupees :   3  5  7  8
      chclas (212) = ' 4-13'
c Code des aretes coupees : 0, 0, 1, 0, 1, 0, 1, 1, 0, 0, 0, 0
      charde (212)(1:12) = '  3  5  7  8'
      chnp1 (212) = 1
      chnar (212) = 13
      chnpy (212) = 8
      chnte (212) = 6
      chnhe (212) = 0
      chperm (212) = 310
      chbirf (212) = 1539
      chetat (212) = 523
      chtn2i (212) = 210
      chbiet (523) = 212
c
c Aretes coupees :   3  5 10 11
      chclas (1556) = ' 4-13'
c Code des aretes coupees : 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 1, 0
      charde (1556)(1:12) = '  3  5 10 11'
      chnp1 (1556) = 1
      chnar (1556) = 13
      chnpy (1556) = 8
      chnte (1556) = 6
      chnhe (1556) = 0
      chperm (1556) = 30
      chbirf (1556) = 1539
      chetat (1556) = 524
      chtn2i (1556) = 210
      chbiet (524) = 1556
c
c Aretes coupees :   4  5  6  7
      chclas (120) = ' 4-13'
c Code des aretes coupees : 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0
      charde (120)(1:12) = '  4  5  6  7'
      chnp1 (120) = 1
      chnar (120) = 13
      chnpy (120) = 8
      chnte (120) = 6
      chnhe (120) = 0
      chperm (120) = 300
      chbirf (120) = 1539
      chetat (120) = 525
      chtn2i (120) = 210
      chbiet (525) = 120
c
c Aretes coupees :   4  6  9 12
      chclas (2344) = ' 4-13'
c Code des aretes coupees : 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1
      charde (2344)(1:12) = '  4  6  9 12'
      chnp1 (2344) = 1
      chnar (2344) = 13
      chnpy (2344) = 8
      chnte (2344) = 6
      chnhe (2344) = 0
      chperm (2344) = 321
      chbirf (2344) = 1539
      chetat (2344) = 526
      chtn2i (2344) = 210
      chbiet (526) = 2344
c
c Aretes coupees :   5  6  7 11
      chclas (1136) = ' 4-13'
c Code des aretes coupees : 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0
      charde (1136)(1:12) = '  5  6  7 11'
      chnp1 (1136) = 1
      chnar (1136) = 13
      chnpy (1136) = 8
      chnte (1136) = 6
      chnhe (1136) = 0
      chperm (1136) = 110
      chbirf (1136) = 1539
      chetat (1136) = 527
      chtn2i (1136) = 210
      chbiet (527) = 1136
c
c Aretes coupees :   5  6  8 12
      chclas (2224) = ' 4-13'
c Code des aretes coupees : 0, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 1
      charde (2224)(1:12) = '  5  6  8 12'
      chnp1 (2224) = 1
      chnar (2224) = 13
      chnpy (2224) = 8
      chnte (2224) = 6
      chnhe (2224) = 0
      chperm (2224) = 120
      chbirf (2224) = 1539
      chetat (2224) = 528
      chtn2i (2224) = 210
      chbiet (528) = 2224
c
c Aretes coupees :   5  7  8  9
      chclas (464) = ' 4-13'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 1, 1, 1, 0, 0, 0
      charde (464)(1:12) = '  5  7  8  9'
      chnp1 (464) = 1
      chnar (464) = 13
      chnpy (464) = 8
      chnte (464) = 6
      chnhe (464) = 0
      chperm (464) = 100
      chbirf (464) = 1539
      chetat (464) = 529
      chtn2i (464) = 210
      chbiet (529) = 464
c
c Aretes coupees :   6  7  8 10
      chclas (736) = ' 4-13'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0
      charde (736)(1:12) = '  6  7  8 10'
      chnp1 (736) = 1
      chnar (736) = 13
      chnpy (736) = 8
      chnte (736) = 6
      chnhe (736) = 0
      chperm (736) = 130
      chbirf (736) = 1539
      chetat (736) = 530
      chtn2i (736) = 210
      chbiet (530) = 736
c
c ===========================================
c Classe d'equivalence  4-14
c
c Aretes coupees :   1  2  8 11
      chclas (1155) = ' 4-14'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0
      charde (1155)(1:12) = '  1  2  8 11'
      chnp1 (1155) = 1
      chnar (1155) = 14
      chnpy (1155) = 6
      chnte (1155) = 12
      chnhe (1155) = 0
      chperm (1155) = 0
      chbirf (1155) = 1155
      chetat (1155) = 531
      chtn2i (1155) = 210
      chbiet (531) = 1155
c
c Aretes coupees :   1  3  7 12
      chclas (2117) = ' 4-14'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1
      charde (2117)(1:12) = '  1  3  7 12'
      chnp1 (2117) = 1
      chnar (2117) = 14
      chnpy (2117) = 6
      chnte (2117) = 12
      chnhe (2117) = 0
      chperm (2117) = 301
      chbirf (2117) = 1155
      chetat (2117) = 532
      chtn2i (2117) = 210
      chbiet (532) = 2117
c
c Aretes coupees :   1  5 11 12
      chclas (3089) = ' 4-14'
c Code des aretes coupees : 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1
      charde (3089)(1:12) = '  1  5 11 12'
      chnp1 (3089) = 1
      chnar (3089) = 14
      chnpy (3089) = 6
      chnte (3089) = 12
      chnhe (3089) = 0
      chperm (3089) = 101
      chbirf (3089) = 1155
      chetat (3089) = 533
      chtn2i (3089) = 210
      chbiet (533) = 3089
c
c Aretes coupees :   1  6  7 10
      chclas (609) = ' 4-14'
c Code des aretes coupees : 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0
      charde (609)(1:12) = '  1  6  7 10'
      chnp1 (609) = 1
      chnar (609) = 14
      chnpy (609) = 6
      chnte (609) = 12
      chnhe (609) = 0
      chperm (609) = 320
      chbirf (609) = 1155
      chetat (609) = 534
      chtn2i (609) = 210
      chbiet (534) = 609
c
c Aretes coupees :   2  4  6  9
      chclas (298) = ' 4-14'
c Code des aretes coupees : 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0
      charde (298)(1:12) = '  2  4  6  9'
      chnp1 (298) = 1
      chnar (298) = 14
      chnpy (298) = 6
      chnte (298) = 12
      chnhe (298) = 0
      chperm (298) = 1
      chbirf (298) = 1155
      chetat (298) = 535
      chtn2i (298) = 210
      chbiet (535) = 298
c
c Aretes coupees :   2  5  8 12
      chclas (2194) = ' 4-14'
c Code des aretes coupees : 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1
      charde (2194)(1:12) = '  2  5  8 12'
      chnp1 (2194) = 1
      chnar (2194) = 14
      chnpy (2194) = 6
      chnte (2194) = 12
      chnhe (2194) = 0
      chperm (2194) = 120
      chbirf (2194) = 1155
      chetat (2194) = 536
      chtn2i (2194) = 210
      chbiet (536) = 2194
c
c Aretes coupees :   2  7  9 11
      chclas (1346) = ' 4-14'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0
      charde (1346)(1:12) = '  2  7  9 11'
      chnp1 (1346) = 1
      chnar (1346) = 14
      chnpy (1346) = 6
      chnte (1346) = 12
      chnhe (1346) = 0
      chperm (1346) = 20
      chbirf (1346) = 1155
      chetat (1346) = 537
      chtn2i (1346) = 210
      chbiet (537) = 1346
c
c Aretes coupees :   3  4  5 10
      chclas (540) = ' 4-14'
c Code des aretes coupees : 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0
      charde (540)(1:12) = '  3  4  5 10'
      chnp1 (540) = 1
      chnar (540) = 14
      chnpy (540) = 6
      chnte (540) = 12
      chnhe (540) = 0
      chperm (540) = 220
      chbirf (540) = 1155
      chetat (540) = 538
      chtn2i (540) = 210
      chbiet (538) = 540
c
c Aretes coupees :   3  5  8  9
      chclas (404) = ' 4-14'
c Code des aretes coupees : 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 0, 0
      charde (404)(1:12) = '  3  5  8  9'
      chnp1 (404) = 1
      chnar (404) = 14
      chnpy (404) = 6
      chnte (404) = 12
      chnhe (404) = 0
      chperm (404) = 100
      chbirf (404) = 1155
      chetat (404) = 539
      chtn2i (404) = 210
      chbiet (539) = 404
c
c Aretes coupees :   3  6 10 12
      chclas (2596) = ' 4-14'
c Code des aretes coupees : 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1
      charde (2596)(1:12) = '  3  6 10 12'
      chnp1 (2596) = 1
      chnar (2596) = 14
      chnpy (2596) = 6
      chnte (2596) = 12
      chnhe (2596) = 0
      chperm (2596) = 200
      chbirf (2596) = 1155
      chetat (2596) = 540
      chtn2i (2596) = 210
      chbiet (540) = 2596
c
c Aretes coupees :   4  6  7 11
      chclas (1128) = ' 4-14'
c Code des aretes coupees : 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 1, 0
      charde (1128)(1:12) = '  4  6  7 11'
      chnp1 (1128) = 1
      chnar (1128) = 14
      chnpy (1128) = 6
      chnte (1128) = 12
      chnhe (1128) = 0
      chperm (1128) = 300
      chbirf (1128) = 1155
      chetat (1128) = 541
      chtn2i (1128) = 210
      chbiet (541) = 1128
c
c Aretes coupees :   4  8  9 10
      chclas (904) = ' 4-14'
c Code des aretes coupees : 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 0, 0
      charde (904)(1:12) = '  4  8  9 10'
      chnp1 (904) = 1
      chnar (904) = 14
      chnpy (904) = 6
      chnte (904) = 12
      chnhe (904) = 0
      chperm (904) = 201
      chbirf (904) = 1155
      chetat (904) = 542
      chtn2i (904) = 210
      chbiet (542) = 904
c
c ===========================================
c Classe d'equivalence  4-15
c
c Aretes coupees :   1  2  8 12
      chclas (2179) = ' 4-15'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1
      charde (2179)(1:12) = '  1  2  8 12'
      chnp1 (2179) = 1
      chnar (2179) = 14
      chnpy (2179) = 6
      chnte (2179) = 12
      chnhe (2179) = 0
      chperm (2179) = 0
      chbirf (2179) = 2179
      chetat (2179) = 543
      chtn2i (2179) = 210
      chbiet (543) = 2179
c
c Aretes coupees :   1  3  7 10
      chclas (581) = ' 4-15'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0
      charde (581)(1:12) = '  1  3  7 10'
      chnp1 (581) = 1
      chnar (581) = 14
      chnpy (581) = 6
      chnte (581) = 12
      chnhe (581) = 0
      chperm (581) = 130
      chbirf (581) = 2179
      chetat (581) = 544
      chtn2i (581) = 210
      chbiet (544) = 581
c
c Aretes coupees :   1  5  8 11
      chclas (1169) = ' 4-15'
c Code des aretes coupees : 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0
      charde (1169)(1:12) = '  1  5  8 11'
      chnp1 (1169) = 1
      chnar (1169) = 14
      chnpy (1169) = 6
      chnte (1169) = 12
      chnhe (1169) = 0
      chperm (1169) = 210
      chbirf (1169) = 2179
      chetat (1169) = 545
      chtn2i (1169) = 210
      chbiet (545) = 1169
c
c Aretes coupees :   1  6 10 12
      chclas (2593) = ' 4-15'
c Code des aretes coupees : 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1
      charde (2593)(1:12) = '  1  6 10 12'
      chnp1 (2593) = 1
      chnar (2593) = 14
      chnpy (2593) = 6
      chnte (2593) = 12
      chnhe (2593) = 0
      chperm (2593) = 200
      chbirf (2593) = 2179
      chetat (2593) = 546
      chtn2i (2593) = 210
      chbiet (546) = 2593
c
c Aretes coupees :   2  4  6 11
      chclas (1066) = ' 4-15'
c Code des aretes coupees : 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0
      charde (1066)(1:12) = '  2  4  6 11'
      chnp1 (1066) = 1
      chnar (1066) = 14
      chnpy (1066) = 6
      chnte (1066) = 12
      chnhe (1066) = 0
      chperm (1066) = 110
      chbirf (1066) = 2179
      chetat (1066) = 547
      chtn2i (1066) = 210
      chbiet (547) = 1066
c
c Aretes coupees :   2  5 11 12
      chclas (3090) = ' 4-15'
c Code des aretes coupees : 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1
      charde (3090)(1:12) = '  2  5 11 12'
      chnp1 (3090) = 1
      chnar (3090) = 14
      chnpy (3090) = 6
      chnte (3090) = 12
      chnhe (3090) = 0
      chperm (3090) = 330
      chbirf (3090) = 2179
      chetat (3090) = 548
      chtn2i (3090) = 210
      chbiet (548) = 3090
c
c Aretes coupees :   2  6  7  9
      chclas (354) = ' 4-15'
c Code des aretes coupees : 0, 1, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0
      charde (354)(1:12) = '  2  6  7  9'
      chnp1 (354) = 1
      chnar (354) = 14
      chnpy (354) = 6
      chnte (354) = 12
      chnhe (354) = 0
      chperm (354) = 230
      chbirf (354) = 2179
      chetat (354) = 549
      chtn2i (354) = 210
      chbiet (549) = 354
c
c Aretes coupees :   3  4  5  9
      chclas (284) = ' 4-15'
c Code des aretes coupees : 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0
      charde (284)(1:12) = '  3  4  5  9'
      chnp1 (284) = 1
      chnar (284) = 14
      chnpy (284) = 6
      chnte (284) = 12
      chnhe (284) = 0
      chperm (284) = 100
      chbirf (284) = 2179
      chetat (284) = 550
      chtn2i (284) = 210
      chbiet (550) = 284
c
c Aretes coupees :   3  6  7 12
      chclas (2148) = ' 4-15'
c Code des aretes coupees : 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 1
      charde (2148)(1:12) = '  3  6  7 12'
      chnp1 (2148) = 1
      chnar (2148) = 14
      chnpy (2148) = 6
      chnte (2148) = 12
      chnhe (2148) = 0
      chperm (2148) = 10
      chbirf (2148) = 2179
      chetat (2148) = 551
      chtn2i (2148) = 210
      chbiet (551) = 2148
c
c Aretes coupees :   3  8  9 10
      chclas (900) = ' 4-15'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0
      charde (900)(1:12) = '  3  8  9 10'
      chnp1 (900) = 1
      chnar (900) = 14
      chnpy (900) = 6
      chnte (900) = 12
      chnhe (900) = 0
      chperm (900) = 310
      chbirf (900) = 2179
      chetat (900) = 552
      chtn2i (900) = 210
      chbiet (552) = 900
c
c Aretes coupees :   4  5  8 10
      chclas (664) = ' 4-15'
c Code des aretes coupees : 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0
      charde (664)(1:12) = '  4  5  8 10'
      chnp1 (664) = 1
      chnar (664) = 14
      chnpy (664) = 6
      chnte (664) = 12
      chnhe (664) = 0
      chperm (664) = 30
      chbirf (664) = 2179
      chetat (664) = 553
      chtn2i (664) = 210
      chbiet (553) = 664
c
c Aretes coupees :   4  7  9 11
      chclas (1352) = ' 4-15'
c Code des aretes coupees : 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0
      charde (1352)(1:12) = '  4  7  9 11'
      chnp1 (1352) = 1
      chnar (1352) = 14
      chnpy (1352) = 6
      chnte (1352) = 12
      chnhe (1352) = 0
      chperm (1352) = 300
      chbirf (1352) = 2179
      chetat (1352) = 554
      chtn2i (1352) = 210
      chbiet (554) = 1352
c
c ===========================================
c Classe d'equivalence  4-16
c
c Aretes coupees :   1  2  5  8
      chclas (147) = ' 4-16'
c Code des aretes coupees : 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0
      charde (147)(1:12) = '  1  2  5  8'
      chnp1 (147) = 1
      chnar (147) = 15
      chnpy (147) = 10
      chnte (147) = 6
      chnhe (147) = 0
      chperm (147) = 0
      chbirf (147) = 147
      chetat (147) = 555
      chtn2i (147) = 210
      chbiet (555) = 147
c
c Aretes coupees :   1  2  5 11
      chclas (1043) = ' 4-16'
c Code des aretes coupees : 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0
      charde (1043)(1:12) = '  1  2  5 11'
      chnp1 (1043) = 1
      chnar (1043) = 15
      chnpy (1043) = 10
      chnte (1043) = 6
      chnhe (1043) = 0
      chperm (1043) = 101
      chbirf (1043) = 147
      chetat (1043) = 556
      chtn2i (1043) = 210
      chbiet (556) = 1043
c
c Aretes coupees :   1  2  5 12
      chclas (2067) = ' 4-16'
c Code des aretes coupees : 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1
      charde (2067)(1:12) = '  1  2  5 12'
      chnp1 (2067) = 1
      chnar (2067) = 15
      chnpy (2067) = 10
      chnte (2067) = 6
      chnhe (2067) = 0
      chperm (2067) = 330
      chbirf (2067) = 147
      chetat (2067) = 557
      chtn2i (2067) = 210
      chbiet (557) = 2067
c
c Aretes coupees :   1  3  6  7
      chclas (101) = ' 4-16'
c Code des aretes coupees : 1, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0
      charde (101)(1:12) = '  1  3  6  7'
      chnp1 (101) = 1
      chnar (101) = 15
      chnpy (101) = 10
      chnte (101) = 6
      chnhe (101) = 0
      chperm (101) = 221
      chbirf (101) = 147
      chetat (101) = 558
      chtn2i (101) = 210
      chbiet (558) = 101
c
c Aretes coupees :   1  3  6 10
      chclas (549) = ' 4-16'
c Code des aretes coupees : 1, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0
      charde (549)(1:12) = '  1  3  6 10'
      chnp1 (549) = 1
      chnar (549) = 15
      chnpy (549) = 10
      chnte (549) = 6
      chnhe (549) = 0
      chperm (549) = 320
      chbirf (549) = 147
      chetat (549) = 559
      chtn2i (549) = 210
      chbiet (559) = 549
c
c Aretes coupees :   1  3  6 12
      chclas (2085) = ' 4-16'
c Code des aretes coupees : 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1
      charde (2085)(1:12) = '  1  3  6 12'
      chnp1 (2085) = 1
      chnar (2085) = 15
      chnpy (2085) = 10
      chnte (2085) = 6
      chnhe (2085) = 0
      chperm (2085) = 10
      chbirf (2085) = 147
      chetat (2085) = 560
      chtn2i (2085) = 210
      chbiet (560) = 2085
c
c Aretes coupees :   1  7 10 12
      chclas (2625) = ' 4-16'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1
      charde (2625)(1:12) = '  1  7 10 12'
      chnp1 (2625) = 1
      chnar (2625) = 15
      chnpy (2625) = 10
      chnte (2625) = 6
      chnhe (2625) = 0
      chperm (2625) = 130
      chbirf (2625) = 147
      chetat (2625) = 561
      chtn2i (2625) = 210
      chbiet (561) = 2625
c
c Aretes coupees :   1  8 11 12
      chclas (3201) = ' 4-16'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1
      charde (3201)(1:12) = '  1  8 11 12'
      chnp1 (3201) = 1
      chnar (3201) = 15
      chnpy (3201) = 10
      chnte (3201) = 6
      chnhe (3201) = 0
      chperm (3201) = 210
      chbirf (3201) = 147
      chetat (3201) = 562
      chtn2i (3201) = 210
      chbiet (562) = 3201
c
c Aretes coupees :   2  4  6  7
      chclas (106) = ' 4-16'
c Code des aretes coupees : 0, 1, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0
      charde (106)(1:12) = '  2  4  6  7'
      chnp1 (106) = 1
      chnar (106) = 15
      chnpy (106) = 10
      chnte (106) = 6
      chnhe (106) = 0
      chperm (106) = 1
      chbirf (106) = 147
      chetat (106) = 563
      chtn2i (106) = 210
      chbiet (563) = 106
c
c Aretes coupees :   2  4  7  9
      chclas (330) = ' 4-16'
c Code des aretes coupees : 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0
      charde (330)(1:12) = '  2  4  7  9'
      chnp1 (330) = 1
      chnar (330) = 15
      chnpy (330) = 10
      chnte (330) = 6
      chnhe (330) = 0
      chperm (330) = 230
      chbirf (330) = 147
      chetat (330) = 564
      chtn2i (330) = 210
      chbiet (564) = 330
c
c Aretes coupees :   2  4  7 11
      chclas (1098) = ' 4-16'
c Code des aretes coupees : 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0
      charde (1098)(1:12) = '  2  4  7 11'
      chnp1 (1098) = 1
      chnar (1098) = 15
      chnpy (1098) = 10
      chnte (1098) = 6
      chnhe (1098) = 0
      chperm (1098) = 300
      chbirf (1098) = 147
      chetat (1098) = 565
      chtn2i (1098) = 210
      chbiet (565) = 1098
c
c Aretes coupees :   2  6  9 11
      chclas (1314) = ' 4-16'
c Code des aretes coupees : 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0
      charde (1314)(1:12) = '  2  6  9 11'
      chnp1 (1314) = 1
      chnar (1314) = 15
      chnpy (1314) = 10
      chnte (1314) = 6
      chnhe (1314) = 0
      chperm (1314) = 321
      chbirf (1314) = 147
      chetat (1314) = 566
      chtn2i (1314) = 210
      chbiet (566) = 1314
c
c Aretes coupees :   2  8 11 12
      chclas (3202) = ' 4-16'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1
      charde (3202)(1:12) = '  2  8 11 12'
      chnp1 (3202) = 1
      chnar (3202) = 15
      chnpy (3202) = 10
      chnte (3202) = 6
      chnhe (3202) = 0
      chperm (3202) = 120
      chbirf (3202) = 147
      chetat (3202) = 567
      chtn2i (3202) = 210
      chbiet (567) = 3202
c
c Aretes coupees :   3  4  5  8
      chclas (156) = ' 4-16'
c Code des aretes coupees : 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0
      charde (156)(1:12) = '  3  4  5  8'
      chnp1 (156) = 1
      chnar (156) = 15
      chnpy (156) = 10
      chnte (156) = 6
      chnhe (156) = 0
      chperm (156) = 220
      chbirf (156) = 147
      chetat (156) = 568
      chtn2i (156) = 210
      chbiet (568) = 156
c
c Aretes coupees :   3  4  8  9
      chclas (396) = ' 4-16'
c Code des aretes coupees : 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0
      charde (396)(1:12) = '  3  4  8  9'
      chnp1 (396) = 1
      chnar (396) = 15
      chnpy (396) = 10
      chnte (396) = 6
      chnhe (396) = 0
      chperm (396) = 310
      chbirf (396) = 147
      chetat (396) = 569
      chtn2i (396) = 210
      chbiet (569) = 396
c
c Aretes coupees :   3  4  8 10
      chclas (652) = ' 4-16'
c Code des aretes coupees : 0, 0, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0
      charde (652)(1:12) = '  3  4  8 10'
      chnp1 (652) = 1
      chnar (652) = 15
      chnpy (652) = 10
      chnte (652) = 6
      chnhe (652) = 0
      chperm (652) = 121
      chbirf (652) = 147
      chetat (652) = 570
      chtn2i (652) = 210
      chbiet (570) = 652
c
c Aretes coupees :   3  5  9 10
      chclas (788) = ' 4-16'
c Code des aretes coupees : 0, 0, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0
      charde (788)(1:12) = '  3  5  9 10'
      chnp1 (788) = 1
      chnar (788) = 15
      chnpy (788) = 10
      chnte (788) = 6
      chnhe (788) = 0
      chperm (788) = 100
      chbirf (788) = 147
      chetat (788) = 571
      chtn2i (788) = 210
      chbiet (571) = 788
c
c Aretes coupees :   3  7 10 12
      chclas (2628) = ' 4-16'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1
      charde (2628)(1:12) = '  3  7 10 12'
      chnp1 (2628) = 1
      chnar (2628) = 15
      chnpy (2628) = 10
      chnte (2628) = 6
      chnhe (2628) = 0
      chperm (2628) = 301
      chbirf (2628) = 147
      chetat (2628) = 572
      chtn2i (2628) = 210
      chbiet (572) = 2628
c
c Aretes coupees :   4  5  9 10
      chclas (792) = ' 4-16'
c Code des aretes coupees : 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0
      charde (792)(1:12) = '  4  5  9 10'
      chnp1 (792) = 1
      chnar (792) = 15
      chnpy (792) = 10
      chnte (792) = 6
      chnhe (792) = 0
      chperm (792) = 30
      chbirf (792) = 147
      chetat (792) = 573
      chtn2i (792) = 210
      chbiet (573) = 792
c
c Aretes coupees :   4  6  9 11
      chclas (1320) = ' 4-16'
c Code des aretes coupees : 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0
      charde (1320)(1:12) = '  4  6  9 11'
      chnp1 (1320) = 1
      chnar (1320) = 15
      chnpy (1320) = 10
      chnte (1320) = 6
      chnhe (1320) = 0
      chperm (1320) = 110
      chbirf (1320) = 147
      chetat (1320) = 574
      chtn2i (1320) = 210
      chbiet (574) = 1320
c
c Aretes coupees :   5  8  9 10
      chclas (912) = ' 4-16'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0
      charde (912)(1:12) = '  5  8  9 10'
      chnp1 (912) = 1
      chnar (912) = 15
      chnpy (912) = 10
      chnte (912) = 6
      chnhe (912) = 0
      chperm (912) = 201
      chbirf (912) = 147
      chetat (912) = 575
      chtn2i (912) = 210
      chbiet (575) = 912
c
c Aretes coupees :   5  8 11 12
      chclas (3216) = ' 4-16'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1
      charde (3216)(1:12) = '  5  8 11 12'
      chnp1 (3216) = 1
      chnar (3216) = 15
      chnpy (3216) = 10
      chnte (3216) = 6
      chnhe (3216) = 0
      chperm (3216) = 21
      chbirf (3216) = 147
      chetat (3216) = 576
      chtn2i (3216) = 210
      chbiet (576) = 3216
c
c Aretes coupees :   6  7  9 11
      chclas (1376) = ' 4-16'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0
      charde (1376)(1:12) = '  6  7  9 11'
      chnp1 (1376) = 1
      chnar (1376) = 15
      chnpy (1376) = 10
      chnte (1376) = 6
      chnhe (1376) = 0
      chperm (1376) = 20
      chbirf (1376) = 147
      chetat (1376) = 577
      chtn2i (1376) = 210
      chbiet (577) = 1376
c
c Aretes coupees :   6  7 10 12
      chclas (2656) = ' 4-16'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1
      charde (2656)(1:12) = '  6  7 10 12'
      chnp1 (2656) = 1
      chnar (2656) = 15
      chnpy (2656) = 10
      chnte (2656) = 6
      chnhe (2656) = 0
      chperm (2656) = 200
      chbirf (2656) = 147
      chetat (2656) = 578
      chtn2i (2656) = 210
      chbiet (578) = 2656
c
c ===========================================
c Classe d'equivalence  4-17
c
c Aretes coupees :   1  4 10 11
      chclas (1545) = ' 4-17'
c Code des aretes coupees : 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0
      charde (1545)(1:12) = '  1  4 10 11'
      chnp1 (1545) = 1
      chnar (1545) = 12
      chnpy (1545) = 4
      chnte (1545) = 12
      chnhe (1545) = 0
      chperm (1545) = 0
      chbirf (1545) = 1545
      chetat (1545) = 579
      chtn2i (1545) = 70
      chbiet (579) = 1545
c
c Aretes coupees :   1  7  8  9
      chclas (449) = ' 4-17'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0
      charde (449)(1:12) = '  1  7  8  9'
      chnp1 (449) = 1
      chnar (449) = 12
      chnpy (449) = 4
      chnte (449) = 12
      chnhe (449) = 0
      chperm (449) = 100
      chbirf (449) = 1545
      chetat (449) = 580
      chtn2i (449) = 70
      chbiet (580) = 449
c
c Aretes coupees :   2  3  9 12
      chclas (2310) = ' 4-17'
c Code des aretes coupees : 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1
      charde (2310)(1:12) = '  2  3  9 12'
      chnp1 (2310) = 1
      chnar (2310) = 12
      chnpy (2310) = 4
      chnte (2310) = 12
      chnhe (2310) = 0
      chperm (2310) = 200
      chbirf (2310) = 1545
      chetat (2310) = 581
      chtn2i (2310) = 70
      chbiet (581) = 2310
c
c Aretes coupees :   2  6  8 10
      chclas (674) = ' 4-17'
c Code des aretes coupees : 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0
      charde (674)(1:12) = '  2  6  8 10'
      chnp1 (674) = 1
      chnar (674) = 12
      chnpy (674) = 4
      chnte (674) = 12
      chnhe (674) = 0
      chperm (674) = 10
      chbirf (674) = 1545
      chetat (674) = 582
      chtn2i (674) = 70
      chbiet (582) = 674
c
c Aretes coupees :   3  5  7 11
      chclas (1108) = ' 4-17'
c Code des aretes coupees : 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0
      charde (1108)(1:12) = '  3  5  7 11'
      chnp1 (1108) = 1
      chnar (1108) = 12
      chnpy (1108) = 4
      chnte (1108) = 12
      chnhe (1108) = 0
      chperm (1108) = 110
      chbirf (1108) = 1545
      chetat (1108) = 583
      chtn2i (1108) = 70
      chbiet (583) = 1108
c
c Aretes coupees :   4  5  6 12
      chclas (2104) = ' 4-17'
c Code des aretes coupees : 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 1
      charde (2104)(1:12) = '  4  5  6 12'
      chnp1 (2104) = 1
      chnar (2104) = 12
      chnpy (2104) = 4
      chnte (2104) = 12
      chnhe (2104) = 0
      chperm (2104) = 300
      chbirf (2104) = 1545
      chetat (2104) = 584
      chtn2i (2104) = 70
      chbiet (584) = 2104
c
c ===========================================
c Classe d'equivalence  4-18
c
c Aretes coupees :   1  4  9 12
      chclas (2313) = ' 4-18'
c Code des aretes coupees : 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1
      charde (2313)(1:12) = '  1  4  9 12'
      chnp1 (2313) = 0
      chnar (2313) = 0
      chnpy (2313) = 0
      chnte (2313) = 0
      chnhe (2313) = 2
      chperm (2313) = 0
      chbirf (2313) = 2313
      chetat (2313) = 585
      chtn2i (2313) = 1
      chbiet (585) = 2313
c
c Aretes coupees :   2  3 10 11
      chclas (1542) = ' 4-18'
c Code des aretes coupees : 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0
      charde (1542)(1:12) = '  2  3 10 11'
      chnp1 (1542) = 0
      chnar (1542) = 0
      chnpy (1542) = 0
      chnte (1542) = 0
      chnhe (1542) = 2
      chperm (1542) = 110
      chbirf (1542) = 2313
      chetat (1542) = 586
      chtn2i (1542) = 1
      chbiet (586) = 1542
c
c Aretes coupees :   5  6  7  8
      chclas (240) = ' 4-18'
c Code des aretes coupees : 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0
      charde (240)(1:12) = '  5  6  7  8'
      chnp1 (240) = 0
      chnar (240) = 0
      chnpy (240) = 0
      chnte (240) = 0
      chnhe (240) = 2
      chperm (240) = 10
      chbirf (240) = 2313
      chetat (240) = 587
      chtn2i (240) = 1
      chbiet (587) = 240
c
c ===========================================
c Classe d'equivalence  5-00
c
c Aretes coupees :   1  2  6  8 12
      chclas (2211) = ' 5-00'
c Code des aretes coupees : 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1
      charde (2211)(1:15) = '  1  2  6  8 12'
      chnp1 (2211) = 1
      chnar (2211) = 16
      chnpy (2211) = 11
      chnte (2211) = 6
      chnhe (2211) = 0
      chperm (2211) = 0
      chbirf (2211) = 2211
      chetat (2211) = 588
      chtn2i (2211) = 210
      chbiet (588) = 2211
c
c Aretes coupees :   1  2  6 10 12
      chclas (2595) = ' 5-00'
c Code des aretes coupees : 1, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1
      charde (2595)(1:15) = '  1  2  6 10 12'
      chnp1 (2595) = 1
      chnar (2595) = 16
      chnpy (2595) = 11
      chnte (2595) = 6
      chnhe (2595) = 0
      chperm (2595) = 320
      chbirf (2595) = 2211
      chetat (2595) = 589
      chtn2i (2595) = 210
      chbiet (589) = 2595
c
c Aretes coupees :   1  2  8 10 12
      chclas (2691) = ' 5-00'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1
      charde (2691)(1:15) = '  1  2  8 10 12'
      chnp1 (2691) = 1
      chnar (2691) = 16
      chnpy (2691) = 11
      chnte (2691) = 6
      chnhe (2691) = 0
      chperm (2691) = 120
      chbirf (2691) = 2211
      chetat (2691) = 590
      chtn2i (2691) = 210
      chbiet (590) = 2691
c
c Aretes coupees :   1  3  7  8 10
      chclas (709) = ' 5-00'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 1, 1, 0, 1, 0, 0
      charde (709)(1:15) = '  1  3  7  8 10'
      chnp1 (709) = 1
      chnar (709) = 16
      chnpy (709) = 11
      chnte (709) = 6
      chnhe (709) = 0
      chperm (709) = 221
      chbirf (709) = 2211
      chetat (709) = 591
      chtn2i (709) = 210
      chbiet (591) = 709
c
c Aretes coupees :   1  3  7  9 10
      chclas (837) = ' 5-00'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 1, 0, 1, 1, 0, 0
      charde (837)(1:15) = '  1  3  7  9 10'
      chnp1 (837) = 1
      chnar (837) = 16
      chnpy (837) = 11
      chnte (837) = 6
      chnhe (837) = 0
      chperm (837) = 130
      chbirf (837) = 2211
      chetat (837) = 592
      chtn2i (837) = 210
      chbiet (592) = 837
c
c Aretes coupees :   1  3  8  9 10
      chclas (901) = ' 5-00'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0
      charde (901)(1:15) = '  1  3  8  9 10'
      chnp1 (901) = 1
      chnar (901) = 16
      chnpy (901) = 11
      chnte (901) = 6
      chnhe (901) = 0
      chperm (901) = 310
      chbirf (901) = 2211
      chetat (901) = 593
      chtn2i (901) = 210
      chbiet (593) = 901
c
c Aretes coupees :   1  4  5  8 10
      chclas (665) = ' 5-00'
c Code des aretes coupees : 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0
      charde (665)(1:15) = '  1  4  5  8 10'
      chnp1 (665) = 1
      chnar (665) = 16
      chnpy (665) = 11
      chnte (665) = 6
      chnhe (665) = 0
      chperm (665) = 30
      chbirf (665) = 2211
      chetat (665) = 594
      chtn2i (665) = 210
      chbiet (594) = 665
c
c Aretes coupees :   1  4  5  8 11
      chclas (1177) = ' 5-00'
c Code des aretes coupees : 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0
      charde (1177)(1:15) = '  1  4  5  8 11'
      chnp1 (1177) = 1
      chnar (1177) = 16
      chnpy (1177) = 11
      chnte (1177) = 6
      chnhe (1177) = 0
      chperm (1177) = 210
      chbirf (1177) = 2211
      chetat (1177) = 595
      chtn2i (1177) = 210
      chbiet (595) = 1177
c
c Aretes coupees :   1  5  8 10 11
      chclas (1681) = ' 5-00'
c Code des aretes coupees : 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0
      charde (1681)(1:15) = '  1  5  8 10 11'
      chnp1 (1681) = 1
      chnar (1681) = 16
      chnpy (1681) = 11
      chnte (1681) = 6
      chnhe (1681) = 0
      chperm (1681) = 101
      chbirf (1681) = 2211
      chetat (1681) = 596
      chtn2i (1681) = 210
      chbiet (596) = 1681
c
c Aretes coupees :   1  6  8 10 12
      chclas (2721) = ' 5-00'
c Code des aretes coupees : 1, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1
      charde (2721)(1:15) = '  1  6  8 10 12'
      chnp1 (2721) = 1
      chnar (2721) = 16
      chnpy (2721) = 11
      chnte (2721) = 6
      chnhe (2721) = 0
      chperm (2721) = 200
      chbirf (2721) = 2211
      chetat (2721) = 597
      chtn2i (2721) = 210
      chbiet (597) = 2721
c
c Aretes coupees :   2  3  6  7  9
      chclas (358) = ' 5-00'
c Code des aretes coupees : 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 0
      charde (358)(1:15) = '  2  3  6  7  9'
      chnp1 (358) = 1
      chnar (358) = 16
      chnpy (358) = 11
      chnte (358) = 6
      chnhe (358) = 0
      chperm (358) = 321
      chbirf (358) = 2211
      chetat (358) = 598
      chtn2i (358) = 210
      chbiet (598) = 358
c
c Aretes coupees :   2  3  6  7 12
      chclas (2150) = ' 5-00'
c Code des aretes coupees : 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 1
      charde (2150)(1:15) = '  2  3  6  7 12'
      chnp1 (2150) = 1
      chnar (2150) = 16
      chnpy (2150) = 11
      chnte (2150) = 6
      chnhe (2150) = 0
      chperm (2150) = 301
      chbirf (2150) = 2211
      chetat (2150) = 599
      chtn2i (2150) = 210
      chbiet (599) = 2150
c
c Aretes coupees :   2  4  5  6 11
      chclas (1082) = ' 5-00'
c Code des aretes coupees : 0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 1, 0
      charde (1082)(1:15) = '  2  4  5  6 11'
      chnp1 (1082) = 1
      chnar (1082) = 16
      chnpy (1082) = 11
      chnte (1082) = 6
      chnhe (1082) = 0
      chperm (1082) = 1
      chbirf (1082) = 2211
      chetat (1082) = 600
      chtn2i (1082) = 210
      chbiet (600) = 1082
c
c Aretes coupees :   2  4  5 11 12
      chclas (3098) = ' 5-00'
c Code des aretes coupees : 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1
      charde (3098)(1:15) = '  2  4  5 11 12'
      chnp1 (3098) = 1
      chnar (3098) = 16
      chnpy (3098) = 11
      chnte (3098) = 6
      chnhe (3098) = 0
      chperm (3098) = 330
      chbirf (3098) = 2211
      chetat (3098) = 601
      chtn2i (3098) = 210
      chbiet (601) = 3098
c
c Aretes coupees :   2  4  6 11 12
      chclas (3114) = ' 5-00'
c Code des aretes coupees : 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 1
      charde (3114)(1:15) = '  2  4  6 11 12'
      chnp1 (3114) = 1
      chnar (3114) = 16
      chnpy (3114) = 11
      chnte (3114) = 6
      chnhe (3114) = 0
      chperm (3114) = 110
      chbirf (3114) = 2211
      chetat (3114) = 602
      chtn2i (3114) = 210
      chbiet (602) = 3114
c
c Aretes coupees :   2  5  6 11 12
      chclas (3122) = ' 5-00'
c Code des aretes coupees : 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1
      charde (3122)(1:15) = '  2  5  6 11 12'
      chnp1 (3122) = 1
      chnar (3122) = 16
      chnpy (3122) = 11
      chnte (3122) = 6
      chnhe (3122) = 0
      chperm (3122) = 21
      chbirf (3122) = 2211
      chetat (3122) = 603
      chtn2i (3122) = 210
      chbiet (603) = 3122
c
c Aretes coupees :   2  6  7  9 12
      chclas (2402) = ' 5-00'
c Code des aretes coupees : 0, 1, 0, 0, 0, 1, 1, 0, 1, 0, 0, 1
      charde (2402)(1:15) = '  2  6  7  9 12'
      chnp1 (2402) = 1
      chnar (2402) = 16
      chnpy (2402) = 11
      chnte (2402) = 6
      chnhe (2402) = 0
      chperm (2402) = 230
      chbirf (2402) = 2211
      chetat (2402) = 604
      chtn2i (2402) = 210
      chbiet (604) = 2402
c
c Aretes coupees :   3  4  5  7  9
      chclas (348) = ' 5-00'
c Code des aretes coupees : 0, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 0
      charde (348)(1:15) = '  3  4  5  7  9'
      chnp1 (348) = 1
      chnar (348) = 16
      chnpy (348) = 11
      chnte (348) = 6
      chnhe (348) = 0
      chperm (348) = 220
      chbirf (348) = 2211
      chetat (348) = 605
      chtn2i (348) = 210
      chbiet (605) = 348
c
c Aretes coupees :   3  4  5  9 11
      chclas (1308) = ' 5-00'
c Code des aretes coupees : 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0
      charde (1308)(1:15) = '  3  4  5  9 11'
      chnp1 (1308) = 1
      chnar (1308) = 16
      chnpy (1308) = 11
      chnte (1308) = 6
      chnhe (1308) = 0
      chperm (1308) = 100
      chbirf (1308) = 2211
      chetat (1308) = 606
      chtn2i (1308) = 210
      chbiet (606) = 1308
c
c Aretes coupees :   3  4  7  9 11
      chclas (1356) = ' 5-00'
c Code des aretes coupees : 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0
      charde (1356)(1:15) = '  3  4  7  9 11'
      chnp1 (1356) = 1
      chnar (1356) = 16
      chnpy (1356) = 11
      chnte (1356) = 6
      chnhe (1356) = 0
      chperm (1356) = 300
      chbirf (1356) = 2211
      chetat (1356) = 607
      chtn2i (1356) = 210
      chbiet (607) = 1356
c
c Aretes coupees :   3  6  7  9 12
      chclas (2404) = ' 5-00'
c Code des aretes coupees : 0, 0, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1
      charde (2404)(1:15) = '  3  6  7  9 12'
      chnp1 (2404) = 1
      chnar (2404) = 16
      chnpy (2404) = 11
      chnte (2404) = 6
      chnhe (2404) = 0
      chperm (2404) = 10
      chbirf (2404) = 2211
      chetat (2404) = 608
      chtn2i (2404) = 210
      chbiet (608) = 2404
c
c Aretes coupees :   3  7  8  9 10
      chclas (964) = ' 5-00'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0
      charde (964)(1:15) = '  3  7  8  9 10'
      chnp1 (964) = 1
      chnar (964) = 16
      chnpy (964) = 11
      chnte (964) = 6
      chnhe (964) = 0
      chperm (964) = 201
      chbirf (964) = 2211
      chetat (964) = 609
      chtn2i (964) = 210
      chbiet (609) = 964
c
c Aretes coupees :   4  5  7  9 11
      chclas (1368) = ' 5-00'
c Code des aretes coupees : 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0
      charde (1368)(1:15) = '  4  5  7  9 11'
      chnp1 (1368) = 1
      chnar (1368) = 16
      chnpy (1368) = 11
      chnte (1368) = 6
      chnhe (1368) = 0
      chperm (1368) = 20
      chbirf (1368) = 2211
      chetat (1368) = 610
      chtn2i (1368) = 210
      chbiet (610) = 1368
c
c Aretes coupees :   4  5  8 10 11
      chclas (1688) = ' 5-00'
c Code des aretes coupees : 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0
      charde (1688)(1:15) = '  4  5  8 10 11'
      chnp1 (1688) = 1
      chnar (1688) = 16
      chnpy (1688) = 11
      chnte (1688) = 6
      chnhe (1688) = 0
      chperm (1688) = 121
      chbirf (1688) = 2211
      chetat (1688) = 611
      chtn2i (1688) = 210
      chbiet (611) = 1688
c
c ===========================================
c Classe d'equivalence  5-01
c
c Aretes coupees :   1  2  7  8 11
      chclas (1219) = ' 5-01'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0
      charde (1219)(1:15) = '  1  2  7  8 11'
      chnp1 (1219) = 1
      chnar (1219) = 16
      chnpy (1219) = 11
      chnte (1219) = 6
      chnhe (1219) = 0
      chperm (1219) = 0
      chbirf (1219) = 1219
      chetat (1219) = 612
      chtn2i (1219) = 210
      chbiet (612) = 1219
c
c Aretes coupees :   1  2  7  9 11
      chclas (1347) = ' 5-01'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0
      charde (1347)(1:15) = '  1  2  7  9 11'
      chnp1 (1347) = 1
      chnar (1347) = 16
      chnpy (1347) = 11
      chnte (1347) = 6
      chnhe (1347) = 0
      chperm (1347) = 230
      chbirf (1347) = 1219
      chetat (1347) = 613
      chtn2i (1347) = 210
      chbiet (613) = 1347
c
c Aretes coupees :   1  2  8  9 11
      chclas (1411) = ' 5-01'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0
      charde (1411)(1:15) = '  1  2  8  9 11'
      chnp1 (1411) = 1
      chnar (1411) = 16
      chnpy (1411) = 11
      chnte (1411) = 6
      chnhe (1411) = 0
      chperm (1411) = 210
      chbirf (1411) = 1219
      chetat (1411) = 614
      chtn2i (1411) = 210
      chbiet (614) = 1411
c
c Aretes coupees :   1  3  5  7 12
      chclas (2133) = ' 5-01'
c Code des aretes coupees : 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1
      charde (2133)(1:15) = '  1  3  5  7 12'
      chnp1 (2133) = 1
      chnar (2133) = 16
      chnpy (2133) = 11
      chnte (2133) = 6
      chnhe (2133) = 0
      chperm (2133) = 221
      chbirf (2133) = 1219
      chetat (2133) = 615
      chtn2i (2133) = 210
      chbiet (615) = 2133
c
c Aretes coupees :   1  3  5 11 12
      chclas (3093) = ' 5-01'
c Code des aretes coupees : 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 1
      charde (3093)(1:15) = '  1  3  5 11 12'
      chnp1 (3093) = 1
      chnar (3093) = 16
      chnpy (3093) = 11
      chnte (3093) = 6
      chnhe (3093) = 0
      chperm (3093) = 101
      chbirf (3093) = 1219
      chetat (3093) = 616
      chtn2i (3093) = 210
      chbiet (616) = 3093
c
c Aretes coupees :   1  3  7 11 12
      chclas (3141) = ' 5-01'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1
      charde (3141)(1:15) = '  1  3  7 11 12'
      chnp1 (3141) = 1
      chnar (3141) = 16
      chnpy (3141) = 11
      chnte (3141) = 6
      chnhe (3141) = 0
      chperm (3141) = 301
      chbirf (3141) = 1219
      chetat (3141) = 617
      chtn2i (3141) = 210
      chbiet (617) = 3141
c
c Aretes coupees :   1  4  6  7 10
      chclas (617) = ' 5-01'
c Code des aretes coupees : 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 0, 0
      charde (617)(1:15) = '  1  4  6  7 10'
      chnp1 (617) = 1
      chnar (617) = 16
      chnpy (617) = 11
      chnte (617) = 6
      chnhe (617) = 0
      chperm (617) = 130
      chbirf (617) = 1219
      chetat (617) = 618
      chtn2i (617) = 210
      chbiet (618) = 617
c
c Aretes coupees :   1  4  6  7 11
      chclas (1129) = ' 5-01'
c Code des aretes coupees : 1, 0, 0, 1, 0, 1, 1, 0, 0, 0, 1, 0
      charde (1129)(1:15) = '  1  4  6  7 11'
      chnp1 (1129) = 1
      chnar (1129) = 16
      chnpy (1129) = 11
      chnte (1129) = 6
      chnhe (1129) = 0
      chperm (1129) = 110
      chbirf (1129) = 1219
      chetat (1129) = 619
      chtn2i (1129) = 210
      chbiet (619) = 1129
c
c Aretes coupees :   1  5  7 11 12
      chclas (3153) = ' 5-01'
c Code des aretes coupees : 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1
      charde (3153)(1:15) = '  1  5  7 11 12'
      chnp1 (3153) = 1
      chnar (3153) = 16
      chnpy (3153) = 11
      chnte (3153) = 6
      chnhe (3153) = 0
      chperm (3153) = 21
      chbirf (3153) = 1219
      chetat (3153) = 620
      chtn2i (3153) = 210
      chbiet (620) = 3153
c
c Aretes coupees :   1  6  7 10 11
      chclas (1633) = ' 5-01'
c Code des aretes coupees : 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0
      charde (1633)(1:15) = '  1  6  7 10 11'
      chnp1 (1633) = 1
      chnar (1633) = 16
      chnpy (1633) = 11
      chnte (1633) = 6
      chnhe (1633) = 0
      chperm (1633) = 320
      chbirf (1633) = 1219
      chetat (1633) = 621
      chtn2i (1633) = 210
      chbiet (621) = 1633
c
c Aretes coupees :   2  3  5  8  9
      chclas (406) = ' 5-01'
c Code des aretes coupees : 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 0
      charde (406)(1:15) = '  2  3  5  8  9'
      chnp1 (406) = 1
      chnar (406) = 16
      chnpy (406) = 11
      chnte (406) = 6
      chnhe (406) = 0
      chperm (406) = 100
      chbirf (406) = 1219
      chetat (406) = 622
      chtn2i (406) = 210
      chbiet (622) = 406
c
c Aretes coupees :   2  3  5  8 12
      chclas (2198) = ' 5-01'
c Code des aretes coupees : 0, 1, 1, 0, 1, 0, 0, 1, 0, 0, 0, 1
      charde (2198)(1:15) = '  2  3  5  8 12'
      chnp1 (2198) = 1
      chnar (2198) = 16
      chnpy (2198) = 11
      chnte (2198) = 6
      chnhe (2198) = 0
      chperm (2198) = 120
      chbirf (2198) = 1219
      chetat (2198) = 623
      chtn2i (2198) = 210
      chbiet (623) = 2198
c
c Aretes coupees :   2  4  6  8  9
      chclas (426) = ' 5-01'
c Code des aretes coupees : 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 0, 0
      charde (426)(1:15) = '  2  4  6  8  9'
      chnp1 (426) = 1
      chnar (426) = 16
      chnpy (426) = 11
      chnte (426) = 6
      chnhe (426) = 0
      chperm (426) = 1
      chbirf (426) = 1219
      chetat (426) = 624
      chtn2i (426) = 210
      chbiet (624) = 426
c
c Aretes coupees :   2  4  6  9 10
      chclas (810) = ' 5-01'
c Code des aretes coupees : 0, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 0
      charde (810)(1:15) = '  2  4  6  9 10'
      chnp1 (810) = 1
      chnar (810) = 16
      chnpy (810) = 11
      chnte (810) = 6
      chnhe (810) = 0
      chperm (810) = 321
      chbirf (810) = 1219
      chetat (810) = 625
      chtn2i (810) = 210
      chbiet (625) = 810
c
c Aretes coupees :   2  4  8  9 10
      chclas (906) = ' 5-01'
c Code des aretes coupees : 0, 1, 0, 1, 0, 0, 0, 1, 1, 1, 0, 0
      charde (906)(1:15) = '  2  4  8  9 10'
      chnp1 (906) = 1
      chnar (906) = 16
      chnpy (906) = 11
      chnte (906) = 6
      chnhe (906) = 0
      chperm (906) = 121
      chbirf (906) = 1219
      chetat (906) = 626
      chtn2i (906) = 210
      chbiet (626) = 906
c
c Aretes coupees :   2  5  8  9 12
      chclas (2450) = ' 5-01'
c Code des aretes coupees : 0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1
      charde (2450)(1:15) = '  2  5  8  9 12'
      chnp1 (2450) = 1
      chnar (2450) = 16
      chnpy (2450) = 11
      chnte (2450) = 6
      chnhe (2450) = 0
      chperm (2450) = 330
      chbirf (2450) = 1219
      chetat (2450) = 627
      chtn2i (2450) = 210
      chbiet (627) = 2450
c
c Aretes coupees :   2  7  8  9 11
      chclas (1474) = ' 5-01'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0
      charde (1474)(1:15) = '  2  7  8  9 11'
      chnp1 (1474) = 1
      chnar (1474) = 16
      chnpy (1474) = 11
      chnte (1474) = 6
      chnhe (1474) = 0
      chperm (1474) = 20
      chbirf (1474) = 1219
      chetat (1474) = 628
      chtn2i (1474) = 210
      chbiet (628) = 1474
c
c Aretes coupees :   3  4  5  6 10
      chclas (572) = ' 5-01'
c Code des aretes coupees : 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0
      charde (572)(1:15) = '  3  4  5  6 10'
      chnp1 (572) = 1
      chnar (572) = 16
      chnpy (572) = 11
      chnte (572) = 6
      chnhe (572) = 0
      chperm (572) = 220
      chbirf (572) = 1219
      chetat (572) = 629
      chtn2i (572) = 210
      chbiet (629) = 572
c
c Aretes coupees :   3  4  5 10 12
      chclas (2588) = ' 5-01'
c Code des aretes coupees : 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 0, 1
      charde (2588)(1:15) = '  3  4  5 10 12'
      chnp1 (2588) = 1
      chnar (2588) = 16
      chnpy (2588) = 11
      chnte (2588) = 6
      chnhe (2588) = 0
      chperm (2588) = 30
      chbirf (2588) = 1219
      chetat (2588) = 630
      chtn2i (2588) = 210
      chbiet (630) = 2588
c
c Aretes coupees :   3  4  6 10 12
      chclas (2604) = ' 5-01'
c Code des aretes coupees : 0, 0, 1, 1, 0, 1, 0, 0, 0, 1, 0, 1
      charde (2604)(1:15) = '  3  4  6 10 12'
      chnp1 (2604) = 1
      chnar (2604) = 16
      chnpy (2604) = 11
      chnte (2604) = 6
      chnhe (2604) = 0
      chperm (2604) = 10
      chbirf (2604) = 1219
      chetat (2604) = 631
      chtn2i (2604) = 210
      chbiet (631) = 2604
c
c Aretes coupees :   3  5  6 10 12
      chclas (2612) = ' 5-01'
c Code des aretes coupees : 0, 0, 1, 0, 1, 1, 0, 0, 0, 1, 0, 1
      charde (2612)(1:15) = '  3  5  6 10 12'
      chnp1 (2612) = 1
      chnar (2612) = 16
      chnpy (2612) = 11
      chnte (2612) = 6
      chnhe (2612) = 0
      chperm (2612) = 200
      chbirf (2612) = 1219
      chetat (2612) = 632
      chtn2i (2612) = 210
      chbiet (632) = 2612
c
c Aretes coupees :   3  5  8  9 12
      chclas (2452) = ' 5-01'
c Code des aretes coupees : 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1
      charde (2452)(1:15) = '  3  5  8  9 12'
      chnp1 (2452) = 1
      chnar (2452) = 16
      chnpy (2452) = 11
      chnte (2452) = 6
      chnhe (2452) = 0
      chperm (2452) = 310
      chbirf (2452) = 1219
      chetat (2452) = 633
      chtn2i (2452) = 210
      chbiet (633) = 2452
c
c Aretes coupees :   4  6  7 10 11
      chclas (1640) = ' 5-01'
c Code des aretes coupees : 0, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0
      charde (1640)(1:15) = '  4  6  7 10 11'
      chnp1 (1640) = 1
      chnar (1640) = 16
      chnpy (1640) = 11
      chnte (1640) = 6
      chnhe (1640) = 0
      chperm (1640) = 300
      chbirf (1640) = 1219
      chetat (1640) = 634
      chtn2i (1640) = 210
      chbiet (634) = 1640
c
c Aretes coupees :   4  6  8  9 10
      chclas (936) = ' 5-01'
c Code des aretes coupees : 0, 0, 0, 1, 0, 1, 0, 1, 1, 1, 0, 0
      charde (936)(1:15) = '  4  6  8  9 10'
      chnp1 (936) = 1
      chnar (936) = 16
      chnpy (936) = 11
      chnte (936) = 6
      chnhe (936) = 0
      chperm (936) = 201
      chbirf (936) = 1219
      chetat (936) = 635
      chtn2i (936) = 210
      chbiet (635) = 936
c
c ===========================================
c Classe d'equivalence  5-02
c
c Aretes coupees :   1  2  8  9 12
      chclas (2435) = ' 5-02'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1
      charde (2435)(1:15) = '  1  2  8  9 12'
      chnp1 (2435) = 1
      chnar (2435) = 15
      chnpy (2435) = 10
      chnte (2435) = 6
      chnhe (2435) = 0
      chperm (2435) = 0
      chbirf (2435) = 2435
      chetat (2435) = 636
      chtn2i (2435) = 210
      chbiet (636) = 2435
c
c Aretes coupees :   1  3  7 10 11
      chclas (1605) = ' 5-02'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 0
      charde (1605)(1:15) = '  1  3  7 10 11'
      chnp1 (1605) = 1
      chnar (1605) = 15
      chnpy (1605) = 10
      chnte (1605) = 6
      chnhe (1605) = 0
      chperm (1605) = 130
      chbirf (1605) = 2435
      chetat (1605) = 637
      chtn2i (1605) = 210
      chbiet (637) = 1605
c
c Aretes coupees :   1  4  6 10 12
      chclas (2601) = ' 5-02'
c Code des aretes coupees : 1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1
      charde (2601)(1:15) = '  1  4  6 10 12'
      chnp1 (2601) = 1
      chnar (2601) = 15
      chnpy (2601) = 10
      chnte (2601) = 6
      chnhe (2601) = 0
      chperm (2601) = 200
      chbirf (2601) = 2435
      chetat (2601) = 638
      chtn2i (2601) = 210
      chbiet (638) = 2601
c
c Aretes coupees :   1  4  7  9 11
      chclas (1353) = ' 5-02'
c Code des aretes coupees : 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0
      charde (1353)(1:15) = '  1  4  7  9 11'
      chnp1 (1353) = 1
      chnar (1353) = 15
      chnpy (1353) = 10
      chnte (1353) = 6
      chnhe (1353) = 0
      chperm (1353) = 300
      chbirf (1353) = 2435
      chetat (1353) = 639
      chtn2i (1353) = 210
      chbiet (639) = 1353
c
c Aretes coupees :   1  5  7  8 11
      chclas (1233) = ' 5-02'
c Code des aretes coupees : 1, 0, 0, 0, 1, 0, 1, 1, 0, 0, 1, 0
      charde (1233)(1:15) = '  1  5  7  8 11'
      chnp1 (1233) = 1
      chnar (1233) = 15
      chnpy (1233) = 10
      chnte (1233) = 6
      chnhe (1233) = 0
      chperm (1233) = 210
      chbirf (1233) = 2435
      chetat (1233) = 640
      chtn2i (1233) = 210
      chbiet (640) = 1233
c
c Aretes coupees :   2  3  5 11 12
      chclas (3094) = ' 5-02'
c Code des aretes coupees : 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 1, 1
      charde (3094)(1:15) = '  2  3  5 11 12'
      chnp1 (3094) = 1
      chnar (3094) = 15
      chnpy (3094) = 10
      chnte (3094) = 6
      chnhe (3094) = 0
      chperm (3094) = 330
      chbirf (3094) = 2435
      chetat (3094) = 641
      chtn2i (3094) = 210
      chbiet (641) = 3094
c
c Aretes coupees :   2  3  8  9 10
      chclas (902) = ' 5-02'
c Code des aretes coupees : 0, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0
      charde (902)(1:15) = '  2  3  8  9 10'
      chnp1 (902) = 1
      chnar (902) = 15
      chnpy (902) = 10
      chnte (902) = 6
      chnhe (902) = 0
      chperm (902) = 310
      chbirf (902) = 2435
      chetat (902) = 642
      chtn2i (902) = 210
      chbiet (642) = 902
c
c Aretes coupees :   2  4  6 10 11
      chclas (1578) = ' 5-02'
c Code des aretes coupees : 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 1, 0
      charde (1578)(1:15) = '  2  4  6 10 11'
      chnp1 (1578) = 1
      chnar (1578) = 15
      chnpy (1578) = 10
      chnte (1578) = 6
      chnhe (1578) = 0
      chperm (1578) = 110
      chbirf (1578) = 2435
      chetat (1578) = 643
      chtn2i (1578) = 210
      chbiet (643) = 1578
c
c Aretes coupees :   2  6  7  8  9
      chclas (482) = ' 5-02'
c Code des aretes coupees : 0, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0
      charde (482)(1:15) = '  2  6  7  8  9'
      chnp1 (482) = 1
      chnar (482) = 15
      chnpy (482) = 10
      chnte (482) = 6
      chnhe (482) = 0
      chperm (482) = 230
      chbirf (482) = 2435
      chetat (482) = 644
      chtn2i (482) = 210
      chbiet (644) = 482
c
c Aretes coupees :   3  4  5  9 12
      chclas (2332) = ' 5-02'
c Code des aretes coupees : 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 1
      charde (2332)(1:15) = '  3  4  5  9 12'
      chnp1 (2332) = 1
      chnar (2332) = 15
      chnpy (2332) = 10
      chnte (2332) = 6
      chnhe (2332) = 0
      chperm (2332) = 100
      chbirf (2332) = 2435
      chetat (2332) = 645
      chtn2i (2332) = 210
      chbiet (645) = 2332
c
c Aretes coupees :   3  5  6  7 12
      chclas (2164) = ' 5-02'
c Code des aretes coupees : 0, 0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 1
      charde (2164)(1:15) = '  3  5  6  7 12'
      chnp1 (2164) = 1
      chnar (2164) = 15
      chnpy (2164) = 10
      chnte (2164) = 6
      chnhe (2164) = 0
      chperm (2164) = 10
      chbirf (2164) = 2435
      chetat (2164) = 646
      chtn2i (2164) = 210
      chbiet (646) = 2164
c
c Aretes coupees :   4  5  6  8 10
      chclas (696) = ' 5-02'
c Code des aretes coupees : 0, 0, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0
      charde (696)(1:15) = '  4  5  6  8 10'
      chnp1 (696) = 1
      chnar (696) = 15
      chnpy (696) = 10
      chnte (696) = 6
      chnhe (696) = 0
      chperm (696) = 30
      chbirf (696) = 2435
      chetat (696) = 647
      chtn2i (696) = 210
      chbiet (647) = 696
c
c ===========================================
c Classe d'equivalence  5-03
c
c Aretes coupees :   1  2  8 10 11
      chclas (1667) = ' 5-03'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0
      charde (1667)(1:15) = '  1  2  8 10 11'
      chnp1 (1667) = 1
      chnar (1667) = 15
      chnpy (1667) = 10
      chnte (1667) = 6
      chnhe (1667) = 0
      chperm (1667) = 0
      chbirf (1667) = 1667
      chetat (1667) = 648
      chtn2i (1667) = 210
      chbiet (648) = 1667
c
c Aretes coupees :   1  3  7  9 12
      chclas (2373) = ' 5-03'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1
      charde (2373)(1:15) = '  1  3  7  9 12'
      chnp1 (2373) = 1
      chnar (2373) = 15
      chnpy (2373) = 10
      chnte (2373) = 6
      chnhe (2373) = 0
      chperm (2373) = 301
      chbirf (2373) = 1667
      chetat (2373) = 649
      chtn2i (2373) = 210
      chbiet (649) = 2373
c
c Aretes coupees :   1  4  5 11 12
      chclas (3097) = ' 5-03'
c Code des aretes coupees : 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1
      charde (3097)(1:15) = '  1  4  5 11 12'
      chnp1 (3097) = 1
      chnar (3097) = 15
      chnpy (3097) = 10
      chnte (3097) = 6
      chnhe (3097) = 0
      chperm (3097) = 101
      chbirf (3097) = 1667
      chetat (3097) = 650
      chtn2i (3097) = 210
      chbiet (650) = 3097
c
c Aretes coupees :   1  4  8  9 10
      chclas (905) = ' 5-03'
c Code des aretes coupees : 1, 0, 0, 1, 0, 0, 0, 1, 1, 1, 0, 0
      charde (905)(1:15) = '  1  4  8  9 10'
      chnp1 (905) = 1
      chnar (905) = 15
      chnpy (905) = 10
      chnte (905) = 6
      chnhe (905) = 0
      chperm (905) = 201
      chbirf (905) = 1667
      chetat (905) = 651
      chtn2i (905) = 210
      chbiet (651) = 905
c
c Aretes coupees :   1  6  7  8 10
      chclas (737) = ' 5-03'
c Code des aretes coupees : 1, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0
      charde (737)(1:15) = '  1  6  7  8 10'
      chnp1 (737) = 1
      chnar (737) = 15
      chnpy (737) = 10
      chnte (737) = 6
      chnhe (737) = 0
      chperm (737) = 320
      chbirf (737) = 1667
      chetat (737) = 652
      chtn2i (737) = 210
      chbiet (652) = 737
c
c Aretes coupees :   2  3  6 10 12
      chclas (2598) = ' 5-03'
c Code des aretes coupees : 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1
      charde (2598)(1:15) = '  2  3  6 10 12'
      chnp1 (2598) = 1
      chnar (2598) = 15
      chnpy (2598) = 10
      chnte (2598) = 6
      chnhe (2598) = 0
      chperm (2598) = 200
      chbirf (2598) = 1667
      chetat (2598) = 653
      chtn2i (2598) = 210
      chbiet (653) = 2598
c
c Aretes coupees :   2  3  7  9 11
      chclas (1350) = ' 5-03'
c Code des aretes coupees : 0, 1, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0
      charde (1350)(1:15) = '  2  3  7  9 11'
      chnp1 (1350) = 1
      chnar (1350) = 15
      chnpy (1350) = 10
      chnte (1350) = 6
      chnhe (1350) = 0
      chperm (1350) = 20
      chbirf (1350) = 1667
      chetat (1350) = 654
      chtn2i (1350) = 210
      chbiet (654) = 1350
c
c Aretes coupees :   2  4  6  9 12
      chclas (2346) = ' 5-03'
c Code des aretes coupees : 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1
      charde (2346)(1:15) = '  2  4  6  9 12'
      chnp1 (2346) = 1
      chnar (2346) = 15
      chnpy (2346) = 10
      chnte (2346) = 6
      chnhe (2346) = 0
      chperm (2346) = 1
      chbirf (2346) = 1667
      chetat (2346) = 655
      chtn2i (2346) = 210
      chbiet (655) = 2346
c
c Aretes coupees :   2  5  6  8 12
      chclas (2226) = ' 5-03'
c Code des aretes coupees : 0, 1, 0, 0, 1, 1, 0, 1, 0, 0, 0, 1
      charde (2226)(1:15) = '  2  5  6  8 12'
      chnp1 (2226) = 1
      chnar (2226) = 15
      chnpy (2226) = 10
      chnte (2226) = 6
      chnhe (2226) = 0
      chperm (2226) = 120
      chbirf (2226) = 1667
      chetat (2226) = 656
      chtn2i (2226) = 210
      chbiet (656) = 2226
c
c Aretes coupees :   3  4  5 10 11
      chclas (1564) = ' 5-03'
c Code des aretes coupees : 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0
      charde (1564)(1:15) = '  3  4  5 10 11'
      chnp1 (1564) = 1
      chnar (1564) = 15
      chnpy (1564) = 10
      chnte (1564) = 6
      chnhe (1564) = 0
      chperm (1564) = 220
      chbirf (1564) = 1667
      chetat (1564) = 657
      chtn2i (1564) = 210
      chbiet (657) = 1564
c
c Aretes coupees :   3  5  7  8  9
      chclas (468) = ' 5-03'
c Code des aretes coupees : 0, 0, 1, 0, 1, 0, 1, 1, 1, 0, 0, 0
      charde (468)(1:15) = '  3  5  7  8  9'
      chnp1 (468) = 1
      chnar (468) = 15
      chnpy (468) = 10
      chnte (468) = 6
      chnhe (468) = 0
      chperm (468) = 100
      chbirf (468) = 1667
      chetat (468) = 658
      chtn2i (468) = 210
      chbiet (658) = 468
c
c Aretes coupees :   4  5  6  7 11
      chclas (1144) = ' 5-03'
c Code des aretes coupees : 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 0
      charde (1144)(1:15) = '  4  5  6  7 11'
      chnp1 (1144) = 1
      chnar (1144) = 15
      chnpy (1144) = 10
      chnte (1144) = 6
      chnhe (1144) = 0
      chperm (1144) = 300
      chbirf (1144) = 1667
      chetat (1144) = 659
      chtn2i (1144) = 210
      chbiet (659) = 1144
c
c ===========================================
c Classe d'equivalence  5-04
c
c Aretes coupees :   1  2  6  7  8
      chclas (227) = ' 5-04'
c Code des aretes coupees : 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0
      charde (227)(1:15) = '  1  2  6  7  8'
      chnp1 (227) = 1
      chnar (227) = 16
      chnpy (227) = 14
      chnte (227) = 0
      chnhe (227) = 0
      chperm (227) = 0
      chbirf (227) = 227
      chetat (227) = 660
      chtn2i (227) = 210
      chbiet (660) = 227
c
c Aretes coupees :   1  2  6 10 11
      chclas (1571) = ' 5-04'
c Code des aretes coupees : 1, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0
      charde (1571)(1:15) = '  1  2  6 10 11'
      chnp1 (1571) = 1
      chnar (1571) = 16
      chnpy (1571) = 14
      chnte (1571) = 0
      chnhe (1571) = 0
      chperm (1571) = 320
      chbirf (1571) = 227
      chetat (1571) = 661
      chtn2i (1571) = 210
      chbiet (661) = 1571
c
c Aretes coupees :   1  2  7  9 12
      chclas (2371) = ' 5-04'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1
      charde (2371)(1:15) = '  1  2  7  9 12'
      chnp1 (2371) = 1
      chnar (2371) = 16
      chnpy (2371) = 14
      chnte (2371) = 0
      chnhe (2371) = 0
      chperm (2371) = 230
      chbirf (2371) = 227
      chetat (2371) = 662
      chtn2i (2371) = 210
      chbiet (662) = 2371
c
c Aretes coupees :   1  3  5  7  8
      chclas (213) = ' 5-04'
c Code des aretes coupees : 1, 0, 1, 0, 1, 0, 1, 1, 0, 0, 0, 0
      charde (213)(1:15) = '  1  3  5  7  8'
      chnp1 (213) = 1
      chnar (213) = 16
      chnpy (213) = 14
      chnte (213) = 0
      chnhe (213) = 0
      chperm (213) = 221
      chbirf (213) = 227
      chetat (213) = 663
      chtn2i (213) = 210
      chbiet (663) = 213
c
c Aretes coupees :   1  3  5 10 11
      chclas (1557) = ' 5-04'
c Code des aretes coupees : 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 1, 0
      charde (1557)(1:15) = '  1  3  5 10 11'
      chnp1 (1557) = 1
      chnar (1557) = 16
      chnpy (1557) = 14
      chnte (1557) = 0
      chnhe (1557) = 0
      chperm (1557) = 101
      chbirf (1557) = 227
      chetat (1557) = 664
      chtn2i (1557) = 210
      chbiet (664) = 1557
c
c Aretes coupees :   1  3  8  9 12
      chclas (2437) = ' 5-04'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1
      charde (2437)(1:15) = '  1  3  8  9 12'
      chnp1 (2437) = 1
      chnar (2437) = 16
      chnpy (2437) = 14
      chnte (2437) = 0
      chnhe (2437) = 0
      chperm (2437) = 310
      chbirf (2437) = 227
      chetat (2437) = 665
      chtn2i (2437) = 210
      chbiet (665) = 2437
c
c Aretes coupees :   1  4  5 10 12
      chclas (2585) = ' 5-04'
c Code des aretes coupees : 1, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 1
      charde (2585)(1:15) = '  1  4  5 10 12'
      chnp1 (2585) = 1
      chnar (2585) = 16
      chnpy (2585) = 14
      chnte (2585) = 0
      chnhe (2585) = 0
      chperm (2585) = 30
      chbirf (2585) = 227
      chetat (2585) = 666
      chtn2i (2585) = 210
      chbiet (666) = 2585
c
c Aretes coupees :   1  4  6 11 12
      chclas (3113) = ' 5-04'
c Code des aretes coupees : 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 1
      charde (3113)(1:15) = '  1  4  6 11 12'
      chnp1 (3113) = 1
      chnar (3113) = 16
      chnpy (3113) = 14
      chnte (3113) = 0
      chnhe (3113) = 0
      chperm (3113) = 110
      chbirf (3113) = 227
      chetat (3113) = 667
      chtn2i (3113) = 210
      chbiet (667) = 3113
c
c Aretes coupees :   1  4  7  9 10
      chclas (841) = ' 5-04'
c Code des aretes coupees : 1, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0
      charde (841)(1:15) = '  1  4  7  9 10'
      chnp1 (841) = 1
      chnar (841) = 16
      chnpy (841) = 14
      chnte (841) = 0
      chnhe (841) = 0
      chperm (841) = 130
      chbirf (841) = 227
      chetat (841) = 668
      chtn2i (841) = 210
      chbiet (668) = 841
c
c Aretes coupees :   1  4  8  9 11
      chclas (1417) = ' 5-04'
c Code des aretes coupees : 1, 0, 0, 1, 0, 0, 0, 1, 1, 0, 1, 0
      charde (1417)(1:15) = '  1  4  8  9 11'
      chnp1 (1417) = 1
      chnar (1417) = 16
      chnpy (1417) = 14
      chnte (1417) = 0
      chnhe (1417) = 0
      chperm (1417) = 210
      chbirf (1417) = 227
      chetat (1417) = 669
      chtn2i (1417) = 210
      chbiet (669) = 1417
c
c Aretes coupees :   2  3  5  9 11
      chclas (1302) = ' 5-04'
c Code des aretes coupees : 0, 1, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0
      charde (1302)(1:15) = '  2  3  5  9 11'
      chnp1 (1302) = 1
      chnar (1302) = 16
      chnpy (1302) = 14
      chnte (1302) = 0
      chnhe (1302) = 0
      chperm (1302) = 100
      chbirf (1302) = 227
      chetat (1302) = 670
      chtn2i (1302) = 210
      chbiet (670) = 1302
c
c Aretes coupees :   2  3  6  9 10
      chclas (806) = ' 5-04'
c Code des aretes coupees : 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0
      charde (806)(1:15) = '  2  3  6  9 10'
      chnp1 (806) = 1
      chnar (806) = 16
      chnpy (806) = 14
      chnte (806) = 0
      chnhe (806) = 0
      chperm (806) = 321
      chbirf (806) = 227
      chetat (806) = 671
      chtn2i (806) = 210
      chbiet (671) = 806
c
c Aretes coupees :   2  3  7 11 12
      chclas (3142) = ' 5-04'
c Code des aretes coupees : 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1
      charde (3142)(1:15) = '  2  3  7 11 12'
      chnp1 (3142) = 1
      chnar (3142) = 16
      chnpy (3142) = 14
      chnte (3142) = 0
      chnhe (3142) = 0
      chperm (3142) = 301
      chbirf (3142) = 227
      chetat (3142) = 672
      chtn2i (3142) = 210
      chbiet (672) = 3142
c
c Aretes coupees :   2  3  8 10 12
      chclas (2694) = ' 5-04'
c Code des aretes coupees : 0, 1, 1, 0, 0, 0, 0, 1, 0, 1, 0, 1
      charde (2694)(1:15) = '  2  3  8 10 12'
      chnp1 (2694) = 1
      chnar (2694) = 16
      chnpy (2694) = 14
      chnte (2694) = 0
      chnhe (2694) = 0
      chperm (2694) = 120
      chbirf (2694) = 227
      chetat (2694) = 673
      chtn2i (2694) = 210
      chbiet (673) = 2694
c
c Aretes coupees :   2  4  5  6  8
      chclas (186) = ' 5-04'
c Code des aretes coupees : 0, 1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0
      charde (186)(1:15) = '  2  4  5  6  8'
      chnp1 (186) = 1
      chnar (186) = 16
      chnpy (186) = 14
      chnte (186) = 0
      chnhe (186) = 0
      chperm (186) = 1
      chbirf (186) = 227
      chetat (186) = 674
      chtn2i (186) = 210
      chbiet (674) = 186
c
c Aretes coupees :   2  4  5  9 12
      chclas (2330) = ' 5-04'
c Code des aretes coupees : 0, 1, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1
      charde (2330)(1:15) = '  2  4  5  9 12'
      chnp1 (2330) = 1
      chnar (2330) = 16
      chnpy (2330) = 14
      chnte (2330) = 0
      chnhe (2330) = 0
      chperm (2330) = 330
      chbirf (2330) = 227
      chetat (2330) = 675
      chtn2i (2330) = 210
      chbiet (675) = 2330
c
c Aretes coupees :   2  4  8 10 11
      chclas (1674) = ' 5-04'
c Code des aretes coupees : 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 1, 0
      charde (1674)(1:15) = '  2  4  8 10 11'
      chnp1 (1674) = 1
      chnar (1674) = 16
      chnpy (1674) = 14
      chnte (1674) = 0
      chnhe (1674) = 0
      chperm (1674) = 121
      chbirf (1674) = 227
      chetat (1674) = 676
      chtn2i (1674) = 210
      chbiet (676) = 1674
c
c Aretes coupees :   3  4  5  6  7
      chclas (124) = ' 5-04'
c Code des aretes coupees : 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0
      charde (124)(1:15) = '  3  4  5  6  7'
      chnp1 (124) = 1
      chnar (124) = 16
      chnpy (124) = 14
      chnte (124) = 0
      chnhe (124) = 0
      chperm (124) = 220
      chbirf (124) = 227
      chetat (124) = 677
      chtn2i (124) = 210
      chbiet (677) = 124
c
c Aretes coupees :   3  4  6  9 12
      chclas (2348) = ' 5-04'
c Code des aretes coupees : 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1
      charde (2348)(1:15) = '  3  4  6  9 12'
      chnp1 (2348) = 1
      chnar (2348) = 16
      chnpy (2348) = 14
      chnte (2348) = 0
      chnhe (2348) = 0
      chperm (2348) = 10
      chbirf (2348) = 227
      chetat (2348) = 678
      chtn2i (2348) = 210
      chbiet (678) = 2348
c
c Aretes coupees :   3  4  7 10 11
      chclas (1612) = ' 5-04'
c Code des aretes coupees : 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0
      charde (1612)(1:15) = '  3  4  7 10 11'
      chnp1 (1612) = 1
      chnar (1612) = 16
      chnpy (1612) = 14
      chnte (1612) = 0
      chnhe (1612) = 0
      chperm (1612) = 300
      chbirf (1612) = 227
      chetat (1612) = 679
      chtn2i (1612) = 210
      chbiet (679) = 1612
c
c Aretes coupees :   5  6  7 11 12
      chclas (3184) = ' 5-04'
c Code des aretes coupees : 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1
      charde (3184)(1:15) = '  5  6  7 11 12'
      chnp1 (3184) = 1
      chnar (3184) = 16
      chnpy (3184) = 14
      chnte (3184) = 0
      chnhe (3184) = 0
      chperm (3184) = 21
      chbirf (3184) = 227
      chetat (3184) = 680
      chtn2i (3184) = 210
      chbiet (680) = 3184
c
c Aretes coupees :   5  6  8 10 12
      chclas (2736) = ' 5-04'
c Code des aretes coupees : 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1
      charde (2736)(1:15) = '  5  6  8 10 12'
      chnp1 (2736) = 1
      chnar (2736) = 16
      chnpy (2736) = 14
      chnte (2736) = 0
      chnhe (2736) = 0
      chperm (2736) = 200
      chbirf (2736) = 227
      chetat (2736) = 681
      chtn2i (2736) = 210
      chbiet (681) = 2736
c
c Aretes coupees :   5  7  8  9 11
      chclas (1488) = ' 5-04'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 1, 1, 1, 0, 1, 0
      charde (1488)(1:15) = '  5  7  8  9 11'
      chnp1 (1488) = 1
      chnar (1488) = 16
      chnpy (1488) = 14
      chnte (1488) = 0
      chnhe (1488) = 0
      chperm (1488) = 20
      chbirf (1488) = 227
      chetat (1488) = 682
      chtn2i (1488) = 210
      chbiet (682) = 1488
c
c Aretes coupees :   6  7  8  9 10
      chclas (992) = ' 5-04'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0
      charde (992)(1:15) = '  6  7  8  9 10'
      chnp1 (992) = 1
      chnar (992) = 16
      chnpy (992) = 14
      chnte (992) = 0
      chnhe (992) = 0
      chperm (992) = 201
      chbirf (992) = 227
      chetat (992) = 683
      chtn2i (992) = 210
      chbiet (683) = 992
c
c ===========================================
c Classe d'equivalence  5-05
c
c Aretes coupees :   1  2  8  9 10
      chclas (899) = ' 5-05'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0
      charde (899)(1:15) = '  1  2  8  9 10'
      chnp1 (899) = 1
      chnar (899) = 15
      chnpy (899) = 10
      chnte (899) = 6
      chnhe (899) = 0
      chperm (899) = 0
      chbirf (899) = 899
      chetat (899) = 684
      chtn2i (899) = 210
      chbiet (684) = 899
c
c Aretes coupees :   1  3  7  9 11
      chclas (1349) = ' 5-05'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0
      charde (1349)(1:15) = '  1  3  7  9 11'
      chnp1 (1349) = 1
      chnar (1349) = 15
      chnpy (1349) = 10
      chnte (1349) = 6
      chnhe (1349) = 0
      chperm (1349) = 20
      chbirf (1349) = 899
      chetat (1349) = 685
      chtn2i (1349) = 210
      chbiet (685) = 1349
c
c Aretes coupees :   1  4  5  7 11
      chclas (1113) = ' 5-05'
c Code des aretes coupees : 1, 0, 0, 1, 1, 0, 1, 0, 0, 0, 1, 0
      charde (1113)(1:15) = '  1  4  5  7 11'
      chnp1 (1113) = 1
      chnar (1113) = 15
      chnpy (1113) = 10
      chnte (1113) = 6
      chnhe (1113) = 0
      chperm (1113) = 300
      chbirf (1113) = 899
      chetat (1113) = 686
      chtn2i (1113) = 210
      chbiet (686) = 1113
c
c Aretes coupees :   1  4  6  8 10
      chclas (681) = ' 5-05'
c Code des aretes coupees : 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0
      charde (681)(1:15) = '  1  4  6  8 10'
      chnp1 (681) = 1
      chnar (681) = 15
      chnpy (681) = 10
      chnte (681) = 6
      chnhe (681) = 0
      chperm (681) = 320
      chbirf (681) = 899
      chetat (681) = 687
      chtn2i (681) = 210
      chbiet (687) = 681
c
c Aretes coupees :   1  7  8 10 11
      chclas (1729) = ' 5-05'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0
      charde (1729)(1:15) = '  1  7  8 10 11'
      chnp1 (1729) = 1
      chnar (1729) = 15
      chnpy (1729) = 10
      chnte (1729) = 6
      chnhe (1729) = 0
      chperm (1729) = 210
      chbirf (1729) = 899
      chetat (1729) = 688
      chtn2i (1729) = 210
      chbiet (688) = 1729
c
c Aretes coupees :   2  3  5  6 12
      chclas (2102) = ' 5-05'
c Code des aretes coupees : 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 1
      charde (2102)(1:15) = '  2  3  5  6 12'
      chnp1 (2102) = 1
      chnar (2102) = 15
      chnpy (2102) = 10
      chnte (2102) = 6
      chnhe (2102) = 0
      chperm (2102) = 10
      chbirf (2102) = 899
      chetat (2102) = 689
      chtn2i (2102) = 210
      chbiet (689) = 2102
c
c Aretes coupees :   2  3  7  8  9
      chclas (454) = ' 5-05'
c Code des aretes coupees : 0, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0
      charde (454)(1:15) = '  2  3  7  8  9'
      chnp1 (454) = 1
      chnar (454) = 15
      chnpy (454) = 10
      chnte (454) = 6
      chnhe (454) = 0
      chperm (454) = 310
      chbirf (454) = 899
      chetat (454) = 690
      chtn2i (454) = 210
      chbiet (690) = 454
c
c Aretes coupees :   2  4  6 10 12
      chclas (2602) = ' 5-05'
c Code des aretes coupees : 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1
      charde (2602)(1:15) = '  2  4  6 10 12'
      chnp1 (2602) = 1
      chnar (2602) = 15
      chnpy (2602) = 10
      chnte (2602) = 6
      chnhe (2602) = 0
      chperm (2602) = 200
      chbirf (2602) = 899
      chetat (2602) = 691
      chtn2i (2602) = 210
      chbiet (691) = 2602
c
c Aretes coupees :   2  6  8  9 12
      chclas (2466) = ' 5-05'
c Code des aretes coupees : 0, 1, 0, 0, 0, 1, 0, 1, 1, 0, 0, 1
      charde (2466)(1:15) = '  2  6  8  9 12'
      chnp1 (2466) = 1
      chnar (2466) = 15
      chnpy (2466) = 10
      chnte (2466) = 6
      chnhe (2466) = 0
      chperm (2466) = 120
      chbirf (2466) = 899
      chetat (2466) = 692
      chtn2i (2466) = 210
      chbiet (692) = 2466
c
c Aretes coupees :   3  4  5 11 12
      chclas (3100) = ' 5-05'
c Code des aretes coupees : 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1
      charde (3100)(1:15) = '  3  4  5 11 12'
      chnp1 (3100) = 1
      chnar (3100) = 15
      chnpy (3100) = 10
      chnte (3100) = 6
      chnhe (3100) = 0
      chperm (3100) = 220
      chbirf (3100) = 899
      chetat (3100) = 693
      chtn2i (3100) = 210
      chbiet (693) = 3100
c
c Aretes coupees :   3  5  7  9 12
      chclas (2388) = ' 5-05'
c Code des aretes coupees : 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1
      charde (2388)(1:15) = '  3  5  7  9 12'
      chnp1 (2388) = 1
      chnar (2388) = 15
      chnpy (2388) = 10
      chnte (2388) = 6
      chnhe (2388) = 0
      chperm (2388) = 100
      chbirf (2388) = 899
      chetat (2388) = 694
      chtn2i (2388) = 210
      chbiet (694) = 2388
c
c Aretes coupees :   4  5  6 10 11
      chclas (1592) = ' 5-05'
c Code des aretes coupees : 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0
      charde (1592)(1:15) = '  4  5  6 10 11'
      chnp1 (1592) = 1
      chnar (1592) = 15
      chnpy (1592) = 10
      chnte (1592) = 6
      chnhe (1592) = 0
      chperm (1592) = 110
      chbirf (1592) = 899
      chetat (1592) = 695
      chtn2i (1592) = 210
      chbiet (695) = 1592
c
c ===========================================
c Classe d'equivalence  5-06
c
c Aretes coupees :   1  2  6  8 10
      chclas (675) = ' 5-06'
c Code des aretes coupees : 1, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0
      charde (675)(1:15) = '  1  2  6  8 10'
      chnp1 (675) = 1
      chnar (675) = 15
      chnpy (675) = 10
      chnte (675) = 6
      chnhe (675) = 0
      chperm (675) = 0
      chbirf (675) = 675
      chetat (675) = 696
      chtn2i (675) = 210
      chbiet (696) = 675
c
c Aretes coupees :   1  3  7  8  9
      chclas (453) = ' 5-06'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0
      charde (453)(1:15) = '  1  3  7  8  9'
      chnp1 (453) = 1
      chnar (453) = 15
      chnpy (453) = 10
      chnte (453) = 6
      chnhe (453) = 0
      chperm (453) = 310
      chbirf (453) = 675
      chetat (453) = 697
      chtn2i (453) = 210
      chbiet (697) = 453
c
c Aretes coupees :   1  4  5 10 11
      chclas (1561) = ' 5-06'
c Code des aretes coupees : 1, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0
      charde (1561)(1:15) = '  1  4  5 10 11'
      chnp1 (1561) = 1
      chnar (1561) = 15
      chnpy (1561) = 10
      chnte (1561) = 6
      chnhe (1561) = 0
      chperm (1561) = 30
      chbirf (1561) = 675
      chetat (1561) = 698
      chtn2i (1561) = 210
      chbiet (698) = 1561
c
c Aretes coupees :   1  4  8 10 11
      chclas (1673) = ' 5-06'
c Code des aretes coupees : 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 1, 0
      charde (1673)(1:15) = '  1  4  8 10 11'
      chnp1 (1673) = 1
      chnar (1673) = 15
      chnpy (1673) = 10
      chnte (1673) = 6
      chnhe (1673) = 0
      chperm (1673) = 210
      chbirf (1673) = 675
      chetat (1673) = 699
      chtn2i (1673) = 210
      chbiet (699) = 1673
c
c Aretes coupees :   1  7  8  9 10
      chclas (961) = ' 5-06'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0
      charde (961)(1:15) = '  1  7  8  9 10'
      chnp1 (961) = 1
      chnar (961) = 15
      chnpy (961) = 10
      chnte (961) = 6
      chnhe (961) = 0
      chperm (961) = 130
      chbirf (961) = 675
      chetat (961) = 700
      chtn2i (961) = 210
      chbiet (700) = 961
c
c Aretes coupees :   2  3  6  9 12
      chclas (2342) = ' 5-06'
c Code des aretes coupees : 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1
      charde (2342)(1:15) = '  2  3  6  9 12'
      chnp1 (2342) = 1
      chnar (2342) = 15
      chnpy (2342) = 10
      chnte (2342) = 6
      chnhe (2342) = 0
      chperm (2342) = 10
      chbirf (2342) = 675
      chetat (2342) = 701
      chtn2i (2342) = 210
      chbiet (701) = 2342
c
c Aretes coupees :   2  3  7  9 12
      chclas (2374) = ' 5-06'
c Code des aretes coupees : 0, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1
      charde (2374)(1:15) = '  2  3  7  9 12'
      chnp1 (2374) = 1
      chnar (2374) = 15
      chnpy (2374) = 10
      chnte (2374) = 6
      chnhe (2374) = 0
      chperm (2374) = 230
      chbirf (2374) = 675
      chetat (2374) = 702
      chtn2i (2374) = 210
      chbiet (702) = 2374
c
c Aretes coupees :   2  4  5  6 12
      chclas (2106) = ' 5-06'
c Code des aretes coupees : 0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 1
      charde (2106)(1:15) = '  2  4  5  6 12'
      chnp1 (2106) = 1
      chnar (2106) = 15
      chnpy (2106) = 10
      chnte (2106) = 6
      chnhe (2106) = 0
      chperm (2106) = 330
      chbirf (2106) = 675
      chetat (2106) = 703
      chtn2i (2106) = 210
      chbiet (703) = 2106
c
c Aretes coupees :   2  6  8 10 12
      chclas (2722) = ' 5-06'
c Code des aretes coupees : 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1
      charde (2722)(1:15) = '  2  6  8 10 12'
      chnp1 (2722) = 1
      chnar (2722) = 15
      chnpy (2722) = 10
      chnte (2722) = 6
      chnhe (2722) = 0
      chperm (2722) = 200
      chbirf (2722) = 675
      chetat (2722) = 704
      chtn2i (2722) = 210
      chbiet (704) = 2722
c
c Aretes coupees :   3  4  5  7 11
      chclas (1116) = ' 5-06'
c Code des aretes coupees : 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0
      charde (1116)(1:15) = '  3  4  5  7 11'
      chnp1 (1116) = 1
      chnar (1116) = 15
      chnpy (1116) = 10
      chnte (1116) = 6
      chnhe (1116) = 0
      chperm (1116) = 300
      chbirf (1116) = 675
      chetat (1116) = 705
      chtn2i (1116) = 210
      chbiet (705) = 1116
c
c Aretes coupees :   3  5  7  9 11
      chclas (1364) = ' 5-06'
c Code des aretes coupees : 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0
      charde (1364)(1:15) = '  3  5  7  9 11'
      chnp1 (1364) = 1
      chnar (1364) = 15
      chnpy (1364) = 10
      chnte (1364) = 6
      chnhe (1364) = 0
      chperm (1364) = 100
      chbirf (1364) = 675
      chetat (1364) = 706
      chtn2i (1364) = 210
      chbiet (706) = 1364
c
c Aretes coupees :   4  5  6 11 12
      chclas (3128) = ' 5-06'
c Code des aretes coupees : 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1
      charde (3128)(1:15) = '  4  5  6 11 12'
      chnp1 (3128) = 1
      chnar (3128) = 15
      chnpy (3128) = 10
      chnte (3128) = 6
      chnhe (3128) = 0
      chperm (3128) = 110
      chbirf (3128) = 675
      chetat (3128) = 707
      chtn2i (3128) = 210
      chbiet (707) = 3128
c
c ===========================================
c Classe d'equivalence  5-07
c
c Aretes coupees :   1  2  7  8  9
      chclas (451) = ' 5-07'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0
      charde (451)(1:15) = '  1  2  7  8  9'
      chnp1 (451) = 1
      chnar (451) = 15
      chnpy (451) = 10
      chnte (451) = 6
      chnhe (451) = 0
      chperm (451) = 0
      chbirf (451) = 451
      chetat (451) = 708
      chtn2i (451) = 210
      chbiet (708) = 451
c
c Aretes coupees :   1  3  5  7 11
      chclas (1109) = ' 5-07'
c Code des aretes coupees : 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0
      charde (1109)(1:15) = '  1  3  5  7 11'
      chnp1 (1109) = 1
      chnar (1109) = 15
      chnpy (1109) = 10
      chnte (1109) = 6
      chnhe (1109) = 0
      chperm (1109) = 101
      chbirf (1109) = 451
      chetat (1109) = 709
      chtn2i (1109) = 210
      chbiet (709) = 1109
c
c Aretes coupees :   1  4  6 10 11
      chclas (1577) = ' 5-07'
c Code des aretes coupees : 1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1, 0
      charde (1577)(1:15) = '  1  4  6 10 11'
      chnp1 (1577) = 1
      chnar (1577) = 15
      chnpy (1577) = 10
      chnte (1577) = 6
      chnhe (1577) = 0
      chperm (1577) = 110
      chbirf (1577) = 451
      chetat (1577) = 710
      chtn2i (1577) = 210
      chbiet (710) = 1577
c
c Aretes coupees :   1  4  7 10 11
      chclas (1609) = ' 5-07'
c Code des aretes coupees : 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 0
      charde (1609)(1:15) = '  1  4  7 10 11'
      chnp1 (1609) = 1
      chnar (1609) = 15
      chnpy (1609) = 10
      chnte (1609) = 6
      chnhe (1609) = 0
      chperm (1609) = 300
      chbirf (1609) = 451
      chetat (1609) = 711
      chtn2i (1609) = 210
      chbiet (711) = 1609
c
c Aretes coupees :   1  7  8  9 11
      chclas (1473) = ' 5-07'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0
      charde (1473)(1:15) = '  1  7  8  9 11'
      chnp1 (1473) = 1
      chnar (1473) = 15
      chnpy (1473) = 10
      chnte (1473) = 6
      chnhe (1473) = 0
      chperm (1473) = 210
      chbirf (1473) = 451
      chetat (1473) = 712
      chtn2i (1473) = 210
      chbiet (712) = 1473
c
c Aretes coupees :   2  3  5  9 12
      chclas (2326) = ' 5-07'
c Code des aretes coupees : 0, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0, 1
      charde (2326)(1:15) = '  2  3  5  9 12'
      chnp1 (2326) = 1
      chnar (2326) = 15
      chnpy (2326) = 10
      chnte (2326) = 6
      chnhe (2326) = 0
      chperm (2326) = 100
      chbirf (2326) = 451
      chetat (2326) = 713
      chtn2i (2326) = 210
      chbiet (713) = 2326
c
c Aretes coupees :   2  3  8  9 12
      chclas (2438) = ' 5-07'
c Code des aretes coupees : 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1
      charde (2438)(1:15) = '  2  3  8  9 12'
      chnp1 (2438) = 1
      chnar (2438) = 15
      chnpy (2438) = 10
      chnte (2438) = 6
      chnhe (2438) = 0
      chperm (2438) = 310
      chbirf (2438) = 451
      chetat (2438) = 714
      chtn2i (2438) = 210
      chbiet (714) = 2438
c
c Aretes coupees :   2  4  6  8 10
      chclas (682) = ' 5-07'
c Code des aretes coupees : 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0
      charde (682)(1:15) = '  2  4  6  8 10'
      chnp1 (682) = 1
      chnar (682) = 15
      chnpy (682) = 10
      chnte (682) = 6
      chnhe (682) = 0
      chperm (682) = 1
      chbirf (682) = 451
      chetat (682) = 715
      chtn2i (682) = 210
      chbiet (715) = 682
c
c Aretes coupees :   2  6  8  9 10
      chclas (930) = ' 5-07'
c Code des aretes coupees : 0, 1, 0, 0, 0, 1, 0, 1, 1, 1, 0, 0
      charde (930)(1:15) = '  2  6  8  9 10'
      chnp1 (930) = 1
      chnar (930) = 15
      chnpy (930) = 10
      chnte (930) = 6
      chnhe (930) = 0
      chperm (930) = 201
      chbirf (930) = 451
      chetat (930) = 716
      chtn2i (930) = 210
      chbiet (716) = 930
c
c Aretes coupees :   3  4  5  6 12
      chclas (2108) = ' 5-07'
c Code des aretes coupees : 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1
      charde (2108)(1:15) = '  3  4  5  6 12'
      chnp1 (2108) = 1
      chnar (2108) = 15
      chnpy (2108) = 10
      chnte (2108) = 6
      chnhe (2108) = 0
      chperm (2108) = 10
      chbirf (2108) = 451
      chetat (2108) = 717
      chtn2i (2108) = 210
      chbiet (717) = 2108
c
c Aretes coupees :   3  5  7 11 12
      chclas (3156) = ' 5-07'
c Code des aretes coupees : 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 1
      charde (3156)(1:15) = '  3  5  7 11 12'
      chnp1 (3156) = 1
      chnar (3156) = 15
      chnpy (3156) = 10
      chnte (3156) = 6
      chnhe (3156) = 0
      chperm (3156) = 301
      chbirf (3156) = 451
      chetat (3156) = 718
      chtn2i (3156) = 210
      chbiet (718) = 3156
c
c Aretes coupees :   4  5  6 10 12
      chclas (2616) = ' 5-07'
c Code des aretes coupees : 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1
      charde (2616)(1:15) = '  4  5  6 10 12'
      chnp1 (2616) = 1
      chnar (2616) = 15
      chnpy (2616) = 10
      chnte (2616) = 6
      chnhe (2616) = 0
      chperm (2616) = 200
      chbirf (2616) = 451
      chetat (2616) = 719
      chtn2i (2616) = 210
      chbiet (719) = 2616
c
c ===========================================
c Classe d'equivalence  5-08
c
c Aretes coupees :   1  2  6  7 11
      chclas (1123) = ' 5-08'
c Code des aretes coupees : 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0
      charde (1123)(1:15) = '  1  2  6  7 11'
      chnp1 (1123) = 1
      chnar (1123) = 17
      chnpy (1123) = 12
      chnte (1123) = 6
      chnhe (1123) = 0
      chperm (1123) = 0
      chbirf (1123) = 1123
      chetat (1123) = 720
      chtn2i (1123) = 210
      chbiet (720) = 1123
c
c Aretes coupees :   1  2  7 11 12
      chclas (3139) = ' 5-08'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1
      charde (3139)(1:15) = '  1  2  7 11 12'
      chnp1 (3139) = 1
      chnar (3139) = 17
      chnpy (3139) = 12
      chnte (3139) = 6
      chnhe (3139) = 0
      chperm (3139) = 230
      chbirf (3139) = 1123
      chetat (3139) = 721
      chtn2i (3139) = 210
      chbiet (721) = 3139
c
c Aretes coupees :   1  3  5  8 12
      chclas (2197) = ' 5-08'
c Code des aretes coupees : 1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 1
      charde (2197)(1:15) = '  1  3  5  8 12'
      chnp1 (2197) = 1
      chnar (2197) = 17
      chnpy (2197) = 12
      chnte (2197) = 6
      chnhe (2197) = 0
      chperm (2197) = 310
      chbirf (2197) = 1123
      chetat (2197) = 722
      chtn2i (2197) = 210
      chbiet (722) = 2197
c
c Aretes coupees :   1  3  5 10 12
      chclas (2581) = ' 5-08'
c Code des aretes coupees : 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1
      charde (2581)(1:15) = '  1  3  5 10 12'
      chnp1 (2581) = 1
      chnar (2581) = 17
      chnpy (2581) = 12
      chnte (2581) = 6
      chnhe (2581) = 0
      chperm (2581) = 30
      chbirf (2581) = 1123
      chetat (2581) = 723
      chtn2i (2581) = 210
      chbiet (723) = 2581
c
c Aretes coupees :   1  6  7 11 12
      chclas (3169) = ' 5-08'
c Code des aretes coupees : 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1
      charde (3169)(1:15) = '  1  6  7 11 12'
      chnp1 (3169) = 1
      chnar (3169) = 17
      chnpy (3169) = 12
      chnte (3169) = 6
      chnhe (3169) = 0
      chperm (3169) = 110
      chbirf (3169) = 1123
      chetat (3169) = 724
      chtn2i (3169) = 210
      chbiet (724) = 3169
c
c Aretes coupees :   2  4  5  8  9
      chclas (410) = ' 5-08'
c Code des aretes coupees : 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0
      charde (410)(1:15) = '  2  4  5  8  9'
      chnp1 (410) = 1
      chnar (410) = 17
      chnpy (410) = 12
      chnte (410) = 6
      chnhe (410) = 0
      chperm (410) = 330
      chbirf (410) = 1123
      chetat (410) = 725
      chtn2i (410) = 210
      chbiet (725) = 410
c
c Aretes coupees :   2  4  8  9 11
      chclas (1418) = ' 5-08'
c Code des aretes coupees : 0, 1, 0, 1, 0, 0, 0, 1, 1, 0, 1, 0
      charde (1418)(1:15) = '  2  4  8  9 11'
      chnp1 (1418) = 1
      chnar (1418) = 17
      chnpy (1418) = 12
      chnte (1418) = 6
      chnhe (1418) = 0
      chperm (1418) = 210
      chbirf (1418) = 1123
      chetat (1418) = 726
      chtn2i (1418) = 210
      chbiet (726) = 1418
c
c Aretes coupees :   2  5  8  9 11
      chclas (1426) = ' 5-08'
c Code des aretes coupees : 0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 0
      charde (1426)(1:15) = '  2  5  8  9 11'
      chnp1 (1426) = 1
      chnar (1426) = 17
      chnpy (1426) = 12
      chnte (1426) = 6
      chnhe (1426) = 0
      chperm (1426) = 100
      chbirf (1426) = 1123
      chetat (1426) = 727
      chtn2i (1426) = 210
      chbiet (727) = 1426
c
c Aretes coupees :   3  4  6  7 10
      chclas (620) = ' 5-08'
c Code des aretes coupees : 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 0
      charde (620)(1:15) = '  3  4  6  7 10'
      chnp1 (620) = 1
      chnar (620) = 17
      chnpy (620) = 12
      chnte (620) = 6
      chnhe (620) = 0
      chperm (620) = 300
      chbirf (620) = 1123
      chetat (620) = 728
      chtn2i (620) = 210
      chbiet (728) = 620
c
c Aretes coupees :   3  4  6  9 10
      chclas (812) = ' 5-08'
c Code des aretes coupees : 0, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0
      charde (812)(1:15) = '  3  4  6  9 10'
      chnp1 (812) = 1
      chnar (812) = 17
      chnpy (812) = 12
      chnte (812) = 6
      chnhe (812) = 0
      chperm (812) = 10
      chbirf (812) = 1123
      chetat (812) = 729
      chtn2i (812) = 210
      chbiet (729) = 812
c
c Aretes coupees :   3  5  8 10 12
      chclas (2708) = ' 5-08'
c Code des aretes coupees : 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1
      charde (2708)(1:15) = '  3  5  8 10 12'
      chnp1 (2708) = 1
      chnar (2708) = 17
      chnpy (2708) = 12
      chnte (2708) = 6
      chnhe (2708) = 0
      chperm (2708) = 200
      chbirf (2708) = 1123
      chetat (2708) = 730
      chtn2i (2708) = 210
      chbiet (730) = 2708
c
c Aretes coupees :   4  6  7  9 10
      chclas (872) = ' 5-08'
c Code des aretes coupees : 0, 0, 0, 1, 0, 1, 1, 0, 1, 1, 0, 0
      charde (872)(1:15) = '  4  6  7  9 10'
      chnp1 (872) = 1
      chnar (872) = 17
      chnpy (872) = 12
      chnte (872) = 6
      chnhe (872) = 0
      chperm (872) = 130
      chbirf (872) = 1123
      chetat (872) = 731
      chtn2i (872) = 210
      chbiet (731) = 872
c
c ===========================================
c Classe d'equivalence  5-09
c
c Aretes coupees :   1  2  6  7 12
      chclas (2147) = ' 5-09'
c Code des aretes coupees : 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1
      charde (2147)(1:15) = '  1  2  6  7 12'
      chnp1 (2147) = 1
      chnar (2147) = 17
      chnpy (2147) = 12
      chnte (2147) = 6
      chnhe (2147) = 0
      chperm (2147) = 0
      chbirf (2147) = 2147
      chetat (2147) = 732
      chtn2i (2147) = 210
      chbiet (732) = 2147
c
c Aretes coupees :   1  2  6 11 12
      chclas (3107) = ' 5-09'
c Code des aretes coupees : 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1
      charde (3107)(1:15) = '  1  2  6 11 12'
      chnp1 (3107) = 1
      chnar (3107) = 17
      chnpy (3107) = 12
      chnte (3107) = 6
      chnhe (3107) = 0
      chperm (3107) = 110
      chbirf (3107) = 2147
      chetat (3107) = 733
      chtn2i (3107) = 210
      chbiet (733) = 3107
c
c Aretes coupees :   1  3  5  8 10
      chclas (661) = ' 5-09'
c Code des aretes coupees : 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0
      charde (661)(1:15) = '  1  3  5  8 10'
      chnp1 (661) = 1
      chnar (661) = 17
      chnpy (661) = 12
      chnte (661) = 6
      chnhe (661) = 0
      chperm (661) = 101
      chbirf (661) = 2147
      chetat (661) = 734
      chtn2i (661) = 210
      chbiet (734) = 661
c
c Aretes coupees :   1  3  8 10 12
      chclas (2693) = ' 5-09'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 1
      charde (2693)(1:15) = '  1  3  8 10 12'
      chnp1 (2693) = 1
      chnar (2693) = 17
      chnpy (2693) = 12
      chnte (2693) = 6
      chnhe (2693) = 0
      chperm (2693) = 310
      chbirf (2693) = 2147
      chetat (2693) = 735
      chtn2i (2693) = 210
      chbiet (735) = 2693
c
c Aretes coupees :   1  5  8 10 12
      chclas (2705) = ' 5-09'
c Code des aretes coupees : 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1
      charde (2705)(1:15) = '  1  5  8 10 12'
      chnp1 (2705) = 1
      chnar (2705) = 17
      chnpy (2705) = 12
      chnte (2705) = 6
      chnhe (2705) = 0
      chperm (2705) = 200
      chbirf (2705) = 2147
      chetat (2705) = 736
      chtn2i (2705) = 210
      chbiet (736) = 2705
c
c Aretes coupees :   2  4  5  8 11
      chclas (1178) = ' 5-09'
c Code des aretes coupees : 0, 1, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0
      charde (1178)(1:15) = '  2  4  5  8 11'
      chnp1 (1178) = 1
      chnar (1178) = 17
      chnpy (1178) = 12
      chnte (1178) = 6
      chnhe (1178) = 0
      chperm (1178) = 1
      chbirf (1178) = 2147
      chetat (1178) = 737
      chtn2i (1178) = 210
      chbiet (737) = 1178
c
c Aretes coupees :   2  4  5  9 11
      chclas (1306) = ' 5-09'
c Code des aretes coupees : 0, 1, 0, 1, 1, 0, 0, 0, 1, 0, 1, 0
      charde (1306)(1:15) = '  2  4  5  9 11'
      chnp1 (1306) = 1
      chnar (1306) = 17
      chnpy (1306) = 12
      chnte (1306) = 6
      chnhe (1306) = 0
      chperm (1306) = 100
      chbirf (1306) = 2147
      chetat (1306) = 738
      chtn2i (1306) = 210
      chbiet (738) = 1306
c
c Aretes coupees :   2  6  7 11 12
      chclas (3170) = ' 5-09'
c Code des aretes coupees : 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1
      charde (3170)(1:15) = '  2  6  7 11 12'
      chnp1 (3170) = 1
      chnar (3170) = 17
      chnpy (3170) = 12
      chnte (3170) = 6
      chnhe (3170) = 0
      chperm (3170) = 301
      chbirf (3170) = 2147
      chetat (3170) = 739
      chtn2i (3170) = 210
      chbiet (739) = 3170
c
c Aretes coupees :   3  4  6  7  9
      chclas (364) = ' 5-09'
c Code des aretes coupees : 0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 0, 0
      charde (364)(1:15) = '  3  4  6  7  9'
      chnp1 (364) = 1
      chnar (364) = 17
      chnpy (364) = 12
      chnte (364) = 6
      chnhe (364) = 0
      chperm (364) = 10
      chbirf (364) = 2147
      chetat (364) = 740
      chtn2i (364) = 210
      chbiet (740) = 364
c
c Aretes coupees :   3  4  7  9 10
      chclas (844) = ' 5-09'
c Code des aretes coupees : 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 0
      charde (844)(1:15) = '  3  4  7  9 10'
      chnp1 (844) = 1
      chnar (844) = 17
      chnpy (844) = 12
      chnte (844) = 6
      chnhe (844) = 0
      chperm (844) = 300
      chbirf (844) = 2147
      chetat (844) = 741
      chtn2i (844) = 210
      chbiet (741) = 844
c
c Aretes coupees :   3  6  7  9 10
      chclas (868) = ' 5-09'
c Code des aretes coupees : 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0
      charde (868)(1:15) = '  3  6  7  9 10'
      chnp1 (868) = 1
      chnar (868) = 17
      chnpy (868) = 12
      chnte (868) = 6
      chnhe (868) = 0
      chperm (868) = 201
      chbirf (868) = 2147
      chetat (868) = 742
      chtn2i (868) = 210
      chbiet (742) = 868
c
c Aretes coupees :   4  5  8  9 11
      chclas (1432) = ' 5-09'
c Code des aretes coupees : 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0
      charde (1432)(1:15) = '  4  5  8  9 11'
      chnp1 (1432) = 1
      chnar (1432) = 17
      chnpy (1432) = 12
      chnte (1432) = 6
      chnhe (1432) = 0
      chperm (1432) = 210
      chbirf (1432) = 2147
      chetat (1432) = 743
      chtn2i (1432) = 210
      chbiet (743) = 1432
c
c ===========================================
c Classe d'equivalence  5-10
c
c Aretes coupees :   1  2  5  8 11
      chclas (1171) = ' 5-10'
c Code des aretes coupees : 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0
      charde (1171)(1:15) = '  1  2  5  8 11'
      chnp1 (1171) = 1
      chnar (1171) = 17
      chnpy (1171) = 12
      chnte (1171) = 6
      chnhe (1171) = 0
      chperm (1171) = 0
      chbirf (1171) = 1171
      chetat (1171) = 744
      chtn2i (1171) = 210
      chbiet (744) = 1171
c
c Aretes coupees :   1  2  5  8 12
      chclas (2195) = ' 5-10'
c Code des aretes coupees : 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1
      charde (2195)(1:15) = '  1  2  5  8 12'
      chnp1 (2195) = 1
      chnar (2195) = 17
      chnpy (2195) = 12
      chnte (2195) = 6
      chnhe (2195) = 0
      chperm (2195) = 330
      chbirf (2195) = 1171
      chetat (2195) = 745
      chtn2i (2195) = 210
      chbiet (745) = 2195
c
c Aretes coupees :   1  2  5 11 12
      chclas (3091) = ' 5-10'
c Code des aretes coupees : 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1
      charde (3091)(1:15) = '  1  2  5 11 12'
      chnp1 (3091) = 1
      chnar (3091) = 17
      chnpy (3091) = 12
      chnte (3091) = 6
      chnhe (3091) = 0
      chperm (3091) = 101
      chbirf (3091) = 1171
      chetat (3091) = 746
      chtn2i (3091) = 210
      chbiet (746) = 3091
c
c Aretes coupees :   1  2  8 11 12
      chclas (3203) = ' 5-10'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1
      charde (3203)(1:15) = '  1  2  8 11 12'
      chnp1 (3203) = 1
      chnar (3203) = 17
      chnpy (3203) = 12
      chnte (3203) = 6
      chnhe (3203) = 0
      chperm (3203) = 210
      chbirf (3203) = 1171
      chetat (3203) = 747
      chtn2i (3203) = 210
      chbiet (747) = 3203
c
c Aretes coupees :   1  3  6  7 10
      chclas (613) = ' 5-10'
c Code des aretes coupees : 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0
      charde (613)(1:15) = '  1  3  6  7 10'
      chnp1 (613) = 1
      chnar (613) = 17
      chnpy (613) = 12
      chnte (613) = 6
      chnhe (613) = 0
      chperm (613) = 320
      chbirf (613) = 1171
      chetat (613) = 748
      chtn2i (613) = 210
      chbiet (748) = 613
c
c Aretes coupees :   1  3  6  7 12
      chclas (2149) = ' 5-10'
c Code des aretes coupees : 1, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 1
      charde (2149)(1:15) = '  1  3  6  7 12'
      chnp1 (2149) = 1
      chnar (2149) = 17
      chnpy (2149) = 12
      chnte (2149) = 6
      chnhe (2149) = 0
      chperm (2149) = 221
      chbirf (2149) = 1171
      chetat (2149) = 749
      chtn2i (2149) = 210
      chbiet (749) = 2149
c
c Aretes coupees :   1  3  6 10 12
      chclas (2597) = ' 5-10'
c Code des aretes coupees : 1, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1
      charde (2597)(1:15) = '  1  3  6 10 12'
      chnp1 (2597) = 1
      chnar (2597) = 17
      chnpy (2597) = 12
      chnte (2597) = 6
      chnhe (2597) = 0
      chperm (2597) = 10
      chbirf (2597) = 1171
      chetat (2597) = 750
      chtn2i (2597) = 210
      chbiet (750) = 2597
c
c Aretes coupees :   1  3  7 10 12
      chclas (2629) = ' 5-10'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1
      charde (2629)(1:15) = '  1  3  7 10 12'
      chnp1 (2629) = 1
      chnar (2629) = 17
      chnpy (2629) = 12
      chnte (2629) = 6
      chnhe (2629) = 0
      chperm (2629) = 301
      chbirf (2629) = 1171
      chetat (2629) = 751
      chtn2i (2629) = 210
      chbiet (751) = 2629
c
c Aretes coupees :   1  5  8 11 12
      chclas (3217) = ' 5-10'
c Code des aretes coupees : 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1
      charde (3217)(1:15) = '  1  5  8 11 12'
      chnp1 (3217) = 1
      chnar (3217) = 17
      chnpy (3217) = 12
      chnte (3217) = 6
      chnhe (3217) = 0
      chperm (3217) = 21
      chbirf (3217) = 1171
      chetat (3217) = 752
      chtn2i (3217) = 210
      chbiet (752) = 3217
c
c Aretes coupees :   1  6  7 10 12
      chclas (2657) = ' 5-10'
c Code des aretes coupees : 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1
      charde (2657)(1:15) = '  1  6  7 10 12'
      chnp1 (2657) = 1
      chnar (2657) = 17
      chnpy (2657) = 12
      chnte (2657) = 6
      chnhe (2657) = 0
      chperm (2657) = 130
      chbirf (2657) = 1171
      chetat (2657) = 753
      chtn2i (2657) = 210
      chbiet (753) = 2657
c
c Aretes coupees :   2  4  6  7  9
      chclas (362) = ' 5-10'
c Code des aretes coupees : 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 0, 0
      charde (362)(1:15) = '  2  4  6  7  9'
      chnp1 (362) = 1
      chnar (362) = 17
      chnpy (362) = 12
      chnte (362) = 6
      chnhe (362) = 0
      chperm (362) = 1
      chbirf (362) = 1171
      chetat (362) = 754
      chtn2i (362) = 210
      chbiet (754) = 362
c
c Aretes coupees :   2  4  6  7 11
      chclas (1130) = ' 5-10'
c Code des aretes coupees : 0, 1, 0, 1, 0, 1, 1, 0, 0, 0, 1, 0
      charde (1130)(1:15) = '  2  4  6  7 11'
      chnp1 (1130) = 1
      chnar (1130) = 17
      chnpy (1130) = 12
      chnte (1130) = 6
      chnhe (1130) = 0
      chperm (1130) = 300
      chbirf (1130) = 1171
      chetat (1130) = 755
      chtn2i (1130) = 210
      chbiet (755) = 1130
c
c Aretes coupees :   2  4  6  9 11
      chclas (1322) = ' 5-10'
c Code des aretes coupees : 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0
      charde (1322)(1:15) = '  2  4  6  9 11'
      chnp1 (1322) = 1
      chnar (1322) = 17
      chnpy (1322) = 12
      chnte (1322) = 6
      chnhe (1322) = 0
      chperm (1322) = 321
      chbirf (1322) = 1171
      chetat (1322) = 756
      chtn2i (1322) = 210
      chbiet (756) = 1322
c
c Aretes coupees :   2  4  7  9 11
      chclas (1354) = ' 5-10'
c Code des aretes coupees : 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0
      charde (1354)(1:15) = '  2  4  7  9 11'
      chnp1 (1354) = 1
      chnar (1354) = 17
      chnpy (1354) = 12
      chnte (1354) = 6
      chnhe (1354) = 0
      chperm (1354) = 230
      chbirf (1354) = 1171
      chetat (1354) = 757
      chtn2i (1354) = 210
      chbiet (757) = 1354
c
c Aretes coupees :   2  5  8 11 12
      chclas (3218) = ' 5-10'
c Code des aretes coupees : 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1
      charde (3218)(1:15) = '  2  5  8 11 12'
      chnp1 (3218) = 1
      chnar (3218) = 17
      chnpy (3218) = 12
      chnte (3218) = 6
      chnhe (3218) = 0
      chperm (3218) = 120
      chbirf (3218) = 1171
      chetat (3218) = 758
      chtn2i (3218) = 210
      chbiet (758) = 3218
c
c Aretes coupees :   2  6  7  9 11
      chclas (1378) = ' 5-10'
c Code des aretes coupees : 0, 1, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0
      charde (1378)(1:15) = '  2  6  7  9 11'
      chnp1 (1378) = 1
      chnar (1378) = 17
      chnpy (1378) = 12
      chnte (1378) = 6
      chnhe (1378) = 0
      chperm (1378) = 20
      chbirf (1378) = 1171
      chetat (1378) = 759
      chtn2i (1378) = 210
      chbiet (759) = 1378
c
c Aretes coupees :   3  4  5  8  9
      chclas (412) = ' 5-10'
c Code des aretes coupees : 0, 0, 1, 1, 1, 0, 0, 1, 1, 0, 0, 0
      charde (412)(1:15) = '  3  4  5  8  9'
      chnp1 (412) = 1
      chnar (412) = 17
      chnpy (412) = 12
      chnte (412) = 6
      chnhe (412) = 0
      chperm (412) = 310
      chbirf (412) = 1171
      chetat (412) = 760
      chtn2i (412) = 210
      chbiet (760) = 412
c
c Aretes coupees :   3  4  5  8 10
      chclas (668) = ' 5-10'
c Code des aretes coupees : 0, 0, 1, 1, 1, 0, 0, 1, 0, 1, 0, 0
      charde (668)(1:15) = '  3  4  5  8 10'
      chnp1 (668) = 1
      chnar (668) = 17
      chnpy (668) = 12
      chnte (668) = 6
      chnhe (668) = 0
      chperm (668) = 220
      chbirf (668) = 1171
      chetat (668) = 761
      chtn2i (668) = 210
      chbiet (761) = 668
c
c Aretes coupees :   3  4  5  9 10
      chclas (796) = ' 5-10'
c Code des aretes coupees : 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0
      charde (796)(1:15) = '  3  4  5  9 10'
      chnp1 (796) = 1
      chnar (796) = 17
      chnpy (796) = 12
      chnte (796) = 6
      chnhe (796) = 0
      chperm (796) = 30
      chbirf (796) = 1171
      chetat (796) = 762
      chtn2i (796) = 210
      chbiet (762) = 796
c
c Aretes coupees :   3  4  8  9 10
      chclas (908) = ' 5-10'
c Code des aretes coupees : 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0
      charde (908)(1:15) = '  3  4  8  9 10'
      chnp1 (908) = 1
      chnar (908) = 17
      chnpy (908) = 12
      chnte (908) = 6
      chnhe (908) = 0
      chperm (908) = 121
      chbirf (908) = 1171
      chetat (908) = 763
      chtn2i (908) = 210
      chbiet (763) = 908
c
c Aretes coupees :   3  5  8  9 10
      chclas (916) = ' 5-10'
c Code des aretes coupees : 0, 0, 1, 0, 1, 0, 0, 1, 1, 1, 0, 0
      charde (916)(1:15) = '  3  5  8  9 10'
      chnp1 (916) = 1
      chnar (916) = 17
      chnpy (916) = 12
      chnte (916) = 6
      chnhe (916) = 0
      chperm (916) = 100
      chbirf (916) = 1171
      chetat (916) = 764
      chtn2i (916) = 210
      chbiet (764) = 916
c
c Aretes coupees :   3  6  7 10 12
      chclas (2660) = ' 5-10'
c Code des aretes coupees : 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1
      charde (2660)(1:15) = '  3  6  7 10 12'
      chnp1 (2660) = 1
      chnar (2660) = 17
      chnpy (2660) = 12
      chnte (2660) = 6
      chnhe (2660) = 0
      chperm (2660) = 200
      chbirf (2660) = 1171
      chetat (2660) = 765
      chtn2i (2660) = 210
      chbiet (765) = 2660
c
c Aretes coupees :   4  5  8  9 10
      chclas (920) = ' 5-10'
c Code des aretes coupees : 0, 0, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0
      charde (920)(1:15) = '  4  5  8  9 10'
      chnp1 (920) = 1
      chnar (920) = 17
      chnpy (920) = 12
      chnte (920) = 6
      chnhe (920) = 0
      chperm (920) = 201
      chbirf (920) = 1171
      chetat (920) = 766
      chtn2i (920) = 210
      chbiet (766) = 920
c
c Aretes coupees :   4  6  7  9 11
      chclas (1384) = ' 5-10'
c Code des aretes coupees : 0, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0
      charde (1384)(1:15) = '  4  6  7  9 11'
      chnp1 (1384) = 1
      chnar (1384) = 17
      chnpy (1384) = 12
      chnte (1384) = 6
      chnhe (1384) = 0
      chperm (1384) = 110
      chbirf (1384) = 1171
      chetat (1384) = 767
      chtn2i (1384) = 210
      chbiet (767) = 1384
c
c ===========================================
c Classe d'equivalence  5-11
c
c Aretes coupees :   1  2  3  4  5
      chclas (31) = ' 5-11'
c Code des aretes coupees : 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0
      charde (31)(1:15) = '  1  2  3  4  5'
      chnp1 (31) = 1
      chnar (31) = 16
      chnpy (31) = 11
      chnte (31) = 6
      chnhe (31) = 0
      chperm (31) = 0
      chbirf (31) = 31
      chetat (31) = 768
      chtn2i (31) = 210
      chbiet (768) = 31
c
c Aretes coupees :   1  2  3  4  6
      chclas (47) = ' 5-11'
c Code des aretes coupees : 1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0
      charde (47)(1:15) = '  1  2  3  4  6'
      chnp1 (47) = 1
      chnar (47) = 16
      chnpy (47) = 11
      chnte (47) = 6
      chnhe (47) = 0
      chperm (47) = 221
      chbirf (47) = 31
      chetat (47) = 769
      chtn2i (47) = 210
      chbiet (769) = 47
c
c Aretes coupees :   1  2  3  4  7
      chclas (79) = ' 5-11'
c Code des aretes coupees : 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0
      charde (79)(1:15) = '  1  2  3  4  7'
      chnp1 (79) = 1
      chnar (79) = 16
      chnpy (79) = 11
      chnte (79) = 6
      chnhe (79) = 0
      chperm (79) = 1
      chbirf (79) = 31
      chetat (79) = 770
      chtn2i (79) = 210
      chbiet (770) = 79
c
c Aretes coupees :   1  2  3  4  8
      chclas (143) = ' 5-11'
c Code des aretes coupees : 1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0
      charde (143)(1:15) = '  1  2  3  4  8'
      chnp1 (143) = 1
      chnar (143) = 16
      chnpy (143) = 11
      chnte (143) = 6
      chnhe (143) = 0
      chperm (143) = 220
      chbirf (143) = 31
      chetat (143) = 771
      chtn2i (143) = 210
      chbiet (771) = 143
c
c Aretes coupees :   1  2  5  6  9
      chclas (307) = ' 5-11'
c Code des aretes coupees : 1, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0
      charde (307)(1:15) = '  1  2  5  6  9'
      chnp1 (307) = 1
      chnar (307) = 16
      chnpy (307) = 11
      chnte (307) = 6
      chnhe (307) = 0
      chperm (307) = 101
      chbirf (307) = 31
      chetat (307) = 772
      chtn2i (307) = 210
      chbiet (772) = 307
c
c Aretes coupees :   1  2  5  7 10
      chclas (595) = ' 5-11'
c Code des aretes coupees : 1, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0
      charde (595)(1:15) = '  1  2  5  7 10'
      chnp1 (595) = 1
      chnar (595) = 16
      chnpy (595) = 11
      chnte (595) = 6
      chnhe (595) = 0
      chperm (595) = 330
      chbirf (595) = 31
      chetat (595) = 773
      chtn2i (595) = 210
      chbiet (773) = 595
c
c Aretes coupees :   1  3  5  6  9
      chclas (309) = ' 5-11'
c Code des aretes coupees : 1, 0, 1, 0, 1, 1, 0, 0, 1, 0, 0, 0
      charde (309)(1:15) = '  1  3  5  6  9'
      chnp1 (309) = 1
      chnar (309) = 16
      chnpy (309) = 11
      chnte (309) = 6
      chnhe (309) = 0
      chperm (309) = 320
      chbirf (309) = 31
      chetat (309) = 774
      chtn2i (309) = 210
      chbiet (774) = 309
c
c Aretes coupees :   1  3  6  8 11
      chclas (1189) = ' 5-11'
c Code des aretes coupees : 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0
      charde (1189)(1:15) = '  1  3  6  8 11'
      chnp1 (1189) = 1
      chnar (1189) = 16
      chnpy (1189) = 11
      chnte (1189) = 6
      chnhe (1189) = 0
      chperm (1189) = 10
      chbirf (1189) = 31
      chetat (1189) = 775
      chtn2i (1189) = 210
      chbiet (775) = 1189
c
c Aretes coupees :   1  5  6  9 10
      chclas (817) = ' 5-11'
c Code des aretes coupees : 1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0
      charde (817)(1:15) = '  1  5  6  9 10'
      chnp1 (817) = 1
      chnar (817) = 16
      chnpy (817) = 11
      chnte (817) = 6
      chnhe (817) = 0
      chperm (817) = 100
      chbirf (817) = 31
      chetat (817) = 776
      chtn2i (817) = 210
      chbiet (776) = 817
c
c Aretes coupees :   1  5  6  9 11
      chclas (1329) = ' 5-11'
c Code des aretes coupees : 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0
      charde (1329)(1:15) = '  1  5  6  9 11'
      chnp1 (1329) = 1
      chnar (1329) = 16
      chnpy (1329) = 11
      chnte (1329) = 6
      chnhe (1329) = 0
      chperm (1329) = 321
      chbirf (1329) = 31
      chetat (1329) = 777
      chtn2i (1329) = 210
      chbiet (777) = 1329
c
c Aretes coupees :   2  4  5  7 10
      chclas (602) = ' 5-11'
c Code des aretes coupees : 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0
      charde (602)(1:15) = '  2  4  5  7 10'
      chnp1 (602) = 1
      chnar (602) = 16
      chnpy (602) = 11
      chnte (602) = 6
      chnhe (602) = 0
      chperm (602) = 230
      chbirf (602) = 31
      chetat (602) = 778
      chtn2i (602) = 210
      chbiet (778) = 602
c
c Aretes coupees :   2  4  7  8 12
      chclas (2250) = ' 5-11'
c Code des aretes coupees : 0, 1, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1
      charde (2250)(1:15) = '  2  4  7  8 12'
      chnp1 (2250) = 1
      chnar (2250) = 16
      chnpy (2250) = 11
      chnte (2250) = 6
      chnhe (2250) = 0
      chperm (2250) = 300
      chbirf (2250) = 31
      chetat (2250) = 779
      chtn2i (2250) = 210
      chbiet (779) = 2250
c
c Aretes coupees :   2  5  7  9 10
      chclas (850) = ' 5-11'
c Code des aretes coupees : 0, 1, 0, 0, 1, 0, 1, 0, 1, 1, 0, 0
      charde (850)(1:15) = '  2  5  7  9 10'
      chnp1 (850) = 1
      chnar (850) = 16
      chnpy (850) = 11
      chnte (850) = 6
      chnhe (850) = 0
      chperm (850) = 30
      chbirf (850) = 31
      chetat (850) = 780
      chtn2i (850) = 210
      chbiet (780) = 850
c
c Aretes coupees :   2  5  7 10 12
      chclas (2642) = ' 5-11'
c Code des aretes coupees : 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1
      charde (2642)(1:15) = '  2  5  7 10 12'
      chnp1 (2642) = 1
      chnar (2642) = 16
      chnpy (2642) = 11
      chnte (2642) = 6
      chnhe (2642) = 0
      chperm (2642) = 130
      chbirf (2642) = 31
      chetat (2642) = 781
      chtn2i (2642) = 210
      chbiet (781) = 2642
c
c Aretes coupees :   3  4  6  8 11
      chclas (1196) = ' 5-11'
c Code des aretes coupees : 0, 0, 1, 1, 0, 1, 0, 1, 0, 0, 1, 0
      charde (1196)(1:15) = '  3  4  6  8 11'
      chnp1 (1196) = 1
      chnar (1196) = 16
      chnpy (1196) = 11
      chnte (1196) = 6
      chnhe (1196) = 0
      chperm (1196) = 310
      chbirf (1196) = 31
      chetat (1196) = 782
      chtn2i (1196) = 210
      chbiet (782) = 1196
c
c Aretes coupees :   3  4  7  8 12
      chclas (2252) = ' 5-11'
c Code des aretes coupees : 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 1
      charde (2252)(1:15) = '  3  4  7  8 12'
      chnp1 (2252) = 1
      chnar (2252) = 16
      chnpy (2252) = 11
      chnte (2252) = 6
      chnhe (2252) = 0
      chperm (2252) = 121
      chbirf (2252) = 31
      chetat (2252) = 783
      chtn2i (2252) = 210
      chbiet (783) = 2252
c
c Aretes coupees :   3  6  8  9 11
      chclas (1444) = ' 5-11'
c Code des aretes coupees : 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0
      charde (1444)(1:15) = '  3  6  8  9 11'
      chnp1 (1444) = 1
      chnar (1444) = 16
      chnpy (1444) = 11
      chnte (1444) = 6
      chnhe (1444) = 0
      chperm (1444) = 110
      chbirf (1444) = 31
      chetat (1444) = 784
      chtn2i (1444) = 210
      chbiet (784) = 1444
c
c Aretes coupees :   3  6  8 11 12
      chclas (3236) = ' 5-11'
c Code des aretes coupees : 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 1
      charde (3236)(1:15) = '  3  6  8 11 12'
      chnp1 (3236) = 1
      chnar (3236) = 16
      chnpy (3236) = 11
      chnte (3236) = 6
      chnhe (3236) = 0
      chperm (3236) = 210
      chbirf (3236) = 31
      chetat (3236) = 785
      chtn2i (3236) = 210
      chbiet (785) = 3236
c
c Aretes coupees :   4  7  8 10 12
      chclas (2760) = ' 5-11'
c Code des aretes coupees : 0, 0, 0, 1, 0, 0, 1, 1, 0, 1, 0, 1
      charde (2760)(1:15) = '  4  7  8 10 12'
      chnp1 (2760) = 1
      chnar (2760) = 16
      chnpy (2760) = 11
      chnte (2760) = 6
      chnhe (2760) = 0
      chperm (2760) = 301
      chbirf (2760) = 31
      chetat (2760) = 786
      chtn2i (2760) = 210
      chbiet (786) = 2760
c
c Aretes coupees :   4  7  8 11 12
      chclas (3272) = ' 5-11'
c Code des aretes coupees : 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 1
      charde (3272)(1:15) = '  4  7  8 11 12'
      chnp1 (3272) = 1
      chnar (3272) = 16
      chnpy (3272) = 11
      chnte (3272) = 6
      chnhe (3272) = 0
      chperm (3272) = 120
      chbirf (3272) = 31
      chetat (3272) = 787
      chtn2i (3272) = 210
      chbiet (787) = 3272
c
c Aretes coupees :   5  9 10 11 12
      chclas (3856) = ' 5-11'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 1
      charde (3856)(1:15) = '  5  9 10 11 12'
      chnp1 (3856) = 1
      chnar (3856) = 16
      chnpy (3856) = 11
      chnte (3856) = 6
      chnhe (3856) = 0
      chperm (3856) = 201
      chbirf (3856) = 31
      chetat (3856) = 788
      chtn2i (3856) = 210
      chbiet (788) = 3856
c
c Aretes coupees :   6  9 10 11 12
      chclas (3872) = ' 5-11'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1
      charde (3872)(1:15) = '  6  9 10 11 12'
      chnp1 (3872) = 1
      chnar (3872) = 16
      chnpy (3872) = 11
      chnte (3872) = 6
      chnhe (3872) = 0
      chperm (3872) = 20
      chbirf (3872) = 31
      chetat (3872) = 789
      chtn2i (3872) = 210
      chbiet (789) = 3872
c
c Aretes coupees :   7  9 10 11 12
      chclas (3904) = ' 5-11'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1
      charde (3904)(1:15) = '  7  9 10 11 12'
      chnp1 (3904) = 1
      chnar (3904) = 16
      chnpy (3904) = 11
      chnte (3904) = 6
      chnhe (3904) = 0
      chperm (3904) = 200
      chbirf (3904) = 31
      chetat (3904) = 790
      chtn2i (3904) = 210
      chbiet (790) = 3904
c
c Aretes coupees :   8  9 10 11 12
      chclas (3968) = ' 5-11'
c Code des aretes coupees : 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1
      charde (3968)(1:15) = '  8  9 10 11 12'
      chnp1 (3968) = 1
      chnar (3968) = 16
      chnpy (3968) = 11
      chnte (3968) = 6
      chnhe (3968) = 0
      chperm (3968) = 21
      chbirf (3968) = 31
      chetat (3968) = 791
      chtn2i (3968) = 210
      chbiet (791) = 3968
c
c ===========================================
c Classe d'equivalence  5-12
c
c Aretes coupees :   1  2  3  4  9
      chclas (271) = ' 5-12'
c Code des aretes coupees : 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0
      charde (271)(1:15) = '  1  2  3  4  9'
      chnp1 (271) = 1
      chnar (271) = 14
      chnpy (271) = 6
      chnte (271) = 12
      chnhe (271) = 0
      chperm (271) = 0
      chbirf (271) = 271
      chetat (271) = 792
      chtn2i (271) = 210
      chbiet (792) = 271
c
c Aretes coupees :   1  2  3  4 10
      chclas (527) = ' 5-12'
c Code des aretes coupees : 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0
      charde (527)(1:15) = '  1  2  3  4 10'
      chnp1 (527) = 1
      chnar (527) = 14
      chnpy (527) = 6
      chnte (527) = 12
      chnhe (527) = 0
      chperm (527) = 1
      chbirf (527) = 271
      chetat (527) = 793
      chtn2i (527) = 210
      chbiet (793) = 527
c
c Aretes coupees :   1  2  3  4 11
      chclas (1039) = ' 5-12'
c Code des aretes coupees : 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0
      charde (1039)(1:15) = '  1  2  3  4 11'
      chnp1 (1039) = 1
      chnar (1039) = 14
      chnpy (1039) = 6
      chnte (1039) = 12
      chnhe (1039) = 0
      chperm (1039) = 221
      chbirf (1039) = 271
      chetat (1039) = 794
      chtn2i (1039) = 210
      chbiet (794) = 1039
c
c Aretes coupees :   1  2  3  4 12
      chclas (2063) = ' 5-12'
c Code des aretes coupees : 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1
      charde (2063)(1:15) = '  1  2  3  4 12'
      chnp1 (2063) = 1
      chnar (2063) = 14
      chnpy (2063) = 6
      chnte (2063) = 12
      chnhe (2063) = 0
      chperm (2063) = 220
      chbirf (2063) = 271
      chetat (2063) = 795
      chtn2i (2063) = 210
      chbiet (795) = 2063
c
c Aretes coupees :   1  4  5  6  9
      chclas (313) = ' 5-12'
c Code des aretes coupees : 1, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 0
      charde (313)(1:15) = '  1  4  5  6  9'
      chnp1 (313) = 1
      chnar (313) = 14
      chnpy (313) = 6
      chnte (313) = 12
      chnhe (313) = 0
      chperm (313) = 320
      chbirf (313) = 271
      chetat (313) = 796
      chtn2i (313) = 210
      chbiet (796) = 313
c
c Aretes coupees :   1  4  7  8 12
      chclas (2249) = ' 5-12'
c Code des aretes coupees : 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1
      charde (2249)(1:15) = '  1  4  7  8 12'
      chnp1 (2249) = 1
      chnar (2249) = 14
      chnpy (2249) = 6
      chnte (2249) = 12
      chnhe (2249) = 0
      chperm (2249) = 300
      chbirf (2249) = 271
      chetat (2249) = 797
      chtn2i (2249) = 210
      chbiet (797) = 2249
c
c Aretes coupees :   1  5  6  7  9
      chclas (369) = ' 5-12'
c Code des aretes coupees : 1, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0
      charde (369)(1:15) = '  1  5  6  7  9'
      chnp1 (369) = 1
      chnar (369) = 14
      chnpy (369) = 6
      chnte (369) = 12
      chnhe (369) = 0
      chperm (369) = 101
      chbirf (369) = 271
      chetat (369) = 798
      chtn2i (369) = 210
      chbiet (798) = 369
c
c Aretes coupees :   1  5  6  8  9
      chclas (433) = ' 5-12'
c Code des aretes coupees : 1, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0
      charde (433)(1:15) = '  1  5  6  8  9'
      chnp1 (433) = 1
      chnar (433) = 14
      chnpy (433) = 6
      chnte (433) = 12
      chnhe (433) = 0
      chperm (433) = 321
      chbirf (433) = 271
      chetat (433) = 799
      chtn2i (433) = 210
      chbiet (799) = 433
c
c Aretes coupees :   1  5  6  9 12
      chclas (2353) = ' 5-12'
c Code des aretes coupees : 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1
      charde (2353)(1:15) = '  1  5  6  9 12'
      chnp1 (2353) = 1
      chnar (2353) = 14
      chnpy (2353) = 6
      chnte (2353) = 12
      chnhe (2353) = 0
      chperm (2353) = 100
      chbirf (2353) = 271
      chetat (2353) = 800
      chtn2i (2353) = 210
      chbiet (800) = 2353
c
c Aretes coupees :   1  9 10 11 12
      chclas (3841) = ' 5-12'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1
      charde (3841)(1:15) = '  1  9 10 11 12'
      chnp1 (3841) = 1
      chnar (3841) = 14
      chnpy (3841) = 6
      chnte (3841) = 12
      chnhe (3841) = 0
      chperm (3841) = 20
      chbirf (3841) = 271
      chetat (3841) = 801
      chtn2i (3841) = 210
      chbiet (801) = 3841
c
c Aretes coupees :   2  3  5  7 10
      chclas (598) = ' 5-12'
c Code des aretes coupees : 0, 1, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0
      charde (598)(1:15) = '  2  3  5  7 10'
      chnp1 (598) = 1
      chnar (598) = 14
      chnpy (598) = 6
      chnte (598) = 12
      chnhe (598) = 0
      chperm (598) = 330
      chbirf (598) = 271
      chetat (598) = 802
      chtn2i (598) = 210
      chbiet (802) = 598
c
c Aretes coupees :   2  3  6  8 11
      chclas (1190) = ' 5-12'
c Code des aretes coupees : 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0
      charde (1190)(1:15) = '  2  3  6  8 11'
      chnp1 (1190) = 1
      chnar (1190) = 14
      chnpy (1190) = 6
      chnte (1190) = 12
      chnhe (1190) = 0
      chperm (1190) = 310
      chbirf (1190) = 271
      chetat (1190) = 803
      chtn2i (1190) = 210
      chbiet (803) = 1190
c
c Aretes coupees :   2  5  6  7 10
      chclas (626) = ' 5-12'
c Code des aretes coupees : 0, 1, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0
      charde (626)(1:15) = '  2  5  6  7 10'
      chnp1 (626) = 1
      chnar (626) = 14
      chnpy (626) = 6
      chnte (626) = 12
      chnhe (626) = 0
      chperm (626) = 30
      chbirf (626) = 271
      chetat (626) = 804
      chtn2i (626) = 210
      chbiet (804) = 626
c
c Aretes coupees :   2  5  7  8 10
      chclas (722) = ' 5-12'
c Code des aretes coupees : 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0
      charde (722)(1:15) = '  2  5  7  8 10'
      chnp1 (722) = 1
      chnar (722) = 14
      chnpy (722) = 6
      chnte (722) = 12
      chnhe (722) = 0
      chperm (722) = 230
      chbirf (722) = 271
      chetat (722) = 805
      chtn2i (722) = 210
      chbiet (805) = 722
c
c Aretes coupees :   2  5  7 10 11
      chclas (1618) = ' 5-12'
c Code des aretes coupees : 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0
      charde (1618)(1:15) = '  2  5  7 10 11'
      chnp1 (1618) = 1
      chnar (1618) = 14
      chnpy (1618) = 6
      chnte (1618) = 12
      chnhe (1618) = 0
      chperm (1618) = 130
      chbirf (1618) = 271
      chetat (1618) = 806
      chtn2i (1618) = 210
      chbiet (806) = 1618
c
c Aretes coupees :   2  9 10 11 12
      chclas (3842) = ' 5-12'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1
      charde (3842)(1:15) = '  2  9 10 11 12'
      chnp1 (3842) = 1
      chnar (3842) = 14
      chnpy (3842) = 6
      chnte (3842) = 12
      chnhe (3842) = 0
      chperm (3842) = 201
      chbirf (3842) = 271
      chetat (3842) = 807
      chtn2i (3842) = 210
      chbiet (807) = 3842
c
c Aretes coupees :   3  5  6  8 11
      chclas (1204) = ' 5-12'
c Code des aretes coupees : 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0
      charde (1204)(1:15) = '  3  5  6  8 11'
      chnp1 (1204) = 1
      chnar (1204) = 14
      chnpy (1204) = 6
      chnte (1204) = 12
      chnhe (1204) = 0
      chperm (1204) = 10
      chbirf (1204) = 271
      chetat (1204) = 808
      chtn2i (1204) = 210
      chbiet (808) = 1204
c
c Aretes coupees :   3  6  7  8 11
      chclas (1252) = ' 5-12'
c Code des aretes coupees : 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 1, 0
      charde (1252)(1:15) = '  3  6  7  8 11'
      chnp1 (1252) = 1
      chnar (1252) = 14
      chnpy (1252) = 6
      chnte (1252) = 12
      chnhe (1252) = 0
      chperm (1252) = 210
      chbirf (1252) = 271
      chetat (1252) = 809
      chtn2i (1252) = 210
      chbiet (809) = 1252
c
c Aretes coupees :   3  6  8 10 11
      chclas (1700) = ' 5-12'
c Code des aretes coupees : 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 1, 0
      charde (1700)(1:15) = '  3  6  8 10 11'
      chnp1 (1700) = 1
      chnar (1700) = 14
      chnpy (1700) = 6
      chnte (1700) = 12
      chnhe (1700) = 0
      chperm (1700) = 110
      chbirf (1700) = 271
      chetat (1700) = 810
      chtn2i (1700) = 210
      chbiet (810) = 1700
c
c Aretes coupees :   3  9 10 11 12
      chclas (3844) = ' 5-12'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1
      charde (3844)(1:15) = '  3  9 10 11 12'
      chnp1 (3844) = 1
      chnar (3844) = 14
      chnpy (3844) = 6
      chnte (3844) = 12
      chnhe (3844) = 0
      chperm (3844) = 21
      chbirf (3844) = 271
      chetat (3844) = 811
      chtn2i (3844) = 210
      chbiet (811) = 3844
c
c Aretes coupees :   4  5  7  8 12
      chclas (2264) = ' 5-12'
c Code des aretes coupees : 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 1
      charde (2264)(1:15) = '  4  5  7  8 12'
      chnp1 (2264) = 1
      chnar (2264) = 14
      chnpy (2264) = 6
      chnte (2264) = 12
      chnhe (2264) = 0
      chperm (2264) = 301
      chbirf (2264) = 271
      chetat (2264) = 812
      chtn2i (2264) = 210
      chbiet (812) = 2264
c
c Aretes coupees :   4  6  7  8 12
      chclas (2280) = ' 5-12'
c Code des aretes coupees : 0, 0, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1
      charde (2280)(1:15) = '  4  6  7  8 12'
      chnp1 (2280) = 1
      chnar (2280) = 14
      chnpy (2280) = 6
      chnte (2280) = 12
      chnhe (2280) = 0
      chperm (2280) = 121
      chbirf (2280) = 271
      chetat (2280) = 813
      chtn2i (2280) = 210
      chbiet (813) = 2280
c
c Aretes coupees :   4  7  8  9 12
      chclas (2504) = ' 5-12'
c Code des aretes coupees : 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 1
      charde (2504)(1:15) = '  4  7  8  9 12'
      chnp1 (2504) = 1
      chnar (2504) = 14
      chnpy (2504) = 6
      chnte (2504) = 12
      chnhe (2504) = 0
      chperm (2504) = 120
      chbirf (2504) = 271
      chetat (2504) = 814
      chtn2i (2504) = 210
      chbiet (814) = 2504
c
c Aretes coupees :   4  9 10 11 12
      chclas (3848) = ' 5-12'
c Code des aretes coupees : 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1
      charde (3848)(1:15) = '  4  9 10 11 12'
      chnp1 (3848) = 1
      chnar (3848) = 14
      chnpy (3848) = 6
      chnte (3848) = 12
      chnhe (3848) = 0
      chperm (3848) = 200
      chbirf (3848) = 271
      chetat (3848) = 815
      chtn2i (3848) = 210
      chbiet (815) = 3848
c
c ===========================================
c Classe d'equivalence  6-00
c
c Aretes coupees :   1  2  5  8 11 12
      chclas (3219) = ' 6-00'
c Code des aretes coupees : 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1
      charde (3219)(1:18) = '  1  2  5  8 11 12'
      chnp1 (3219) = 1
      chnar (3219) = 20
      chnpy (3219) = 18
      chnte (3219) = 0
      chnhe (3219) = 0
      chperm (3219) = 0
      chbirf (3219) = 3219
      chetat (3219) = 816
      chtn2i (3219) = 210
      chbiet (816) = 3219
c
c Aretes coupees :   1  3  6  7 10 12
      chclas (2661) = ' 6-00'
c Code des aretes coupees : 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1
      charde (2661)(1:18) = '  1  3  6  7 10 12'
      chnp1 (2661) = 1
      chnar (2661) = 20
      chnpy (2661) = 18
      chnte (2661) = 0
      chnhe (2661) = 0
      chperm (2661) = 200
      chbirf (2661) = 3219
      chetat (2661) = 817
      chtn2i (2661) = 210
      chbiet (817) = 2661
c
c Aretes coupees :   2  4  6  7  9 11
      chclas (1386) = ' 6-00'
c Code des aretes coupees : 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0
      charde (1386)(1:18) = '  2  4  6  7  9 11'
      chnp1 (1386) = 1
      chnar (1386) = 20
      chnpy (1386) = 18
      chnte (1386) = 0
      chnhe (1386) = 0
      chperm (1386) = 300
      chbirf (1386) = 3219
      chetat (1386) = 818
      chtn2i (1386) = 210
      chbiet (818) = 1386
c
c Aretes coupees :   3  4  5  8  9 10
      chclas (924) = ' 6-00'
c Code des aretes coupees : 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0
      charde (924)(1:18) = '  3  4  5  8  9 10'
      chnp1 (924) = 1
      chnar (924) = 20
      chnpy (924) = 18
      chnte (924) = 0
      chnhe (924) = 0
      chperm (924) = 100
      chbirf (924) = 3219
      chetat (924) = 819
      chtn2i (924) = 210
      chbiet (819) = 924
c
c ===========================================
c Classe d'equivalence  6-01
c
c Aretes coupees :   1  2  3  4  9 10
      chclas (783) = ' 6-01'
c Code des aretes coupees : 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0
      charde (783)(1:18) = '  1  2  3  4  9 10'
      chnp1 (783) = 1
      chnar (783) = 16
      chnpy (783) = 11
      chnte (783) = 6
      chnhe (783) = 0
      chperm (783) = 0
      chbirf (783) = 783
      chetat (783) = 820
      chtn2i (783) = 210
      chbiet (820) = 783
c
c Aretes coupees :   1  2  3  4  9 11
      chclas (1295) = ' 6-01'
c Code des aretes coupees : 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 1, 0
      charde (1295)(1:18) = '  1  2  3  4  9 11'
      chnp1 (1295) = 1
      chnar (1295) = 16
      chnpy (1295) = 11
      chnte (1295) = 6
      chnhe (1295) = 0
      chperm (1295) = 221
      chbirf (1295) = 783
      chetat (1295) = 821
      chtn2i (1295) = 210
      chbiet (821) = 1295
c
c Aretes coupees :   1  2  3  4 10 12
      chclas (2575) = ' 6-01'
c Code des aretes coupees : 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1
      charde (2575)(1:18) = '  1  2  3  4 10 12'
      chnp1 (2575) = 1
      chnar (2575) = 16
      chnpy (2575) = 11
      chnte (2575) = 6
      chnhe (2575) = 0
      chperm (2575) = 1
      chbirf (2575) = 783
      chetat (2575) = 822
      chtn2i (2575) = 210
      chbiet (822) = 2575
c
c Aretes coupees :   1  2  3  4 11 12
      chclas (3087) = ' 6-01'
c Code des aretes coupees : 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1
      charde (3087)(1:18) = '  1  2  3  4 11 12'
      chnp1 (3087) = 1
      chnar (3087) = 16
      chnpy (3087) = 11
      chnte (3087) = 6
      chnhe (3087) = 0
      chperm (3087) = 220
      chbirf (3087) = 783
      chetat (3087) = 823
      chtn2i (3087) = 210
      chbiet (823) = 3087
c
c Aretes coupees :   1  2  9 10 11 12
      chclas (3843) = ' 6-01'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1
      charde (3843)(1:18) = '  1  2  9 10 11 12'
      chnp1 (3843) = 1
      chnar (3843) = 16
      chnpy (3843) = 11
      chnte (3843) = 6
      chnhe (3843) = 0
      chperm (3843) = 201
      chbirf (3843) = 783
      chetat (3843) = 824
      chtn2i (3843) = 210
      chbiet (824) = 3843
c
c Aretes coupees :   1  3  9 10 11 12
      chclas (3845) = ' 6-01'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1
      charde (3845)(1:18) = '  1  3  9 10 11 12'
      chnp1 (3845) = 1
      chnar (3845) = 16
      chnpy (3845) = 11
      chnte (3845) = 6
      chnhe (3845) = 0
      chperm (3845) = 20
      chbirf (3845) = 783
      chetat (3845) = 825
      chtn2i (3845) = 210
      chbiet (825) = 3845
c
c Aretes coupees :   1  4  5  6  7  9
      chclas (377) = ' 6-01'
c Code des aretes coupees : 1, 0, 0, 1, 1, 1, 1, 0, 1, 0, 0, 0
      charde (377)(1:18) = '  1  4  5  6  7  9'
      chnp1 (377) = 1
      chnar (377) = 16
      chnpy (377) = 11
      chnte (377) = 6
      chnhe (377) = 0
      chperm (377) = 101
      chbirf (377) = 783
      chetat (377) = 826
      chtn2i (377) = 210
      chbiet (826) = 377
c
c Aretes coupees :   1  4  5  6  8  9
      chclas (441) = ' 6-01'
c Code des aretes coupees : 1, 0, 0, 1, 1, 1, 0, 1, 1, 0, 0, 0
      charde (441)(1:18) = '  1  4  5  6  8  9'
      chnp1 (441) = 1
      chnar (441) = 16
      chnpy (441) = 11
      chnte (441) = 6
      chnhe (441) = 0
      chperm (441) = 320
      chbirf (441) = 783
      chetat (441) = 827
      chtn2i (441) = 210
      chbiet (827) = 441
c
c Aretes coupees :   1  4  5  7  8 12
      chclas (2265) = ' 6-01'
c Code des aretes coupees : 1, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 1
      charde (2265)(1:18) = '  1  4  5  7  8 12'
      chnp1 (2265) = 1
      chnar (2265) = 16
      chnpy (2265) = 11
      chnte (2265) = 6
      chnhe (2265) = 0
      chperm (2265) = 300
      chbirf (2265) = 783
      chetat (2265) = 828
      chtn2i (2265) = 210
      chbiet (828) = 2265
c
c Aretes coupees :   1  4  6  7  8 12
      chclas (2281) = ' 6-01'
c Code des aretes coupees : 1, 0, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1
      charde (2281)(1:18) = '  1  4  6  7  8 12'
      chnp1 (2281) = 1
      chnar (2281) = 16
      chnpy (2281) = 11
      chnte (2281) = 6
      chnhe (2281) = 0
      chperm (2281) = 121
      chbirf (2281) = 783
      chetat (2281) = 829
      chtn2i (2281) = 210
      chbiet (829) = 2281
c
c Aretes coupees :   1  5  6  7  9 12
      chclas (2417) = ' 6-01'
c Code des aretes coupees : 1, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0, 1
      charde (2417)(1:18) = '  1  5  6  7  9 12'
      chnp1 (2417) = 1
      chnar (2417) = 16
      chnpy (2417) = 11
      chnte (2417) = 6
      chnhe (2417) = 0
      chperm (2417) = 100
      chbirf (2417) = 783
      chetat (2417) = 830
      chtn2i (2417) = 210
      chbiet (830) = 2417
c
c Aretes coupees :   1  5  6  8  9 12
      chclas (2481) = ' 6-01'
c Code des aretes coupees : 1, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1
      charde (2481)(1:18) = '  1  5  6  8  9 12'
      chnp1 (2481) = 1
      chnar (2481) = 16
      chnpy (2481) = 11
      chnte (2481) = 6
      chnhe (2481) = 0
      chperm (2481) = 321
      chbirf (2481) = 783
      chetat (2481) = 831
      chtn2i (2481) = 210
      chbiet (831) = 2481
c
c Aretes coupees :   2  3  5  6  7 10
      chclas (630) = ' 6-01'
c Code des aretes coupees : 0, 1, 1, 0, 1, 1, 1, 0, 0, 1, 0, 0
      charde (630)(1:18) = '  2  3  5  6  7 10'
      chnp1 (630) = 1
      chnar (630) = 16
      chnpy (630) = 11
      chnte (630) = 6
      chnhe (630) = 0
      chperm (630) = 330
      chbirf (630) = 783
      chetat (630) = 832
      chtn2i (630) = 210
      chbiet (832) = 630
c
c Aretes coupees :   2  3  5  6  8 11
      chclas (1206) = ' 6-01'
c Code des aretes coupees : 0, 1, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0
      charde (1206)(1:18) = '  2  3  5  6  8 11'
      chnp1 (1206) = 1
      chnar (1206) = 16
      chnpy (1206) = 11
      chnte (1206) = 6
      chnhe (1206) = 0
      chperm (1206) = 10
      chbirf (1206) = 783
      chetat (1206) = 833
      chtn2i (1206) = 210
      chbiet (833) = 1206
c
c Aretes coupees :   2  3  5  7  8 10
      chclas (726) = ' 6-01'
c Code des aretes coupees : 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 0
      charde (726)(1:18) = '  2  3  5  7  8 10'
      chnp1 (726) = 1
      chnar (726) = 16
      chnpy (726) = 11
      chnte (726) = 6
      chnhe (726) = 0
      chperm (726) = 230
      chbirf (726) = 783
      chetat (726) = 834
      chtn2i (726) = 210
      chbiet (834) = 726
c
c Aretes coupees :   2  3  6  7  8 11
      chclas (1254) = ' 6-01'
c Code des aretes coupees : 0, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 0
      charde (1254)(1:18) = '  2  3  6  7  8 11'
      chnp1 (1254) = 1
      chnar (1254) = 16
      chnpy (1254) = 11
      chnte (1254) = 6
      chnhe (1254) = 0
      chperm (1254) = 310
      chbirf (1254) = 783
      chetat (1254) = 835
      chtn2i (1254) = 210
      chbiet (835) = 1254
c
c Aretes coupees :   2  4  9 10 11 12
      chclas (3850) = ' 6-01'
c Code des aretes coupees : 0, 1, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1
      charde (3850)(1:18) = '  2  4  9 10 11 12'
      chnp1 (3850) = 1
      chnar (3850) = 16
      chnpy (3850) = 11
      chnte (3850) = 6
      chnhe (3850) = 0
      chperm (3850) = 200
      chbirf (3850) = 783
      chetat (3850) = 836
      chtn2i (3850) = 210
      chbiet (836) = 3850
c
c Aretes coupees :   2  5  6  7 10 11
      chclas (1650) = ' 6-01'
c Code des aretes coupees : 0, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 0
      charde (1650)(1:18) = '  2  5  6  7 10 11'
      chnp1 (1650) = 1
      chnar (1650) = 16
      chnpy (1650) = 11
      chnte (1650) = 6
      chnhe (1650) = 0
      chperm (1650) = 30
      chbirf (1650) = 783
      chetat (1650) = 837
      chtn2i (1650) = 210
      chbiet (837) = 1650
c
c Aretes coupees :   2  5  7  8 10 11
      chclas (1746) = ' 6-01'
c Code des aretes coupees : 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1, 0
      charde (1746)(1:18) = '  2  5  7  8 10 11'
      chnp1 (1746) = 1
      chnar (1746) = 16
      chnpy (1746) = 11
      chnte (1746) = 6
      chnhe (1746) = 0
      chperm (1746) = 130
      chbirf (1746) = 783
      chetat (1746) = 838
      chtn2i (1746) = 210
      chbiet (838) = 1746
c
c Aretes coupees :   3  4  9 10 11 12
      chclas (3852) = ' 6-01'
c Code des aretes coupees : 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1
      charde (3852)(1:18) = '  3  4  9 10 11 12'
      chnp1 (3852) = 1
      chnar (3852) = 16
      chnpy (3852) = 11
      chnte (3852) = 6
      chnhe (3852) = 0
      chperm (3852) = 21
      chbirf (3852) = 783
      chetat (3852) = 839
      chtn2i (3852) = 210
      chbiet (839) = 3852
c
c Aretes coupees :   3  5  6  8 10 11
      chclas (1716) = ' 6-01'
c Code des aretes coupees : 0, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0
      charde (1716)(1:18) = '  3  5  6  8 10 11'
      chnp1 (1716) = 1
      chnar (1716) = 16
      chnpy (1716) = 11
      chnte (1716) = 6
      chnhe (1716) = 0
      chperm (1716) = 110
      chbirf (1716) = 783
      chetat (1716) = 840
      chtn2i (1716) = 210
      chbiet (840) = 1716
c
c Aretes coupees :   3  6  7  8 10 11
      chclas (1764) = ' 6-01'
c Code des aretes coupees : 0, 0, 1, 0, 0, 1, 1, 1, 0, 1, 1, 0
      charde (1764)(1:18) = '  3  6  7  8 10 11'
      chnp1 (1764) = 1
      chnar (1764) = 16
      chnpy (1764) = 11
      chnte (1764) = 6
      chnhe (1764) = 0
      chperm (1764) = 210
      chbirf (1764) = 783
      chetat (1764) = 841
      chtn2i (1764) = 210
      chbiet (841) = 1764
c
c Aretes coupees :   4  5  7  8  9 12
      chclas (2520) = ' 6-01'
c Code des aretes coupees : 0, 0, 0, 1, 1, 0, 1, 1, 1, 0, 0, 1
      charde (2520)(1:18) = '  4  5  7  8  9 12'
      chnp1 (2520) = 1
      chnar (2520) = 16
      chnpy (2520) = 11
      chnte (2520) = 6
      chnhe (2520) = 0
      chperm (2520) = 301
      chbirf (2520) = 783
      chetat (2520) = 842
      chtn2i (2520) = 210
      chbiet (842) = 2520
c
c Aretes coupees :   4  6  7  8  9 12
      chclas (2536) = ' 6-01'
c Code des aretes coupees : 0, 0, 0, 1, 0, 1, 1, 1, 1, 0, 0, 1
      charde (2536)(1:18) = '  4  6  7  8  9 12'
      chnp1 (2536) = 1
      chnar (2536) = 16
      chnpy (2536) = 11
      chnte (2536) = 6
      chnhe (2536) = 0
      chperm (2536) = 120
      chbirf (2536) = 783
      chetat (2536) = 843
      chtn2i (2536) = 210
      chbiet (843) = 2536
c
c ===========================================
c Classe d'equivalence  6-02
c
c Aretes coupees :   1  2  3  4  9 12
      chclas (2319) = ' 6-02'
c Code des aretes coupees : 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 1
      charde (2319)(1:18) = '  1  2  3  4  9 12'
      chnp1 (2319) = 1
      chnar (2319) = 15
      chnpy (2319) = 10
      chnte (2319) = 6
      chnhe (2319) = 0
      chperm (2319) = 0
      chbirf (2319) = 2319
      chetat (2319) = 844
      chtn2i (2319) = 210
      chbiet (844) = 2319
c
c Aretes coupees :   1  2  3  4 10 11
      chclas (1551) = ' 6-02'
c Code des aretes coupees : 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 0
      charde (1551)(1:18) = '  1  2  3  4 10 11'
      chnp1 (1551) = 1
      chnar (1551) = 15
      chnpy (1551) = 10
      chnte (1551) = 6
      chnhe (1551) = 0
      chperm (1551) = 1
      chbirf (1551) = 2319
      chetat (1551) = 845
      chtn2i (1551) = 210
      chbiet (845) = 1551
c
c Aretes coupees :   1  4  5  6  9 12
      chclas (2361) = ' 6-02'
c Code des aretes coupees : 1, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 1
      charde (2361)(1:18) = '  1  4  5  6  9 12'
      chnp1 (2361) = 1
      chnar (2361) = 15
      chnpy (2361) = 10
      chnte (2361) = 6
      chnhe (2361) = 0
      chperm (2361) = 100
      chbirf (2361) = 2319
      chetat (2361) = 846
      chtn2i (2361) = 210
      chbiet (846) = 2361
c
c Aretes coupees :   1  4  7  8  9 12
      chclas (2505) = ' 6-02'
c Code des aretes coupees : 1, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 1
      charde (2505)(1:18) = '  1  4  7  8  9 12'
      chnp1 (2505) = 1
      chnar (2505) = 15
      chnpy (2505) = 10
      chnte (2505) = 6
      chnhe (2505) = 0
      chperm (2505) = 300
      chbirf (2505) = 2319
      chetat (2505) = 847
      chtn2i (2505) = 210
      chbiet (847) = 2505
c
c Aretes coupees :   1  4  9 10 11 12
      chclas (3849) = ' 6-02'
c Code des aretes coupees : 1, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1
      charde (3849)(1:18) = '  1  4  9 10 11 12'
      chnp1 (3849) = 1
      chnar (3849) = 15
      chnpy (3849) = 10
      chnte (3849) = 6
      chnhe (3849) = 0
      chperm (3849) = 200
      chbirf (3849) = 2319
      chetat (3849) = 848
      chtn2i (3849) = 210
      chbiet (848) = 3849
c
c Aretes coupees :   1  5  6  7  8  9
      chclas (497) = ' 6-02'
c Code des aretes coupees : 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0
      charde (497)(1:18) = '  1  5  6  7  8  9'
      chnp1 (497) = 1
      chnar (497) = 15
      chnpy (497) = 10
      chnte (497) = 6
      chnhe (497) = 0
      chperm (497) = 101
      chbirf (497) = 2319
      chetat (497) = 849
      chtn2i (497) = 210
      chbiet (849) = 497
c
c Aretes coupees :   2  3  5  7 10 11
      chclas (1622) = ' 6-02'
c Code des aretes coupees : 0, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0
      charde (1622)(1:18) = '  2  3  5  7 10 11'
      chnp1 (1622) = 1
      chnar (1622) = 15
      chnpy (1622) = 10
      chnte (1622) = 6
      chnhe (1622) = 0
      chperm (1622) = 130
      chbirf (1622) = 2319
      chetat (1622) = 850
      chtn2i (1622) = 210
      chbiet (850) = 1622
c
c Aretes coupees :   2  3  6  8 10 11
      chclas (1702) = ' 6-02'
c Code des aretes coupees : 0, 1, 1, 0, 0, 1, 0, 1, 0, 1, 1, 0
      charde (1702)(1:18) = '  2  3  6  8 10 11'
      chnp1 (1702) = 1
      chnar (1702) = 15
      chnpy (1702) = 10
      chnte (1702) = 6
      chnhe (1702) = 0
      chperm (1702) = 110
      chbirf (1702) = 2319
      chetat (1702) = 851
      chtn2i (1702) = 210
      chbiet (851) = 1702
c
c Aretes coupees :   2  3  9 10 11 12
      chclas (3846) = ' 6-02'
c Code des aretes coupees : 0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1
      charde (3846)(1:18) = '  2  3  9 10 11 12'
      chnp1 (3846) = 1
      chnar (3846) = 15
      chnpy (3846) = 10
      chnte (3846) = 6
      chnhe (3846) = 0
      chperm (3846) = 201
      chbirf (3846) = 2319
      chetat (3846) = 852
      chtn2i (3846) = 210
      chbiet (852) = 3846
c
c Aretes coupees :   2  5  6  7  8 10
      chclas (754) = ' 6-02'
c Code des aretes coupees : 0, 1, 0, 0, 1, 1, 1, 1, 0, 1, 0, 0
      charde (754)(1:18) = '  2  5  6  7  8 10'
      chnp1 (754) = 1
      chnar (754) = 15
      chnpy (754) = 10
      chnte (754) = 6
      chnhe (754) = 0
      chperm (754) = 30
      chbirf (754) = 2319
      chetat (754) = 853
      chtn2i (754) = 210
      chbiet (853) = 754
c
c Aretes coupees :   3  5  6  7  8 11
      chclas (1268) = ' 6-02'
c Code des aretes coupees : 0, 0, 1, 0, 1, 1, 1, 1, 0, 0, 1, 0
      charde (1268)(1:18) = '  3  5  6  7  8 11'
      chnp1 (1268) = 1
      chnar (1268) = 15
      chnpy (1268) = 10
      chnte (1268) = 6
      chnhe (1268) = 0
      chperm (1268) = 10
      chbirf (1268) = 2319
      chetat (1268) = 854
      chtn2i (1268) = 210
      chbiet (854) = 1268
c
c Aretes coupees :   4  5  6  7  8 12
      chclas (2296) = ' 6-02'
c Code des aretes coupees : 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1
      charde (2296)(1:18) = '  4  5  6  7  8 12'
      chnp1 (2296) = 1
      chnar (2296) = 15
      chnpy (2296) = 10
      chnte (2296) = 6
      chnhe (2296) = 0
      chperm (2296) = 301
      chbirf (2296) = 2319
      chetat (2296) = 855
      chtn2i (2296) = 210
      chbiet (855) = 2296
c
c ===========================================
c Classe d'equivalence  6-03
c
c Aretes coupees :   1  2  3  4  5 11
      chclas (1055) = ' 6-03'
c Code des aretes coupees : 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0
      charde (1055)(1:18) = '  1  2  3  4  5 11'
      chnp1 (1055) = 1
      chnar (1055) = 17
      chnpy (1055) = 12
      chnte (1055) = 6
      chnhe (1055) = 0
      chperm (1055) = 0
      chbirf (1055) = 1055
      chetat (1055) = 856
      chtn2i (1055) = 210
      chbiet (856) = 1055
c
c Aretes coupees :   1  2  3  4  6 12
      chclas (2095) = ' 6-03'
c Code des aretes coupees : 1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 1
      charde (2095)(1:18) = '  1  2  3  4  6 12'
      chnp1 (2095) = 1
      chnar (2095) = 17
      chnpy (2095) = 12
      chnte (2095) = 6
      chnhe (2095) = 0
      chperm (2095) = 221
      chbirf (2095) = 1055
      chetat (2095) = 857
      chtn2i (2095) = 210
      chbiet (857) = 2095
c
c Aretes coupees :   1  2  3  4  7  9
      chclas (335) = ' 6-03'
c Code des aretes coupees : 1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 0, 0
      charde (335)(1:18) = '  1  2  3  4  7  9'
      chnp1 (335) = 1
      chnar (335) = 17
      chnpy (335) = 12
      chnte (335) = 6
      chnhe (335) = 0
      chperm (335) = 1
      chbirf (335) = 1055
      chetat (335) = 858
      chtn2i (335) = 210
      chbiet (858) = 335
c
c Aretes coupees :   1  2  3  4  8 10
      chclas (655) = ' 6-03'
c Code des aretes coupees : 1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0
      charde (655)(1:18) = '  1  2  3  4  8 10'
      chnp1 (655) = 1
      chnar (655) = 17
      chnpy (655) = 12
      chnte (655) = 6
      chnhe (655) = 0
      chperm (655) = 220
      chbirf (655) = 1055
      chetat (655) = 859
      chtn2i (655) = 210
      chbiet (859) = 655
c
c Aretes coupees :   1  2  5  6  9 12
      chclas (2355) = ' 6-03'
c Code des aretes coupees : 1, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1
      charde (2355)(1:18) = '  1  2  5  6  9 12'
      chnp1 (2355) = 1
      chnar (2355) = 17
      chnpy (2355) = 12
      chnte (2355) = 6
      chnhe (2355) = 0
      chperm (2355) = 101
      chbirf (2355) = 1055
      chetat (2355) = 860
      chtn2i (2355) = 210
      chbiet (860) = 2355
c
c Aretes coupees :   1  2  5  7  8 10
      chclas (723) = ' 6-03'
c Code des aretes coupees : 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0
      charde (723)(1:18) = '  1  2  5  7  8 10'
      chnp1 (723) = 1
      chnar (723) = 17
      chnpy (723) = 12
      chnte (723) = 6
      chnhe (723) = 0
      chperm (723) = 330
      chbirf (723) = 1055
      chetat (723) = 861
      chtn2i (723) = 210
      chbiet (861) = 723
c
c Aretes coupees :   1  3  5  6  7  9
      chclas (373) = ' 6-03'
c Code des aretes coupees : 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 0, 0
      charde (373)(1:18) = '  1  3  5  6  7  9'
      chnp1 (373) = 1
      chnar (373) = 17
      chnpy (373) = 12
      chnte (373) = 6
      chnhe (373) = 0
      chperm (373) = 320
      chbirf (373) = 1055
      chetat (373) = 862
      chtn2i (373) = 210
      chbiet (862) = 373
c
c Aretes coupees :   1  3  6  8 10 11
      chclas (1701) = ' 6-03'
c Code des aretes coupees : 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 1, 0
      charde (1701)(1:18) = '  1  3  6  8 10 11'
      chnp1 (1701) = 1
      chnar (1701) = 17
      chnpy (1701) = 12
      chnte (1701) = 6
      chnhe (1701) = 0
      chperm (1701) = 10
      chbirf (1701) = 1055
      chetat (1701) = 863
      chtn2i (1701) = 210
      chbiet (863) = 1701
c
c Aretes coupees :   1  4  5  6  9 11
      chclas (1337) = ' 6-03'
c Code des aretes coupees : 1, 0, 0, 1, 1, 1, 0, 0, 1, 0, 1, 0
      charde (1337)(1:18) = '  1  4  5  6  9 11'
      chnp1 (1337) = 1
      chnar (1337) = 17
      chnpy (1337) = 12
      chnte (1337) = 6
      chnhe (1337) = 0
      chperm (1337) = 321
      chbirf (1337) = 1055
      chetat (1337) = 864
      chtn2i (1337) = 210
      chbiet (864) = 1337
c
c Aretes coupees :   1  4  7  8 10 12
      chclas (2761) = ' 6-03'
c Code des aretes coupees : 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 0, 1
      charde (2761)(1:18) = '  1  4  7  8 10 12'
      chnp1 (2761) = 1
      chnar (2761) = 17
      chnpy (2761) = 12
      chnte (2761) = 6
      chnhe (2761) = 0
      chperm (2761) = 301
      chbirf (2761) = 1055
      chetat (2761) = 865
      chtn2i (2761) = 210
      chbiet (865) = 2761
c
c Aretes coupees :   1  5  6  8  9 10
      chclas (945) = ' 6-03'
c Code des aretes coupees : 1, 0, 0, 0, 1, 1, 0, 1, 1, 1, 0, 0
      charde (945)(1:18) = '  1  5  6  8  9 10'
      chnp1 (945) = 1
      chnar (945) = 17
      chnpy (945) = 12
      chnte (945) = 6
      chnhe (945) = 0
      chperm (945) = 100
      chbirf (945) = 1055
      chetat (945) = 866
      chtn2i (945) = 210
      chbiet (866) = 945
c
c Aretes coupees :   1  8  9 10 11 12
      chclas (3969) = ' 6-03'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1
      charde (3969)(1:18) = '  1  8  9 10 11 12'
      chnp1 (3969) = 1
      chnar (3969) = 17
      chnpy (3969) = 12
      chnte (3969) = 6
      chnhe (3969) = 0
      chperm (3969) = 21
      chbirf (3969) = 1055
      chetat (3969) = 867
      chtn2i (3969) = 210
      chbiet (867) = 3969
c
c Aretes coupees :   2  3  5  7  9 10
      chclas (854) = ' 6-03'
c Code des aretes coupees : 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 0
      charde (854)(1:18) = '  2  3  5  7  9 10'
      chnp1 (854) = 1
      chnar (854) = 17
      chnpy (854) = 12
      chnte (854) = 6
      chnhe (854) = 0
      chperm (854) = 30
      chbirf (854) = 1055
      chetat (854) = 868
      chtn2i (854) = 210
      chbiet (868) = 854
c
c Aretes coupees :   2  3  6  8 11 12
      chclas (3238) = ' 6-03'
c Code des aretes coupees : 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 1, 1
      charde (3238)(1:18) = '  2  3  6  8 11 12'
      chnp1 (3238) = 1
      chnar (3238) = 17
      chnpy (3238) = 12
      chnte (3238) = 6
      chnhe (3238) = 0
      chperm (3238) = 210
      chbirf (3238) = 1055
      chetat (3238) = 869
      chtn2i (3238) = 210
      chbiet (869) = 3238
c
c Aretes coupees :   2  4  5  7 10 11
      chclas (1626) = ' 6-03'
c Code des aretes coupees : 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0
      charde (1626)(1:18) = '  2  4  5  7 10 11'
      chnp1 (1626) = 1
      chnar (1626) = 17
      chnpy (1626) = 12
      chnte (1626) = 6
      chnhe (1626) = 0
      chperm (1626) = 230
      chbirf (1626) = 1055
      chetat (1626) = 870
      chtn2i (1626) = 210
      chbiet (870) = 1626
c
c Aretes coupees :   2  4  6  7  8 12
      chclas (2282) = ' 6-03'
c Code des aretes coupees : 0, 1, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1
      charde (2282)(1:18) = '  2  4  6  7  8 12'
      chnp1 (2282) = 1
      chnar (2282) = 17
      chnpy (2282) = 12
      chnte (2282) = 6
      chnhe (2282) = 0
      chperm (2282) = 300
      chbirf (2282) = 1055
      chetat (2282) = 871
      chtn2i (2282) = 210
      chbiet (871) = 2282
c
c Aretes coupees :   2  5  6  7 10 12
      chclas (2674) = ' 6-03'
c Code des aretes coupees : 0, 1, 0, 0, 1, 1, 1, 0, 0, 1, 0, 1
      charde (2674)(1:18) = '  2  5  6  7 10 12'
      chnp1 (2674) = 1
      chnar (2674) = 17
      chnpy (2674) = 12
      chnte (2674) = 6
      chnhe (2674) = 0
      chperm (2674) = 130
      chbirf (2674) = 1055
      chetat (2674) = 872
      chtn2i (2674) = 210
      chbiet (872) = 2674
c
c Aretes coupees :   2  6  9 10 11 12
      chclas (3874) = ' 6-03'
c Code des aretes coupees : 0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1
      charde (3874)(1:18) = '  2  6  9 10 11 12'
      chnp1 (3874) = 1
      chnar (3874) = 17
      chnpy (3874) = 12
      chnte (3874) = 6
      chnhe (3874) = 0
      chperm (3874) = 20
      chbirf (3874) = 1055
      chetat (3874) = 873
      chtn2i (3874) = 210
      chbiet (873) = 3874
c
c Aretes coupees :   3  4  5  6  8 11
      chclas (1212) = ' 6-03'
c Code des aretes coupees : 0, 0, 1, 1, 1, 1, 0, 1, 0, 0, 1, 0
      charde (1212)(1:18) = '  3  4  5  6  8 11'
      chnp1 (1212) = 1
      chnar (1212) = 17
      chnpy (1212) = 12
      chnte (1212) = 6
      chnhe (1212) = 0
      chperm (1212) = 310
      chbirf (1212) = 1055
      chetat (1212) = 874
      chtn2i (1212) = 210
      chbiet (874) = 1212
c
c Aretes coupees :   3  4  7  8  9 12
      chclas (2508) = ' 6-03'
c Code des aretes coupees : 0, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1
      charde (2508)(1:18) = '  3  4  7  8  9 12'
      chnp1 (2508) = 1
      chnar (2508) = 17
      chnpy (2508) = 12
      chnte (2508) = 6
      chnhe (2508) = 0
      chperm (2508) = 121
      chbirf (2508) = 1055
      chetat (2508) = 875
      chtn2i (2508) = 210
      chbiet (875) = 2508
c
c Aretes coupees :   3  6  7  8  9 11
      chclas (1508) = ' 6-03'
c Code des aretes coupees : 0, 0, 1, 0, 0, 1, 1, 1, 1, 0, 1, 0
      charde (1508)(1:18) = '  3  6  7  8  9 11'
      chnp1 (1508) = 1
      chnar (1508) = 17
      chnpy (1508) = 12
      chnte (1508) = 6
      chnhe (1508) = 0
      chperm (1508) = 110
      chbirf (1508) = 1055
      chetat (1508) = 876
      chtn2i (1508) = 210
      chbiet (876) = 1508
c
c Aretes coupees :   3  7  9 10 11 12
      chclas (3908) = ' 6-03'
c Code des aretes coupees : 0, 0, 1, 0, 0, 0, 1, 0, 1, 1, 1, 1
      charde (3908)(1:18) = '  3  7  9 10 11 12'
      chnp1 (3908) = 1
      chnar (3908) = 17
      chnpy (3908) = 12
      chnte (3908) = 6
      chnhe (3908) = 0
      chperm (3908) = 200
      chbirf (3908) = 1055
      chetat (3908) = 877
      chtn2i (3908) = 210
      chbiet (877) = 3908
c
c Aretes coupees :   4  5  7  8 11 12
      chclas (3288) = ' 6-03'
c Code des aretes coupees : 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1
      charde (3288)(1:18) = '  4  5  7  8 11 12'
      chnp1 (3288) = 1
      chnar (3288) = 17
      chnpy (3288) = 12
      chnte (3288) = 6
      chnhe (3288) = 0
      chperm (3288) = 120
      chbirf (3288) = 1055
      chetat (3288) = 878
      chtn2i (3288) = 210
      chbiet (878) = 3288
c
c Aretes coupees :   4  5  9 10 11 12
      chclas (3864) = ' 6-03'
c Code des aretes coupees : 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1
      charde (3864)(1:18) = '  4  5  9 10 11 12'
      chnp1 (3864) = 1
      chnar (3864) = 17
      chnpy (3864) = 12
      chnte (3864) = 6
      chnhe (3864) = 0
      chperm (3864) = 201
      chbirf (3864) = 1055
      chetat (3864) = 879
      chtn2i (3864) = 210
      chbiet (879) = 3864
c
c ===========================================
c Classe d'equivalence  6-04
c
c Aretes coupees :   1  2  3  4  5 12
      chclas (2079) = ' 6-04'
c Code des aretes coupees : 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1
      charde (2079)(1:18) = '  1  2  3  4  5 12'
      chnp1 (2079) = 1
      chnar (2079) = 17
      chnpy (2079) = 12
      chnte (2079) = 6
      chnhe (2079) = 0
      chperm (2079) = 0
      chbirf (2079) = 2079
      chetat (2079) = 880
      chtn2i (2079) = 210
      chbiet (880) = 2079
c
c Aretes coupees :   1  2  3  4  6 10
      chclas (559) = ' 6-04'
c Code des aretes coupees : 1, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0
      charde (559)(1:18) = '  1  2  3  4  6 10'
      chnp1 (559) = 1
      chnar (559) = 17
      chnpy (559) = 12
      chnte (559) = 6
      chnhe (559) = 0
      chperm (559) = 221
      chbirf (559) = 2079
      chetat (559) = 881
      chtn2i (559) = 210
      chbiet (881) = 559
c
c Aretes coupees :   1  2  3  4  7 11
      chclas (1103) = ' 6-04'
c Code des aretes coupees : 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0
      charde (1103)(1:18) = '  1  2  3  4  7 11'
      chnp1 (1103) = 1
      chnar (1103) = 17
      chnpy (1103) = 12
      chnte (1103) = 6
      chnhe (1103) = 0
      chperm (1103) = 1
      chbirf (1103) = 2079
      chetat (1103) = 882
      chtn2i (1103) = 210
      chbiet (882) = 1103
c
c Aretes coupees :   1  2  3  4  8  9
      chclas (399) = ' 6-04'
c Code des aretes coupees : 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0
      charde (399)(1:18) = '  1  2  3  4  8  9'
      chnp1 (399) = 1
      chnar (399) = 17
      chnpy (399) = 12
      chnte (399) = 6
      chnhe (399) = 0
      chperm (399) = 220
      chbirf (399) = 2079
      chetat (399) = 883
      chtn2i (399) = 210
      chbiet (883) = 399
c
c Aretes coupees :   1  2  5  6  8  9
      chclas (435) = ' 6-04'
c Code des aretes coupees : 1, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0
      charde (435)(1:18) = '  1  2  5  6  8  9'
      chnp1 (435) = 1
      chnar (435) = 17
      chnpy (435) = 12
      chnte (435) = 6
      chnhe (435) = 0
      chperm (435) = 101
      chbirf (435) = 2079
      chetat (435) = 884
      chtn2i (435) = 210
      chbiet (884) = 435
c
c Aretes coupees :   1  2  5  7 10 11
      chclas (1619) = ' 6-04'
c Code des aretes coupees : 1, 1, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0
      charde (1619)(1:18) = '  1  2  5  7 10 11'
      chnp1 (1619) = 1
      chnar (1619) = 17
      chnpy (1619) = 12
      chnte (1619) = 6
      chnhe (1619) = 0
      chperm (1619) = 330
      chbirf (1619) = 2079
      chetat (1619) = 885
      chtn2i (1619) = 210
      chbiet (885) = 1619
c
c Aretes coupees :   1  3  5  6  9 12
      chclas (2357) = ' 6-04'
c Code des aretes coupees : 1, 0, 1, 0, 1, 1, 0, 0, 1, 0, 0, 1
      charde (2357)(1:18) = '  1  3  5  6  9 12'
      chnp1 (2357) = 1
      chnar (2357) = 17
      chnpy (2357) = 12
      chnte (2357) = 6
      chnhe (2357) = 0
      chperm (2357) = 320
      chbirf (2357) = 2079
      chetat (2357) = 886
      chtn2i (2357) = 210
      chbiet (886) = 2357
c
c Aretes coupees :   1  3  6  7  8 11
      chclas (1253) = ' 6-04'
c Code des aretes coupees : 1, 0, 1, 0, 0, 1, 1, 1, 0, 0, 1, 0
      charde (1253)(1:18) = '  1  3  6  7  8 11'
      chnp1 (1253) = 1
      chnar (1253) = 17
      chnpy (1253) = 12
      chnte (1253) = 6
      chnhe (1253) = 0
      chperm (1253) = 10
      chbirf (1253) = 2079
      chetat (1253) = 887
      chtn2i (1253) = 210
      chbiet (887) = 1253
c
c Aretes coupees :   1  4  5  6  9 10
      chclas (825) = ' 6-04'
c Code des aretes coupees : 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 0, 0
      charde (825)(1:18) = '  1  4  5  6  9 10'
      chnp1 (825) = 1
      chnar (825) = 17
      chnpy (825) = 12
      chnte (825) = 6
      chnhe (825) = 0
      chperm (825) = 100
      chbirf (825) = 2079
      chetat (825) = 888
      chtn2i (825) = 210
      chbiet (888) = 825
c
c Aretes coupees :   1  4  7  8 11 12
      chclas (3273) = ' 6-04'
c Code des aretes coupees : 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 1
      charde (3273)(1:18) = '  1  4  7  8 11 12'
      chnp1 (3273) = 1
      chnar (3273) = 17
      chnpy (3273) = 12
      chnte (3273) = 6
      chnhe (3273) = 0
      chperm (3273) = 120
      chbirf (3273) = 2079
      chetat (3273) = 889
      chtn2i (3273) = 210
      chbiet (889) = 3273
c
c Aretes coupees :   1  5  6  7  9 11
      chclas (1393) = ' 6-04'
c Code des aretes coupees : 1, 0, 0, 0, 1, 1, 1, 0, 1, 0, 1, 0
      charde (1393)(1:18) = '  1  5  6  7  9 11'
      chnp1 (1393) = 1
      chnar (1393) = 17
      chnpy (1393) = 12
      chnte (1393) = 6
      chnhe (1393) = 0
      chperm (1393) = 321
      chbirf (1393) = 2079
      chetat (1393) = 890
      chtn2i (1393) = 210
      chbiet (890) = 1393
c
c Aretes coupees :   1  7  9 10 11 12
      chclas (3905) = ' 6-04'
c Code des aretes coupees : 1, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1
      charde (3905)(1:18) = '  1  7  9 10 11 12'
      chnp1 (3905) = 1
      chnar (3905) = 17
      chnpy (3905) = 12
      chnte (3905) = 6
      chnhe (3905) = 0
      chperm (3905) = 200
      chbirf (3905) = 2079
      chetat (3905) = 891
      chtn2i (3905) = 210
      chbiet (891) = 3905
c
c Aretes coupees :   2  3  5  7 10 12
      chclas (2646) = ' 6-04'
c Code des aretes coupees : 0, 1, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1
      charde (2646)(1:18) = '  2  3  5  7 10 12'
      chnp1 (2646) = 1
      chnar (2646) = 17
      chnpy (2646) = 12
      chnte (2646) = 6
      chnhe (2646) = 0
      chperm (2646) = 130
      chbirf (2646) = 2079
      chetat (2646) = 892
      chtn2i (2646) = 210
      chbiet (892) = 2646
c
c Aretes coupees :   2  3  6  8  9 11
      chclas (1446) = ' 6-04'
c Code des aretes coupees : 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0
      charde (1446)(1:18) = '  2  3  6  8  9 11'
      chnp1 (1446) = 1
      chnar (1446) = 17
      chnpy (1446) = 12
      chnte (1446) = 6
      chnhe (1446) = 0
      chperm (1446) = 110
      chbirf (1446) = 2079
      chetat (1446) = 893
      chtn2i (1446) = 210
      chbiet (893) = 1446
c
c Aretes coupees :   2  4  5  6  7 10
      chclas (634) = ' 6-04'
c Code des aretes coupees : 0, 1, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0
      charde (634)(1:18) = '  2  4  5  6  7 10'
      chnp1 (634) = 1
      chnar (634) = 17
      chnpy (634) = 12
      chnte (634) = 6
      chnhe (634) = 0
      chperm (634) = 230
      chbirf (634) = 2079
      chetat (634) = 894
      chtn2i (634) = 210
      chbiet (894) = 634
c
c Aretes coupees :   2  4  7  8  9 12
      chclas (2506) = ' 6-04'
c Code des aretes coupees : 0, 1, 0, 1, 0, 0, 1, 1, 1, 0, 0, 1
      charde (2506)(1:18) = '  2  4  7  8  9 12'
      chnp1 (2506) = 1
      chnar (2506) = 17
      chnpy (2506) = 12
      chnte (2506) = 6
      chnhe (2506) = 0
      chperm (2506) = 300
      chbirf (2506) = 2079
      chetat (2506) = 895
      chtn2i (2506) = 210
      chbiet (895) = 2506
c
c Aretes coupees :   2  5  7  8  9 10
      chclas (978) = ' 6-04'
c Code des aretes coupees : 0, 1, 0, 0, 1, 0, 1, 1, 1, 1, 0, 0
      charde (978)(1:18) = '  2  5  7  8  9 10'
      chnp1 (978) = 1
      chnar (978) = 17
      chnpy (978) = 12
      chnte (978) = 6
      chnhe (978) = 0
      chperm (978) = 30
      chbirf (978) = 2079
      chetat (978) = 896
      chtn2i (978) = 210
      chbiet (896) = 978
c
c Aretes coupees :   2  8  9 10 11 12
      chclas (3970) = ' 6-04'
c Code des aretes coupees : 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1
      charde (3970)(1:18) = '  2  8  9 10 11 12'
      chnp1 (3970) = 1
      chnar (3970) = 17
      chnpy (3970) = 12
      chnte (3970) = 6
      chnhe (3970) = 0
      chperm (3970) = 21
      chbirf (3970) = 2079
      chetat (3970) = 897
      chtn2i (3970) = 210
      chbiet (897) = 3970
c
c Aretes coupees :   3  4  5  7  8 12
      chclas (2268) = ' 6-04'
c Code des aretes coupees : 0, 0, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1
      charde (2268)(1:18) = '  3  4  5  7  8 12'
      chnp1 (2268) = 1
      chnar (2268) = 17
      chnpy (2268) = 12
      chnte (2268) = 6
      chnhe (2268) = 0
      chperm (2268) = 121
      chbirf (2268) = 2079
      chetat (2268) = 898
      chtn2i (2268) = 210
      chbiet (898) = 2268
c
c Aretes coupees :   3  4  6  8 10 11
      chclas (1708) = ' 6-04'
c Code des aretes coupees : 0, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0
      charde (1708)(1:18) = '  3  4  6  8 10 11'
      chnp1 (1708) = 1
      chnar (1708) = 17
      chnpy (1708) = 12
      chnte (1708) = 6
      chnhe (1708) = 0
      chperm (1708) = 310
      chbirf (1708) = 2079
      chetat (1708) = 899
      chtn2i (1708) = 210
      chbiet (899) = 1708
c
c Aretes coupees :   3  5  6  8 11 12
      chclas (3252) = ' 6-04'
c Code des aretes coupees : 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1
      charde (3252)(1:18) = '  3  5  6  8 11 12'
      chnp1 (3252) = 1
      chnar (3252) = 17
      chnpy (3252) = 12
      chnte (3252) = 6
      chnhe (3252) = 0
      chperm (3252) = 210
      chbirf (3252) = 2079
      chetat (3252) = 900
      chtn2i (3252) = 210
      chbiet (900) = 3252
c
c Aretes coupees :   3  5  9 10 11 12
      chclas (3860) = ' 6-04'
c Code des aretes coupees : 0, 0, 1, 0, 1, 0, 0, 0, 1, 1, 1, 1
      charde (3860)(1:18) = '  3  5  9 10 11 12'
      chnp1 (3860) = 1
      chnar (3860) = 17
      chnpy (3860) = 12
      chnte (3860) = 6
      chnhe (3860) = 0
      chperm (3860) = 201
      chbirf (3860) = 2079
      chetat (3860) = 901
      chtn2i (3860) = 210
      chbiet (901) = 3860
c
c Aretes coupees :   4  6  7  8 10 12
      chclas (2792) = ' 6-04'
c Code des aretes coupees : 0, 0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1
      charde (2792)(1:18) = '  4  6  7  8 10 12'
      chnp1 (2792) = 1
      chnar (2792) = 17
      chnpy (2792) = 12
      chnte (2792) = 6
      chnhe (2792) = 0
      chperm (2792) = 301
      chbirf (2792) = 2079
      chetat (2792) = 902
      chtn2i (2792) = 210
      chbiet (902) = 2792
c
c Aretes coupees :   4  6  9 10 11 12
      chclas (3880) = ' 6-04'
c Code des aretes coupees : 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 1, 1
      charde (3880)(1:18) = '  4  6  9 10 11 12'
      chnp1 (3880) = 1
      chnar (3880) = 17
      chnpy (3880) = 12
      chnte (3880) = 6
      chnhe (3880) = 0
      chperm (3880) = 20
      chbirf (3880) = 2079
      chetat (3880) = 903
      chtn2i (3880) = 210
      chbiet (903) = 3880
c
c ===========================================
c Classe d'equivalence  6-05
c
c Aretes coupees :   1  2  3  4  5  8
      chclas (159) = ' 6-05'
c Code des aretes coupees : 1, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0
      charde (159)(1:18) = '  1  2  3  4  5  8'
      chnp1 (159) = 1
      chnar (159) = 19
      chnpy (159) = 17
      chnte (159) = 0
      chnhe (159) = 0
      chperm (159) = 0
      chbirf (159) = 159
      chetat (159) = 904
      chtn2i (159) = 210
      chbiet (904) = 159
c
c Aretes coupees :   1  2  3  4  6  7
      chclas (111) = ' 6-05'
c Code des aretes coupees : 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0
      charde (111)(1:18) = '  1  2  3  4  6  7'
      chnp1 (111) = 1
      chnar (111) = 19
      chnpy (111) = 17
      chnte (111) = 0
      chnhe (111) = 0
      chperm (111) = 1
      chbirf (111) = 159
      chetat (111) = 905
      chtn2i (111) = 210
      chbiet (905) = 111
c
c Aretes coupees :   1  2  5  6  9 11
      chclas (1331) = ' 6-05'
c Code des aretes coupees : 1, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0
      charde (1331)(1:18) = '  1  2  5  6  9 11'
      chnp1 (1331) = 1
      chnar (1331) = 19
      chnpy (1331) = 17
      chnte (1331) = 0
      chnhe (1331) = 0
      chperm (1331) = 101
      chbirf (1331) = 159
      chetat (1331) = 906
      chtn2i (1331) = 210
      chbiet (906) = 1331
c
c Aretes coupees :   1  2  5  7 10 12
      chclas (2643) = ' 6-05'
c Code des aretes coupees : 1, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1
      charde (2643)(1:18) = '  1  2  5  7 10 12'
      chnp1 (2643) = 1
      chnar (2643) = 19
      chnpy (2643) = 17
      chnte (2643) = 0
      chnhe (2643) = 0
      chperm (2643) = 130
      chbirf (2643) = 159
      chetat (2643) = 907
      chtn2i (2643) = 210
      chbiet (907) = 2643
c
c Aretes coupees :   1  3  5  6  9 10
      chclas (821) = ' 6-05'
c Code des aretes coupees : 1, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 0
      charde (821)(1:18) = '  1  3  5  6  9 10'
      chnp1 (821) = 1
      chnar (821) = 19
      chnpy (821) = 17
      chnte (821) = 0
      chnhe (821) = 0
      chperm (821) = 100
      chbirf (821) = 159
      chetat (821) = 908
      chtn2i (821) = 210
      chbiet (908) = 821
c
c Aretes coupees :   1  3  6  8 11 12
      chclas (3237) = ' 6-05'
c Code des aretes coupees : 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 1
      charde (3237)(1:18) = '  1  3  6  8 11 12'
      chnp1 (3237) = 1
      chnar (3237) = 19
      chnpy (3237) = 17
      chnte (3237) = 0
      chnhe (3237) = 0
      chperm (3237) = 10
      chbirf (3237) = 159
      chetat (3237) = 909
      chtn2i (3237) = 210
      chbiet (909) = 3237
c
c Aretes coupees :   2  4  5  7  9 10
      chclas (858) = ' 6-05'
c Code des aretes coupees : 0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 0
      charde (858)(1:18) = '  2  4  5  7  9 10'
      chnp1 (858) = 1
      chnar (858) = 19
      chnpy (858) = 17
      chnte (858) = 0
      chnhe (858) = 0
      chperm (858) = 30
      chbirf (858) = 159
      chetat (858) = 910
      chtn2i (858) = 210
      chbiet (910) = 858
c
c Aretes coupees :   2  4  7  8 11 12
      chclas (3274) = ' 6-05'
c Code des aretes coupees : 0, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 1
      charde (3274)(1:18) = '  2  4  7  8 11 12'
      chnp1 (3274) = 1
      chnar (3274) = 19
      chnpy (3274) = 17
      chnte (3274) = 0
      chnhe (3274) = 0
      chperm (3274) = 300
      chbirf (3274) = 159
      chetat (3274) = 911
      chtn2i (3274) = 210
      chbiet (911) = 3274
c
c Aretes coupees :   3  4  6  8  9 11
      chclas (1452) = ' 6-05'
c Code des aretes coupees : 0, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0
      charde (1452)(1:18) = '  3  4  6  8  9 11'
      chnp1 (1452) = 1
      chnar (1452) = 19
      chnpy (1452) = 17
      chnte (1452) = 0
      chnhe (1452) = 0
      chperm (1452) = 110
      chbirf (1452) = 159
      chetat (1452) = 912
      chtn2i (1452) = 210
      chbiet (912) = 1452
c
c Aretes coupees :   3  4  7  8 10 12
      chclas (2764) = ' 6-05'
c Code des aretes coupees : 0, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 1
      charde (2764)(1:18) = '  3  4  7  8 10 12'
      chnp1 (2764) = 1
      chnar (2764) = 19
      chnpy (2764) = 17
      chnte (2764) = 0
      chnhe (2764) = 0
      chperm (2764) = 301
      chbirf (2764) = 159
      chetat (2764) = 913
      chtn2i (2764) = 210
      chbiet (913) = 2764
c
c Aretes coupees :   5  8  9 10 11 12
      chclas (3984) = ' 6-05'
c Code des aretes coupees : 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1
      charde (3984)(1:18) = '  5  8  9 10 11 12'
      chnp1 (3984) = 1
      chnar (3984) = 19
      chnpy (3984) = 17
      chnte (3984) = 0
      chnhe (3984) = 0
      chperm (3984) = 201
      chbirf (3984) = 159
      chetat (3984) = 914
      chtn2i (3984) = 210
      chbiet (914) = 3984
c
c Aretes coupees :   6  7  9 10 11 12
      chclas (3936) = ' 6-05'
c Code des aretes coupees : 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 1, 1
      charde (3936)(1:18) = '  6  7  9 10 11 12'
      chnp1 (3936) = 1
      chnar (3936) = 19
      chnpy (3936) = 17
      chnte (3936) = 0
      chnhe (3936) = 0
      chperm (3936) = 200
      chbirf (3936) = 159
      chetat (3936) = 915
      chtn2i (3936) = 210
      chbiet (915) = 3936
c
c ===========================================
c Classe d'equivalence  6-06
c
c Aretes coupees :   1  2  6  7 11 12
      chclas (3171) = ' 6-06'
c Code des aretes coupees : 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1
      charde (3171)(1:18) = '  1  2  6  7 11 12'
      chnp1 (3171) = 1
      chnar (3171) = 20
      chnpy (3171) = 18
      chnte (3171) = 0
      chnhe (3171) = 0
      chperm (3171) = 0
      chbirf (3171) = 3171
      chetat (3171) = 916
      chtn2i (3171) = 210
      chbiet (916) = 3171
c
c Aretes coupees :   1  3  5  8 10 12
      chclas (2709) = ' 6-06'
c Code des aretes coupees : 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1
      charde (2709)(1:18) = '  1  3  5  8 10 12'
      chnp1 (2709) = 1
      chnar (2709) = 20
      chnpy (2709) = 18
      chnte (2709) = 0
      chnhe (2709) = 0
      chperm (2709) = 200
      chbirf (2709) = 3171
      chetat (2709) = 917
      chtn2i (2709) = 210
      chbiet (917) = 2709
c
c Aretes coupees :   2  4  5  8  9 11
      chclas (1434) = ' 6-06'
c Code des aretes coupees : 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0
      charde (1434)(1:18) = '  2  4  5  8  9 11'
      chnp1 (1434) = 1
      chnar (1434) = 20
      chnpy (1434) = 18
      chnte (1434) = 0
      chnhe (1434) = 0
      chperm (1434) = 100
      chbirf (1434) = 3171
      chetat (1434) = 918
      chtn2i (1434) = 210
      chbiet (918) = 1434
c
c Aretes coupees :   3  4  6  7  9 10
      chclas (876) = ' 6-06'
c Code des aretes coupees : 0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0
      charde (876)(1:18) = '  3  4  6  7  9 10'
      chnp1 (876) = 1
      chnar (876) = 20
      chnpy (876) = 18
      chnte (876) = 0
      chnhe (876) = 0
      chperm (876) = 300
      chbirf (876) = 3171
      chetat (876) = 919
      chtn2i (876) = 210
      chbiet (919) = 876
c
c ===========================================
c Classe d'equivalence  6-07
c
c Aretes coupees :   1  2  6  8 10 12
      chclas (2723) = ' 6-07'
c Code des aretes coupees : 1, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1
      charde (2723)(1:18) = '  1  2  6  8 10 12'
      chnp1 (2723) = 1
      chnar (2723) = 18
      chnpy (2723) = 16
      chnte (2723) = 0
      chnhe (2723) = 0
      chperm (2723) = 0
      chbirf (2723) = 2723
      chetat (2723) = 920
      chtn2i (2723) = 210
      chbiet (920) = 2723
c
c Aretes coupees :   1  3  7  8  9 10
      chclas (965) = ' 6-07'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0
      charde (965)(1:18) = '  1  3  7  8  9 10'
      chnp1 (965) = 1
      chnar (965) = 18
      chnpy (965) = 16
      chnte (965) = 0
      chnhe (965) = 0
      chperm (965) = 310
      chbirf (965) = 2723
      chetat (965) = 921
      chtn2i (965) = 210
      chbiet (921) = 965
c
c Aretes coupees :   1  4  5  8 10 11
      chclas (1689) = ' 6-07'
c Code des aretes coupees : 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0
      charde (1689)(1:18) = '  1  4  5  8 10 11'
      chnp1 (1689) = 1
      chnar (1689) = 18
      chnpy (1689) = 16
      chnte (1689) = 0
      chnhe (1689) = 0
      chperm (1689) = 210
      chbirf (1689) = 2723
      chetat (1689) = 922
      chtn2i (1689) = 210
      chbiet (922) = 1689
c
c Aretes coupees :   2  3  6  7  9 12
      chclas (2406) = ' 6-07'
c Code des aretes coupees : 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1
      charde (2406)(1:18) = '  2  3  6  7  9 12'
      chnp1 (2406) = 1
      chnar (2406) = 18
      chnpy (2406) = 16
      chnte (2406) = 0
      chnhe (2406) = 0
      chperm (2406) = 10
      chbirf (2406) = 2723
      chetat (2406) = 923
      chtn2i (2406) = 210
      chbiet (923) = 2406
c
c Aretes coupees :   2  4  5  6 11 12
      chclas (3130) = ' 6-07'
c Code des aretes coupees : 0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1
      charde (3130)(1:18) = '  2  4  5  6 11 12'
      chnp1 (3130) = 1
      chnar (3130) = 18
      chnpy (3130) = 16
      chnte (3130) = 0
      chnhe (3130) = 0
      chperm (3130) = 110
      chbirf (3130) = 2723
      chetat (3130) = 924
      chtn2i (3130) = 210
      chbiet (924) = 3130
c
c Aretes coupees :   3  4  5  7  9 11
      chclas (1372) = ' 6-07'
c Code des aretes coupees : 0, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0
      charde (1372)(1:18) = '  3  4  5  7  9 11'
      chnp1 (1372) = 1
      chnar (1372) = 18
      chnpy (1372) = 16
      chnte (1372) = 0
      chnhe (1372) = 0
      chperm (1372) = 100
      chbirf (1372) = 2723
      chetat (1372) = 925
      chtn2i (1372) = 210
      chbiet (925) = 1372
c
c ===========================================
c Classe d'equivalence  6-08
c
c Aretes coupees :   1  2  7  8  9 11
      chclas (1475) = ' 6-08'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0
      charde (1475)(1:18) = '  1  2  7  8  9 11'
      chnp1 (1475) = 1
      chnar (1475) = 18
      chnpy (1475) = 16
      chnte (1475) = 0
      chnhe (1475) = 0
      chperm (1475) = 0
      chbirf (1475) = 1475
      chetat (1475) = 926
      chtn2i (1475) = 210
      chbiet (926) = 1475
c
c Aretes coupees :   1  3  5  7 11 12
      chclas (3157) = ' 6-08'
c Code des aretes coupees : 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 1
      charde (3157)(1:18) = '  1  3  5  7 11 12'
      chnp1 (3157) = 1
      chnar (3157) = 18
      chnpy (3157) = 16
      chnte (3157) = 0
      chnhe (3157) = 0
      chperm (3157) = 101
      chbirf (3157) = 1475
      chetat (3157) = 927
      chtn2i (3157) = 210
      chbiet (927) = 3157
c
c Aretes coupees :   1  4  6  7 10 11
      chclas (1641) = ' 6-08'
c Code des aretes coupees : 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0
      charde (1641)(1:18) = '  1  4  6  7 10 11'
      chnp1 (1641) = 1
      chnar (1641) = 18
      chnpy (1641) = 16
      chnte (1641) = 0
      chnhe (1641) = 0
      chperm (1641) = 300
      chbirf (1641) = 1475
      chetat (1641) = 928
      chtn2i (1641) = 210
      chbiet (928) = 1641
c
c Aretes coupees :   2  3  5  8  9 12
      chclas (2454) = ' 6-08'
c Code des aretes coupees : 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1
      charde (2454)(1:18) = '  2  3  5  8  9 12'
      chnp1 (2454) = 1
      chnar (2454) = 18
      chnpy (2454) = 16
      chnte (2454) = 0
      chnhe (2454) = 0
      chperm (2454) = 100
      chbirf (2454) = 1475
      chetat (2454) = 929
      chtn2i (2454) = 210
      chbiet (929) = 2454
c
c Aretes coupees :   2  4  6  8  9 10
      chclas (938) = ' 6-08'
c Code des aretes coupees : 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 0
      charde (938)(1:18) = '  2  4  6  8  9 10'
      chnp1 (938) = 1
      chnar (938) = 18
      chnpy (938) = 16
      chnte (938) = 0
      chnhe (938) = 0
      chperm (938) = 1
      chbirf (938) = 1475
      chetat (938) = 930
      chtn2i (938) = 210
      chbiet (930) = 938
c
c Aretes coupees :   3  4  5  6 10 12
      chclas (2620) = ' 6-08'
c Code des aretes coupees : 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1
      charde (2620)(1:18) = '  3  4  5  6 10 12'
      chnp1 (2620) = 1
      chnar (2620) = 18
      chnpy (2620) = 16
      chnte (2620) = 0
      chnhe (2620) = 0
      chperm (2620) = 200
      chbirf (2620) = 1475
      chetat (2620) = 931
      chtn2i (2620) = 210
      chbiet (931) = 2620
c
c ===========================================
c Classe d'equivalence  7-00
c
c Aretes coupees :   1  2  3  4  5  6  9
      chclas (319) = ' 7-00'
c Code des aretes coupees : 1, 1, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0
      charde (319)(1:21) = '  1  2  3  4  5  6  9'
      chnp1 (319) = 1
      chnar (319) = 19
      chnpy (319) = 14
      chnte (319) = 6
      chnhe (319) = 0
      chperm (319) = 0
      chbirf (319) = 319
      chetat (319) = 932
      chtn2i (319) = 210
      chbiet (932) = 319
c
c Aretes coupees :   1  2  3  4  5  7 10
      chclas (607) = ' 7-00'
c Code des aretes coupees : 1, 1, 1, 1, 1, 0, 1, 0, 0, 1, 0, 0
      charde (607)(1:21) = '  1  2  3  4  5  7 10'
      chnp1 (607) = 1
      chnar (607) = 19
      chnpy (607) = 14
      chnte (607) = 6
      chnhe (607) = 0
      chperm (607) = 330
      chbirf (607) = 319
      chetat (607) = 933
      chtn2i (607) = 210
      chbiet (933) = 607
c
c Aretes coupees :   1  2  3  4  6  8 11
      chclas (1199) = ' 7-00'
c Code des aretes coupees : 1, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 0
      charde (1199)(1:21) = '  1  2  3  4  6  8 11'
      chnp1 (1199) = 1
      chnar (1199) = 19
      chnpy (1199) = 14
      chnte (1199) = 6
      chnhe (1199) = 0
      chperm (1199) = 310
      chbirf (1199) = 319
      chetat (1199) = 934
      chtn2i (1199) = 210
      chbiet (934) = 1199
c
c Aretes coupees :   1  2  3  4  7  8 12
      chclas (2255) = ' 7-00'
c Code des aretes coupees : 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 0, 1
      charde (2255)(1:21) = '  1  2  3  4  7  8 12'
      chnp1 (2255) = 1
      chnar (2255) = 19
      chnpy (2255) = 14
      chnte (2255) = 6
      chnhe (2255) = 0
      chperm (2255) = 300
      chbirf (2255) = 319
      chetat (2255) = 935
      chtn2i (2255) = 210
      chbiet (935) = 2255
c
c Aretes coupees :   1  2  5  6  7  9 10
      chclas (883) = ' 7-00'
c Code des aretes coupees : 1, 1, 0, 0, 1, 1, 1, 0, 1, 1, 0, 0
      charde (883)(1:21) = '  1  2  5  6  7  9 10'
      chnp1 (883) = 1
      chnar (883) = 19
      chnpy (883) = 14
      chnte (883) = 6
      chnhe (883) = 0
      chperm (883) = 30
      chbirf (883) = 319
      chetat (883) = 936
      chtn2i (883) = 210
      chbiet (936) = 883
c
c Aretes coupees :   1  3  5  6  8  9 11
      chclas (1461) = ' 7-00'
c Code des aretes coupees : 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0
      charde (1461)(1:21) = '  1  3  5  6  8  9 11'
      chnp1 (1461) = 1
      chnar (1461) = 19
      chnpy (1461) = 14
      chnte (1461) = 6
      chnhe (1461) = 0
      chperm (1461) = 10
      chbirf (1461) = 319
      chetat (1461) = 937
      chtn2i (1461) = 210
      chbiet (937) = 1461
c
c Aretes coupees :   1  5  6  9 10 11 12
      chclas (3889) = ' 7-00'
c Code des aretes coupees : 1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1
      charde (3889)(1:21) = '  1  5  6  9 10 11 12'
      chnp1 (3889) = 1
      chnar (3889) = 19
      chnpy (3889) = 14
      chnte (3889) = 6
      chnhe (3889) = 0
      chperm (3889) = 100
      chbirf (3889) = 319
      chetat (3889) = 938
      chtn2i (3889) = 210
      chbiet (938) = 3889
c
c Aretes coupees :   2  4  5  7  8 10 12
      chclas (2778) = ' 7-00'
c Code des aretes coupees : 0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1
      charde (2778)(1:21) = '  2  4  5  7  8 10 12'
      chnp1 (2778) = 1
      chnar (2778) = 19
      chnpy (2778) = 14
      chnte (2778) = 6
      chnhe (2778) = 0
      chperm (2778) = 230
      chbirf (2778) = 319
      chetat (2778) = 939
      chtn2i (2778) = 210
      chbiet (939) = 2778
c
c Aretes coupees :   2  5  7  9 10 11 12
      chclas (3922) = ' 7-00'
c Code des aretes coupees : 0, 1, 0, 0, 1, 0, 1, 0, 1, 1, 1, 1
      charde (3922)(1:21) = '  2  5  7  9 10 11 12'
      chnp1 (3922) = 1
      chnar (3922) = 19
      chnpy (3922) = 14
      chnte (3922) = 6
      chnhe (3922) = 0
      chperm (3922) = 130
      chbirf (3922) = 319
      chetat (3922) = 940
      chtn2i (3922) = 210
      chbiet (940) = 3922
c
c Aretes coupees :   3  4  6  7  8 11 12
      chclas (3308) = ' 7-00'
c Code des aretes coupees : 0, 0, 1, 1, 0, 1, 1, 1, 0, 0, 1, 1
      charde (3308)(1:21) = '  3  4  6  7  8 11 12'
      chnp1 (3308) = 1
      chnar (3308) = 19
      chnpy (3308) = 14
      chnte (3308) = 6
      chnhe (3308) = 0
      chperm (3308) = 210
      chbirf (3308) = 319
      chetat (3308) = 941
      chtn2i (3308) = 210
      chbiet (941) = 3308
c
c Aretes coupees :   3  6  8  9 10 11 12
      chclas (4004) = ' 7-00'
c Code des aretes coupees : 0, 0, 1, 0, 0, 1, 0, 1, 1, 1, 1, 1
      charde (4004)(1:21) = '  3  6  8  9 10 11 12'
      chnp1 (4004) = 1
      chnar (4004) = 19
      chnpy (4004) = 14
      chnte (4004) = 6
      chnhe (4004) = 0
      chperm (4004) = 110
      chbirf (4004) = 319
      chetat (4004) = 942
      chtn2i (4004) = 210
      chbiet (942) = 4004
c
c Aretes coupees :   4  7  8  9 10 11 12
      chclas (4040) = ' 7-00'
c Code des aretes coupees : 0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 1
      charde (4040)(1:21) = '  4  7  8  9 10 11 12'
      chnp1 (4040) = 1
      chnar (4040) = 19
      chnpy (4040) = 14
      chnte (4040) = 6
      chnhe (4040) = 0
      chperm (4040) = 200
      chbirf (4040) = 319
      chetat (4040) = 943
      chtn2i (4040) = 210
      chbiet (943) = 4040
c
c ===========================================
c Classe d'equivalence  7-01
c
c Aretes coupees :   1  2  3  4  5 11 12
      chclas (3103) = ' 7-01'
c Code des aretes coupees : 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1
      charde (3103)(1:21) = '  1  2  3  4  5 11 12'
      chnp1 (3103) = 1
      chnar (3103) = 19
      chnpy (3103) = 17
      chnte (3103) = 0
      chnhe (3103) = 0
      chperm (3103) = 0
      chbirf (3103) = 3103
      chetat (3103) = 944
      chtn2i (3103) = 210
      chbiet (944) = 3103
c
c Aretes coupees :   1  2  3  4  6 10 12
      chclas (2607) = ' 7-01'
c Code des aretes coupees : 1, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 1
      charde (2607)(1:21) = '  1  2  3  4  6 10 12'
      chnp1 (2607) = 1
      chnar (2607) = 19
      chnpy (2607) = 17
      chnte (2607) = 0
      chnhe (2607) = 0
      chperm (2607) = 221
      chbirf (2607) = 3103
      chetat (2607) = 945
      chtn2i (2607) = 210
      chbiet (945) = 2607
c
c Aretes coupees :   1  2  3  4  7  9 11
      chclas (1359) = ' 7-01'
c Code des aretes coupees : 1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0
      charde (1359)(1:21) = '  1  2  3  4  7  9 11'
      chnp1 (1359) = 1
      chnar (1359) = 19
      chnpy (1359) = 17
      chnte (1359) = 0
      chnhe (1359) = 0
      chperm (1359) = 1
      chbirf (1359) = 3103
      chetat (1359) = 946
      chtn2i (1359) = 210
      chbiet (946) = 1359
c
c Aretes coupees :   1  2  3  4  8  9 10
      chclas (911) = ' 7-01'
c Code des aretes coupees : 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0
      charde (911)(1:21) = '  1  2  3  4  8  9 10'
      chnp1 (911) = 1
      chnar (911) = 19
      chnpy (911) = 17
      chnte (911) = 0
      chnhe (911) = 0
      chperm (911) = 220
      chbirf (911) = 3103
      chetat (911) = 947
      chtn2i (911) = 210
      chbiet (947) = 911
c
c Aretes coupees :   1  2  5  6  8  9 12
      chclas (2483) = ' 7-01'
c Code des aretes coupees : 1, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1
      charde (2483)(1:21) = '  1  2  5  6  8  9 12'
      chnp1 (2483) = 1
      chnar (2483) = 19
      chnpy (2483) = 17
      chnte (2483) = 0
      chnhe (2483) = 0
      chperm (2483) = 101
      chbirf (2483) = 3103
      chetat (2483) = 948
      chtn2i (2483) = 210
      chbiet (948) = 2483
c
c Aretes coupees :   1  2  5  7  8 10 11
      chclas (1747) = ' 7-01'
c Code des aretes coupees : 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1, 0
      charde (1747)(1:21) = '  1  2  5  7  8 10 11'
      chnp1 (1747) = 1
      chnar (1747) = 19
      chnpy (1747) = 17
      chnte (1747) = 0
      chnhe (1747) = 0
      chperm (1747) = 330
      chbirf (1747) = 3103
      chetat (1747) = 949
      chtn2i (1747) = 210
      chbiet (949) = 1747
c
c Aretes coupees :   1  2  8  9 10 11 12
      chclas (3971) = ' 7-01'
c Code des aretes coupees : 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1
      charde (3971)(1:21) = '  1  2  8  9 10 11 12'
      chnp1 (3971) = 1
      chnar (3971) = 19
      chnpy (3971) = 17
      chnte (3971) = 0
      chnhe (3971) = 0
      chperm (3971) = 21
      chbirf (3971) = 3103
      chetat (3971) = 950
      chtn2i (3971) = 210
      chbiet (950) = 3971
c
c Aretes coupees :   1  3  5  6  7  9 12
      chclas (2421) = ' 7-01'
c Code des aretes coupees : 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 0, 1
      charde (2421)(1:21) = '  1  3  5  6  7  9 12'
      chnp1 (2421) = 1
      chnar (2421) = 19
      chnpy (2421) = 17
      chnte (2421) = 0
      chnhe (2421) = 0
      chperm (2421) = 320
      chbirf (2421) = 3103
      chetat (2421) = 951
      chtn2i (2421) = 210
      chbiet (951) = 2421
c
c Aretes coupees :   1  3  6  7  8 10 11
      chclas (1765) = ' 7-01'
c Code des aretes coupees : 1, 0, 1, 0, 0, 1, 1, 1, 0, 1, 1, 0
      charde (1765)(1:21) = '  1  3  6  7  8 10 11'
      chnp1 (1765) = 1
      chnar (1765) = 19
      chnpy (1765) = 17
      chnte (1765) = 0
      chnhe (1765) = 0
      chperm (1765) = 10
      chbirf (1765) = 3103
      chetat (1765) = 952
      chtn2i (1765) = 210
      chbiet (952) = 1765
c
c Aretes coupees :   1  3  7  9 10 11 12
      chclas (3909) = ' 7-01'
c Code des aretes coupees : 1, 0, 1, 0, 0, 0, 1, 0, 1, 1, 1, 1
      charde (3909)(1:21) = '  1  3  7  9 10 11 12'
      chnp1 (3909) = 1
      chnar (3909) = 19
      chnpy (3909) = 17
      chnte (3909) = 0
      chnhe (3909) = 0
      chperm (3909) = 200
      chbirf (3909) = 3103
      chetat (3909) = 953
      chtn2i (3909) = 210
      chbiet (953) = 3909
c
c Aretes coupees :   1  4  5  6  7  9 11
      chclas (1401) = ' 7-01'
c Code des aretes coupees : 1, 0, 0, 1, 1, 1, 1, 0, 1, 0, 1, 0
      charde (1401)(1:21) = '  1  4  5  6  7  9 11'
      chnp1 (1401) = 1
      chnar (1401) = 19
      chnpy (1401) = 17
      chnte (1401) = 0
      chnhe (1401) = 0
      chperm (1401) = 321
      chbirf (1401) = 3103
      chetat (1401) = 954
      chtn2i (1401) = 210
      chbiet (954) = 1401
c
c Aretes coupees :   1  4  5  6  8  9 10
      chclas (953) = ' 7-01'
c Code des aretes coupees : 1, 0, 0, 1, 1, 1, 0, 1, 1, 1, 0, 0
      charde (953)(1:21) = '  1  4  5  6  8  9 10'
      chnp1 (953) = 1
      chnar (953) = 19
      chnpy (953) = 17
      chnte (953) = 0
      chnhe (953) = 0
      chperm (953) = 100
      chbirf (953) = 3103
      chetat (953) = 955
      chtn2i (953) = 210
      chbiet (955) = 953
c
c Aretes coupees :   1  4  5  7  8 11 12
      chclas (3289) = ' 7-01'
c Code des aretes coupees : 1, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1
      charde (3289)(1:21) = '  1  4  5  7  8 11 12'
      chnp1 (3289) = 1
      chnar (3289) = 19
      chnpy (3289) = 17
      chnte (3289) = 0
      chnhe (3289) = 0
      chperm (3289) = 120
      chbirf (3289) = 3103
      chetat (3289) = 956
      chtn2i (3289) = 210
      chbiet (956) = 3289
c
c Aretes coupees :   1  4  6  7  8 10 12
      chclas (2793) = ' 7-01'
c Code des aretes coupees : 1, 0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1
      charde (2793)(1:21) = '  1  4  6  7  8 10 12'
      chnp1 (2793) = 1
      chnar (2793) = 19
      chnpy (2793) = 17
      chnte (2793) = 0
      chnhe (2793) = 0
      chperm (2793) = 301
      chbirf (2793) = 3103
      chetat (2793) = 957
      chtn2i (2793) = 210
      chbiet (957) = 2793
c
c Aretes coupees :   2  3  5  6  7 10 12
      chclas (2678) = ' 7-01'
c Code des aretes coupees : 0, 1, 1, 0, 1, 1, 1, 0, 0, 1, 0, 1
      charde (2678)(1:21) = '  2  3  5  6  7 10 12'
      chnp1 (2678) = 1
      chnar (2678) = 19
      chnpy (2678) = 17
      chnte (2678) = 0
      chnhe (2678) = 0
      chperm (2678) = 130
      chbirf (2678) = 3103
      chetat (2678) = 958
      chtn2i (2678) = 210
      chbiet (958) = 2678
c
c Aretes coupees :   2  3  5  6  8 11 12
      chclas (3254) = ' 7-01'
c Code des aretes coupees : 0, 1, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1
      charde (3254)(1:21) = '  2  3  5  6  8 11 12'
      chnp1 (3254) = 1
      chnar (3254) = 19
      chnpy (3254) = 17
      chnte (3254) = 0
      chnhe (3254) = 0
      chperm (3254) = 210
      chbirf (3254) = 3103
      chetat (3254) = 959
      chtn2i (3254) = 210
      chbiet (959) = 3254
c
c Aretes coupees :   2  3  5  7  8  9 10
      chclas (982) = ' 7-01'
c Code des aretes coupees : 0, 1, 1, 0, 1, 0, 1, 1, 1, 1, 0, 0
      charde (982)(1:21) = '  2  3  5  7  8  9 10'
      chnp1 (982) = 1
      chnar (982) = 19
      chnpy (982) = 17
      chnte (982) = 0
      chnhe (982) = 0
      chperm (982) = 30
      chbirf (982) = 3103
      chetat (982) = 960
      chtn2i (982) = 210
      chbiet (960) = 982
c
c Aretes coupees :   2  3  6  7  8  9 11
      chclas (1510) = ' 7-01'
c Code des aretes coupees : 0, 1, 1, 0, 0, 1, 1, 1, 1, 0, 1, 0
      charde (1510)(1:21) = '  2  3  6  7  8  9 11'
      chnp1 (1510) = 1
      chnar (1510) = 19
      chnpy (1510) = 17
      chnte (1510) = 0
      chnhe (1510) = 0
      chperm (1510) = 110
      chbirf (1510) = 3103
      chetat (1510) = 961
      chtn2i (1510) = 210
      chbiet (961) = 1510
c
c Aretes coupees :   2  4  5  6  7 10 11
      chclas (1658) = ' 7-01'
c Code des aretes coupees : 0, 1, 0, 1, 1, 1, 1, 0, 0, 1, 1, 0
      charde (1658)(1:21) = '  2  4  5  6  7 10 11'
      chnp1 (1658) = 1
      chnar (1658) = 19
      chnpy (1658) = 17
      chnte (1658) = 0
      chnhe (1658) = 0
      chperm (1658) = 230
      chbirf (1658) = 3103
      chetat (1658) = 962
      chtn2i (1658) = 210
      chbiet (962) = 1658
c
c Aretes coupees :   2  4  6  7  8  9 12
      chclas (2538) = ' 7-01'
c Code des aretes coupees : 0, 1, 0, 1, 0, 1, 1, 1, 1, 0, 0, 1
      charde (2538)(1:21) = '  2  4  6  7  8  9 12'
      chnp1 (2538) = 1
      chnar (2538) = 19
      chnpy (2538) = 17
      chnte (2538) = 0
      chnhe (2538) = 0
      chperm (2538) = 300
      chbirf (2538) = 3103
      chetat (2538) = 963
      chtn2i (2538) = 210
      chbiet (963) = 2538
c
c Aretes coupees :   2  4  6  9 10 11 12
      chclas (3882) = ' 7-01'
c Code des aretes coupees : 0, 1, 0, 1, 0, 1, 0, 0, 1, 1, 1, 1
      charde (3882)(1:21) = '  2  4  6  9 10 11 12'
      chnp1 (3882) = 1
      chnar (3882) = 19
      chnpy (3882) = 17
      chnte (3882) = 0
      chnhe (3882) = 0
      chperm (3882) = 20
      chbirf (3882) = 3103
      chetat (3882) = 964
      chtn2i (3882) = 210
      chbiet (964) = 3882
c
c Aretes coupees :   3  4  5  6  8 10 11
      chclas (1724) = ' 7-01'
c Code des aretes coupees : 0, 0, 1, 1, 1, 1, 0, 1, 0, 1, 1, 0
      charde (1724)(1:21) = '  3  4  5  6  8 10 11'
      chnp1 (1724) = 1
      chnar (1724) = 19
      chnpy (1724) = 17
      chnte (1724) = 0
      chnhe (1724) = 0
      chperm (1724) = 310
      chbirf (1724) = 3103
      chetat (1724) = 965
      chtn2i (1724) = 210
      chbiet (965) = 1724
c
c Aretes coupees :   3  4  5  7  8  9 12
      chclas (2524) = ' 7-01'
c Code des aretes coupees : 0, 0, 1, 1, 1, 0, 1, 1, 1, 0, 0, 1
      charde (2524)(1:21) = '  3  4  5  7  8  9 12'
      chnp1 (2524) = 1
      chnar (2524) = 19
      chnpy (2524) = 17
      chnte (2524) = 0
      chnhe (2524) = 0
      chperm (2524) = 121
      chbirf (2524) = 3103
      chetat (2524) = 966
      chtn2i (2524) = 210
      chbiet (966) = 2524
c
c Aretes coupees :   3  4  5  9 10 11 12
      chclas (3868) = ' 7-01'
c Code des aretes coupees : 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1
      charde (3868)(1:21) = '  3  4  5  9 10 11 12'
      chnp1 (3868) = 1
      chnar (3868) = 19
      chnpy (3868) = 17
      chnte (3868) = 0
      chnhe (3868) = 0
      chperm (3868) = 201
      chbirf (3868) = 3103
      chetat (3868) = 967
      chtn2i (3868) = 210
      chbiet (967) = 3868
c
c ===========================================
c Classe d'equivalence  8-00
c
c Aretes coupees :   1  2  3  4  9 10 11 12
      chclas (3855) = ' 8-00'
c Code des aretes coupees : 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1
      charde (3855)(1:24) = '  1  2  3  4  9 10 11 12'
      chnp1 (3855) = 0
      chnar (3855) = 1
      chnpy (3855) = 0
      chnte (3855) = 0
      chnhe (3855) = 4
      chperm (3855) = 0
      chbirf (3855) = 3855
      chetat (3855) = 968
      chtn2i (3855) = 17
      chbiet (968) = 3855
c
c Aretes coupees :   1  4  5  6  7  8  9 12
      chclas (2553) = ' 8-00'
c Code des aretes coupees : 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 1
      charde (2553)(1:24) = '  1  4  5  6  7  8  9 12'
      chnp1 (2553) = 0
      chnar (2553) = 1
      chnpy (2553) = 0
      chnte (2553) = 0
      chnhe (2553) = 4
      chperm (2553) = 100
      chbirf (2553) = 3855
      chetat (2553) = 969
      chtn2i (2553) = 17
      chbiet (969) = 2553
c
c Aretes coupees :   2  3  5  6  7  8 10 11
      chclas (1782) = ' 8-00'
c Code des aretes coupees : 0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 0
      charde (1782)(1:24) = '  2  3  5  6  7  8 10 11'
      chnp1 (1782) = 0
      chnar (1782) = 1
      chnpy (1782) = 0
      chnte (1782) = 0
      chnhe (1782) = 4
      chperm (1782) = 10
      chbirf (1782) = 3855
      chetat (1782) = 970
      chtn2i (1782) = 17
      chbiet (970) = 1782
c
c ===========================================
c Classe d'equivalence  8-01
c
c Aretes coupees :   1  2  3  4  5  6  9 12
      chclas (2367) = ' 8-01'
c Code des aretes coupees : 1, 1, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1
      charde (2367)(1:24) = '  1  2  3  4  5  6  9 12'
      chnp1 (2367) = 1
      chnar (2367) = 20
      chnpy (2367) = 18
      chnte (2367) = 0
      chnhe (2367) = 0
      chperm (2367) = 0
      chbirf (2367) = 2367
      chetat (2367) = 971
      chtn2i (2367) = 210
      chbiet (971) = 2367
c
c Aretes coupees :   1  2  3  4  5  7 10 11
      chclas (1631) = ' 8-01'
c Code des aretes coupees : 1, 1, 1, 1, 1, 0, 1, 0, 0, 1, 1, 0
      charde (1631)(1:24) = '  1  2  3  4  5  7 10 11'
      chnp1 (1631) = 1
      chnar (1631) = 20
      chnpy (1631) = 18
      chnte (1631) = 0
      chnhe (1631) = 0
      chperm (1631) = 330
      chbirf (1631) = 2367
      chetat (1631) = 972
      chtn2i (1631) = 210
      chbiet (972) = 1631
c
c Aretes coupees :   1  2  3  4  6  8 10 11
      chclas (1711) = ' 8-01'
c Code des aretes coupees : 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0
      charde (1711)(1:24) = '  1  2  3  4  6  8 10 11'
      chnp1 (1711) = 1
      chnar (1711) = 20
      chnpy (1711) = 18
      chnte (1711) = 0
      chnhe (1711) = 0
      chperm (1711) = 310
      chbirf (1711) = 2367
      chetat (1711) = 973
      chtn2i (1711) = 210
      chbiet (973) = 1711
c
c Aretes coupees :   1  2  3  4  7  8  9 12
      chclas (2511) = ' 8-01'
c Code des aretes coupees : 1, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1
      charde (2511)(1:24) = '  1  2  3  4  7  8  9 12'
      chnp1 (2511) = 1
      chnar (2511) = 20
      chnpy (2511) = 18
      chnte (2511) = 0
      chnhe (2511) = 0
      chperm (2511) = 300
      chbirf (2511) = 2367
      chetat (2511) = 974
      chtn2i (2511) = 210
      chbiet (974) = 2511
c
c Aretes coupees :   1  2  5  6  7  8  9 10
      chclas (1011) = ' 8-01'
c Code des aretes coupees : 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0
      charde (1011)(1:24) = '  1  2  5  6  7  8  9 10'
      chnp1 (1011) = 1
      chnar (1011) = 20
      chnpy (1011) = 18
      chnte (1011) = 0
      chnhe (1011) = 0
      chperm (1011) = 30
      chbirf (1011) = 2367
      chetat (1011) = 975
      chtn2i (1011) = 210
      chbiet (975) = 1011
c
c Aretes coupees :   1  3  5  6  7  8  9 11
      chclas (1525) = ' 8-01'
c Code des aretes coupees : 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0
      charde (1525)(1:24) = '  1  3  5  6  7  8  9 11'
      chnp1 (1525) = 1
      chnar (1525) = 20
      chnpy (1525) = 18
      chnte (1525) = 0
      chnhe (1525) = 0
      chperm (1525) = 10
      chbirf (1525) = 2367
      chetat (1525) = 976
      chtn2i (1525) = 210
      chbiet (976) = 1525
c
c Aretes coupees :   1  4  5  6  9 10 11 12
      chclas (3897) = ' 8-01'
c Code des aretes coupees : 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1
      charde (3897)(1:24) = '  1  4  5  6  9 10 11 12'
      chnp1 (3897) = 1
      chnar (3897) = 20
      chnpy (3897) = 18
      chnte (3897) = 0
      chnhe (3897) = 0
      chperm (3897) = 100
      chbirf (3897) = 2367
      chetat (3897) = 977
      chtn2i (3897) = 210
      chbiet (977) = 3897
c
c Aretes coupees :   1  4  7  8  9 10 11 12
      chclas (4041) = ' 8-01'
c Code des aretes coupees : 1, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 1
      charde (4041)(1:24) = '  1  4  7  8  9 10 11 12'
      chnp1 (4041) = 1
      chnar (4041) = 20
      chnpy (4041) = 18
      chnte (4041) = 0
      chnhe (4041) = 0
      chperm (4041) = 200
      chbirf (4041) = 2367
      chetat (4041) = 978
      chtn2i (4041) = 210
      chbiet (978) = 4041
c
c Aretes coupees :   2  3  5  7  9 10 11 12
      chclas (3926) = ' 8-01'
c Code des aretes coupees : 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1
      charde (3926)(1:24) = '  2  3  5  7  9 10 11 12'
      chnp1 (3926) = 1
      chnar (3926) = 20
      chnpy (3926) = 18
      chnte (3926) = 0
      chnhe (3926) = 0
      chperm (3926) = 130
      chbirf (3926) = 2367
      chetat (3926) = 979
      chtn2i (3926) = 210
      chbiet (979) = 3926
c
c Aretes coupees :   2  3  6  8  9 10 11 12
      chclas (4006) = ' 8-01'
c Code des aretes coupees : 0, 1, 1, 0, 0, 1, 0, 1, 1, 1, 1, 1
      charde (4006)(1:24) = '  2  3  6  8  9 10 11 12'
      chnp1 (4006) = 1
      chnar (4006) = 20
      chnpy (4006) = 18
      chnte (4006) = 0
      chnhe (4006) = 0
      chperm (4006) = 110
      chbirf (4006) = 2367
      chetat (4006) = 980
      chtn2i (4006) = 210
      chbiet (980) = 4006
c
c Aretes coupees :   2  4  5  6  7  8 10 12
      chclas (2810) = ' 8-01'
c Code des aretes coupees : 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1
      charde (2810)(1:24) = '  2  4  5  6  7  8 10 12'
      chnp1 (2810) = 1
      chnar (2810) = 20
      chnpy (2810) = 18
      chnte (2810) = 0
      chnhe (2810) = 0
      chperm (2810) = 230
      chbirf (2810) = 2367
      chetat (2810) = 981
      chtn2i (2810) = 210
      chbiet (981) = 2810
c
c Aretes coupees :   3  4  5  6  7  8 11 12
      chclas (3324) = ' 8-01'
c Code des aretes coupees : 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1
      charde (3324)(1:24) = '  3  4  5  6  7  8 11 12'
      chnp1 (3324) = 1
      chnar (3324) = 20
      chnpy (3324) = 18
      chnte (3324) = 0
      chnhe (3324) = 0
      chperm (3324) = 210
      chbirf (3324) = 2367
      chetat (3324) = 982
      chtn2i (3324) = 210
      chbiet (982) = 3324
c
c ===========================================
c Classe d'equivalence  9-00
c
c Aretes coupees :   1  2  3  4  5  6  7  9 10
      chclas (895) = ' 9-00'
c Code des aretes coupees : 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 0
      charde (895)(1:27) = '  1  2  3  4  5  6  7  9 10'
      chnp1 (895) = 1
      chnar (895) = 23
      chnpy (895) = 21
      chnte (895) = 0
      chnhe (895) = 0
      chperm (895) = 0
      chbirf (895) = 895
      chetat (895) = 983
      chtn2i (895) = 210
      chbiet (983) = 895
c
c Aretes coupees :   1  2  3  4  5  6  8  9 11
      chclas (1471) = ' 9-00'
c Code des aretes coupees : 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 0
      charde (1471)(1:27) = '  1  2  3  4  5  6  8  9 11'
      chnp1 (1471) = 1
      chnar (1471) = 23
      chnpy (1471) = 21
      chnte (1471) = 0
      chnhe (1471) = 0
      chperm (1471) = 10
      chbirf (1471) = 895
      chetat (1471) = 984
      chtn2i (1471) = 210
      chbiet (984) = 1471
c
c Aretes coupees :   1  2  3  4  5  7  8 10 12
      chclas (2783) = ' 9-00'
c Code des aretes coupees : 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 0, 1
      charde (2783)(1:27) = '  1  2  3  4  5  7  8 10 12'
      chnp1 (2783) = 1
      chnar (2783) = 23
      chnpy (2783) = 21
      chnte (2783) = 0
      chnhe (2783) = 0
      chperm (2783) = 300
      chbirf (2783) = 895
      chetat (2783) = 985
      chtn2i (2783) = 210
      chbiet (985) = 2783
c
c Aretes coupees :   1  2  3  4  6  7  8 11 12
      chclas (3311) = ' 9-00'
c Code des aretes coupees : 1, 1, 1, 1, 0, 1, 1, 1, 0, 0, 1, 1
      charde (3311)(1:27) = '  1  2  3  4  6  7  8 11 12'
      chnp1 (3311) = 1
      chnar (3311) = 23
      chnpy (3311) = 21
      chnte (3311) = 0
      chnhe (3311) = 0
      chperm (3311) = 310
      chbirf (3311) = 895
      chetat (3311) = 986
      chtn2i (3311) = 210
      chbiet (986) = 3311
c
c Aretes coupees :   1  2  5  6  7  9 10 11 12
      chclas (3955) = ' 9-00'
c Code des aretes coupees : 1, 1, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1
      charde (3955)(1:27) = '  1  2  5  6  7  9 10 11 12'
      chnp1 (3955) = 1
      chnar (3955) = 23
      chnpy (3955) = 21
      chnte (3955) = 0
      chnhe (3955) = 0
      chperm (3955) = 100
      chbirf (3955) = 895
      chetat (3955) = 987
      chtn2i (3955) = 210
      chbiet (987) = 3955
c
c Aretes coupees :   1  3  5  6  8  9 10 11 12
      chclas (4021) = ' 9-00'
c Code des aretes coupees : 1, 0, 1, 0, 1, 1, 0, 1, 1, 1, 1, 1
      charde (4021)(1:27) = '  1  3  5  6  8  9 10 11 12'
      chnp1 (4021) = 1
      chnar (4021) = 23
      chnpy (4021) = 21
      chnte (4021) = 0
      chnhe (4021) = 0
      chperm (4021) = 110
      chbirf (4021) = 895
      chetat (4021) = 988
      chtn2i (4021) = 210
      chbiet (988) = 4021
c
c Aretes coupees :   2  4  5  7  8  9 10 11 12
      chclas (4058) = ' 9-00'
c Code des aretes coupees : 0, 1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1
      charde (4058)(1:27) = '  2  4  5  7  8  9 10 11 12'
      chnp1 (4058) = 1
      chnar (4058) = 23
      chnpy (4058) = 21
      chnte (4058) = 0
      chnhe (4058) = 0
      chperm (4058) = 200
      chbirf (4058) = 895
      chetat (4058) = 989
      chtn2i (4058) = 210
      chbiet (989) = 4058
c
c Aretes coupees :   3  4  6  7  8  9 10 11 12
      chclas (4076) = ' 9-00'
c Code des aretes coupees : 0, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1
      charde (4076)(1:27) = '  3  4  6  7  8  9 10 11 12'
      chnp1 (4076) = 1
      chnar (4076) = 23
      chnpy (4076) = 21
      chnte (4076) = 0
      chnhe (4076) = 0
      chperm (4076) = 210
      chbirf (4076) = 895
      chetat (4076) = 990
      chtn2i (4076) = 210
      chbiet (990) = 4076
c
c ===========================================
c Classe d'equivalence 12-00
c
c Aretes coupees :   1  2  3  4  5  6  7  8  9 10 11 12
      chclas (4095) = '12-00'
c Code des aretes coupees : 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
      charde (4095)(1:36) = '  1  2  3  4  5  6  7  8  9 10 11 12'
      chnp1 (4095) = 1
      chnar (4095) = 6
      chnpy (4095) = 0
      chnte (4095) = 0
      chnhe (4095) = 8
      chperm (4095) = 0
      chbirf (4095) = 4095
      chetat (4095) = 8
      chtn2i (4095) = 6
      chbiet (8) = 4095
