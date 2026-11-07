c
c=======================================================================
c declaration de variables du format MED
c cet include est deduit de l'include med.h de la bibliotheque med 4.0
c
c     MED_FULL_INTERLACE/edfuin :
c Exemple avec 3 composantes X,Y,Z : X1Y1Z1X2Y2Z2X3Y3Z3...
c Exemple avec 3 MED_TRIA3 T1,T2,T3 : N11N12N13 N21N22N23 N31N32N33
c     MED_NO_INTERLACE/ednoin :
c Exemple avec 3 composantes X,Y,Z : X1X2X3Y1Y2Y3Z1Z2Z3...
c Exemple avec 3 MED_TRIA3 T1,T2,T3 : N11N21N31 N12N22N32 N13N23N33
c
      integer edfuin, ednoin
      parameter (
     >            edfuin = 0,
     >            ednoin = 1
     > )
c
c Indique le mode de stockage utilise par l'application.
c     MED_UNDEF_STMODE/edstmo :
c Mode de stockage en memoire non initialise
c     MED_GLOBAL_STMODE/edstgl :
c Le stockage utilise contient en memoire toutes les valeurs
c relatives a toutes les entites d'un meme type
c     MED_COMPACT_STMODE/edstco :
c Le stockage utilise contient en memoire contigüe un sous-ensemble
c de valeurs relatives a un sous-ensemble d'entites d'un meme type.
c
      integer edstmo, edstgl, edstco
      parameter (
     >            edstmo = 0,
     >            edstgl = 1,
     >            edstco = 2
     > )
c
c     MED_ACC_RDONLY/edlect : Ouverture en lecture seule
c     MED_ACC_RDWR/edrdwr : Ouverture en lecture/ecriture
c                   . si un element existe, il est ecrase
c     MED_ACC_RDEXT/edrdex : Ouverture en lecture/ecriture
c                   . l'ecriture d'un objet existant provoque une erreur
c     MED_ACC_CREAT/edcrea : Cree le fichier s'il n'existe pas, l'ecrase
c                            sinon
c
      integer edlect, edrdwr, edrdex, edcrea
      parameter (
     >            edlect = 0,
     >            edrdwr = 1,
     >            edrdex = 2,
     >            edcrea = 3
     > )
c
c     MED_NON_STRUCTURE/ednost : maillage non structure
c     MED_STRUCTURE/edmast : maillage  structure
c
      integer ednost, edmast
      parameter (
     >            ednost = 0,
     >            edmast = 1
     > )
c
c     MED_MAIL/edmail
c     MED_FACE/edface
c     MED_ARET/edaret
c     MED_NOEU/ednoeu
c     MED_NOEU_MAILLE/ednoma
      integer edmail, edface, edaret, ednoeu, ednoma
      parameter (
     >            edmail = 0,
     >            edface = 1,
     >            edaret = 2,
     >            ednoeu = 3,
     >            ednoma = 4
     > )
c
c     MED_COOR/edcoor
c     MED_CONN/edconn
c     MED_NOM/ednom
c     MED_NUM/ednum
c     MED_FAM/edfam
      integer edcoor, edconn, ednom, ednum, edfam
      parameter (
     >            edcoor = 0,
     >            edconn = 1,
     >            ednom  = 2,
     >            ednum  = 3,
     >            edfam  = 4
     > )
c
c     MED_FLOAT64/edfl64
c     MED_INT32/edin32
c     MED_INT64/edin64
c     MED_INT/edint
      integer edfl64, edin32, edin64, edint
      parameter (
     >            edfl64 = 6,
     >            edin32 = 24,
     >            edin64 = 26,
     >            edint  = 28
     > )
c
c     MED_NBR_GEOMETRIE_MAILLE/edgema
c     MED_NBR_GEOMETRIE_FACE/edgefa
c     MED_NBR_GEOMETRIE_ARETE/edgear
      integer edgema, edgefa, edgear
      parameter (
     >            edgema = 15,
     >            edgefa = 4,
     >            edgear = 2
     > )
c
c     MED_POINT1
c     MED_SEG2
c     MED_SEG3
c     MED_SEG4
c     MED_TRIA3, MED_QUAD4
c     MED_TRIA6, MED_QUAD8
c     MED_TETRA4,  MED_PYRA5,  MED_PENTA6,  MED_HEXA8
c     MED_TETRA10, MED_PYRA13, MED_PENTA15, MED_HEXA20
c     MED_POLYGONE, MED_POLYEDRE
c
      integer edpoi1,
     >        edseg2, edseg3, edseg4,
     >        edtri3, edtri6, edtri7,
     >        edqua4, edqua8, edqua9,
     >        edtet4, edte10,
     >        edpyr5, edpy13,
     >        edpen6, edpe15, edpe18,
     >        edhex8, edhe20, edhe27
      parameter (
     >            edpoi1 = 1,
     >            edseg2 = 102,
     >            edseg3 = 103,
     >            edseg4 = 104,
     >            edtri3 = 203,
     >            edtri6 = 206,
     >            edtri7 = 207,
     >            edqua4 = 204,
     >            edqua8 = 208,
     >            edqua9 = 209,
     >            edtet4 = 304,
     >            edte10 = 310,
     >            edpyr5 = 305,
     >            edpy13 = 313,
     >            edpen6 = 306,
     >            edpe15 = 315,
     >            edpe18 = 318,
     >            edhex8 = 308,
     >            edhe20 = 320,
     >            edhe27 = 327
     > )
c
c     MED_NOD/ednoda
c     MED_DESC/eddesc
      integer ednoda, eddesc
      parameter (
     >            ednoda = 0,
     >            eddesc = 1
     > )
c
c     MED_CART/edcart
c     MED_CYL/edcyli
c     MED_SPHER/edsphe
      integer edcart, edcyli, edsphe
      parameter (
     >            edcart = 0,
     >            edcyli = 1,
     >            edsphe = 2
     > )
c
c     MED_COMP/edcomp
c     MED_DTYPE/eddtyp
      integer edcomp, eddtyp
      parameter (
     >            edcomp = 0,
     >            eddtyp = 1
     > )
c
c     MED_GROUPE/edgrou
c     MED_ATTR/edattr
c     MED_FAMILLE/edfami
      integer edgrou, edattr, edfami
      parameter (
     >            edgrou = 0,
     >            edattr = 1,
     >            edfami = 2
     > )
c
c     MED_HDF_VERSION/edhdve
c     MED_VERSION/ededve
c     MED_FICH_DES/edfide
      integer edhdve, ededve, edfide
      parameter (
     >            edhdve = 0,
     >            ededve = 1,
     >            edfide = 2
     > )
c
c     MED_NOPG/ednopg
c     MED_NOGAUSS/ednoga
c     MED_GAUSS_ELNO/edngen
c     MED_NOPF/ednopf
c     MED_NOPFL/ednopl
c     MED_NONOR/ednonr
c     MED_ALL/edall
      character*64 ednoga, edngen, ednopl
      integer ednopg, ednopf, ednonr, edall
      parameter (
     >            ednopg = 1,
     >            ednoga = blan64,
     >            edngen =
     >'MED_GAUSS_ELNO                                                  '
     >            ,
     >            ednopf = 0,
     >            ednopl = blan64,
     >            ednonr = -1,
     >            edall  = 0
     > )
c      1234567890123456789012345678901234567890123456789012345678901234
c
c     MED_NO_DT/ednodt
c     MED_NO_IT/ednoit
c     MED_UNDEF_DT/edundt
      integer ednodt, ednoit
      double precision edundt
      parameter (
     >            ednodt = -1,
     >            ednoit = -1,
     >            edundt = 1.7921958d15
     > )
c
c     MED_SORT_DTIT/edsodi
c     MED_SORT_ITDT/edsoid
c     MED_SORT_UNDEF/edsoun
      integer edsodi, edsoid, edsoun
      parameter (
     >            edsodi =  0,
     >            edsoid =  1,
     >            edsoun = -1
     > )
c
c     MED_COORDINATE/edda00
c     MED_CONNECTIVITY/edda01
c     MED_NAME/
c     MED_NUMBER/edda03
c     MED_FAMILY_NUMBER/edda04
c     MED_COORDINATE_AXIS1
c     MED_COORDINATE_AXIS2
c     MED_COORDINATE_AXIS3
c     MED_INDEX_FACE
c     MED_INDEX_NODE
c     MED_GLOBAL_STMODE_NUMBER/edda10
c     MED_VARIABLE_ATTRIBUTE
c     MED_COORDINATE_TRSF
c     MED_UNDEF_DATATYPE/eddaty
      integer edda00, edda01, edda03, edda04, edda10
      integer eddaty
      parameter (
     >            edda00 =   0,
     >            edda01 =   1,
     >            edda03 =   3,
     >            edda04 =   4,
     >            edda10 =  10,
     >            eddaty = -1
     > )
c
c     MED_FALSE/edfals
c     MED_TRUE/edtrue
      integer edfals, edtrue
      parameter (
     >            edfals = 0,
     >            edtrue = 1
     > )
c
c     MED_RETERREUR/edreer
c     MED_EXIT/edexit
      integer edreer, edexit
      parameter (
     >            edreer = 0,
     >            edexit = 1
     > )
