      subroutine pcmape ( elemen, nbele0,
     >                    somare, np2are,
     >                    arequa,
     >                    facpen, cofape, arepen,
     >                    hetpen, fampen, cfapen,
     >                    nnosca, npesca, npesho,
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
c                                   Coperight EDF 1997, 1998, 1999, 2002
c ______________________________________________________________________
c
c
c    aPres adaptation - Conversion - MAillage connectivite - PEntaedres
c     -                 -            --                      --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . elemen . es  .   1    . numero du dernier element cree             .
c . nbele0 . e   .   1    . estimation du nombre d'elements            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . np2are . e   . nbarto . numero du noeud p2 milieu d'arete          .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . facpen . e   .nbpecf*5. numeros des faces des pentaedres           .
c . cofape . e   .nbpecf*5. codes des faces des pentaedres             .
c . arepen . e   .nbpeca*9. numeros des 9 aretes des pentaedres        .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . fampen . e   . nbpeto . famille des pentaedres                     .
c . cfapen .     . nctfhe. codes des familles des pentaedres           .
c .        .     . nbfpen .   1 : famille MED                          .
c .        .     .        .   2 : type d'pentaedres                    .
c . nnosca . e   . rsnoto . numero des noeuds du code de calcul        .
c . npesca .  s  . rspeto . numero des pentaedres dans le calcul       .
c . npesho .  s  . nbele0 . numero des pentaedres dans HOMARD          .
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
      parameter ( nompro = 'PCMAPE' )
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
#include "nombqu.h"
#include "nombpe.h"
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
      integer arequa(nbquto,4)
      integer facpen(nbpecf,5), cofape(nbpecf,5), arepen(nbpeca,9)
      integer hetpen(nbpeto)
c
      integer cfapen(nctfpe,nbfpen), fampen(nbpeto)
c
      integer nnosca(rsnoto)
      integer npesca(rspeto), npesho(nbele0)
c
      integer famele(nbele0), noeele(nbele0,nbmane)
      integer typele(nbele0)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer lepent, lepen0
      integer etat
      integer iaux
      integer listar(9), listso(15), nomiar(9)
#ifdef _DEBUG_HOMARD_
      integer glop
#endif
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
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'nbpecf, nbpeca =', nbpecf, nbpeca
#endif
c
#include "impr03.h"
c
#include "impr06.h"
c
c====
c 2. initialisations des renumerotations
c====
c
      do 21 , iaux = 1 , rspeto
        npesca(iaux) = 0
   21 continue
c
      do 22 , iaux = 1 , nbele0
        npesho(iaux) = 0
   22 continue
c
c====
c 3. Conversion en lineaire
c====
c
      if ( degre.eq.1 ) then
c
c          S3                   a9                     S6
c           x------------------------------------------x
c          .                                          .
c         .  .                                       .  .
c     a3 .                                       a6 .
c       .     .                                    .     .
c      .                                          .
c     .        .a1                               .        .a4
c    .                                          .
c S2.           .       a8                   S5.           .
c  x------------------------------------------x
c     .          .                               .          .
c          .                                          .
c        a2    .  .                                 a5    .  .
c                  x------------------------------------------x
c                 S1                   a7                     S4
c   La face f1 est le triangle (S1,S2,S3).
c   La face f2 est le triangle (S4,S6,S5).
c   La face fi, 3<=i<=5, est le quadrangle s'appuyant sur l'arete ai-2.
c
        do 31 , lepen0 = 1 , nbpeto
c
          lepent = lepen0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,11)) mess14(langue,2,7), lepent
#endif
c
          etat = mod( hetpen(lepent) , 100 )
c
          if ( etat.eq.0 .or. hierar.ne.0 ) then
c
            elemen = elemen + 1
#ifdef _DEBUG_HOMARD_
        if ( elemen.eq.-12 ) then
          glop = 1
        else
          glop = 0
        endif
#endif
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
            write (ulsort,texte(langue,14)) elemen
        endif
#endif
            npesho(elemen) = lepent
            npesca(lepent) = elemen
c
            call utaspe ( lepent,
     >                    nbquto, nbpecf, nbpeca,
     >                    somare, arequa,
     >                    facpen, cofape, arepen,
     >                    listar, listso )
c
c     Attention : utaspe donne la numerotation dans la convention homard
c                 il faut permuter les sommets 2/3 et 5/6 pour obtenir
c                 la numerotation dans la convention med
c
            noeele(elemen,1) = nnosca(listso(1))
            noeele(elemen,2) = nnosca(listso(3))
            noeele(elemen,3) = nnosca(listso(2))
            noeele(elemen,4) = nnosca(listso(4))
            noeele(elemen,5) = nnosca(listso(6))
            noeele(elemen,6) = nnosca(listso(5))
c
            famele(elemen) = cfapen(cofamd,fampen(lepent))
            typele(elemen) = cfapen(cotyel,fampen(lepent))
c
#ifdef _DEBUG_HOMARD_
            if ( glop.ne.0 ) then
            write (ulsort,90002) 'fampen', fampen(lepent)
            write (ulsort,texte(langue,14)) elemen
            write (ulsort,texte(langue,15))
     >             (noeele(elemen,iaux),iaux=1,6)
            write (ulsort,90002) 'Famille MED',famele(elemen)
            write (ulsort,90002) 'Type MED   ',typele(elemen)
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
c          S3                   a9/N14                 S6
c           x------------------------------------------x
c          .                                          .
c         .  .                                       .  .
c     a3 .                                       a6 .
c     N8.     .                                 N11.     .
c      .                                          .
c     .        .a1                               .        .a4
c    .          N7                              .           N10
c S2.           .       a8/N15               S5.           .
c  x------------------------------------------x
c     .          .                               .          .
c          .                                      N12 .
c        a2    .  .                                 a5    .  .
c        N9        x------------------------------------------x
c                 S1                   a7/N13                 S4
c   La face f1 est le triangle (S1,S2,S3).
c   La face f2 est le triangle (S4,S6,S5).
c   La face fi, 3<=i<=5, est le quadrangle s'appuyant sur l'arete ai-2.
c
c            Au sens homard      au sens MED
c          arete  1 de s1 a s3 | de s1 a s2
c          arete  2 de s1 a s2 | de s1 a s3
c          arete  3 de s2 a s3 | de s2 a s3
c          arete  4 de s4 a s6 | de s4 a s5
c          arete  5 de s4 a s5 | de s4 a s6
c          arete  6 de s5 a s6 | de s5 a s6
c          arete  7 de s1 a s4 | de s1 a s4
c          arete  8 de s2 a s5 | de s3 a s6
c          arete  9 de s3 a s6 | de s2 a s5
c       Tableau de travail nomiar :
c       nomiar(i) contient le numero local au sens MED du noeud porte
c       par l'arete de numero local i au sens homard
c
        nomiar( 1) =  7
        nomiar( 2) =  9
        nomiar( 3) =  8
        nomiar( 4) = 10
        nomiar( 5) = 12
        nomiar( 6) = 11
        nomiar( 7) = 13
        nomiar( 8) = 15
        nomiar( 9) = 14
c
        do 41 , lepen0 = 1 , nbpeto
c
          lepent = lepen0
c
#ifdef _DEBUG_HOMARD_
        if ( elemen.eq.-12 ) then
          glop = 1
        else
          glop = 0
        endif
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,11)) mess14(langue,2,7), lepent
#endif
c
          etat = mod( hetpen(lepent) , 100 )
c
          if ( etat.eq.0 .or. hierar.ne.0 ) then
c
            elemen = elemen + 1
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
            write (ulsort,texte(langue,14)) elemen
        endif
#endif
            npesho(elemen) = lepent
            npesca(lepent) = elemen
cgn      write (ulsort,555) 'tria', (facpen(lepent,iaux),iaux=1,2)
cgn      write (ulsort,555) 'quad',facpen(lepent,3),cofape(lepent,3)
cgn      write (ulsort,555) '-> ',(arequa(facpen(lepent,3),iaux),iaux=1,4)
cgn      write (ulsort,555) 'quad',facpen(lepent,4),cofape(lepent,4)
cgn      write (ulsort,555) '-> ',(arequa(facpen(lepent,4),iaux),iaux=1,4)
cgn      write (ulsort,555) 'quad',facpen(lepent,5),cofape(lepent,5)
cgn      write (ulsort,555) '-> ',(arequa(facpen(lepent,5),iaux),iaux=1,4)
c
            call utaspe ( lepent,
     >                    nbquto, nbpecf, nbpeca,
     >                    somare, arequa,
     >                    facpen, cofape, arepen,
     >                    listar, listso )
c
c     Attention : utaspe donne la numerotation dans la convention homard
c                 il faut permuter les sommets 2/3 et 5/6 pour obtenir
c                 la numerotation dans la convention med
c
cgn      write (ulsort,555) 'listso',(listso(iaux),iaux=1,6)
            noeele(elemen,1) = nnosca(listso(1))
            noeele(elemen,2) = nnosca(listso(3))
            noeele(elemen,3) = nnosca(listso(2))
            noeele(elemen,4) = nnosca(listso(4))
            noeele(elemen,5) = nnosca(listso(6))
            noeele(elemen,6) = nnosca(listso(5))
cgn      write (ulsort,555) '--> so',(noeele(elemen,iaux),iaux=1,6)
c
c     Les noeuds au milieu des aretes
c
            do 411 , iaux = 1 , 9
              noeele(elemen,nomiar(iaux)) = nnosca(np2are(listar(iaux)))
  411       continue
cgn      write (ulsort,555) 'p2',(noeele(elemen,nomiar(iaux)),iaux=1,9)
c
cgn  555 format(a,10i3)
            famele(elemen) = cfapen(cofamd,fampen(lepent))
            typele(elemen) = cfapen(cotyel,fampen(lepent))
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
