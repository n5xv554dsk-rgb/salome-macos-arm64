      subroutine utimpg ( choix, ngauss, nbnorf, sdim,
     >                    conorf, copgrf, wipg,
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
c    UTilitaire - IMpressions relatives aux Points de Gauss
c    --           --                        -         -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . choix  . e   .   1    . choix des impressions                      .
c .        .     .        . 2n : les localisations de l'element de     .
c .        .     .        .      reference                             .
c .        .     .        . 3n : les fonctions de forme                .
c . ngauss . e   .   1    . nbre de points de Gauss des fonctions pg   .
c . nbnorf . e   .   1    . nbre de noeuds de l'element de reference   .
c . sdim   . e   .   1    . dimension de l'element de reference        .
c . conorf . e   .  sdim* . coordonnees des noeuds de l'element de     .
c .        .     . nbnorf . reference                                  .
c . copgrf . e   .  sdim* . coordonnees des points de Gauss            .
c .        .     . ngauss . de l'element de reference                  .
c . wipg   .   s . nbnorf*. fonctions de forme exprimees aux points de .
c .        .     . ngauss . Gauss                                      .
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
      parameter ( nompro = 'UTIMPG' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer choix
      integer ngauss, nbnorf, sdim
c
      double precision conorf(sdim,nbnorf), copgrf(sdim,ngauss)
      double precision wipg(nbnorf,ngauss)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
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
      if ( choix.gt.0 ) then
c
c====
c 2. Ecriture des localisations
c====
c
      if ( mod(choix,2).eq.0 ) then
c
c 2.1. ==> dimension 1
c
        if ( sdim.eq.1 ) then
c                            123456789012345
          write (ulsort,20001) 'noeuds         '
          do 2011 , iaux = 1 , nbnorf
            write (ulsort,20011) iaux, conorf(1,iaux)
 2011     continue
          write (ulsort,20021)
          write (ulsort,20001) 'points de Gauss'
          do 2021 , iaux = 1 , ngauss
            write (ulsort,20011) iaux, copgrf(1,iaux)
 2021     continue
          write (ulsort,20021)
c
c 2.2. ==> dimension 2
c
        elseif ( sdim.eq.2 ) then
c
          write (ulsort,20002) 'noeuds         '
          do 2012 , iaux = 1 , nbnorf
            write (ulsort,20012) iaux, conorf(1,iaux), conorf(2,iaux)
 2012     continue
          write (ulsort,20022)
          write (ulsort,20002) 'points de Gauss'
          do 2022 , iaux = 1 , ngauss
            write (ulsort,20012) iaux, copgrf(1,iaux), copgrf(2,iaux)
 2022     continue
          write (ulsort,20022)
c
c 2.3. ==> dimension 3
c
        else
c
          write (ulsort,20003) 'noeuds         '
          do 2013 , iaux = 1 , nbnorf
            write (ulsort,20013) iaux, conorf(1,iaux), conorf(2,iaux),
     >                           conorf(3,iaux)
 2013     continue
          write (ulsort,20023)
          write (ulsort,20003) 'points de Gauss'
          do 2023 , iaux = 1 , ngauss
            write (ulsort,20013) iaux, copgrf(1,iaux), copgrf(2,iaux),
     >                           copgrf(3,iaux)
 2023     continue
          write (ulsort,20023)
        endif
c
20001 format(
     >/,28('*'),
     >/,'*      Coordonnees des     *',
     >/,'*      ',a15        ,'     *',
     >/,28('*'),
     >/,'*  Numero  *       x       *',
     >/,28('*'))
20002 format(
     >/,44('*'),
     >/,'*       Coordonnees des ',a15        ,'    *',
     >/,44('*'),
     >/,'*  Numero  *       x       *       y       *',
     >/,44('*'))
20003 format(
     >/,60('*'),
     >/,'*            Coordonnees des ',a15         ,
     >'               *',
     >/,60('*'),
     >/,'*  Numero  *       x       *       y       *',
     >'       z       *',
     >/,60('*'))
20011 format('* ',i5,'    *  ',g11.5,'  *')
20012 format('* ',i5,2x,2('  *  ',g11.5),'  *')
20013 format('* ',i5,2x,3('  *  ',g11.5),'  *')
20021 format(28('*'))
20022 format(44('*'))
20023 format(60('*'))
c
c====
c 3. Ecriture des fonctions de forme aux points de Gauss
c====
c
      elseif ( mod(choix,3).eq.0 ) then
c                            123456789012345
        do 3011 , iaux = 1 , nbnorf
          write (ulsort,30001) iaux
          do 3021 , jaux = 1 , ngauss
            write (ulsort,20011) jaux, wipg(iaux,jaux)
 3021     continue
          write (ulsort,20021)
 3011   continue
c
      endif
c
c        123456789012345678901234567890
30001 format(
     >/,28('*'),
     >/,'*  Fonction associee au    *',
     >/,'*  noeud numero',  i8,'    *',
     >/,28('*'),
     >/,'* Point de *     Valeur    *',
     >/,'*  Gauss   *               *',
     >/,28('*'))
c
      endif
c
c====
c 4. la fin
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
