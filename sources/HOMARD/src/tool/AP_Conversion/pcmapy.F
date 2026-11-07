      subroutine pcmapy ( elemen, nbele0,
     >                    somare, np2are,
     >                    aretri,
     >                    facpyr, cofapy, arepyr,
     >                    hetpyr, fampyr, cfapyr,
     >                    nnosca, npysca, npysho,
     >                    famele, noeele, typele,
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
c    aPres adaptation - Conversion - MAillage connectivite - PYramides
c     -                 -            --                      --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . elemen . es  .   1    . numero du dernier element cree             .
c . nbele0 . e   .   1    . estimation du nombre d'elements            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . np2are . e   . nbarto . numero du noeud p2 milieu d'arete          .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des faces des pyramides              .
c . arepyr . e   .nbpyca*8. numeros des 8 aretes des pyramides         .
c . hetpyr . e   . nbpyto . historique de l'etat des pyramides         .
c . fampyr . e   . nbpyto . famille des pyramides                      .
c . cfapyr .     . nctfhe. codes des familles des pyramides            .
c .        .     . nbfpyr .   1 : famille MED                          .
c .        .     .        .   2 : type d'pyramides                     .
c . nnosca . e   . rsnoto . numero des noeuds du code de calcul        .
c . npysca .  s  . rspyto . numero des pyramides dans le calcul sortie .
c . npysho .  s  . nbele0 . numero des pyramides dans HOMARD           .
c . famele . es  . nbele0 . famille med des elements                   .
c . noeele . es  . nbele0 . noeuds des elements                        .
c .        .     . *nbmane.                                            .
c . typele . es  . nbele0 . type des elements                          .
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
      parameter ( nompro = 'PCMAPY' )
c
#include "nblang.h"
#include "coftex.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
#include "envca1.h"
c
#include "nbfami.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombpy.h"
c
#include "nombsr.h"
c
#include "dicfen.h"
c
c 0.3. ==> arguments
c
      integer elemen
      integer nbele0
c
      integer somare(2,nbarto), np2are(nbarto)
      integer aretri(nbtrto,3)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5), arepyr(nbpyca,8)
      integer hetpyr(nbpyto)
c
      integer cfapyr(nctfpy,nbfpyr), fampyr(nbpyto)
c
      integer nnosca(rsnoto)
      integer npysca(rspyto), npysho(nbele0)
c
      integer famele(nbele0), noeele(nbele0,nbmane)
      integer typele(nbele0)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer lapyra, lapyr0
      integer etat
      integer iaux
      integer listar(8), listso(13), nomiar(8)
c
      integer nbmess
      parameter ( nbmess = 20 )
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
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'nbpycf, nbpyca', nbpycf, nbpyca
      write(ulsort,90002) 'nbele0, nbmane', nbele0, nbmane
      write(ulsort,90002) 'degre', degre
cgn      write(ulsort,*) cfapyr
#endif
c
#include "impr06.h"
c
c====
c 2. initialisations des renumerotations
c====
c
      do 21 , iaux = 1 , rspyto
        npysca(iaux) = 0
   21 continue
c
      do 22 , iaux = 1 , nbele0
        npysho(iaux) = 0
   22 continue
c
c====
c 3. Conversion en lineaire
c====
c
      if ( degre.eq.1 ) then
c
c                            S5
c                            x
c                         . . . .
c                       .  .   .   .
c                     .   .     .     .
c                   .    .       .       .
c                 .     .        x .         .
c               .      .     .   S2    .        .
c             .       .  .                 .       .
c           .        .                         .      .
c         .      .  .                              .     .
c       .    .     .                                   .    .
c     .  .        .                                        .   .
c S1 .           .                                             .  .
c  x .         .                                                  .  .
c         .    .                                                      .
c             x--------------------------------------------------------x
c           S4                                                        S3
c
c    . Les noeuds (1,2,3,4) definissent un quadrangle a orientation
c      vers l'exterieur
c
        do 31 , lapyr0 = 1 , nbpyto
c
          lapyra = lapyr0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,11)) mess14(langue,2,5), lapyra
#endif
c
          etat = mod( hetpyr(lapyra) , 100 )
c
          if ( etat.eq.0 .or. hierar.ne.0 ) then
c
            elemen = elemen + 1
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,14)) elemen
#endif
            npysho(elemen) = lapyra
            npysca(lapyra) = elemen
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTASPY', nompro
#endif
            call utaspy ( lapyra,
     >                    nbtrto, nbpycf, nbpyca,
     >                    somare, aretri,
     >                    facpyr, cofapy, arepyr,
     >                    listar, listso )
c
cgn      write (ulsort,90002) 'listar', (listar(iaux),iaux = 1 , 8)
cgn      write (ulsort,90002) 'listso', (listso(iaux),iaux = 1 , 5)
c
c     Attention : utaspy donne la numerotation dans la convention homard
c                 il faut permuter les sommets 2/4 pour obtenir
c                 la numerotation dans la convention med
c
            noeele(elemen,1) = nnosca(listso(1))
            noeele(elemen,2) = nnosca(listso(4))
            noeele(elemen,3) = nnosca(listso(3))
            noeele(elemen,4) = nnosca(listso(2))
            noeele(elemen,5) = nnosca(listso(5))
c
            famele(elemen) = cfapyr(cofamd,fampyr(lapyra))
            typele(elemen) = cfapyr(cotyel,fampyr(lapyra))
c
#ifdef _DEBUG_HOMARD_
            if ( noeele(elemen,1).ne.-54117 ) then
            write (ulsort,*) 'fampyr = ', fampyr(lapyra)
            write (ulsort,texte(langue,14)) elemen
            write (ulsort,texte(langue,15))
     >             (noeele(elemen,iaux),iaux=1,5)
            write (ulsort,*) 'Famille MED = ',famele(elemen),
     >                       ', Type MED = ',typele(elemen)
            endif
#endif
c
          endif
c
  31   continue
c
c====
c 4. Conversion en quadratique
c====
c
      else
c
c                            S5
c                            x
c                         . . . .
c                       .  .   .   .
c                     .   .   N11     .
c                   .    .       .       .
c                 .     .        x .         .
c             N10.      .     .   S2    .        .N12
c             .       .  .                 .       .
c           .        .                         .      .
c         .      .  .N13                           .     .
c       .    .     .                            N7     .    .
c     .  .  N6    .                                        .   .
c S1 .           .                                             .  .
c  x .         .                                                  .  .
c         .    .                                                      .
c       N9    x--------------------------------------------------------x
c           S4                           N8                          S3
c
c    . Les noeuds (1,2,3,4) definissent un quadrangle a orientation
c      vers l'exterieur
c
c            Au sens homard      au sens MED
c          arete  1 de s1 a s5 | de s1 a s5
c          arete  2 de s2 a s5 | de s4 a s5
c          arete  3 de s3 a s5 | de s3 a s5
c          arete  4 de s4 a s5 | de s2 a s5
c          arete  5 de s1 a s2 | de s1 a s4
c          arete  6 de s2 a s3 | de s4 a s3
c          arete  7 de s3 a s4 | de s3 a s2
c          arete  8 de s4 a s1 | de s2 a s1
c       Tableau de travail nomiar :
c       nomiar(i) contient le numero local au sens MED du noeud porte
c       par l'arete de numero local i au sens homard
c
        nomiar( 1) = 10
        nomiar( 2) = 13
        nomiar( 3) = 12
        nomiar( 4) = 11
        nomiar( 5) =  9
        nomiar( 6) =  8
        nomiar( 7) =  7
        nomiar( 8) =  6
c
        do 41 , lapyr0 = 1 , nbpyto
c
          lapyra = lapyr0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,11)) mess14(langue,2,5), lapyra
#endif
c
          etat = mod( hetpyr(lapyra) , 100 )
c
          if ( etat.eq.0 .or. hierar.ne.0 ) then
c
            elemen = elemen + 1
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,14)) elemen
#endif
            npysho(elemen) = lapyra
            npysca(lapyra) = elemen
c
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTASPY', nompro
#endif
            call utaspy ( lapyra,
     >                    nbtrto, nbpycf, nbpyca,
     >                    somare, aretri,
     >                    facpyr, cofapy, arepyr,
     >                    listar, listso )
c
cgn      write (ulsort,90002) 'listar', (listar(iaux),iaux = 1 , 8)
cgn      write (ulsort,90002) 'listso', (listso(iaux),iaux = 1 , 5)
c
c     Attention : utaspy donne la numerotation dans la convention homard
c                 il faut permuter les sommets 2/4 pour obtenir la
c                 numerotation dans la convention med
c
            noeele(elemen,1) = nnosca(listso(1))
            noeele(elemen,2) = nnosca(listso(4))
            noeele(elemen,3) = nnosca(listso(3))
            noeele(elemen,4) = nnosca(listso(2))
            noeele(elemen,5) = nnosca(listso(5))
c
c     Les noeuds au milieu des aretes
c
            do 411 , iaux = 1 , 8
              noeele(elemen,nomiar(iaux)) = nnosca(np2are(listar(iaux)))
  411       continue
c
            famele(elemen) = cfapyr(cofamd,fampyr(lapyra))
            typele(elemen) = cfapyr(cotyel,fampyr(lapyra))
c
#ifdef _DEBUG_HOMARD_
            if ( elemen.eq.-601 ) then
            write (ulsort,*) 'fampyr = ', fampyr(lapyra)
            write (ulsort,texte(langue,14)) elemen
            write (ulsort,texte(langue,15))
     >             (noeele(elemen,iaux),iaux=1,13)
            write (ulsort,*) 'Famille MED = ',famele(elemen),
     >                       ', Type MED = ',typele(elemen)
            endif
#endif
c
          endif
c
  41   continue
c
      endif
c
c====
c 5. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
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
