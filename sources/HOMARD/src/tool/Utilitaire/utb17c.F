      subroutine utb17c ( somare, np2are,
     >                    hettri, aretri,
     >                    hetqua, arequa,
     >                    voltri,
     >                    volqua,
     >                    posifa, facare,
     >                    famare, cfaare,
     >                    famtri, cfatri,
     >                    famqua, cfaqua,
     >                    tabaux,
     >                    ulbila,
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
c    UTilitaire - Bilan sur le maillage - option 17 - phase c
c    --           -                              --         -
c ______________________________________________________________________
c
c Diagnostic des elements surfaciques du calcul
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . np2are . e   . nbarto . numero des noeuds p2 milieux d'aretes      .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . voltri . e   .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . volqua . e   .2*nbquto. numeros des 2 volumes par quadrangle       .
c .        .     .        . volqua(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre j                           .
c .        .     .        . j<0 : pyramide/pentaedre dans pypequ(1/2,j).
c . posifa . e   .0:nbarto. pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . famare . e   . nbarto . famille des aretes                         .
c . cfaare . e   . nctfar*. codes des familles des aretes              .
c .        .     . nbfare .   1 : famille MED                          .
c .        .     .        .   2 : type de segment                      .
c .        .     .        .   3 : orientation                          .
c .        .     .        .   4 : famille d'orientation inverse        .
c .        .     .        .   5 : numero de ligne de frontiere         .
c .        .     .        .  > 0 si concernee par le suivi de frontiere.
c .        .     .        . <= 0 si non concernee                      .
c .        .     .        .   6 : famille frontiere active/inactive    .
c .        .     .        .   7 : numero de surface de frontiere       .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famtri . e   . nbtrto . famille des triangles                      .
c . cfatri . e   . nctftr*. codes des familles des triangles           .
c .        .     . nbftri .   1 : famille MED                          .
c .        .     .        .   2 : type de triangle                     .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famqua . e   . nbquto . famille des quadrangles                    .
c . cfaqua . e   . nctfqu*. codes des familles des quadrangles         .
c .        .     . nbfqua .   1 : famille MED                          .
c .        .     .        .   2 : type de quadrangle                   .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        .   5 : famille des triangles de conformite  .
c .        .     .        .   6 : famille de sf active/inactive        .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . tabaux . e   . nbnoto . 0 : le noeud est interne                   .
c .        .     .        . 1 : le noeud est au bord d'une face        .
c . ulbila . e   .   1    . unite logique d'ecriture du bilan          .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
c .____________________________________________________________________.
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
      parameter ( nompro = 'UTB17C' )
c
#include "nblang.h"
#include "coftex.h"
c
c 0.2. ==> communs
c
#include "envca1.h"
#include "nbfami.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
c
#include "dicfen.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer somare(2,nbarto), np2are(nbarto)
      integer hettri(nbtrto), aretri(nbtrto,3)
      integer hetqua(nbquto), arequa(nbquto,4)
c
      integer voltri(2,nbtrto)
      integer volqua(2,nbquto)
      integer posifa(0:nbarto), facare(nbfaar)
c
      integer famare(nbarto), cfaare(nctfar,nbfare)
      integer famtri(nbtrto), cfatri(nctftr,nbftri)
      integer famqua(nbquto), cfaqua(nctfqu,nbfqua)
c
      integer tabaux(nbnoto)
c
      integer ulbila
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer jdeb, jfin
      integer letria, lequad, larete
      integer laface
      integer nbensc, nbensb
      integer nbvoto
      integer etat, etat00
      integer a1, a2, a3, a4
      integer sa1a2, sa2a3, sa3a1, sa3a4, sa4a1
      integer listso(4)
c
      logical afaire
      logical aubord
c
      integer nbmess
      parameter (nbmess = 10 )
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
      texte(1,4) = '(''Nombre de '',a,'' actifs :'',i10)'
      texte(1,5) = '(''. Examen du '',a,i10)'
      texte(1,6) = '(''... '',a,i10,'' au bord'')'
      texte(1,7) =
     >'(''. Le bord du '',a,i10,'' n''''est pas une maille de calcul.''
     >)'
      texte(1,8) = '(''. Le '',a,i8,'' est surcontraint.'')'
c
      texte(2,4) = '(''Number of active '',a,'' : '',i8)'
      texte(2,5) = '(''. Examination of '',a,''#'',i8)'
      texte(2,6) = '(''... '',a,''#'',i8,'' on the boundary'')'
      texte(2,7) =
     >'(''. The boundary of the '',a,i10,'' is not a calculation mesh.''
     >)'
      texte(2,8) = '(''. The '',a,''#'',i8,'' is overstressed.'')'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,2), nbtrac
      write (ulsort,texte(langue,4)) mess14(langue,3,4), nbquac
#endif
c
      codret = 0
c
c====
c 2. Diagnostic sur les triangles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. triangles, codret = ', codret
#endif
c
      if ( nbtrac.gt.0 ) then
c
        nbensc = 0
        nbensb = 0
        aubord = .false.
        afaire = .false.
        nbvoto = nbteto + nbpyto + nbpeto
c
        do 2 , letria = 1, nbtrto
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,1,2), letria
#endif
c
          if ( cfatri(cotyel,famtri(letria)).ne.0 ) then
c
          etat = mod( hettri(letria),10 )
c
          if ( etat.eq.0 ) then
c
c 2.0. ==> S'il y a des volumes, on ne prend que des triangles purs
c
            if ( nbvoto.ne.0 ) then
c
              if ( voltri(1,letria).ne.0 ) then
                goto 2
              endif
c
            endif
c
            afaire = .true.
c
c 2.1. ==> On regarde si tous les noeuds sont sur le bord
c
            a1 = aretri(letria,1)
            a2 = aretri(letria,2)
            a3 = aretri(letria,3)
            call utsotr ( somare, a1, a2, a3,
     >                    sa1a2, sa2a3, sa3a1 )
c
            listso(1) = sa1a2
            listso(2) = sa2a3
            listso(3) = sa3a1
c
            do 211 , iaux = 1 , 3
              if ( tabaux(listso(iaux)).eq.0 ) then
                goto 219
              endif
  211       continue
            if ( degre.eq.2 ) then
              do 212 , iaux = 1 , 3
                if ( tabaux(np2are(aretri(letria,iaux))).eq.0 ) then
                  goto 219
                endif
  212         continue
            endif
c
            nbensc = nbensc + 1
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,8)) mess14(langue,1,2), letria
#endif
c
  219       continue
c
c 2.2. ==> On verifie que chaque arete au bord est un element de calcul
c
            do 22 , iaux = 1 , 3
c
              larete = aretri(letria,iaux)
              jdeb = posifa(larete-1)+1
              jfin = posifa(larete)
c
c 2.2.1. ==> L'arete a au plus une face voisine : elle est de bord
c
              if ( jfin.le.jdeb ) then
cgn         write (ulsort,*) 'au plus une face voisine'
c
                kaux = 0
c
c 2.2.2. ==> L'arete a au moins deux faces voisines : il faut compter
c            le nombre de faces actives car avec la conformite, une
c            face et sa fille sont declarees voisines de l'arete
c
              else
c
                kaux = 0
                do 222 , jaux = jdeb, jfin
                  laface = facare(jaux)
cgn         write (ulsort,*) 'voisine de', laface
                  if ( laface.gt.0 ) then
                    etat00 = mod(hettri(laface),10)
                  else
                    etat00 = mod(hetqua(-laface),100)
                  endif
                  if ( etat00.eq.0 ) then
                    kaux = kaux + 1
                  endif
  222           continue
c
              endif
c
c 2.2.3. ==> Bilan
c
              if ( kaux.le.1 ) then
#ifdef _DEBUG_HOMARD_
              write (ulsort,texte(langue,6)) mess14(langue,1,1), larete
#endif
                aubord = .true.
c
                if ( cfaare(cotyel,famare(larete)).eq.0 ) then
                  nbensb = nbensb + 1
#ifdef _DEBUG_HOMARD_
              write (ulsort,texte(langue,7)) mess14(langue,1,2), letria
#endif
                  goto 229
                endif
c
              endif
c
   22       continue
c
  229       continue
c
          endif
c
          endif
c
    2   continue
c
c 2.3. ==> Impression
c
        if ( afaire ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB17E', nompro
#endif
          iaux = 2
          call utb17e ( iaux, nbensc, aubord, nbensb,
     >                  ulbila,
     >                  ulsort, langue, codret )
c
        endif
c
      endif
c
c====
c 3. Diagnostic sur les quadrangles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. quadrangles, codret = ', codret
#endif
c
      if ( nbquac.gt.0 ) then
c
        nbensc = 0
        nbensb = 0
        aubord = .false.
        afaire = .false.
        nbvoto = nbheto + nbpyto + nbpeto
c
        do 3 , lequad = 1, nbquto
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,1,4), lequad
#endif
c
          if ( cfaqua(cotyel,famqua(lequad)).ne.0 ) then
c
          etat = mod( hetqua(lequad),100 )
c
          if ( etat.eq.0 ) then
c
c 3.0. ==> S'il y a des volumes, on ne prend que des quadrangles purs
c
            if ( nbvoto.ne.0 ) then
c
              if ( volqua(1,lequad).ne.0 ) then
                goto 3
              endif
c
            endif
c
            afaire = .true.
c
c 3.1. ==> On regarde si tous les noeuds sont sur le bord
c
            a1 = arequa(lequad,1)
            a2 = arequa(lequad,2)
            a3 = arequa(lequad,3)
            a4 = arequa(lequad,4)
            call utsoqu ( somare, a1, a2, a3, a4,
     >                    sa1a2, sa2a3, sa3a4, sa4a1 )
            listso(1) = sa1a2
            listso(2) = sa2a3
            listso(3) = sa3a4
            listso(4) = sa4a1
c
            do 311 , iaux = 1 , 4
              if ( tabaux(listso(iaux)).eq.0 ) then
                goto 319
              endif
  311       continue
            if ( degre.eq.2 ) then
              do 312 , iaux = 1 , 4
                if ( tabaux(np2are(arequa(lequad,iaux))).eq.0 ) then
                  goto 319
                endif
  312         continue
            endif
c
            nbensc = nbensc + 1
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,8)) mess14(langue,1,4), lequad
#endif
c
  319       continue
c
c 3.2. ==> On verifie que chaque arete au bord est un element de calcul
c
            do 32 , iaux = 1 , 4
c
              larete = arequa(lequad,iaux)
              jdeb = posifa(larete-1)+1
              jfin = posifa(larete)
c
c 3.2.1. ==> L'arete a au plus une face voisine : elle est de bord
c
              if ( jfin.le.jdeb ) then
cgn         write (ulsort,*) 'au plus une face voisine'
c
                kaux = 0
c
c 3.2.2. ==> L'arete a au moins deux faces voisines : il faut compter
c            le nombre de faces actives car avec la conformite, une
c            face et sa fille sont declarees voisines de l'arete
c
              else
c
                kaux = 0
                do 322 , jaux = jdeb, jfin
                  laface = facare(jaux)
cgn         write (ulsort,*) 'voisine de', laface
                  if ( laface.gt.0 ) then
                    etat00 = mod(hettri(laface),10)
                  else
                    etat00 = mod(hetqua(-laface),100)
                  endif
                  if ( etat00.eq.0 ) then
                    kaux = kaux + 1
                  endif
  322           continue
c
              endif
c
c 3.2.3. ==> Bilan
c
              if ( kaux.le.1 ) then
#ifdef _DEBUG_HOMARD_
              write (ulsort,texte(langue,6)) mess14(langue,1,1), larete
#endif
                aubord = .true.
c
                if ( cfaare(cotyel,famare(larete)).eq.0 ) then
                  nbensb = nbensb + 1
#ifdef _DEBUG_HOMARD_
              write (ulsort,texte(langue,7)) mess14(langue,1,4), lequad
#endif
                  goto 329
                endif
c
              endif
c
   32       continue
c
  329       continue
c
          endif
c
          endif
c
    3   continue
c
c 3.3. ==> Impression
c
        if ( afaire ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB17E', nompro
#endif
          iaux = 4
          call utb17e ( iaux, nbensc, aubord, nbensb,
     >                  ulbila,
     >                  ulsort, langue, codret )
c
        endif
c
      endif
c
      end
