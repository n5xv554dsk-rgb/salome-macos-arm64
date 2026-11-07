      subroutine cmhomo ( noehom, arehom, trihom, quahom,
     >                    somare, filare, hetare, np2are,
     >                    aretri, filtri, hettri,
     >                    arequa, filqua, hetqua,
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
c    Creation du Maillage - HOMOlogues
c    -           -          ----
c ______________________________________________________________________
c
c but : mise a jour des tables d'homologues
c
c   remarque importante : reperage des elements homologues
c     on prend la convention de reperage suivante : lorsque
c     l'on a deux faces periodiques 1 et 2, on attribue un signe a
c     chacune des faces. pour un noeud "i", noehom(i) est alors egal
c     a la valeur suivante :
c     - "le numero du noeud correspondant par periodicite
c        si i est sur la face 2"
c     - "l'oppose du numero du noeud correspondant par periodicite
c        si i est sur la face 1"
c
c     Donc, on etend cette convention a toutes les entites noeuds,
c     aretes, triangles et quadrangles :
c     enthom(i) = abs(homologue(i)) ssi i est sur la face 2
c     enthom(i) = -abs(homologue(i)) ssi i est sur la face 1
c     pour une entite situee sur l'axe, on prend la convention positive.
c
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . noehom . es  . nbnoto . ensemble des noeuds homologues             .
c . arehom . es  . nbarto . ensemble des aretes homologues             .
c . trihom . es  . nbtrto . ensemble des triangles homologues          .
c . quahom . es  . nbquto . ensemble des quadrangles homologues        .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . filare . e   . nbarto . premiere fille des aretes                  .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . np2are . e   . nbarto . numero des noeuds p2 milieux d'aretes      .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . filtri . e   . nbtrto . premier fils des triangles                 .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . filqua . e   . nbquto . premier fils des quadrangles               .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
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
      parameter ( nompro = 'CMHOMO' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
c
c 0.3. ==> arguments
c
      integer noehom(nbnoto), arehom(nbarto)
      integer trihom(nbtrto), quahom(nbquto)
      integer somare(2,nbarto), filare(nbarto), hetare(nbarto)
      integer np2are(nbarto)
      integer aretri(nbtrto,3), filtri(nbtrto), hettri(nbtrto)
      integer arequa(nbquto,4), filqua(nbquto), hetqua(nbquto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer areh
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
      codret = 0
c
c====
c 2. les tables des aretes
c    il faut commencer par les aretes pour pouvoir traiter les tables
c    des faces ensuite
c====
c
cgn           print *,'debut de ', nompro
cgn           print *,'trihom'
cgn           print 1788,(trihom(iaux),iaux=1,16)
cgn           print *,'quahom'
cgn           print 1787,(quahom(iaux),iaux=1,8)
cgn           print *,'arehom'
cgn           print 1789,(arehom(iaux),iaux=1,50)
cgn           print *,'noehom'
cgn           print 1789,(noehom(iaux),iaux=1,27)
cgn 1787 format(4I4)
cgn 1788 format(8I4)
cgn 1789 format(10I4)
      if (codret.eq.0 ) then
c
      if ( homolo.ge.2 ) then
c
        call cmhoma ( noehom, arehom,
     >                somare, filare, hetare,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 3. les tables des triangles
c====
c
      if (codret.eq.0 ) then
c
      if ( homolo.ge.3 .and. nbtrto.ne.0 ) then
c
        call cmhomt ( arehom, trihom,
     >                somare,
     >                aretri, filtri, hettri,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 4. les tables des quadrangles et complements sur les triangles
c====
c
      if (codret.eq.0 ) then
c
      if ( homolo.ge.3 .and. nbquto.ne.0 ) then
c
        call cmhomq ( noehom, arehom, trihom, quahom,
     >                somare, aretri,
     >                arequa, filqua, hetqua,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 5. les noeuds milieux en degre 2
c    on n'examine que les aretes tracees sur la face periodique 2
c    comme d'habitude, attention a l'axe ...
c====
c
      if ( codret.eq.0 ) then
c
      if ( homolo.ge.2 ) then
c
      if ( degre.eq.2 ) then
c
      do 51, iaux = 1, nbarto
c
        if ( arehom(iaux).gt.0 ) then
c
          areh = arehom(iaux)
c
          noehom(np2are(iaux)) = np2are(areh)
          if ( iaux.ne.areh ) then
            noehom(np2are(areh)) = -np2are(iaux)
          endif
c
        endif
c
   51 continue
c
      endif
c
      endif
c
      endif
c
c====
c 6. decompte du nombre de paires d'entites homologues
c====
c
      if ( codret.eq.0 ) then
c
      call uthonh ( noehom, arehom,
     >              trihom, quahom,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 7. la fin
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
cgn           print *,'fin de ', nompro
cgn           print *,'trihom'
cgn           print 1789,(trihom(iaux),iaux=1,nbtrto)
cgn           print *,'quahom'
cgn           print 1789,(quahom(iaux),iaux=1,nbquto)
cgn           print *,'arehom'
cgn           print 1789,(arehom(iaux),iaux=1,nbarto)
cgn           print *,'noehom'
cgn           print 1789,(noehom(iaux),iaux=1,nbnoto)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
