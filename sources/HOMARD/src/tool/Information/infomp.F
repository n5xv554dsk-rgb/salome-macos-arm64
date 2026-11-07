      subroutine infomp ( choix,  lamapo,
     >                    noempo, hetmpo,
     >                    fammpo,
     >                    nmpoho, nmpoca, nmpocs,
     >                    coonoe,
     >                    nbpafo, nopafo,
     >                    ulsost,
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
c   INFOrmation : Maille-Point
c   ----          -      -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . choix  . e   .  ch2   . choix                                      .
c . lamapo . e   .   1    . numero de la maille-point a analyser       .
c . noempo . e   . nbmpto . numeros des noeuds associes aux mailles    .
c . hetmpo . e   . nbmpto . historique de l'etat des maille-points     .
c . fammpo . e   . nbmpto . famille des mailles-points                 .
c . nmpoho . e   . rearac . numero des maille-points dans HOMARD       .
c . nmpoca . e   . rearto . numero des maille-points du code de calcul .
c . nmpocs . e   . rearto . numero des m-pts du calcul pour la solution.
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . nbpafo . e   .   1    . nombre de paquets de fonctions             .
c . nopafo . e   . nbpafo . nom des objets qui contiennent la          .
c .        .     .        . description de chaque paquet de fonctions  .
c . ulsost . e   .   1    . unite logique de la sortie standard        .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . non nul : probleme                         .
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
      parameter ( nompro = 'INFOMP' )
c
#include "nblang.h"
#include "consts.h"
#include "meddc0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "inmess.h"
c
#include "nombno.h"
#include "nombmp.h"
#include "nomber.h"
#include "envca1.h"
#include "envada.h"
c
c 0.3. ==> arguments
c
      character*2 choix
c
      integer lamapo
c
      integer noempo(nbmpto), hetmpo(nbmpto)
      integer fammpo(nbmpto)
      integer nmpoho(rempac), nmpoca(*), nmpocs(*)
      integer nbpafo
c
      double precision coonoe(nbnoto,sdim)
c
      character*8 nopafo(*)
c
      integer ulsost
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer numcal
      integer etat00, etat01
      integer somsup
      integer uldeb, ulfin, ulpas, ulecr
c
      character*40 taux40
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisation
c====
c
#include "impr01.h"
#include "infoen.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      codret = 0
c
      uldeb = min(ulsost,ulsort)
      ulfin = max(ulsost,ulsort)
      ulpas = max ( 1 , ulfin-uldeb )
c
c====
c 2. numero de la maille-point dans HOMARD
c====
c
      if ( choix.eq.'MP' ) then
        iaux = lamapo
        if ( lamapo.gt.0 .and. lamapo.le.rearac ) then
          lamapo = nmpoho(iaux)
        else
          lamapo = 0
        endif
      endif
c
c====
c 3. reponses
c====
c
      do 30 , ulecr = uldeb , ulfin, ulpas
c
      write (ulecr,40000)
c
c 3.1. ==> numero de maille-point impossible
c
      if ( lamapo.le.0 .or. lamapo.gt.nbmpto ) then
c
        if ( choix.eq.'MP' ) then
          write (ulecr,40010) iaux
        else
          write (ulecr,40020) lamapo
        endif
        write (ulecr,40031)
c
c 3.2. ==> numero de maille-point correct
c
      else
c
        numcal = nmpoca(lamapo)
        write (ulecr,40020) lamapo
        write (ulecr,40010) numcal
c
c 3.2.1. ==> caracteristiques
c
        write (ulecr,42000) fammpo(lamapo)
c
c 3.2.2. ==> etat
c
        etat01 = mod(hetmpo(lamapo),10)
        etat00 = (hetmpo(lamapo)-etat01) / 10
c
        taux40 = textmp(etat01)
        write (ulecr,44010)
        write (ulecr,40001) taux40
        if ( nbiter.ge.1 ) then
          taux40 = textmp(etat00)
          write (ulecr,44020)
          write (ulecr,40001) taux40
        endif
c
c 3.2.3. ==> le noeud support
c
        somsup = noempo(lamapo)
        write (ulecr,43000) somsup
c
c 3.2.4. ==> la position
c
        if ( sdim.eq.1 ) then
          write (ulecr,44001) coonoe(somsup,1)
        elseif ( sdim.eq.2 ) then
          write (ulecr,44002) (coonoe(somsup,iaux), iaux = 1 , sdim)
        else
          write (ulecr,44003) (coonoe(somsup,iaux), iaux = 1 , sdim)
        endif
c
c 3.2.5. ==> les valeurs des fonctions
c
        if ( nbpafo.ne.0 .and. numcal.ne.0 ) then
c
          iaux = edpoi1
          jaux = nmpocs(numcal)
          kaux = ulecr
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFOPF', nompro
#endif
          call infopf ( nbpafo, nopafo,
     >                  iaux, jaux,
     >                  kaux,
     >                  ulsort, langue, codret )
c
        endif
c
      endif
c
      write (ulecr,40000)
c
   30 continue
c
c===
c 4. formats
c===
c
40020 format(
     >  '* Maille-point numero :',i10,   ' dans HOMARD               *')
c
43000 format(
     >  '* Le noeud support est ',i10,   '                           *')
c
44001 format(
     >  '* . Position  : ',   g15.5   ,'                             *')
44002 format(
     >  '* . Position  : ',   g15.5   ,   g15.5     ,'               *')
44003 format(
     >  '* . Position  : ',   g14.4   ,   g14.4    ,   g14.4     ,'  *')
c
c====
c 5. La fin
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
