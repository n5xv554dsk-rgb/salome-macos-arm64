      subroutine vcmex1 (         famnoe, posnoe, inxnoe,
     >                    somare, famare, posare, inxare,
     >                            famtri,
     >                    postri, inxtri, pentri,
     >                    arequa, famqua, posqua, inxqua, hexqua,
     >                    quahex, coquhe, famhex,
     >                    facpen, cofape, fampen,
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
c    aVant adaptation - Conversion de Maillage EXtrude - phase 1
c     -                 -             -        --              -
c Memorise les informations pour l'extrusion
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . famnoe . e   . nbnoto . famille des noeuds                         .
c . posnoe . e   . nbnoto . position des noeuds                        .
c .        .     .        . 0 : face avant                             .
c .        .     .        . 1 : face arriere                           .
c . inxnoe .  s  .2*nbnoto. informations pour l'extrusion des noeuds   .
c .        .     .        . 1 : famille du noeud extrude               .
c .        .     .        . 2 : famille de l'arete perpendiculaire     .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . famare . e   . nbarto . famille des aretes                         .
c . posare . e   . nbarto . position des aretes                        .
c .        .     .        . 0 : arete avant                            .
c .        .     .        . 1 : arete arriere                          .
c .        .     .        . 2 : arete perpendiculaire                  .
c . inxare .  s  .4*nbarto. informations pour l'extrusion des aretes   .
c .        .     .        . 1 : famille de l'arete extrudee            .
c .        .     .        . 2 : famille du quadrangle perpendiculaire  .
c .        .     .        . 3 : code du quadrangle dans le volume      .
c .        .     .        . 4 : quadrangle perpendiculaire             .
c . famtri . e   . nbtrto . famille des triangles                      .
c . postri . e   . nbtrto . position des triangles                     .
c .        .     .        . 0 : face avant                             .
c .        .     .        . 1 : face arriere                           .
c .        .     .        . 2 : face perpendiculaire                   .
c . inxtri .  s  .3*nbtrto. informations pour l'extrusion des triangles.
c .        .     .        . 1 : famille du triangle extrude            .
c .        .     .        . 2 : famille du pentaedre                   .
c .        .     .        . 3 : code du triangle dans le pentaedre     .
c . pentri .  s  . nbtrto . pentaedre sur un triangle de la face avant .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . famqua . e   . nbquto . famille des quadrangles                    .
c . posqua . e   . nbquto . position des quadrangles                   .
c .        .     .        . 0 : face avant                             .
c .        .     .        . 1 : face arriere                           .
c .        .     .        . 2 : face perpendiculaire                   .
c . inxqua . es  .3*nbquto. informations pour l'extrusion des quads    .
c .        .     .        . Pour un quadrangle a l'avant :             .
c .        .     .        .  1 : famille du quadrangle extrude         .
c .        .     .        .  2 : famille de l'hexaedre                 .
c .        .     .        .  3 : orientation du quadrangle dans le vol..
c .        .     .        . Pour un quadrangle a l'arriere :           .
c .        .     .        .  1 : inutile                               .
c .        .     .        .  2 : inutile                               .
c .        .     .        .  3 : orientation du quadrangle dans le vol..
c .        .     .        . Pour un quadrangle perpendiculaire :       .
c .        .     .        .  1 : sens de la 1ere compos. de la normale .
c .        .     .        .  2 : sens de la 2eme compos. de la normale .
c .        .     .        .  3 : orientation du quadrangle dans le vol..
c . hexqua .  s  . nbquto . hexaedre sur un quadrangle de la face avant.
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . famhex . e   . nbheto . famille des hexaedres                      .
c . facpen . e   .nbpecf*5. numeros des faces des pentaedres           .
c . cofape . e   .nbpecf*5. code des 5 faces des pentaedres            .
c . fampen . e   . nbpeto . famille des pentaedres                     .
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
      parameter ( nompro = 'VCMEX1' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombhe.h"
#include "nombpe.h"
c
#include "ope1a4.h"
c
c 0.3. ==> arguments
c
      integer                   famnoe(nbnoto)
      integer posnoe(nbnoto), inxnoe(2,nbnoto)
      integer somare(2,nbarto), famare(nbarto)
      integer posare(nbarto), inxare(4,nbarto)
      integer                   famtri(nbtrto)
      integer postri(nbtrto), inxtri(3,nbtrto), pentri(nbtrto)
      integer arequa(nbquto,4), famqua(nbquto)
      integer posqua(nbquto), inxqua(3,nbquto), hexqua(nbquto)
      integer quahex(nbhecf,6), coquhe(nbhecf,6), famhex(nbheto)
      integer facpen(nbpecf,5), cofape(nbpecf,5), fampen(nbpeto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer iaux1, iaux2, iaux3, iaux4
      integer lehexa, lepent
      integer facear, cofaar
      integer faceav, cofaav
      integer facepp
      integer aretar, aretav, aretpp
      integer noeuar, noeuav
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
#include "impr03.h"
c
      codret = 0
c
c====
c 2. Prealables : rien n'est vu
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. Prealables ; codret', codret
#endif
c
      do 21 , iaux = 1 , nbarto
        inxare(1,iaux) = -1
   21 continue
c
      do 22 , iaux = 1 , nbtrto
        pentri(iaux) = 0
   22 continue
c
      do 23 , iaux = 1 , nbquto
        inxqua(3,iaux) = -1
        hexqua(iaux) = 0
   23 continue
c
c====
c 3. Examen des hexaedres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. hexaedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbheto', nbheto
#endif
c
      do 31 , lehexa = 1 , nbheto
c
c 3.1. ==> Bases quadrangulaires
c
cgn        write (ulsort,90012) 'faces de l''hexa', lehexa,
cgn     >        ( quahex(lehexa,jaux) , jaux = 1 , 6)
cgn        write (ulsort,90012) 'faces de l''hexa', lehexa,
cgn     >        ( inxqua(1,quahex(lehexa,jaux)) , jaux = 1 , 6)
        do 311 , jaux = 1 , 6
          iaux1 = quahex(lehexa,jaux)
          if ( posqua(iaux1).eq.0 ) then
            faceav = iaux1
            cofaav = coquhe(lehexa,jaux)
          elseif ( posqua(iaux1).eq.1 ) then
            facear = iaux1
            cofaar = coquhe(lehexa,jaux)
          endif
  311   continue
cgn        write (ulsort,90002) '.. faces de base', faceav, facear
c
cgn        write (ulsort,90002) '.. quad/hexa', faceav, lehexa
        inxqua(1,faceav) = famqua(facear)
        inxqua(2,faceav) = famhex(lehexa)
        inxqua(3,faceav) = cofaav
        inxqua(1,facear) = 0
        inxqua(2,facear) = 0
        inxqua(3,facear) = cofaar
        hexqua(faceav) = lehexa
c
c 3.2. ==> Faces perpendiculaires a l'extrusion
c          Remarque : une face n'est traitee qu'une fois, inxqua(3,.)<0
c
        do 312 , jaux = 1 , 6
c
          facepp = quahex(lehexa,jaux)
          if ( inxqua(3,facepp).lt.0 ) then
c
cgn      write (ulsort,90002) 'quad perp', facepp
c
c 3.2.1. ==> reperage des aretes avant et arriere
c
            do 3211 , kaux = 1, 4
              if ( posare(arequa(facepp,kaux)).eq.0 ) then
                iaux1 = kaux
              endif
 3211       continue
            aretav = arequa(facepp,iaux1)
            aretar = arequa(facepp,per1a4(2,iaux1))
cgn      write (ulsort,90002) 'aretes av/ar', aretav, aretar
c
c 3.2.2. ==> informations pour les aretes avant et arriere
c
            inxare(1,aretav) = famare(aretar)
            inxare(2,aretav) = famqua(facepp)
            inxare(3,aretav) = coquhe(lehexa,jaux)
            inxare(4,aretav) = facepp
c
c 3.2.3. ==> les deux aretes perpendiculaires
c
            do 3213 , kaux = 1 , 2
c
c 3.2.3.1. ==> numero de l'arete perpendiculaire
c
              if ( kaux.eq.1 ) then
                iaux2 = per1a4(1,iaux1)
              else
                iaux2 = per1a4(3,iaux1)
              endif
              aretpp = arequa(facepp,iaux2)
c
              if ( inxare(1,aretpp).lt.0 ) then
cgn        write (ulsort,90002) '.... arete perp 1', aretpp
c
c 3.2.3.2. ==> les deux sommets avant et arriere
c
                iaux3 = somare(1,aretpp)
                iaux4 = somare(2,aretpp)
                if ( posnoe(iaux3).eq.0 ) then
                  noeuav = iaux3
                  noeuar = iaux4
                else
                  noeuav = iaux4
                  noeuar = iaux3
                endif
cgn          write (ulsort,90002) '.... noeuds av/ar', noeuav, noeuar
                inxnoe(1,noeuav) = famnoe(noeuar)
                inxnoe(2,noeuav) = famare(aretpp)
                inxare(1,aretpp) = 0
              endif
c
 3213       continue
c
c 4.2.4. ==> Code de la face
c
            inxqua(3,facepp) = coquhe(lehexa,jaux)
c
          endif
c
  312   continue

c
   31 continue
c
      endif
c
c====
c 4. Examen des pentaedres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. pentaedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbpeto', nbpeto
#endif
c
      do 41 , lepent = 1 , nbpeto
c
c 4.1. ==> Bases triangulaires
c
cgn        write (ulsort,90012) 'faces du pentaedre', lepent,
cgn     >        ( facpen(lepent,jaux) , jaux = 1 , 5)
cgn        write (ulsort,90012) 'faces du pentaedre', lepent,
cgn     >        ( inxtri(1,facpen(lepent,jaux)) , jaux = 1 , 2),
cgn     >        ( inxqua(1,facpen(lepent,jaux)) , jaux = 3 , 5)
        iaux1 = facpen(lepent,1)
        iaux2 = facpen(lepent,2)
        if ( postri(iaux1) .eq.0 ) then
          faceav = iaux1
          cofaav = cofape(lepent,1)
          facear = iaux2
          cofaar = cofape(lepent,2)
        else
          faceav = iaux2
          cofaav = cofape(lepent,2)
          facear = iaux1
          cofaar = cofape(lepent,1)
        endif
cgn        write (ulsort,90002) '.. faces de base', faceav, facear
c
cgn        write (ulsort,90002) '.. tria/pent', faceav, lepent
        inxtri(1,faceav) = famtri(facear)
        inxtri(2,faceav) = fampen(lepent)
        inxtri(3,faceav) = cofaav
        inxtri(1,facear) = 0
        inxtri(2,facear) = 0
        inxtri(3,facear) = cofaar
        pentri(faceav) = lepent
c
c 4.2. ==> Faces perpendiculaires a l'extrusion
c          Remarque : on ne traite qu'une seule fois, inxqua(3,.)<0
c
        do 421 , jaux = 3 , 5
c
          facepp = facpen(lepent,jaux)
          if ( inxqua(3,facepp).lt.0 ) then
c
cgn      write (ulsort,90002) '.. quad perp', facepp
c
c 4.2.1. ==> reperage des aretes avant et arriere
c
            do 4211 , kaux = 1, 4
              if ( posare(arequa(facepp,kaux)).eq.0 ) then
                iaux1 = kaux
              endif
 4211       continue
            aretav = arequa(facepp,iaux1)
            aretar = arequa(facepp,per1a4(2,iaux1))
cgn      write (ulsort,90002) '.... aretes av/ar', aretav, aretar
c
c 4.2.2. ==> informations pour les aretes avant et arriere
c
            inxare(1,aretav) = famare(aretar)
            inxare(2,aretav) = famqua(facepp)
            inxare(3,aretav) = cofape(lepent,jaux)
            inxare(4,aretav) = facepp
c
c 4.2.3. ==> les deux aretes perpendiculaires
c
            do 4213 , kaux = 1 , 2
c
c 4.2.3.1. ==> numero de l'arete perpendiculaire
c
              if ( kaux.eq.1 ) then
                iaux2 = per1a4(1,iaux1)
              else
                iaux2 = per1a4(3,iaux1)
              endif
              aretpp = arequa(facepp,iaux2)
c
              if ( inxare(1,aretpp).lt.0 ) then
cgn        write (ulsort,90002) '.... arete perp 1', aretpp
c
c 4.2.3.2. ==> les deux sommets avant et arriere
c
                iaux3 = somare(1,aretpp)
                iaux4 = somare(2,aretpp)
                if ( posnoe(iaux3).eq.0 ) then
                  noeuav = iaux3
                  noeuar = iaux4
                else
                  noeuav = iaux4
                  noeuar = iaux3
                endif
cgn          write (ulsort,90002) '.... noeuds av/ar', noeuav, noeuar
                inxnoe(1,noeuav) = famnoe(noeuar)
                inxnoe(2,noeuav) = famare(aretpp)
                inxare(1,aretpp) = 0
              endif
c
 4213       continue
c
c 4.2.4. ==> Code de la face
c
            inxqua(3,facepp) = cofape(lepent,jaux)
c
          endif
c
  421   continue
c
   41 continue
c
      endif
c
#ifdef _DEBUG_HOMARD_
49900 format(/,24x,a)
      write(ulsort,49900) ' famille fa noe ex  fa arete'
      do 4991 , iaux = 1 , nbnoto
        if ( posnoe(iaux).eq.0 ) then
        write(ulsort,90012) 'noeud',iaux,famnoe(iaux),
     >                      inxnoe(1,iaux),inxnoe(2,iaux)
        endif
 4991 continue
c
      write(ulsort,49900)
     > ' famille fa are ex   fa quad code q/vo face perp'
      do 4992 , iaux = 1 , nbarto
        if ( posare(iaux).eq.0 ) then
        write(ulsort,90012) 'arete',iaux,famare(iaux),
     >               inxare(1,iaux),inxare(2,iaux),inxare(3,iaux)
        endif
 4992 continue
c
      write(ulsort,49900) 'famille fa tri ex   fa pent code t/pe'
      do 4993 , iaux = 1 , nbtrto
        if ( postri(iaux).eq.0 ) then
        write(ulsort,90012) 'tria',iaux,famtri(iaux),
     >               inxtri(1,iaux),inxtri(2,iaux),inxtri(3,iaux)
        endif
 4993 continue
c
      write(ulsort,49900)
     >'famille  position fa qua ex   fa hexa code q/vo'
      do 4994 , iaux = 1 , nbquto
        write(ulsort,90012) 'quad',iaux,famqua(iaux),posqua(iaux),
     >               inxqua(1,iaux),inxqua(2,iaux),inxqua(3,iaux)
 4994 continue
#endif
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
