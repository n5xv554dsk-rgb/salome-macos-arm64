      subroutine vcmar0 ( nnosho, nnosca,
     >                    noeele, typele,
     >                    povoso, voisom,
     >                    nbardb,
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
c    aVant adaptation - Conversion de Maillage - ARetes - phase 0
c     -                 -             -          --             -
c ______________________________________________________________________
c
c but : estime le nombre d'aretes en doubles dans le maillage
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nnosho . e   . rsnoac . numero des noeuds dans HOMARD              .
c . nnosca . e   . rsnoto . numero des noeuds dans le calcul           .
c . noeele . e   . nbelem . noeuds des elements                        .
c .        .     .*nbmane .                                            .
c . typele . e   . nbelem . type des elements pour le code de calcul   .
c . povoso . e   .0:nbnoto. pointeur des voisins par sommet            .
c . voisom . e   . nvosom . voisins des sommets en stockage morse      .
c . nnardb .  s  .   1    . nombre d'aretes en double                  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2313 : maille double                       .
c .        .     .        . 232 : noeud bizarre                        .
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
      parameter ( nompro = 'VCMAR0' )
c
#include "coftex.h"
#include "referx.h"
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
#include "nbutil.h"
#include "nombno.h"
#include "refere.h"
#include "nombsr.h"
#include "rftmed.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nnosho(rsnoac), nnosca(rsnoto)
      integer noeele(nbelem,nbmane), typele(nbelem)
      integer voisom(nvosom), povoso(0:nbnoto)
      integer nbardb
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer poinde, poinfi, point
      integer sommet, nbvois, nbaret
      integer nbsomm, elem, elem00, typhom
#ifdef _DEBUG_HOMARD_
      integer glop
#endif
      integer tbjaux(200,4)
      integer tbkaux(200,2)
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. preliminaires
c====
c
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,7) =
     >'(''  Ses noeuds (numerotation du calcul) : '',/,10i10)'
      texte(1,8) =
     >'(''  Ses noeuds (numerotation HOMARD) : '',/,10i10)'
      texte(1,10) =
     >'(''. Element voisin (numero du calcul)'',i10,'' ('',a,'')'')'
c
      texte(2,7) =
     > '(''  Its nodes (with calculation #) : '',/,10i10)'
      texte(2,8) =
     > '(''  Its nodes (with HOMARD #) : '',/,10i10)'
      texte(2,10) =
     >'(''. Neighbour element (calculation #)'',i10,'' ('',a,'')'')'
c
#include "impr03.h"
c
c====
c 2. on passe en revue chaque maille
c    pour chaque maille, on compte combien de ses voisins comptent
c    au moins 2 de ses noeuds. Cela fait autant d'aretes doubles.
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. chaque maille ; codret', codret
#endif
c
      nbardb = 0
c
      do 20 , elem = 1 , nbelem
c
        typhom = medtrf(typele(elem))
        nbsomm = nbnref(typhom,1)
c
#ifdef _DEBUG_HOMARD_
        if ( elem.lt.1 ) then
          glop = 1
        else
          glop = 0
        endif
        if ( glop.ne.0 ) then
        write (ulsort,*) ' '
        iaux = ( typhom + mod(typhom,2)) / 2
        write (ulsort,texte(langue,10)) elem, mess14(langue,1,iaux)
        write (ulsort,texte(langue,7)) (noeele(elem,iaux),iaux=1,nbsomm)
        write (ulsort,texte(langue,8))
     >        (nnosho(noeele(elem,iaux)),iaux=1,nbsomm)
        endif
#endif
c
        nbvois = 0
c
c 2.1. ==> Parcours des nbsomm sommets de la maille
c
        do 21 , iaux = 1 , nbsomm
c
          sommet = nnosho(noeele(elem,iaux))
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,90002) '. sommet', sommet
        endif
#endif
c
          poinde = povoso(nnosca(sommet)-1) + 1
          poinfi = povoso(nnosca(sommet))
c
cgn          write(ulsort,90002) 'pointeur debut et fin', poinde, poinfi
c
c 2.1.1. ==> Examen des mailles contenant ce sommet
c
          do 211 , point = poinde , poinfi
c
            elem00 = voisom(point)
c
c 2.1.1.a. ==> Si la maille est de meme type que la maille courante
c              mais sans l'etre :
c
            if ( ( elem.ne.elem00 ) .and.
     >           ( typhom.eq.medtrf(typele(elem00)) ) ) then
#ifdef _DEBUG_HOMARD_
              if ( glop.ne.0 ) then
              write (ulsort,90002) '.... maille', elem00
              endif
#endif
c
c             On cherche si cette maille est deja enregistre dans
c             les voisins :
c             . Si oui, on memorise le second sommet et on passe au
c               sommet suivant (goto 211)
c             . Si non, on enregistre cette maille avec
c               ce premier sommet
c
              do 212 , jaux = 1 , nbvois
                if ( tbjaux(jaux,1).eq.elem00 ) then
                  tbjaux(jaux,2) = tbjaux(jaux,2) + 1
                  tbjaux(jaux,4) = max(tbjaux(jaux,4),sommet)
                  goto 211
                endif
  212         continue
c
              nbvois = nbvois + 1
cgn              write (ulsort,90002) '...... nbvois', nbvois
              tbjaux(nbvois,1) = elem00
              tbjaux(nbvois,2) = 1
              tbjaux(nbvois,3) = sommet
              tbjaux(nbvois,4) = 0
              if ( nbvois.eq.200 ) then
                goto 2222
              endif
c
            endif
c
  211     continue
c
   21   continue
c
c 2.2. ==> Bilan
c          On parcourt les voisins enregistres. On compte a
c          combien d'aretes identiques cela correspond.
c
 2222   continue
c
        nbaret = 0
        do 22 , jaux = 1 , nbvois
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,90015) '. maille', tbjaux(jaux,1),
     >  ' :', tbjaux(jaux,2), tbjaux(jaux,3), tbjaux(jaux,4)
        endif
#endif
c
          if ( tbjaux(jaux,2).ge.2 ) then
c
            do 221 , kaux = 1 , nbaret
              if ( ( tbkaux(kaux,1).eq.tbjaux(jaux,3) ) .and.
     >             ( tbkaux(kaux,2).eq.tbjaux(jaux,4) ) ) then
                goto 22
              endif
  221       continue
c
            nbaret = nbaret + 1
cgn            write (ulsort,90002) '...... nbaret', nbaret
            tbkaux(nbaret,1) = tbjaux(jaux,3)
            tbkaux(nbaret,2) = tbjaux(jaux,4)
            nbardb = nbardb + 1
          endif
c
   22   continue
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
      write (ulsort,90002) 'nbardb', nbardb
        endif
#endif
c
   20 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbardb', nbardb
#endif
c
c====
c 3. la fin
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
