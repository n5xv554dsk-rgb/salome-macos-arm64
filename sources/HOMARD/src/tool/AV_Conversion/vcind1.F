      subroutine vcind1 ( nbcomp, nomcmp,
     >                    ncmpin, pointe, taille, table,
     >                    nucomp,
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
c    aVant adaptation - Conversion d'INDicateur - phase 1
c     -                 -            ---                -
c recuperation des composantes a prendre en compte
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbcomp . e   .   1    . nombre de composantes du champ examine     .
c . nomcmp . e   . nbtvch . nom des composantes du champ examine       .
c . ncmpin . es  .   1    . nombre de composantes retenues             .
c . pointe . e   .0:ncmpin. pointeurs dans taille et table             .
c . taille . e   .   *    . longueur de chacune des composantes        .
c . table  . e   . char*8 . nom des composantes a utiliser             .
c . nucomp .  s  . ncmpin . numeros des composantes retenues           .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 5 : mauvais type de code de calcul associe .
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
      parameter ( nompro = 'VCIND1' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer nbcomp
      integer ncmpin
      integer pointe(0:*), taille(*)
      integer nucomp(*)
c
      character*8 nomcmp(*)
      character*8 table(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer nombco
      integer ideb, ifin
      integer jdeb, jfin
c
      character*16 nocmpi
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
      texte(1,4) = '(''Le champ examine a'',i14,'' composante(s).'')'
      texte(1,5) = '(''Impossible de trouver la composante '',a)'
      texte(1,6) =
     > '(''dans le champ examine, dont les composantes sont :'')'
      texte(1,7) = '(a,''Composante'',i3,'' : '',a)'
      texte(1,8) = '(''Composante retenue : '',a)'
c
      texte(2,4) = '(''Examined field has got'',i14,'' component(s).'')'
      texte(2,5) = '(''Component '',a,'' cannot be found in the'')'
      texte(2,6) = '(''field, the components of which are :'')'
      texte(2,7) = '(a,''Component #'',i3,'' : '',a)'
      texte(2,8) = '(''Component : '',a)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbcomp
#endif
c
c====
c 2. Si le champ d'indicateur n'a qu'une composante, on retient celle-la
c====
c
      if ( nbcomp.eq.1 ) then
c
        if ( codret.eq.0 ) then
c
        ncmpin = 1
        nucomp(1) = 1
c
        endif
c
c====
c 3. Si le champ d'indicateur a plusieurs composantes :
c====
c
      else
c
        nombco = ncmpin
c
c 3.1. ==> Si au moins une composante a ete choisie ; on retient celles
c          qui l'ont ete
c
        if ( nombco.gt.0 ) then
c
          ncmpin = 0
c
          jfin = pointe(0)
c
          do 31 , iaux = 1 , nombco
c
c 3.1.1. ==> Reconstitution du nom de la composante
c
            nocmpi = '                '
c                     1234567890123456
            jdeb = jfin + 1
            jfin = pointe(iaux)
            ifin = 0
            do 311 , jaux = jdeb, jfin
c
              ideb = ifin + 1
              ifin = ifin + taille(jaux)
              if ( taille(jaux).eq.8 ) then
                nocmpi(ideb:ifin) = table(jaux)
              elseif ( taille(jaux).gt.0 ) then
                nocmpi(ideb:ifin) = table(jaux)(1:taille(jaux))
              else
                goto 3111
              endif
c
  311       continue
c
 3111       continue
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,7)) ' ', iaux, nocmpi
#endif
c
c 3.1.2. ==> Reherche
c
            if ( codret.eq.0 ) then
c
            do 312 , jaux = 1 , nbcomp
c
#ifdef _DEBUG_HOMARD_
              write (ulsort,texte(langue,7)) '.. ', jaux,
     >                                  nomcmp(2*jaux-1)//nomcmp(2*jaux)
#endif
              if ( nocmpi.eq.nomcmp(2*jaux-1)//nomcmp(2*jaux) ) then
                do 3121 , kaux = 1 , ncmpin
                  if ( nucomp(kaux).eq.jaux ) then
                    goto 3129
                  endif
 3121           continue
                ncmpin = ncmpin + 1
                nucomp(ncmpin) = jaux
                goto 3129
              endif
c
  312       continue
c
            codret = 2
            write (ulsort,texte(langue,5)) nocmpi
            write (ulsort,texte(langue,6))
            do 3122 , jaux = 1 , nbcomp
              write (ulsort,texte(langue,7)) ' ', jaux,
     >                                  nomcmp(2*jaux-1)//nomcmp(2*jaux)
 3122       continue
c
 3129       continue
c
            endif
c
   31     continue
c
c 3.2. ==> Si aucune n'a ete choisie, on les prend toutes
c
        elseif ( nombco.eq.0 ) then
c
          if ( codret.eq.0 ) then
c
          ncmpin = nbcomp
          do 32 , iaux = 1 , nbcomp
            nucomp(iaux) = iaux
   32     continue
c
          endif
c
c 3.3. ==> Sinon, probleme
c
        else
c
          codret = 1
c
        endif
c
      endif
c
c====
c 4. Impressions
c====
c
      if ( codret.eq.0 ) then
c
      do 41 , iaux = 1 , ncmpin
        jaux = nucomp(iaux)
        write (ulsort,texte(langue,8)) nomcmp(2*jaux-1)//nomcmp(2*jaux)
   41 continue
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
