      subroutine utmfv1 ( typenh, nbvoto, nbvoco,
     >                    filvol, fvpyte,
     >                    pertet, perpyr,
     >                    pthepe, pphepe,
     >                    ulsort, langue, codret)
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
c    UTilitaire - passage de Mere a Fille pour les Volumes - 1
c    --                      -      -              -         -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typenh . e   .   1    . code des entites                           .
c .        .     .        .   6 : hexaedres                            .
c .        .     .        .   7 : pentaedres                           .
c . nbvoto . e   .   1    . nombre total de volumes concernes          .
c . nbvoco . e   .   1    . nombre de volumes decoupes en conformite   .
c . filvol . es  . nbvoto . fils des volumes                           .
c . fvpyte . e   .2*nbvoco. fvpyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille du volume k tel que filvol(k) =-j    .
c .        .     .        . fvpyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils du volume k tel que filvol(k) = -j    .
c . pertet . e   . nbteto . pere des tetraedres                        .
c .        .     .        . si pertet(i) > 0 : numero du tetraedre     .
c .        .     .        . si pertet(i) < 0 : -numero dans pthepe     .
c . perpyr . e   . nbpyto . pere des pyramides                         .
c .        .     .        . si perpyr(i) > 0 : numero de la pyramide   .
c .        .     .        . si perpyr(i) < 0 : -numero dans pphepe     .
c . pthepe . es  .    *   . si i <= nbheco : numero de l'hexaedre      .
c .        .     .        . si non : numero du pentaedre               .
c . pphepe . es  .    *   . si i <= nbheco : numero de l'hexaedre      .
c .        .     .        . si non : numero du pentaedre               .
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
      parameter ( nompro = 'UTMFV1' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombte.h"
#include "nombpy.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer typenh, nbvoto, nbvoco
      integer filvol(nbvoto)
      integer fvpyte(2,nbvoco)
      integer pertet(nbteto)
      integer perpyr(nbpyto)
      integer pthepe(*)
      integer pphepe(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer indic1, indic2
      integer lapyra, letetr
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
      texte(1,4) = '(''. Reperage des filles des '',a)'
      texte(1,5) =
     >'(''.. Nombre de '',a,'' decoupes en conformite :'',i10)'
      texte(1,6) = '(''Probleme de parentes pour les '',a)'
      texte(1,7) = '(''Indice du pere de '',a,i10,'' :'',i10))'
      texte(1,8) = '(''Incoherence.''))'
      texte(1,9) = '(''. Reperage des filles du'',i6,''-ieme '',a)'
c
      texte(2,4) = '(''. Son arrays from father arrays for '',a)'
      texte(2,5) =
     >'(''.. Number of '',a,'' cut for conformal reasons :'',i10)'
      texte(2,6) = '(''Problems with the parents of the '',a)'
      texte(2,7) =
     > '(''Index for the father of '',a,'',i10,'' is '',i10))'
      texte(2,8) = '(''Incoherence.''))'
      texte(2,9) = '(''. Search for the sons of'',i6,''-th '',a)'
c
#include "impr03.h"
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,typenh)
      write (ulsort,texte(langue,5)) mess14(langue,3,typenh), nbvoco
#endif
c
c====
c 2. parcours des volumes concernes
c====
c
      do 21 , iaux = 1 , nbvoco
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,9)) iaux, mess14(langue,1,typenh)
#endif
c
c 2.1. ==> Examen par les pyramides
c
        lapyra = fvpyte(1,iaux)
        if ( lapyra.gt.0 ) then
          indic1 = -perpyr(lapyra)
          if ( indic1.eq.0 ) then
            codret = 1
          endif
        else
          indic1 = 0
        endif
c
c 2.2. ==> Examen par les tetraedres
c
        letetr = fvpyte(2,iaux)
        if ( letetr.gt.0 ) then
          indic2 = -pertet(letetr)
          if ( indic2.eq.0 ) then
            codret = 2
          endif
        else
          indic2 = 0
        endif
c
c 2.3. ==> Controle et affectation
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,7)) mess14(langue,1,5),lapyra, indic1
        write (ulsort,texte(langue,7)) mess14(langue,1,3),letetr, indic2
#endif
        if ( indic1.ne.0 .and. indic2.ne.0 ) then
          if ( indic1.ne.indic2 ) then
            codret = 3
          endif
        endif
c
        if ( codret.eq.0 ) then
          if ( indic1.ne.0 ) then
            filvol(pphepe(indic1)) = -iaux
          else
            filvol(pthepe(indic2)) = -iaux
          endif
        endif
c
        endif
c
   21 continue
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
      if ( codret.eq.1 ) then
        write (ulsort,texte(langue,6)) mess14(langue,3,5)
      elseif ( codret.eq.2 ) then
        write (ulsort,texte(langue,6)) mess14(langue,3,3)
      elseif ( codret.eq.3 ) then
        write (ulsort,texte(langue,7)) mess14(langue,1,5),lapyra, indic1
        write (ulsort,texte(langue,7)) mess14(langue,1,3),letetr, indic2
        write (ulsort,texte(langue,8))
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
