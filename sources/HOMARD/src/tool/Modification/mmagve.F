      subroutine mmagve ( famtet, cfatet,
     >                    nbfmed, numfam,
     >                    grfmpo, grfmtl, grfmtb,
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
c    Modification de Maillage - AGregat - VErifications
c    -               -          --        --
c    Verifications de la possibilite de calculer les joints
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . famtet . e   . nbteto . famille des tetraedres                     .
c . cfatet . e   . nctfte. codes des familles des tetraedres           .
c .        .     . nbftet .   1 : famille MED                          .
c .        .     .        .   2 : type de tetraedres                   .
c . nbfmed . e   .    1   . nombre de familles MED dans le maillage    .
c . numfam . e   . nbfmed . numero MED des familles                    .
c . grfmpo . e   .0:nbfmed. groupes calcul - pointeur                  .
c . grfmta . e   .   *    . groupes calcul - taille                    .
c . grfmtb . e   .   *    . groupes calcul - table                     .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
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
      parameter ( nompro = 'MMAGVE' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
c
#include "coftex.h"
#include "nbfami.h"
#include "dicfen.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      integer famtet(nbteto), cfatet(nctfte,nbftet)
      integer nbfmed, numfam(nbfmed)
      integer grfmpo(0:nbfmed), grfmtl(*)
c
      character*8 grfmtb(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer codre0
c
      integer letetr
      integer fammed, nufali
      integer ptrdeb, ptrfin
c
      character*80 saux80
c
      integer nbmess
      parameter ( nbmess = 40 )
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
#include "impr03.h"
#include "mmag01.h"
c
      texte(1,31) =
     >'(''Les seules mailles volumiques possibles sont les '',a,''.'')'
      texte(1,32) =
     >'(''Impossible de trouver la famille MED dans la liste.'')'
      texte(1,33) = '(''Nombre de groupes :'',i4)'
      texte(1,34) =
     > '(''Un '',a,'' doit appartenir a un groupe et un seul.'')'
      texte(1,35) = '(''. Groupe : '',a)'
c
      texte(2,31) =
     >'(''The only authorized volumic meshes are the '',a,''.'')'
      texte(2,32) = '(''MED family cannot be found into the list.'')'
      texte(2,33) = '(''Number of groups:'',i4)'
      texte(2,34) =
     > '(''A '',a,'' must belong to one single group.'')'
      texte(2,35) = '(''. Group: '',a)'
c
      codret = 0
c
c====
c 2. Uniquement des tetraedres
c====
c
cgn        write (ulsort,90002) 'nbteto', nbteto
cgn        write (ulsort,90002) 'nbheto', nbheto
cgn        write (ulsort,90002) 'nbpyto', nbpyto
cgn        write (ulsort,90002) 'nbpeto', nbpeto
      if ( nbheto.ne.0 .or. nbpyto.ne.0 .or. nbpeto.ne.0 ) then
        codret = 2
      endif
c
c====
c 3. Parcours des tetraedres
c    Si la famille MED du tetraedre n'a pas exactement un groupe,
c    il y a un probleme
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,3,3)
#endif
c
      if ( codret.eq.0 ) then
c
      do 30 , iaux = 1 , nbteto
c
c 3.1. ==> Reperage de la famille MED
c
        if ( codret.eq.0 ) then
c
        fammed = cfatet(cofamd,famtet(iaux))
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30)) mess14(langue,1,3), iaux, fammed
#endif
c
        do 31 , jaux = 1 , nbfmed
          if ( fammed.eq.numfam(jaux) ) then
            nufali = jaux
cgn            write (ulsort,90002) 'fammed nufali',fammed,nufali
            goto 310
          endif
   31   continue
c
        letetr = iaux
        codret = 31
c
  310   continue
c
        endif
c
c 3.2. ==> Nombre de groupes de la famille MED
c
        if ( codret.eq.0 ) then
c
        ptrdeb = grfmpo(nufali-1) + 1
        ptrfin = grfmpo(nufali)
c
cgn        write (ulsort,90002) 'ptrdeb ptrfin',ptrdeb,ptrfin
        if ( ptrfin.ne.ptrdeb+9 ) then
          letetr = iaux
          codret = 320 + ( ptrfin-ptrdeb + 1 ) / 10
        endif
c
        endif
c
   30 continue
c
      endif
c
c====
c 4. Messages d'erreur
c====
c
      if ( codret.ne.0 ) then
c
      if ( codret.eq.2 ) then
        write (ulsort,texte(langue,31)) mess14(langue,3,3)
      else
        write (ulsort,texte(langue,30)) mess14(langue,1,3),
     >                                  letetr, fammed
       if ( codret.eq.31 ) then
          write (ulsort,texte(langue,32))
        else
          jaux = codret - 320
          write (ulsort,texte(langue,33)) jaux
          do 41 , iaux = 1  , jaux
            kaux = grfmtl(ptrdeb)
            call uts8ch ( grfmtb(ptrdeb), kaux, saux80,
     >                    ulsort, langue, codre0 )
            write (ulsort,texte(langue,35)) saux80(1:kaux)
            ptrdeb = ptrdeb + 10
   41     continue
          write (ulsort,texte(langue,34)) mess14(langue,1,3)
        endif
      endif
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
