      subroutine utnc11 ( nbanci, arreca,
     >                    aretri, filtri,
     >                    arequa, filqua,
     >                    filare, posifa, facare,
     >                    nbnoct, nbnocq,
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
c    UTilitaire - Non Conformite - phase 11
c    --           -   -                  --
c    On repere chaque face du macro maillage qui est bordee par une
c    arete recouvrante pour la non conformite initiale.
c    . Pour un triangle, on compte ceux dont les 3 aretes
c      sont recouvrantes.
c    . Pour un quadrangle on compte ceux dont les 4 aretes
c      sont recouvrantes.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbanci . e   .    1   . nombre d'aretes de non conformite initiale .
c .        .     .        . egal au nombre d'aretes recouvrant 2 autres.
c . arreca . e   .2*nbanci. liste des aretes recouvrant une autre      .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . filtri . e   . nbtrto . premier fils des triangles                 .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . filqua . e   . nbquto . premier fils des quadrangles               .
c . filare . e   . nbarto . premiere fille des aretes                  .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . nbnoct .  s  .   1    . nombre de tria avec 3 aretes recouvrantes  .
c . nbnocq .  s  .   1    . nombre de quad avec 4 aretes recouvrantes  .
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
      parameter ( nompro = 'UTNC11' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
c
c 0.3. ==> arguments
c
      integer nbanci, arreca(2*nbanci)
      integer aretri(nbtrto,3)
      integer filtri(nbtrto)
      integer arequa(nbquto,4)
      integer filqua(nbquto)
      integer filare(nbarto)
      integer posifa(0:nbarto), facare(nbfaar) 
      integer nbnoct, nbnocq
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer ipos
      integer ideb, ifin
      integer larete, letria, lequad
      integer compte
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
      texte(1,4) =
     > '(''Nombre de paires de '',a,'' non-conformes :'',i10))'
      texte(1,5) = '(a,'' Examen du '',a,'' numero'',i10)'
      texte(1,6) = '(''...'',i2,''eme face voisine'')'
      texte(1,7) = '(''... Nombre de '',a,'' recouvrants :'',i10))'
      texte(1,8) =
     > '(''Nombre de '',a,'' a aretes recouvrantes :'',i10))'
c
      texte(2,4) =
     > '(''Number of pairs of non-conformal '',a,'' :'',i10))'
      texte(2,5) = '(a,'' Examination of '',a,'' #'',i10)'
      texte(2,6) = '(''...'',i2,''th face'')'
      texte(2,7) = '(''Number of covering '',a,'' :'',i10))'
      texte(2,8) =
     > '(''Number of '',a,'' with covering edges :'',i10))'
c
      codret = 0
c
      nbnoct = 0
      nbnocq = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,1), nbanci
#endif
c
c====
c 2. On regarde toutes les aretes qui en recouvrent une autre.
c====
cgn       print *,'filqua : ',filqua
c
      jaux = 2*nbanci
      do 21 , iaux = 1 , jaux
c
        larete = arreca(iaux)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) '.', mess14(langue,1,1), larete
#endif
c
c 2.1. ==> On regarde toutes les faces qui s'appuie sur cette arete
c
        ideb = posifa(larete-1)+1
        ifin = posifa(larete)
c
        do 211 , ipos = ideb, ifin
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) ipos-ideb+1
#endif
c
c 2.1.1. ==> un triangle : on arrete pour le moment
c
          if ( facare(ipos).gt.0 ) then
            letria = facare(ipos)
cgn#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) '...', mess14(langue,1,2), letria
cgn#endif
            codret = 666
c
c 2.1.2. ==> Un quadrangle : on compte le nombre d'aretes recouvrantes
c            qui le definissent
c            Attention a ne pas examiner plusieurs fois de suite
c            le meme quadrangle ...
c
          else
            lequad = -facare(ipos)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) '...', mess14(langue,1,4), lequad
#endif
            if ( filqua(lequad).eq.0 ) then
c
              compte = 0
              do 2121 , kaux = 1 , 4
                if ( filare(arequa(lequad,kaux)).ne.0 ) then
                  compte = compte + 1
                endif
 2121         continue
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) mess14(langue,3,1), compte
#endif
c
              if ( compte.eq.4 ) then
                filqua(lequad) = -4
                nbnocq = nbnocq + 1
              endif
c
            endif
c
          endif
c
  211   continue
c
   21 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) mess14(langue,3,2), nbnoct
      write (ulsort,texte(langue,8)) mess14(langue,3,4), nbnocq
#endif
cgn       print *,'filqua : ',filqua
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
