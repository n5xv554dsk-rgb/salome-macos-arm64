      subroutine deinfi ( option, obfiad,
     >                    decare, decfac, iniada,
     >                    filtar, filtfa,
     >                    povoso, voisom,
     >                    noempo,
     >                    somare,
     >                    aretri,
     >                    arequa,
     >                    tritet,
     >                    quahex,
     >                    facpyr,
     >                    facpen,
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
c traitement des DEcisions - INitialisations - FIltrage
c                --          --                --
c ______________________________________________________________________
c  Modification des decisions pour tenir compte du filtrage
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .    1   . 0 : on retire les entites filtrees         .
c .        .     .        . 1 : on ajoute les entites filtrees         .
c . obfiad . e   . char*8 . memorisation du filtrage de l'adaptation   .
c . decare . es  .0:nbarto. decisions des aretes                       .
c . decfac . es  . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . iniada . e   .   1    . initialisation de l'adaptation             .
c .        .     .        . 0 : on garde tout (defaut)                 .
c .        .     .        .-1 : reactivation des mailles ou aucun      .
c .        .     .        .     indicateur n'est defini                .
c .        .     .        . 1 : raffinement des mailles ou aucun       .
c .        .     .        .     indicateur n'est defini                .
c . filtar .  a  . nbarto . filtrage des aretes                        .
c . filtfa .  a  . -nbquto. filtrage sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . povoso . e   .0:nbnoto. pointeur des voisins par sommet            .
c . voisom . e   . nvosom . aretes voisines de chaque noeud            .
c . noempo . e   . nbmpto . numeros des noeuds associes aux mailles    .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . facpen . e   .nbpecf*5. numeros des faces des pentaedres           .
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
      parameter ( nompro = 'DEINFI' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "gmenti.h"
#include "nombno.h"
#include "nombmp.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer option
c
      character*8 obfiad
c
      integer decare(0:nbarto), decfac(-nbquto:nbtrto)
      integer iniada
      integer filtar(nbarto), filtfa(-nbquto:nbtrto)
      integer povoso(0:nbnoto), voisom(*)
      integer noempo(nbmpto)
      integer somare(2,nbarto)
      integer aretri(nbtrto,3)
      integer arequa(nbquto,4)
      integer tritet(nbtecf,4)
      integer quahex(nbhecf,6)
      integer facpyr(nbpycf,5)
      integer facpen(nbpecf,5)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, laux
      integer kdeb, kfin
      integer larete, lesomm
      integer nbvent, adfilt
      integer typenh
      integer valdef, valmod
      integer nbpass
c
      character*5 saux
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
      data nbpass / 0 /
c ______________________________________________________________________
c
c====
c 1. Initialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
c 1.1. ==> Les messages
c
      texte(1,4) = '(5x,''Filtrage'',i2)'
      texte(1,5) = '(5x,''Retrait des entites filtrees'')'
      texte(1,6) = '(5x,''Ajout des entites filtrees'')'
      texte(1,7) = '(''Filtrage pour les '',a)'
c
      texte(2,4) = '(5x,''Filtering #'',i2)'
      texte(2,5) = '(5x,''Removal of filtered entities'')'
      texte(2,6) = '(5x,''Addition of filtered entities'')'
      texte(2,7) = '(''Filtering for the '',a)'
c
#include "impr03.h"
c
      nbpass = nbpass + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbpass
      write (ulsort,texte(langue,5+option))
#endif
c
      codret = 0
c
c 1.2. ==> Au depart rien n'est retenu
c
      if ( option.eq.0 ) then
        valdef = 1
        valmod = 0
      elseif ( option.eq.1 ) then
        valdef = 0
        valmod = 1
      else
        codret = 1
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'option', option
      write (ulsort,90002) 'valdef', valdef
      write (ulsort,90002) 'valmod', valmod
#endif
c
      if ( codret.eq.0 ) then
c
      do 121 , iaux = 1 , nbarto
        filtar(iaux) = valdef
  121 continue
c
      do 122 , iaux = -nbquto , nbtrto
        filtfa(iaux) = valdef
  122 continue
c
      endif
c
c====
c 2. Boucle sur tous les types d'entites mailles (cf. vcfia0)
c====
cgn      write (ulsort,90003) 'obfiad', obfiad
#ifdef _DEBUG_HOMARD_
      call gmprsx ( nompro, obfiad )
#endif
c
      do 21 , typenh = -1 , 7
c
c 2.1. ==> Nombre de valeurs
c
        if ( codret.eq.0 ) then
c
        iaux = typenh + 2
        call gmliat ( obfiad, iaux, nbvent, codret )
c
        endif
c
c 2.2. ==> Adresse des valeurs s'il y en a
c
        if ( codret.eq.0 ) then
c
        if ( nbvent.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,7)) mess14(langue,3,typenh)
#endif
c
          if ( codret.eq.0 ) then
c
          iaux = typenh + 2
          call utench ( iaux, 'g', jaux, saux,
     >                  ulsort, langue, codret )
c
          endif
c
          if ( codret.eq.0 ) then
c
          saux = '.Tab'//saux(1:1)
          call gmadoj ( obfiad//saux, adfilt, iaux, codret )
          adfilt = adfilt - 1
c
          endif
c
        endif
c
        endif
c
c 2.3. ==> Prise en compte selon le type de mailles
c          On boucle sur le nombre de mailles courantes. Ce n'est pas
c          toujours egal au nombre de valeurs du fait de la suppression
c          eventuelle de mailles de mise en conformite. Ce n'est pas
c          grave car dans la creation de obfiad (vcfiad), on a pris en
c          compte toutes les entites, quel que soit leur statut.
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.3. '//mess14(langue,3,typenh)//' codret',
     >                     codret
#endif
c
        if ( codret.eq.0 ) then
c
        if ( nbvent.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
          call gmprsx ( nompro, obfiad//saux )
#endif
c
c 2.3.1. ==> Les sommets : on traite les aretes dont les deux
c                          extremites sont dans le filtre
c
          if ( typenh.eq.-1 ) then
c
            do 231 , iaux = 1 , nbarto
              if ( imem(adfilt+somare(1,iaux)).ne.0 .and.
     >             imem(adfilt+somare(2,iaux)).ne.0 ) then
cgn                write (ulsort,90002) 'arete ', iaux
                filtar(iaux) = valmod
              endif
  231       continue
c
c 2.3.2. ==> Les mailles-points :
c            Pour une maille-point retenue, on parcourt toutes les
c            aretes qui ont le noeud sous-jacent pour extremite. Pour
c            chacune de ces aretes, on regarde l'autre sommet. Si une
c            maille-point retenue est basee sur cet autre sommet, on
c            declare l'arete comme faisant partie des candidats a
c            l'adaptation.
c            Remarque : il n'est pas trop grave de faire la double
c                       boucle car il y a peu de mailles-points !
c
          elseif ( typenh.eq.0 ) then
c
            do 232 , iaux = 1 , nbmpto
c
              if ( imem(adfilt+iaux).ne.0 ) then
c
                jaux = noempo(iaux)
                kdeb = povoso(jaux-1) + 1
                kfin = povoso(jaux)
c
                do 2321 , kaux = kdeb, kfin
                  larete = voisom(kaux)
                  if ( somare(1,larete).eq.jaux ) then
                    lesomm = somare(2,larete)
                  else
                    lesomm = somare(1,larete)
                  endif
                  do 23211 , laux = 1 , nbmpto
                    if ( noempo(laux).eq.lesomm ) then
                      if ( imem(adfilt+laux).ne.0 ) then
                        filtar(larete) = valmod
                        goto 232
                      endif
                    endif
23211           continue
 2321           continue
c
              endif
c
  232       continue
c
c 2.3.3. ==> Les aretes : chacune est traitee
c
          elseif ( typenh.eq.1 ) then
c
            do 233 , iaux = 1 , nbarto
cgn                write (ulsort,90002) 'arete ', iaux
              if ( imem(adfilt+iaux).ne.0 ) then
cgn                write (ulsort,90002) '==> passage a', valmod
                filtar(iaux) = valmod
              endif
  233       continue
c
c 2.3.4. ==> Les triangles : chacun est traite, de meme que ses aretes
c
          elseif ( typenh.eq.2 ) then
c
            do 234 , iaux = 1 , nbtrto
cgn      write (ulsort,90002) 'triangle ', iaux,imem(adfilt+iaux),decfac(iaux)
              if ( imem(adfilt+iaux).ne.0 ) then
cgn                write (ulsort,90002) '==> passage a', valmod
cgn      write (ulsort,90002) '==> modif aretes', (aretri(iaux,jaux),jaux=1,3)
                filtfa(iaux) = valmod
                filtar(aretri(iaux,1)) = valmod
                filtar(aretri(iaux,2)) = valmod
                filtar(aretri(iaux,3)) = valmod
              endif
  234       continue
c
c 2.3.5. ==> Les tetraedres : chacune de ses faces et de ses aretes est
c                             traitee
c
          elseif ( typenh.eq.3 ) then
c
            do 235 , iaux = 1 , nbteto
cgn         print *,'tetr',iaux,imem(adfilt+iaux)
              if ( imem(adfilt+iaux).ne.0 ) then
                do 2351 , jaux = 1 , 4
                  kaux = tritet(iaux,jaux)
                  filtfa(kaux) = valmod
                  filtar(aretri(kaux,1)) = valmod
                  filtar(aretri(kaux,2)) = valmod
                  filtar(aretri(kaux,3)) = valmod
 2351           continue
              endif
  235       continue
c
c 2.3.6. ==> Les quadrangles : chacun est traite, de meme que ses aretes
c
          elseif ( typenh.eq.4 ) then
c
            do 236 , iaux = 1 , nbquto
              if ( imem(adfilt+iaux).ne.0 ) then
                filtfa(-iaux) = valmod
                filtar(arequa(iaux,1)) = valmod
                filtar(arequa(iaux,2)) = valmod
                filtar(arequa(iaux,3)) = valmod
                filtar(arequa(iaux,4)) = valmod
              endif
  236       continue
c
c 2.3.7. ==> Les pyramides : chacune de ses faces et de ses aretes est
c                            traitee
c          Remarque : comme on affecte valmod a toutes les aretes des
c                     triangles, il est inutile de se preoccuper des
c                     aretes du quadrangle car elles sont deja traitees
c
          elseif ( typenh.eq.5 ) then
c
            do 237 , iaux = 1 , nbpyto
              if ( imem(adfilt+iaux).ne.0 ) then
                do 2371 , jaux = 1 , 4
                  kaux = facpyr(iaux,jaux)
                  filtfa(kaux) = valmod
                  filtar(aretri(kaux,1)) = valmod
                  filtar(aretri(kaux,2)) = valmod
                  filtar(aretri(kaux,3)) = valmod
 2371           continue
                kaux = facpyr(iaux,5)
                filtfa(-kaux) = valmod
              endif
  237       continue
c
c 2.3.8. ==> Les hexaedres : chacune de ses faces et de ses aretes est
c                            traitee
c
          elseif ( typenh.eq.6 ) then
c
            do 238 , iaux = 1 , nbheto
              if ( imem(adfilt+iaux).ne.0 ) then
cgn                write(*,*)'.. hexaedre', iaux
                do 2381 , jaux = 1 , 6
                  kaux = quahex(iaux,jaux)
                  filtfa(-kaux) = valmod
                  filtar(arequa(kaux,1)) = valmod
                  filtar(arequa(kaux,2)) = valmod
                  filtar(arequa(kaux,3)) = valmod
                  filtar(arequa(kaux,4)) = valmod
cgn                  write(*,*)'.... face', kaux
 2381           continue
              endif
  238       continue
c
c 2.3.9. ==> Les pentaedres : chacune de ses faces et de ses aretes est
c                             traitee
c          Remarque : comme on affecte valmod a toutes les aretes des
c                     quadrangles, il est inutile de se preoccuper des
c                     aretes des triangles car elles sont deja traitees
c
          elseif ( typenh.eq.7 ) then
c
            do 239 , iaux = 1 , nbpeto
cgn              write(ulsort,*)'.... pentaedre', iaux
              if ( imem(adfilt+iaux).ne.0 ) then
                do 2391 , jaux = 1 , 2
                  kaux = facpen(iaux,jaux)
                  filtfa(kaux) = valmod
 2391           continue
                do 2392 , jaux = 3 , 5
                  kaux = facpen(iaux,jaux)
cgn                  write(ulsort,*)'.... face', kaux
cgn                  write(ulsort,*)'.... aretes', arequa(kaux,1),
cgn     >            arequa(kaux,2),arequa(kaux,3),arequa(kaux,4)
                  filtfa(-kaux) = valmod
                  filtar(arequa(kaux,1)) = valmod
                  filtar(arequa(kaux,2)) = valmod
                  filtar(arequa(kaux,3)) = valmod
                  filtar(arequa(kaux,4)) = valmod
 2392           continue
              endif
  239       continue
c
          endif
c
        endif
c
        endif
c
   21 continue
c
c====
c 3. Applications aux decisions
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Applications ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( iniada.eq.1 ) then
        valmod = 2
      else
        valmod = iniada
      endif
c
      do 31 , iaux = 1 , nbarto
        if ( filtar(iaux).eq.0 ) then
cgn          if ( decare(iaux).gt.0 ) then
cgn        write(ulsort,*)'    suppression pour arete', iaux
            decare(iaux) = valmod
cgn          endif
        endif
   31 continue
c
      if ( iniada.eq.1 ) then
        valmod = 4
      else
        valmod = iniada
      endif
c
      do 32 , iaux = -nbquto , nbtrto
        if ( filtfa(iaux).eq.0 ) then
cgn          if ( decfac(iaux).gt.0 ) then
            decfac(iaux) = valmod
cgn          endif
        endif
   32 continue
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
