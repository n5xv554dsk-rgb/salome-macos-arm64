      subroutine utnc12 ( hettri, aretri, filtri, pertri,
     >                    hetqua, arequa, filqua, perqua,
     >                    filare, posifa, facare,
     >                    nbnocq, qureca, qurecb, conocq,
     >                    nbnoct, trreca, trrecb, conoct,
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
c    UTilitaire - Non Conformite - phase 12
c    --           -   -                  --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . filtri . e   . nbtrto . premier fils des triangles                 .
c . pertri . e   . nbtrto . pere des triangles                         .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . filqua . e   . nbquto . premier fils des quadrangles               .
c . perqua . e   . nbquto . pere des quadrangles                       .
c . filare . e   . nbarto . premiere fille des aretes                  .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . nbnocq . e   .    1   . nombre de non conformites de quadrangles   .
c . qureca .  s  .4*nbnocq. liste des quad. recouvrant un autre        .
c . qurecb .  s  .4*nbnocq. liste des quad. recouverts par un autre    .
c . nbnoct . e   .    1   . nombre de non conformites de quadrangles   .
c . trreca .  s  .4*nbnoct. liste des triangles recouvrant un autre    .
c . trrecb .  s  .4*nbnoct. liste des triangles recouverts par un autre.
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
      parameter ( nompro = 'UTNC12' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "ope1a4.h"
#include "impr02.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
c
c 0.3. ==> arguments
c
      integer nbnocq, qureca(4*nbnocq), qurecb(4*nbnocq), conocq
      integer nbnoct, trreca(4*nbnoct), trrecb(4*nbnoct), conoct
      integer hettri(nbtrto), aretri(nbtrto,3)
      integer filtri(nbtrto), pertri(nbtrto)
      integer hetqua(nbquto), arequa(nbquto,4)
      integer filqua(nbquto), perqua(nbquto)
      integer filare(nbarto)
      integer posifa(0:nbarto), facare(nbfaar)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer ipos
      integer ideb, ifin
      integer lequad
      integer conosv
      integer lareta, laretb
      integer fillea, filleb, lequfi
c
      integer nbmess
      parameter ( nbmess = 20 )
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
     > '(''Nombre de '',a,'' a aretes recouvrantes :'',i10))'
      texte(1,6) = '(a,'' Examen du '',a,'' numero'',i10)'
      texte(1,7) = '(''Recollement des '',a)'
      texte(1,8) = '(''Nombre trouve  :'',i10)'
      texte(1,9) = '(''Nombre attendu :'',i10)'
c
      texte(2,4) =
     > '(''Number of '',a,'' with covering edges :'',i10))'
      texte(2,6) = '(a,'' Examination of '',a,'' #'',i10)'
      texte(2,7) = '(''Glue for '',a)'
      texte(2,8) = '(''Found number    :'',i10)'
      texte(2,9) = '(''Expected number :'',i10)'
c
      codret = 0
c
      conoct = 0
      conocq = 0
c
c====
c 2. Les triangles
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,2), nbnoct
      write (ulsort,texte(langue,4)) mess14(langue,3,4), nbnocq
#endif
c
      if ( nbnoct.gt.0 ) then
        codret = 12000
      endif
cgn       print *,'pertri : ',pertri
cgn       print *,'filtri : ',filtri
c
c====
c 3. Les quadrangles
c    On va reperer tous ceux concernes : c'est possible car on leur a
c    attribue un fils negatif a l'etape precedente.
c====
c
      if ( nbnocq.gt.0 ) then
c
      do 31 , lequad = 1 , nbquto
c
#ifdef _DEBUG_HOMARD_
        if ( filqua(lequad).ne.0 ) then
      write (ulsort,texte(langue,6)) '...', mess14(langue,1,4), lequad
      endif
#endif
c
c 3.1. ==> Le quadrangle a 4 aretes non conformes
c          On cherche les numeros des 4 quadrangles qui se trouvent
c          'dessous'. On passe par les aretes qui sont les filles de
c          ces aretes a lui. Les quadrangles fils sont ceux qui
c          partagent deux aretes filles consecutives.
c          Remarque : il faut placer les quadrangles fils dans l'ordre
c          de la convention de decoupage (cf. cmrdqu). Le premier est
c          celui qui s'appuie sur les aretes 4 et 1. Le 2eme s'appuie
c          sur les aretes 1 et 2, le 3eme sur les aretes2 et 3, le 4eme
c          sur les aretes 3 et 4. On va les ranger dans l'ordre dans
c          les listes de recollement.
c
c          remarque : le dernier quadrangle est celui qui correspond
c                     au fils aine
c          remarque : per1a4(-1,i) renvoie l'entier qui est avant i
c
        if ( filqua(lequad).eq.-4 ) then
c
          conosv = conocq
c
          do 311 , iaux = 4, 1, -1
c
            lareta = arequa(lequad,iaux)
            laretb = arequa(lequad,per1a4(-1,iaux))
cgn            write (ulsort,*) lareta, laretb
c
            do 312 , jaux = 0 , 1
              fillea = filare(lareta) + jaux
              ideb = posifa(fillea-1)+1
              ifin = posifa(fillea)
cgn                write (ulsort,*) '.', ideb, ifin
              do 313 , kaux = 0 , 1
                filleb = filare(laretb) + kaux
cgn                write (ulsort,*) '...', fillea, filleb
                do 314 , ipos = ideb, ifin
                  if ( facare(ipos).lt.0 ) then
                    lequfi = -facare(ipos)
cgn                write (ulsort,*) '.....', lequfi
                    if ( arequa(lequfi,1).eq.filleb .or.
     >                   arequa(lequfi,2).eq.filleb .or.
     >                   arequa(lequfi,3).eq.filleb .or.
     >                   arequa(lequfi,4).eq.filleb ) then
                      conocq = conocq + 1
                      qureca(conocq) = lequad
                      qurecb(conocq) = lequfi
                      perqua(lequfi) = lequad
                      goto 311
                    endif
                  endif
  314           continue
  313         continue
  312       continue
c
cccc            codret = codret + 1
c
  311     continue
c
          if ( conocq.eq.conosv ) then
            filqua(lequad) = 0
          elseif ( conocq.eq.(conosv+4) ) then
            filqua(lequad) = lequfi
            hetqua(lequad) = 4
          else
            write(ulsort,*) 'lequad = ',lequad
            write(ulsort,*) 'conocq = ',conocq
            write(ulsort,*) 'conosv = ',conosv
            codret = 31
          endif
c
c 3.2. ==> Le quadrangle a 2 aretes non conformes
c
        elseif ( filqua(lequad).eq.-1 .or. filqua(lequad).eq.-2 ) then
c
         codret = 3232
c
        endif
c
   31 continue
cgn       print *,'filqua : ',filqua
cgn       print *,'perqua : ',perqua
c
      endif
c
c====
c 4. controle
c====
c
      if ( conoct.gt.4*nbnoct ) then
c
        write (ulsort,texte(langue,7)) mess14(langue,3,2)
        write (ulsort,texte(langue,8)) conoct
        write (ulsort,texte(langue,9)) 4*nbnoct
        codret = 1
c
      endif
c
      if ( conocq.gt.4*nbnocq ) then
c
        write (ulsort,texte(langue,7)) mess14(langue,3,4)
        write (ulsort,texte(langue,8)) conocq
        write (ulsort,texte(langue,9)) 4*nbnocq
        codret = 1
c
      endif
c
      conoct = conoct / 4
      conocq = conocq / 4
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
