      subroutine cmin00 ( option,
     >                    degre, homolo,
     >                    eancno, nbnoan, nbnono,
     >                    eancar, nbaran, nbarno,
     >                    eanctr, nbtran, nbtrno,
     >                    eancqu, nbquan, nbquno,
     >                    eancte, nbtean, nbteno,
     >                    eanche, nbhean, nbheno,
     >                    eancpe, nbpean, nbpeno,
     >                    eancpy, nbpyan, nbpyno,
     >                    decfac,
     >                    ancnoe, noehom,
     >                    ancare, arehom, np2are,
     >                    anctri, trihom,
     >                    ancqua, quahom,
     >                    anctet, anchex,
     >                    ancpen, ancpyr )
c ______________________________________________________________________
c
c                             H O M A R D
c
c Outil de Maillage Adaptatif par Raffinement et Deraffinement d'EDF R&D
c
c Version originale enregistree le 18 juin 1996 sous le numero 96036
c aupres des huissiers de justice Simart et Lavoir a Clamart
c Version 11.2 enregistree le 13 fevrier 2015 sous le numero 2015/014
c aupres des huissiers de justice
c Lavoir, Silinski & Cherqui-Abrahmi a Clamart
c
c    HOMARD est une marque deposee d'Electricite de France
c
c Copyright EDF 1996
c Copyright EDF 1998
c Copyright EDF 2002
c Copyright EDF 2020
c ______________________________________________________________________
c
c    Creation du Maillage - INitialisation - 00
c    -           -          --               --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .    1   . type de traitement                         .
c .        .     .        . 0 : raffinement                            .
c .        .     .        . 1 : deraffinement                          .
c .        .     .        . 2 : conformite                             .
c . eancno . e   . logique. vrai si ancnoe existe, faux sinon          .
c . nbnoan . e   .    1   . nombre de noeuds - ancien                  .
c . nbnono . e   .    1   . nombre de noeuds - nouveau                 .
c . eancar . e   . logique. vrai si ancare existe, faux sinon          .
c . nbaran . e   .    1   . nombre d'aretes - ancien                   .
c . nbarno . e   .    1   . nombre d'aretes - nouveau                  .
c . eanctr . e   . logique. vrai si anctri existe, faux sinon          .
c . nbtran . e   .    1   . nombre de triangles - ancien               .
c . nbtrno . e   .    1   . nombre de triangles - nouveau              .
c . eancqu . e   . logique. vrai si ancqua existe, faux sinon          .
c . nbquan . e   .    1   . nombre de quadrangles - ancien             .
c . nbquno . e   .    1   . nombre de quadrangles - nouveau            .
c . eancte . e   . logique. vrai si anctet existe, faux sinon          .
c . nbtean . e   .    1   . nombre de tetraedres - ancien              .
c . nbteno . e   .    1   . nombre de tetraedres - nouveau             .
c . eanche . e   . logique. vrai si anchex existe, faux sinon          .
c . nbhean . e   .    1   . nombre d'hexaedres - ancien                .
c . nbheno . e   .    1   . nombre d'hexaedres - nouveau               .
c . eancpe . e   . logique. vrai si ancpen existe, faux sinon          .
c . nbpean . e   .    1   . nombre de pentaedres - ancien              .
c . nbpeno . e   .    1   . nombre de pentaedres - nouveau             .
c . eancpy . e   . logique. vrai si ancpyr existe, faux sinon          .
c . nbpyan . e   .    1   . nombre de pyramides - ancien               .
c . nbpyno . e   .    1   . nombre de pyramides - nouveau              .
c . decfac . es  . -nbquno. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrno.                                            .
c . ancnoe . es  . nouvno . ancien numero des noeuds                   .
c . noehom . es  . nbnono . ensemble des noeuds homologues             .
c . ancare . es  . nouvar . ancien numero des aretes                   .
c . arehom . es  . nbarno . ensemble des aretes homologues             .
c . np2are . es  . nbarno . numero des noeuds p2 milieux d'aretes      .
c .        .     .        . ou 0 lorsqu'on est en degre 1              .
c . anctri . es  . nbtrno . ancien numero des triangles                .
c . trihom . es  . nbtrno . ensemble des triangles homologues          .
c . ancqua . es  . nbquno . ancien numero des quadrangles              .
c . quahom . es  . nbquno . ensemble des quadrangles homologues        .
c . anctet . es  . nbteno . ancien numero des tetraedres               .
c . anchex . es  . nbheno . ancien numero des hexaedres                .
c . ancpen . es  . nbpeno . ancien numero des pentaedres               .
c . ancpyr . es  . nbpyno . ancien numero des pyramides                .
c ______________________________________________________________________
c
c====
c 0. declarations et dimensionnement
c====
c
c 0.1. ==> generalites
c
      implicit none
      save
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer option
      integer degre, homolo
c
      logical eancno, eancar, eanctr, eancqu
      logical eancte, eanche, eancpe, eancpy
      integer nbnoan, nbnono
      integer nbaran, nbarno
      integer nbtran, nbtrno
      integer nbquan, nbquno
      integer nbtean, nbteno
      integer nbhean, nbheno
      integer nbpean, nbpeno
      integer nbpyan, nbpyno
c
      integer decfac(-nbquno:nbtrno)
      integer ancnoe(nbnono), noehom(nbnono)
      integer ancare(nbarno), arehom(nbarno), np2are(nbarno)
      integer anctri(nbtrno), trihom(nbtrno)
      integer ancqua(nbquno), quahom(nbquno)
      integer anctet(nbteno)
      integer anchex(nbheno)
      integer ancpen(nbpeno)
      integer ancpyr(nbpyno)
c
c 0.4. ==> variables locales
c
      integer ideb, ifin
      integer iaux
c ______________________________________________________________________
c
c====
c 1. pas d'ancien numeros pour les futures entites
c====
c
      if ( eancno ) then
c
        ideb = nbnoan + 1
        ifin = nbnono
c
        do 11 , iaux = ideb , ifin
          ancnoe(iaux) = -1
   11   continue
c
      endif
c
      if ( eancar ) then
c
        ideb = nbaran + 1
        ifin = nbarno
c
        do 12 , iaux = ideb , ifin
          ancare(iaux) = -1
   12   continue
c
      endif
c
      if ( eanctr ) then
c
        ideb = nbtran + 1
        ifin = nbtrno
c
        do 13 , iaux = ideb , ifin
          anctri(iaux) = -1
   13   continue
c
      endif
c
      if ( eancqu ) then
c
        ideb = nbquan + 1
        ifin = nbquno
c
        do 14 , iaux = ideb , ifin
          ancqua(iaux) = -1
   14   continue
c
      endif
c
      if ( eancte ) then
c
        ideb = nbtean + 1
        ifin = nbteno
c
        do 15 , iaux = ideb , ifin
          anctet(iaux) = -1
   15   continue
c
      endif
c
      if ( eanche ) then
c
        ideb = nbhean + 1
        ifin = nbheno
c
        do 16 , iaux = ideb , ifin
          anchex(iaux) = -1
 16     continue
c
      endif
c
      if ( eancpe ) then
c
        ideb = nbpean + 1
        ifin = nbpeno
c
        do 17 , iaux = ideb , ifin
          ancpen(iaux) = -1
 17     continue
c
      endif
c
      if ( eancpy ) then
c
        ideb = nbpyan + 1
        ifin = nbpyno
c
        do 18 , iaux = ideb , ifin
          ancpyr(iaux) = -1
   18   continue
c
      endif
c
c====
c 2. mise a zero eventuelle des tables pour le degre 2
c====
c
      if ( degre.eq.2 ) then
c
        ideb = nbaran + 1
        ifin = nbarno
c
        do 21 , iaux = ideb , ifin
          np2are(iaux) = 0
   21   continue
c
      endif
c
c====
c 3. mise a zero eventuelle des tables pour les homologues
c====
c
      if ( homolo.ge.1 ) then
c
        ideb = nbnoan + 1
        ifin = nbnono
c
        do 31 , iaux = ideb , ifin
          noehom(iaux) = 0
   31   continue
c
      endif
c
      if ( homolo.ge.2 ) then
c
        ideb = nbaran + 1
        ifin = nbarno
c
        do 32 , iaux = ideb , ifin
          arehom(iaux) = 0
   32   continue
c
      endif
c
      if ( homolo.ge.3 ) then
c
        ideb = nbtran + 1
        ifin = nbtrno
c
        do 33 , iaux = ideb , ifin
          trihom(iaux) = 0
   33   continue
c
        ideb = nbquan + 1
        ifin = nbquno
c
        do 34 , iaux = ideb , ifin
          quahom(iaux) = 0
   34   continue
c
      endif
c
c====
c 4. mise a zero des decisions sur les futures faces
c====
c
      if ( option.eq.0 ) then
c
        ideb = nbtran + 1
        ifin = nbtrno
c
        do 41 , iaux = ideb , ifin
          decfac(iaux) = 0
   41   continue
c
        ideb = -nbquno
        ifin = -nbquan - 1
c
        do 42 , iaux = ideb , ifin
          decfac(iaux) = 0
   42   continue
c
      endif
c
      end
