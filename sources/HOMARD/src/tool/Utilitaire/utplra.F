      subroutine utplra ( optimp,
     >                    indnoe, indnp2, indnim, indare,
     >                    indtri, indqua, indtet, indhex, indpen,
     >                    decare, decfac,
     >                    hettri,
     >                    hetqua,
     >                    tritet, hettet,
     >                    quahex, hethex,
     >                    facpen, hetpen,
     >                    nbsoan, nbsono,
     >                    nbnoan, nbnono,
     >                    nbaran, nbarno,
     >                    nbtran, nbtrno,
     >                    nbquan, nbquno,
     >                    nbtean, nbteno,
     >                    nbhean, nbheno,
     >                    nbpean, nbpeno,
     >                    nbpyan, nbpyno,
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
c     UTilitaire : PLace pour le RAffinement
c     --           --            --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . optimp . e   .   1    . impressions 0:non, 1:oui                   .
c . indnoe . e   .   1    . indice du dernier noeud cree               .
c . indnp2 . e   .   1    . nombre de noeuds p2 en vigueur             .
c . indnim . e   .   1    . nombre de noeuds internes en vigueur       .
c . indare . e   .   1    . indice de la derniere arete creee          .
c . indtri . e   .   1    . indice du dernier triangle cree            .
c . indqua . e   .   1    . indice du dernier quadrangle cree          .
c . indtet . e   .   1    . indice du dernier tetraedre cree           .
c . indhex . e   .   1    . indice du dernier hexaedre cree            .
c . indpen . es  .   1    . indice du dernier pentaedre cree           .
c . decare . e   .0:nbarto. table des decisions sur les aretes         .
c . decfac . e   . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . facpen . e   .nbpecf*5. numeros des faces des pentaedres           .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . nbsoan . s   .    1   . nombre de sommets - ancien                 .
c . nbsono . s   .    1   . nombre de sommets - nouveau                .
c . nbnoan . s   .    1   . nombre de noeuds - ancien                  .
c . nbnono . s   .    1   . nombre de noeuds - nouveau                 .
c . nbaran . s   .    1   . nombre d'aretes - ancien                   .
c . nbarno . s   .    1   . nombre d'aretes - nouveau                  .
c . nbtran . s   .    1   . nombre de triangles - ancien               .
c . nbtrno . s   .    1   . nombre de triangles - nouveau              .
c . nbquan . s   .    1   . nombre de quadrangles - ancien             .
c . nbquno . s   .    1   . nombre de quadrangles - nouveau            .
c . nbtean . s   .    1   . nombre de tetraedres - ancien              .
c . nbteno . s   .    1   . nombre de tetraedres - nouveau             .
c . nbhean . s   .    1   . nombre d'hexaedres - ancien                .
c . nbheno . s   .    1   . nombre d'hexaedres - nouveau               .
c . nbpean . s   .    1   . nombre de pentaedres - ancien              .
c . nbpeno . s   .    1   . nombre de pentaedres - nouveau             .
c . nbpyan . s   .    1   . nombre de pyramides - ancien               .
c . nbpyno . s   .    1   . nombre de pyramides - nouveau              .
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
      parameter ( nompro = 'UTPLRA' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpe.h"
#include "nombpy.h"
#include "nouvnb.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer optimp
c
      integer indnoe, indnp2, indnim, indare, indtri, indqua
      integer indtet, indhex, indpen
      integer decare(0:nbarto)
      integer decfac(-nbquto:nbtrto)
      integer hettri(nbtrto)
      integer hetqua(nbquto)
      integer tritet(nbtecf,4), hettet(nbteto)
      integer quahex(nbhecf,6), hethex(nbheto)
      integer facpen(nbpecf,5), hetpen(nbpeto)
      integer nbsoan, nbsono
      integer nbnoan, nbnono
      integer nbaran, nbarno
      integer nbtran, nbtrno
      integer nbquan, nbquno
      integer nbtean, nbteno
      integer nbhean, nbheno
      integer nbpean, nbpeno
      integer nbpyan, nbpyno
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer cpt1, cpt2
      integer larete, letria, lequad, letetr, lehexa, lepent
c
      logical opti00
      logical noinma
c
      integer nbmess
      parameter ( nbmess = 10 )
c
      character*80 texte(nblang,nbmess)
      character*40 mess40(nblang,2)
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
c                    1234567890123456789012345678901234567890
      mess40(1,1) = '    Nombres d''entites permanentes du    '
      mess40(1,2) = '           nouveau maillage             '
c
      mess40(2,1) = '    Number of permanent entities of     '
      mess40(2,2) = '              the new mesh              '
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      opti00 = .True.
#else
      if ( optimp.eq.1 ) then
        opti00 = .True.
      else
        opti00 = .False.
      endif
#endif
c
50000 format(
     >  5x,'==========================================',
     >/,5x,'!',a40                                 ,'!',
     >/,5x,'!',a40                                 ,'!',
     >/,5x,'==========================================')
50010 format(
     >  5x,'!     ',       a14,'    !   ',   i10,'   !')
c                                       1234567890
50020 format(
     >  5x,'==========================================',
     > /)
c
c====
c 2. initialisation des nombres d'entites
c====
c
      permp1 = indnoe - indnp2
      permno = indnoe
      permp2 = indnp2
      permim = indnim
      permar = indare
      permtr = indtri
      permqu = indqua
      permte = indtet
      permhe = indhex
      permpe = indpen
cgn      write(ulsort,90002) 'depart  permno, permp1, permp2, permim',
cgn     >                             permno, permp1, permp2, permim
c
c====
c 3. entites nouvelles crees par decoupage des aretes
c    remarque : en degre 2, le decoupage d'une arete entraine la
c               creation de 2 p2 et la transformation d'un p2 en p1.
c               au bilan, il y a donc 2 noeuds en plus : 1 p1 et 1 p2.
c====
c
      cpt1 = 0
c
      do 30 , larete = 1 , nbarto
c
        if ( decare(larete).eq.2 ) then
c
c         decoupage en 2 de l'arete
c         -------------------------
c
          cpt1 = cpt1 + 1
c
        endif
c
   30 continue
c
      if ( degre.eq.1 ) then
        permno = permno + cpt1
      elseif ( degre.eq.2 ) then
        permno = permno + 2*cpt1
        permp2 = permp2 +   cpt1
      endif
      permp1 = permp1 + cpt1
      permar = permar + 2*cpt1
cgn      write(ulsort,90002) 'aretes  permno, permp1, permp2, permim',
cgn     >                             permno, permp1, permp2, permim
c
c====
c 4. entites nouvelles crees par decoupage standard des triangles
c====
c
      if ( nbtrto.ne.0 ) then
c
        if ( mod(mailet,2).eq.0 ) then
          noinma = .true.
        else
          noinma = .false.
        endif
c
        cpt1 = 0
c
        do 40 , letria = 1 , nbtrto
c
          if ( decfac(letria).eq.4 ) then
c
c           decoupage en 4 du triangle
c           --------------------------
c
            cpt1 = cpt1 + 1
c
          endif
c
   40   continue
c
        if ( degre.eq.2 ) then
          permno = permno + 3*cpt1
          permp2 = permp2 + 3*cpt1
        endif
c
        if ( noinma ) then
          permno = permno + 3*cpt1
          permim = permim + 3*cpt1
        endif
c
        permar = permar + 3*cpt1
        permtr = permtr + 4*cpt1
c
      endif
cgn      write(ulsort,90002) 'tria    permno, permp1, permp2, permim',
cgn     >                             permno, permp1, permp2, permim
c
c====
c 5. entites nouvelles crees par decoupage standard des quadrangles
c====
c
      if ( nbquto.ne.0 ) then
c
        if ( mod(mailet,3).eq.0 ) then
          noinma = .true.
        else
          noinma = .false.
        endif
c
        cpt1 = 0
c
        do 50 , lequad = 1 , nbquto
c
          if ( decfac(-lequad).eq.4 ) then
c
c           decoupage en 4 du quadrangle
c           ----------------------------
c
            cpt1 = cpt1 + 1
c
          endif
c
   50   continue
c
        if ( degre.eq.2 ) then
          permno = permno + 4*cpt1
          permp2 = permp2 + 4*cpt1
        endif
c
        if ( noinma ) then
          permno = permno + 3*cpt1
          permp1 = permp1 + 3*cpt1
          permim = permim + 3*cpt1
        endif
c
        permno = permno + cpt1
        permp1 = permp1 + cpt1
        permar = permar + 4*cpt1
        permqu = permqu + 4*cpt1
c
      endif
cgn      write(ulsort,90002) 'quad    permno, permp1, permp2, permim',
cgn     >                             permno, permp1, permp2, permim
c
c====
c 6. entites nouvelles crees par decoupage des tetraedres
c    un tetraedre est a decouper si et seulement si :
c    . il est actif
c    . chacune de ses 4 faces est coupee ou a couper
c====
c
      if ( nbtecf.ne.0 ) then
c
        cpt1 = 0
c
        do 60 , letetr = 1 , nbtecf
c
         if ( mod( hettet(letetr) , 100 ).eq.0 ) then
c
            cpt2 = 0
            do 61 , iaux = 1 , 4
              letria = tritet(letetr,iaux)
              if ( mod(hettri(letria),10).eq.4 .or.
     >             mod(hettri(letria),10).eq.5 .or.
     >             mod(hettri(letria),10).eq.6 .or.
     >             mod(hettri(letria),10).eq.7 .or.
     >             mod(hettri(letria),10).eq.9) then
                cpt2 = cpt2 + 1
              else if ( decfac(letria).eq.4 ) then
                cpt2 = cpt2 + 1
              endif
   61       continue
c
            if ( cpt2.eq.4 ) then
c
c             decoupage standard en 8
c             -----------------------
c
              cpt1 = cpt1 + 1
c
            endif
c
          endif
c
   60   continue
c
        if ( degre.eq.2 ) then
          permno = permno + cpt1
          permp2 = permp2 + cpt1
        endif
c
        permar = permar +   cpt1
        permtr = permtr + 8*cpt1
        permte = permte + 8*cpt1
c
      endif
cgn      write(ulsort,90002) 'tetr    permno, permp1, permp2, permim',
cgn     >                             permno, permp1, permp2, permim
c
c====
c 7. entites nouvelles crees par decoupage des hexaedres
c    un hexaedre est a decouper si et seulement si :
c    . il est actif
c    . chacune de ses 6 faces est coupee ou a couper
c====
c
      if ( nbheto.ne.0 ) then
c
        cpt1 = 0
c
        do 70 , lehexa = 1 , nbheto
c
          if ( mod( hethex(lehexa),1000 ).eq.0 ) then
c
            cpt2 = 0
            do 71 , iaux = 1 , 6
              lequad = quahex(lehexa,iaux)
              if ( mod(hetqua(lequad),100).eq.4 .or.
     >             mod(hetqua(lequad),100).eq.99) then
                cpt2 = cpt2 + 1
              else if ( decfac(-lequad).eq.4 ) then
                cpt2 = cpt2 + 1
              endif
   71       continue
c
            if ( cpt2.eq.6 ) then
c
c             decoupage standard en 8
c             -----------------------
c
              cpt1 = cpt1 + 1
c
            endif
c
          endif
c
   70   continue
c
        if ( degre.eq.2 ) then
          permno = permno +6*cpt1
          permp2 = permp2 +6*cpt1
        endif
c
        permp1 = permp1 +   cpt1
        permno = permno +   cpt1
        permar = permar + 6*cpt1
        permqu = permqu +12*cpt1
        permhe = permhe + 8*cpt1
c
      endif
cgn      write(ulsort,90002) 'hexa    permno, permp1, permp2, permim',
cgn     >                             permno, permp1, permp2, permim
c
c====
c 8. entites nouvelles crees par decoupage des pentaedres
c    un pentaedre est a decouper si et seulement si :
c    . il est actif
c    . chacune de ses 5 faces est coupee ou a couper
c====
c
      if ( nbpeto.ne.0 ) then
c
        cpt1 = 0
c
        do 80 , lepent = 1 , nbpeto
c
          if ( mod( hetpen(lepent) , 100 ).eq.0 ) then
c
            cpt2 = 0
            do 81 , iaux = 1 , 2
              letria = facpen(lepent,iaux)
              if ( mod(hettri(letria),10).eq.4 .or.
     >             mod(hettri(letria),10).eq.9) then
                cpt2 = cpt2 + 1
              else if ( decfac(letria).eq.4 ) then
                cpt2 = cpt2 + 1
              endif
   81       continue
            do 82 , iaux = 3, 5
              lequad = facpen(lepent,iaux)
              if ( mod(hetqua(lequad),100).eq.4 .or.
     >             mod(hetqua(lequad),100).eq.99) then
                cpt2 = cpt2 + 1
              else if ( decfac(-lequad).eq.4 ) then
                cpt2 = cpt2 + 1
              endif
   82       continue
c
            if ( cpt2.eq.5 ) then
c
c             decoupage standard en 8
c             -----------------------
c
              cpt1 = cpt1 + 1
c
            endif
c
          endif
c
   80   continue
c
        if ( degre.eq.2 ) then
          permno = permno +3*cpt1
          permp2 = permp2 +3*cpt1
        endif
c
        permno = permno
        permar = permar + 3*cpt1
        permtr = permtr + 4*cpt1
        permqu = permqu + 6*cpt1
        permpe = permpe + 8*cpt1
c
      endif
cgn      write(ulsort,90002) 'pent    permno, permp1, permp2, permim',
cgn     >                             permno, permp1, permp2, permim
c
c====
c 8. bilan, initialisations et impressions
c====
c
      nouvno = permno
      nouvp2 = permp2
      nouvim = permim
      nouvar = permar
      nouvtr = permtr
      nouvqu = permqu
      nouvte = permte
      nouvtf = nouvte
      nouvhe = permhe
      nouvhf = nouvhe
      nouvpe = permpe
      nouvpf = nouvpe
c
      if ( opti00 ) then
c
        write(ulsort,50000) mess40(langue,1), mess40(langue,2)
        write(ulsort,50010) mess14(langue,2,-1), nouvno
        write(ulsort,50010) mess14(langue,2,1), nouvar
        if ( nbtrto.gt.0 ) then
          write(ulsort,50010) mess14(langue,2,2), nouvtr
        endif
        if ( nbquto.gt.0 ) then
          write(ulsort,50010) mess14(langue,2,4), nouvqu
        endif
        if ( nbteto.gt.0 ) then
          write(ulsort,50010) mess14(langue,2,3), nouvte
        endif
        if ( nbheto.gt.0 ) then
          write(ulsort,50010) mess14(langue,2,6), nouvhe
        endif
        if ( nbpeto.gt.0 ) then
          write(ulsort,50010) mess14(langue,2,7), nouvpe
        endif
        write(ulsort,50020)
c
      endif
cgn      write(ulsort,90002)
cgn     > 'fin de '//nompro//' permno, permp1, permp2, permim',
cgn     >                      permno, permp1, permp2, permim
c
      if ( codret.eq.0 ) then
c
      nbsoan = nbnop1
      nbsono = permp1
      nbnoan = nbnoto
      nbnono = permno
      nbaran = nbarto
      nbarno = permar
      nbtran = nbtrto
      nbtrno = permtr
      nbquan = nbquto
      nbquno = permqu
      nbtean = nbteto
      nbteno = permte
      nbhean = nbheto
      nbheno = permhe
      nbpean = nbpeto
      nbpeno = permpe
      nbpyan = nbpyto
      nbpyno = permpy
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'nbnoan, nbnono', nbnoan, nbnono
      write(ulsort,90002) 'nbaran, nbarno', nbaran, nbarno
      write(ulsort,90002) 'nbtran, nbtrno', nbtran, nbtrno
      write(ulsort,90002) 'nbquan, nbquno', nbquan, nbquno
      write(ulsort,90002) 'nbtean, nbteno', nbtean, nbteno
      write(ulsort,90002) 'nbhean, nbheno', nbhean, nbheno
      write(ulsort,90002) 'nbpean, nbpeno', nbpean, nbpeno
      write(ulsort,90002) 'nbpyan, nbpyno', nbpyan, nbpyno
#endif
c
      endif
c
c====
c 9. la fin
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
