      subroutine pcseh9 ( etan, etanp1, hehn, hehnp1, typint,
     >                    f1hp, nrofon, valeur, coef, prfcap,
     >                    ficp, propor,
     >                    coonoe, somare, aretri, arequa,
     >                    tritet, cotrte, aretet,
     >                    quahex, coquhe, arehex,
     >                    facpyr, cofapy, arepyr,
     >                    hethex, filhex, fhpyte,
     >                    nhesca,
     >                    ntesca,
     >                    npysca,
     >                    nbfonc, vafott,
     >                    prftep, vatett,
     >                    prfpyp, vapytt,
     >                    ulsort, langue, codret )
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
c    aPres adaptation - Conversion de Solution Elements de volume -
c     -                 -             -        -
c                       Hexaedres d'etat 80
c                       -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . etan   . e   .    1   . ETAt de l'hexaedre a l'iteration N         .
c . etanp1 . e   .    1   . ETAt du hexaedre a l'iteration N+1         .
c . hehn   . e   .    1   . Hexaedre courant en numerotation Homard    .
c .        .     .        . a l'iteration N                            .
c . hehnp1 . e   .    1   . Hexaedre courant en numerotation Homard    .
c .        .     .        . a l'iteration N+1                          .
c . typint . e   .   1    . type d'interpolation                       .
c .        .     .        .  0, si automatique                         .
c .        .     .        .  elements : 0 si intensif, sans orientation.
c .        .     .        .             1 si extensif, sans orientation.
c .        .     .        .             2 si intensif, avec orientation.
c .        .     .        .             3 si extensif, avec orientation.
c .        .     .        .  noeuds : 1 si degre 1                     .
c .        .     .        .           2 si degre 2                     .
c .        .     .        .           3 si iso-P2                      .
c . f1hp   . e   .    1   . Fils 1er de l'hexaedre en numerotation     .
c .        .     .        . Homard a l'iteration N+1                   .
c . nrofon . e   .    1   . numero de la fonction en cours d'examen    .
c . valeur . e   .    1   . valeur de la fonction en cours d'examen    .
c . coef   . e   .    1   . coefficient pour la moyenne                .
c . prfcap . es  .   *    . En numero du calcul a l'iteration n+1 :    .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . ficp   . e   .  3,18  . fils en numerotation du calcul n+1         .
c .        .     .        . 1 : hexaedres                              .
c .        .     .        . 2 : pyramides                              .
c .        .     .        . 3 : tetraedres                             .
c . propor . e   .   18   . proportion de volume entre fils et pere    .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. code des 4 triangles des tetraedres        .
c . aretet . e   .nbteca*6. numeros des 6 aretes des tetraedres        .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . arehex . e   .nbheca12. numeros des 12 aretes des hexaedres        .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des faces des pyramides              .
c . arepyr . e   .nbpyca*8. numeros des 8 aretes des pyramides         .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . filhex . e   . nbheto . premier fils des hexaedres                 .
c . fhpyte . e   .2*nbheco. fhpyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille de l'hexaedre k tel que filhex(k) =-j.
c .        .     .        . fhpyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils de l'hexaedre k tel que filhex(k) = -j.
c . nhesca . e   . rsteto . numero des hexaedres dans le calcul sortie .
c . ntesca . e   . rsteto . numero des tetraedres dans le calcul sortie.
c . npysca . e   . rspyto . numero des pyramides dans le calcul sortie .
c . nbfonc . e   .    1   . nombre de fonctions elements de volume     .
c . vafott . es  . nbfonc*. variables en sortie de l'adaptation        .
c .        .     . nbevso .                                            .
c . prftep . es  .   *    . En numero du calcul a l'iteration n+1 :    .
c .        .     .        . 0 : le tetraedre est absent du profil      .
c .        .     .        . 1 : le tetraedre est present dans le profil.
c . vatett .   a . nbfonc*. tableau temporaire de la solution pour     .
c .        .     .    *   . les tetraedres                             .
c . prfpyp . es  .   *    . En numero du calcul a l'iteration n+1 :    .
c .        .     .        . 0 : la pyramide est absente du profil      .
c .        .     .        . 1 : la pyramide est presente dans le profil
c . vapytt .   a . nbfonc*. tableau temporaire de la solution pour     .
c .        .     .    *   . les pyramides                              .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
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
      character*6 nompro
      parameter ( nompro = 'PCSEH9' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envca1.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombsr.h"
c
c 0.3. ==> arguments
c
      integer etan, etanp1, hehn, hehnp1
      integer typint
      integer f1hp, nrofon
      integer nbfonc
      integer prfcap(*)
      integer ficp(3,18)
c
      integer somare(2,nbarto)
      integer aretri(nbtrto,3)
      integer arequa(nbquto,4)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
      integer quahex(nbhecf,6), coquhe(nbhecf,6), arehex(nbheca,12)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5), arepyr(nbpyca,8)
c
      integer hethex(nbheto)
      integer filhex(nbheto), fhpyte(2,nbheco)
      integer nhesca(rsheto)
      integer ntesca(rsteto)
      integer npysca(rspyto)
      integer prftep(*)
      integer prfpyp(*)
c
      double precision valeur, coef
c
      double precision propor(18)
      double precision coonoe(nbnoto,sdim)
      double precision vafott(nbfonc,*)
      double precision vatett(nbfonc,*)
      double precision vapytt(nbfonc,*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer fihp
      integer etatfi
c
      integer nfhexf, nfpyrf, nftetf
      integer ficf(3,18)
c
      double precision daux
      double precision propof(18)
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =
     >'(/,''Hexa. en cours : numero a l''''iteration '',a3,'' : '',i10)'
      texte(1,5) =
     >'(  ''                 etat a l''''iteration '',a3,''   : '',i4)'
c
      texte(2,4) =
     >'(/,''Current hexahedron : # at iteration '',a3,''     : '',i10)'
      texte(2,5) =
     > '(  ''                     status at iteration '',a3,'' : '',i4)'
c
c====
c 2. Exploration des 8 fils
c====
c
      do 20 , iaux = 0 , 7
c
        if ( codret.eq.0 ) then
c
        fihp = f1hp + iaux
        etatfi = mod(hethex(fihp),1000)
cgn            write (ulsort,*) '. fihp', fihp,', etat =', hethex(fihp)
c
c 2.1. ==> Le fils est actif
c
        if ( etatfi.eq.0 ) then
c
          if ( typint.eq.0 ) then
            daux = valeur*coef
          else
            daux = valeur*propor(iaux+1)
          endif
cgn              write (ulsort,*) '. ficp', ficp(1,iaux+1)
          vafott(nrofon,ficp(1,iaux+1)) = daux
          prfcap(ficp(1,iaux+1)) = 1
c
c 2.2. ==> Le fils est coupe en conformite
c
        elseif ( etatfi.ge.11 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'PCSEHY', nompro
#endif
          call pcsehy ( nfhexf, nfpyrf, nftetf, ficf,
     >                  fihp, etatfi,
     >                  filhex, fhpyte,
     >                  nhesca, ntesca, npysca,
     >                  ulsort, langue, codret )
c
          if ( typint.eq.0 ) then
c
            daux = valeur*coef
            do 2203 , jaux = 1 , nfpyrf
              vapytt(nrofon,ficf(2,jaux)) = daux
 2203       continue
            do 2204 , jaux = 1 , nftetf
              vatett(nrofon,ficf(3,jaux)) = daux
 2204       continue
c
          else
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'PCSEHZ', nompro
#endif
            call pcsehz ( propof,
     >                    fihp, etatfi,
     >                    coonoe, somare, aretri, arequa,
     >                    tritet, cotrte, aretet,
     >                    quahex, coquhe, arehex,
     >                    facpyr, cofapy, arepyr,
     >                    filhex, fhpyte,
     >                    ulsort, langue, codret )
c
            daux = valeur*propor(iaux+1)
            do 2213 , jaux = 1 , nfpyrf
              vapytt(nrofon,ficf(2,jaux)) = daux * propof(jaux)
 2213       continue
            do 2214 , jaux = 1 , nftetf
              vatett(nrofon,ficf(3,jaux)) = daux * propof(jaux+nfpyrf)
 2214       continue
c
          endif
c
          if ( codret.eq.0 ) then
c
          do 222 , jaux = 1 , nfpyrf
            prfpyp(ficf(2,jaux)) = 1
  222     continue
c
          do 223 , jaux = 1 , nftetf
            prftep(ficf(3,jaux)) = 1
  223     continue
c
          endif
c
        else
c
          codret = 1
          write (ulsort,texte(langue,4)) 'n  ', hehn
          write (ulsort,texte(langue,5)) 'n  ', etan
          write (ulsort,texte(langue,4)) 'n+1', hehnp1
          write (ulsort,texte(langue,5)) 'n+1', etanp1
c
        endif
c
        endif
c
   20 continue
c
c====
c 3. la fin
c====
c
      if ( codret.ne.0 ) then
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
