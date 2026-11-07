      subroutine pcmex0 ( indnoe, indare, nouvno, nouvar,
     >                    coocst,
     >                    hetnoe, coonoe, arenoe,
     >                    famnoe, cfanoe,
     >                    hetare, somare,
     >                    filare, merare,
     >                    famare,
     >                    entxno,
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
c    aPres adaptation - Conversion de Maillage EXtrude - phase 0
c     -                 -             -        --              -
c    Duplication des noeuds
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . indnoe . es  . 1      . indice du dernier noeud cree               .
c . indare . es  . 1      . indice de la derniere arete creee          .
c . nouvno . e   .   1    . nouveau nombre de noeuds                   .
c . nouvar . e   .   1    . nouveau nombre d'aretes                    .
c . coocst . es  .   11   . 1 : coordonnee constante eventuelle        .
c .        .     .        . 2, 3, 4 : xmin, ymin, zmin                 .
c .        .     .        . 5, 6, 7 : xmax, ymax, zmax                 .
c .        .     .        . 8, 9, 10 : -1 si constant, max-min sinon   .
c .        .     .        . 11 : max des (max-min)                     .
c . hetnoe . es  . nouvno . historique de l'etat des noeuds            .
c .        .     .        . 0 pour les noeuds isoles                   .
c .        .     .        . 1 pour les sommets                         .
c .        .     .        . 2 pour les noeuds milieux                  .
c .        .     .        . 3 pour les noeuds support de maille-point  .
c .        .     .        . 4 pour les noeuds internes aux mailles     .
c .        .     .        . 7 pour les noeuds n'appartenant qu'a des   .
c .        .     .        .   elements ignores                         .
c . coonoe . es  . nouvno . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . arenoe . es  . nouvno . arete liee a un nouveau noeud              .
c . famnoe . es  . nouvno . famille des noeuds                         .
c . cfanoe . e   . nctfno*. codes des familles des noeuds              .
c .        .     . nbnoto .   1 : famille MED                          .
c .        .     .        . si extrusion :                             .
c .        .     .        .   2 : famille du noeud extrude             .
c .        .     .        .   3 : famille de l'arete perpendiculaire   .
c .        .     .        .   4 : position du noeud                    .
c .        .     .        . si equivalence :                           .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . hetare . es  . nouvar . historique de l'etat des aretes            .
c . somare . es  .2*nouvar. numeros des extremites d'arete             .
c . filare . es  . nouvar . fille ainee de chaque arete                .
c . merare . es  . nouvar . mere de chaque arete                       .
c . famare . es  . nouvar . famille des aretes                         .
c . entxno .  s  .2*nouvno. entites liees a l'extrusion du noeud       .
c .        .     .        . 1 : le noeud                               .
c .        .     .        . 2 : l'arete perpendiculaire                .
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
      parameter ( nompro = 'PCMEX0' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nbfami.h"
#include "cofexn.h"
#include "dicfen.h"
#include "envca1.h"
#include "nombno.h"
c
c 0.3. ==> arguments
c
      integer indnoe, indare, nouvno, nouvar
c
      integer hetnoe(nouvno), arenoe(nouvno)
      integer famnoe(nouvno), cfanoe(nctfno,nbfnoe)
      integer somare(2,nouvar)
      integer hetare(nouvar), filare(nouvar), merare(nouvar)
      integer famare(nouvar)
c
      integer entxno(2,nbnoto)
c
      double precision coocst(11)
      double precision coonoe(nouvno,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer iaux1, iaux2
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. messages
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
     > '(''Direction '',a1,'' : mini = '',g12.5,'' maxi = '',g12.5)'
      texte(1,5) = '(''Nombre de noeuds :'',i10)'
      texte(1,6) = '(''==> epaisseur maximale = '',g13.5)'
      texte(1,7) = '(''==> coordonnee '',a3,'' ='',g13.5)'
c
      texte(2,4) =
     > '(a1,''direction '','' : mini = '',g12.5,'' maxi = '',g12.5)'
      texte(2,5) = '(''Number of nodes:'',i10)'
      texte(2,6) = '(''==> maximal thickness:'',g13.5)'
      texte(2,7) = '(''==> '',a3,'' coordinate:'',g13.5)'
c
#include "impr03.h"
c
      codret = 0
c
      if ( maextr.eq.1 ) then
        iaux1 = 2
        iaux2 = 3
      elseif ( maextr.eq.2 ) then
        iaux1 = 1
        iaux2 = 3
      elseif ( maextr.eq.3 ) then
        iaux1 = 1
        iaux2 = 2
      else
        codret = 1
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,texte(langue,5)) nbnoto
      write (ulsort,90002) 'maextr', maextr
      write (ulsort,texte(langue,4)) 'x', coocst(2), coocst(5)
      write (ulsort,texte(langue,4)) 'y', coocst(3), coocst(6)
      write (ulsort,texte(langue,6)) coocst(11)
      write (ulsort,texte(langue,7)) 'inf', coocst(4)
      write (ulsort,texte(langue,7)) 'sup', coocst(7)
      endif
#endif
c
c====
c 2. parcours des noeuds
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. parcours noeuds ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbnoto', nbnoto
      write (ulsort,90002) 'nouvno', nouvno
      write (ulsort,90002) 'nouvar', nouvar
#endif
c
      do 20 , iaux = 1 , nbnoto
c
c 2.1. ===> Creation du nouveau noeud
c
        indnoe = indnoe + 1
        coonoe(indnoe,iaux1) = coonoe(iaux,iaux1)
        coonoe(indnoe,iaux2) = coonoe(iaux,iaux2)
        coonoe(indnoe,maextr) = coocst(7)
c
        hetnoe(indnoe) = 51
        arenoe(indnoe) = 0
        famnoe(indnoe) = cfanoe(cofxnt,famnoe(iaux))
c
c 2.2. ===> Creation de l'arete joignant ces deux noeuds
c
        indare = indare + 1
        somare(1,indare) = iaux
        somare(2,indare) = indnoe
        hetare(indare) = 50
        filare(indare) = 0
        merare(indare) = 0
        famare(indare) = cfanoe(cofxnx,famnoe(iaux))
c
c 2.3. ===> Retablissement des coordonnes du noeud courant
c
        coonoe(iaux,maextr) = coocst(4)
c
c 2.4. ===> Memorisation de l'extrusion du noeud
c
        entxno(1,iaux) = indnoe
        entxno(2,iaux) = indare
c
   20 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'indnoe', indnoe
      write (ulsort,90002) 'indare', indare
      do 2221 , iaux = 1 , nbnoto
      write (ulsort,90112) 'entxno',iaux,entxno(1,iaux), entxno(2,iaux)
 2221 continue
#endif
c
      endif
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
