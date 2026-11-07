      subroutine utnc09 ( nbanci, arrecb, numea0,
     >                    pertri, perqua, numead,
     >                    posifa, facare,
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
c    UTilitaire - Non Conformite - phase 09
c    --           -   -                  --
c    On repere chaque face du macro maillage qui est bordee par une
c    arete de non conformite initiale. On declare que cette face a une
c    mere, dont le numero est un numero fictif, ne correspondant a
c    aucune face possible.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbanci . e   .    1   . nombre d'aretes de non conformite initiale .
c .        .     .        . egal au nombre d'aretes recouvrant 2 autres.
c . arrecb . e   .2*nbanci. liste des aretes recouvertes par une autre .
c . numea0 . e   .   1    . ancien numero de la mere adoptive ou 0     .
c . pertri . es  . nbtrto . pere des triangles                         .
c . perqua . es  . nbquto . pere des quadrangles                       .
c . numead .  s  .   1    . numero de la mere adoptive                 .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 3 : probleme                               .
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
      parameter ( nompro = 'UTNC09' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
c
c 0.3. ==> arguments
c
      integer nbanci, arrecb(2*nbanci)
      integer numea0
      integer pertri(nbtrto), perqua(nbquto)
      integer numead
      integer posifa(0:nbarto), facare(nbfaar) 
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer ipos
      integer ideb, ifin
      integer larete
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
      texte(1,4) = '(''Nombre de non-conformites :'',i10))'
      texte(1,5) = '(''Numero de la mere adoptive :'',i10))'
      texte(1,6) = '(''Examen de l''''arete'',i10)'
      texte(1,7) = '(''..'',i2,''eme face :'',i10)'
      texte(1,8) = '(''Ancien numero de la mere adoptive :'',i10))'
c
      texte(2,4) = '(''Number of non-conformal situations :'',i10))'
      texte(2,5) = '(''Number for adoptive mother :'',i10))'
      texte(2,6) = '(''Examination of edge #'',i10)'
      texte(2,7) = '(''..'',i2,''th face :'',i10)'
      texte(2,8) = '(''Old number for adoptive mother :'',i10))'
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbanci
      if ( numea0.ne.0 ) then
        write (ulsort,texte(langue,8)) numea0
      endif
#endif
c
c====
c 2. On regarde toutes les aretes qui sont recouvertes par une autre.
c    On trie les faces qui sont bordees par une de ces aretes.
c    Chacune de ces faces qui sont du macro-maillage se voit
c    attribuer une mere fictive, -nbfato-1, sauf si elle a deja une
c    mere. Cela arrive dans le cas de face des recollement en 3D.
c====
cgn       print *,'perqua : ',perqua
cgn       print *,'arrecb : ',arrecb
c
      numead = -(nbtrto+nbquto+1)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) numead
#endif
c
      jaux = 2*nbanci
      do 21 , iaux = 1 , jaux
c
        larete = arrecb(iaux)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) larete
#endif
        ideb = posifa(larete-1)+1
        ifin = posifa(larete)
        do 211 , ipos = ideb, ifin
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) ipos-ideb+1, facare(ipos)
#endif
          if ( facare(ipos).gt.0 ) then
            if ( facare(ipos).le.nbtrma ) then
              if ( pertri(facare(ipos)).eq.0 .or.
     >             pertri(facare(ipos)).eq.numea0 ) then
                pertri(facare(ipos)) = numead
              endif
            endif
          else
            if ( -facare(ipos).le.nbquma ) then
              if ( perqua(-facare(ipos)).eq.0 .or.
     >             perqua(-facare(ipos)).eq.numea0 ) then
                perqua(-facare(ipos)) = numead
              endif
            endif
          endif
  211   continue
c
   21 continue
cgn       print *,'pertri : ',pertri
cgn       print *,'perqua : ',perqua
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
