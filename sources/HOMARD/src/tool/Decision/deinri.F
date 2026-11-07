      subroutine deinri ( pilraf, pilder,
     >                    typseh, typseb, seuilh, seuilb, nbsoci,
     >                    usacmp,
     >                    nbvpen, nbvpyr, nbvhex, nbvtet,
     >                    nbvqua, nbvtri, nbvare, nbvnoe,
     >                    nosupp, noindr, noindi,
     >                    arsupp, arindr, arindi,
     >                    trsupp, trindr, trindi,
     >                    qusupp, quindr, quindi,
     >                    tesupp, teindr, teindi,
     >                    hesupp, heindr, heindi,
     >                    pysupp, pyindr, pyindi,
     >                    pesupp, peindr, peindi,
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
c traitement des DEcisions - INitialisation de l'indicateur
c                --          --
c                                passage de Reel a entIer
c                                           -         -
c ______________________________________________________________________
c
c remarque : il faut filtrer par les supports pour les endroits ou
c            la valeur de l'indicateur est indefinie. mettre une
c            valeur "moyenne" ne permet pas de passer certains cas
c            biscornus a cause des .le. ou .lt.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . pilraf . e   .   1    . pilotage du raffinement                    .
c .        .     .        . -1 : raffinement uniforme                  .
c .        .     .        .  0 : pas de raffinement                    .
c .        .     .        .  1 : raffinement libre                     .
c .        .     .        .  2 : raff. libre homogene en type d'element.
c . pilder . e   .   1    . pilotage du deraffinement                  .
c .        .     .        . 0 : pas de deraffinement                   .
c .        .     .        . 1 : deraffinement libre                    .
c .        .     .        . -1 : deraffinement uniforme                .
c . typseh . e   .   1    . type de seuil haut                         .
c .        .     .        . 1 : absolu                                 .
c .        .     .        . 2 : relatif                                .
c .        .     .        . 3 : pourcentage d'entites                  .
c .        .     .        . 4 : moyenne + nh*ecart-type                .
c .        .     .        . 5 : cible en nombre de noeuds              .
c . typseb . e   .   1    . type de seuil bas                          .
c .        .     .        . 1 : absolu                                 .
c .        .     .        . 2 : relatif                                .
c .        .     .        . 3 : pourcentage d'entites                  .
c .        .     .        . 4 : moyenne - nb*ecart-type                .
c . seuilh . es  .   1    . borne superieure de l'erreur (absolue,     .
c .        .     .        . relatif, pourcentage d'entites ou nh)      .
c . seuilb . e   .   1    . borne inferieure de l'erreur (absolue,     .
c .        .     .        . relatif, pourcentage d'entites ou nb)      .
c . nbsoci . e   .   1    . cible en nombre de sommets  (-1 si non)    .
c . usacmp . e   .   1    . usage des composantes de l'indicateur      .
c .        .     .        . 0 : norme L2                               .
c .        .     .        . 1 : norme infinie -max des valeurs absolues.
c .        .     .        . 2 : valeur relative si une seule composante.
c . nbvpen . e   .   1    . nombre de valeurs par pentaedres           .
c . nbvpyr . e   .   1    . nombre de valeurs par pyramides            .
c . nbvhex . e   .   1    . nombre de valeurs par hexaedres            .
c . nbvtet . e   .   1    . nombre de valeurs par tetraedres           .
c . nbvqua . e   .   1    . nombre de valeurs par quadrangles          .
c . nbvtri . e   .   1    . nombre de valeurs par triangles            .
c . nbvare . e   .   1    . nombre de valeurs par aretes               .
c . nbvnoe . e   .   1    . nombre de valeurs par noeuds               .
c . nosupp . e   . nbnoto . support pour les noeuds                    .
c . noindr . e   . nbnoto . valeurs reelles pour les noeuds            .
c . noindi .  s  . nbnoto . valeurs entieres pour les noeuds           .
c . arsupp . e   . nbarto . support pour les aretes                    .
c . arindr . es  . nbarto . valeurs reelles pour les aretes            .
c . arindi .  s  . nbarto . valeurs entieres pour les aretes           .
c . trsupp . e   . nbtrto . support pour les triangles                 .
c . trindr . es  . nbtrto . valeurs reelles pour les triangles         .
c . trindi .  s  . nbtrto . valeurs entieres pour les triangles        .
c . qusupp . e   . nbquto . support pour les quadrangles               .
c . quindr . es  . nbquto . valeurs reelles pour les quadrangles       .
c . quindi .  s  . nbquto . valeurs entieres pour les quadrangles      .
c . tesupp . e   . nbteto . support pour les tetraedres                .
c . teindr . es  . nbteto . valeurs reelles pour les tetraedres        .
c . teindi .  s  . nbteto . valeurs entieres pour les tetraedres       .
c . hesupp . e   . nbheto . support pour les hexaedres                 .
c . heindr . es  . nbheto . valeurs reelles pour les hexaedres         .
c . heindi .  s  . nbheto . valeurs entieres pour les hexaedres        .
c . pysupp . e   . nbpyto . support pour les pyramides                 .
c . pyindr . es  . nbpyto . valeurs reelles pour les pyramides         .
c . pyindi .  s  . nbpyto . valeurs entieres pour les pyramides        .
c . pesupp . e   . nbpeto . support pour les pentaedres                .
c . peindr . es  . nbpeto . valeurs reelles pour les pentaedres        .
c . peindi .  s  . nbpeto . valeurs entieres pour les pentaedres       .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme dans le traitement            .
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
      parameter ( nompro = 'DEINRI' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "gmreel.h"
c
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      integer pilraf, pilder
      integer typseh, typseb
      integer nbsoci
      integer usacmp
      integer nbvpen, nbvpyr, nbvhex, nbvtet
      integer nbvqua, nbvtri, nbvare, nbvnoe
c
      integer nosupp(nbnoto), noindi(nbnoto)
      integer arsupp(nbarto), arindi(nbarto)
      integer trsupp(nbtrto), trindi(nbtrto)
      integer qusupp(nbquto), quindi(nbquto)
      integer tesupp(nbteto), teindi(nbteto)
      integer hesupp(nbheto), heindi(nbheto)
      integer pysupp(nbpyto), pyindi(nbpyto)
      integer pesupp(nbpeto), peindi(nbpeto)
c
      integer ulsort, langue, codret
c
      double precision seuilb, seuilh
      double precision noindr(nbnoto)
      double precision arindr(nbarto)
      double precision trindr(nbtrto)
      double precision quindr(nbquto)
      double precision teindr(nbteto)
      double precision heindr(nbheto)
      double precision pyindr(nbpyto)
      double precision peindr(nbpeto)
c
c 0.4. ==> variables locales
c
      integer iaux
      integer indtab
      integer typenh, typen0
      integer ptrav1
      integer codre0
c
      double precision seuihe, seuibe
c
      character*8 ntrav1
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisation
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
c====
c 2. allocation de tableaux temporaires
c====
c
      iaux = 0
      if ( nbvnoe.ne.0 ) then
        iaux = iaux + nbnoto
      endif
      if ( nbvare.ne.0 ) then
        iaux = iaux + nbarto
      endif
      if ( nbvtri.ne.0 ) then
        iaux = iaux + nbtrto
      endif
      if ( nbvqua.ne.0 ) then
        iaux = iaux + nbquto
      endif
      if ( nbvtet.ne.0 ) then
        iaux = iaux + nbteto
      endif
      if ( nbvpyr.ne.0 ) then
        iaux = iaux + nbpyto
      endif
      if ( nbvhex.ne.0 ) then
        iaux = iaux + nbheto
      endif
      if ( nbvpen.ne.0 ) then
        iaux = iaux + nbpeto
      endif
c
      call gmalot ( ntrav1, 'reel    ', iaux, ptrav1, codre0 )
c
      codret = max ( abs(codre0), codret )
c
c====
c 3. traitement des indicateurs
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. traitement indicateurs ; codret', codret
#endif
c
      indtab = 0
      typen0 = -2
c
c 3.1. ==> noeuds
c
      if ( nbvnoe.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINTI_no', nompro
#endif
        typenh = -1
        call deinti ( typenh,
     >                usacmp, nbnoto, nosupp, noindr,
     >                indtab, rmem(ptrav1),
     >                ulsort, langue, codret)
        typen0 = typenh
c
        endif
c
      endif
c
c 3.2. ==> aretes
c
      if ( nbvare.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINTI_ar', nompro
#endif
        typenh = 1
        call deinti ( typenh,
     >                usacmp, nbarto, arsupp, arindr,
     >                indtab, rmem(ptrav1),
     >                ulsort, langue, codret)
        if ( typen0.eq.-2 ) then
          typen0 = typenh
        else
          typen0 = 10
        endif
c
        endif
c
      endif
c
c 3.3. ==> triangles
c
      if ( nbvtri.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINTI_tr', nompro
#endif
        typenh = 2
        call deinti ( typenh,
     >                usacmp, nbtrto, trsupp, trindr,
     >                indtab, rmem(ptrav1),
     >                ulsort, langue, codret)
        if ( typen0.eq.-2 ) then
          typen0 = typenh
        else
          typen0 = 10
        endif
c
        endif
c
      endif
c
c 3.4. ==> quadrangles
c
      if ( nbvqua.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINTI_qu', nompro
#endif
        typenh = 4
        call deinti ( typenh,
     >                usacmp, nbquto, qusupp, quindr,
     >                indtab, rmem(ptrav1),
     >                ulsort, langue, codret)
        if ( typen0.eq.-2 ) then
          typen0 = typenh
        elseif ( typen0.eq.2 ) then
          typen0 = 8
        else
          typen0 = 10
        endif
c
        endif
c
      endif
c
c 3.5. ==> tetraedres
c
      if ( nbvtet.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINTI_te', nompro
#endif
        typenh = 3
        call deinti ( typenh,
     >                usacmp, nbteto, tesupp, teindr,
     >                indtab, rmem(ptrav1),
     >                ulsort, langue, codret)
        if ( typen0.eq.-2 ) then
          typen0 = typenh
        else
          typen0 = 10
        endif
c
        endif
c
      endif
c
c 3.6. ==> pyramides
c
      if ( nbvpyr.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINTI_py', nompro
#endif
        typenh = 5
        call deinti ( typenh,
     >                usacmp, nbpyto, pysupp, pyindr,
     >                indtab, rmem(ptrav1),
     >                ulsort, langue, codret)
        if ( typen0.eq.-2 ) then
          typen0 = typenh
        elseif ( typen0.eq.3 ) then
          typen0 = 9
        else
          typen0 = 10
        endif
c
        endif
c
      endif
c
c 3.7. ==> hexaedres
c
      if ( nbvhex.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINTI_he', nompro
#endif
        typenh = 6
        call deinti ( typenh,
     >                usacmp, nbheto, hesupp, heindr,
     >                indtab, rmem(ptrav1),
     >                ulsort, langue, codret)
        if ( typen0.eq.-2 ) then
          typen0 = typenh
        elseif ( typen0.eq.3 .or. typen0.eq.5 .or. typen0.eq.9 ) then
          typen0 = 9
        else
          typen0 = 10
        endif
c
        endif
c
      endif
c
c 3.8. ==> pentaedres
c
      if ( nbvpen.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINTI_pe', nompro
#endif
        typenh = 7
        call deinti ( typenh,
     >                usacmp, nbpeto, pesupp, peindr,
     >                indtab, rmem(ptrav1),
     >                ulsort, langue, codret)
        if ( typen0.eq.-2 ) then
          typen0 = typenh
        elseif ( typen0.eq.3 .or. typen0.eq.5 .or.
     >           typen0.eq.6 .or. typen0.eq.9 ) then
          typen0 = 9
        else
          typen0 = 10
        endif
c
        endif
c
      endif
c
c====
c 4. determination du seuil
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. determination du seuil ; codret', codret
#endif
cgn      call gmprsx (nompro, ntrav1 )
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINSE', nompro
#endif
c
      call deinse ( typen0,
     >              seuihe, seuibe,
     >              pilraf, pilder,
     >              typseh, typseb, seuilh, seuilb, nbsoci,
     >              indtab, rmem(ptrav1),
     >              ulsort, langue, codret)
c
      endif
c
c====
c 5. transfert de reel a entier
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. transfert reel/entier ; codret', codret
#endif
c 5.1. ==> noeuds
c
      if ( nbvnoe.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINST_no', nompro
#endif
        typenh = -1
        call deinst ( typenh,
     >                seuihe, seuibe,
     >                nbnoto, nosupp, noindr, noindi,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
c 5.2. ==> aretes
c
      if ( nbvare.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINST_ar', nompro
#endif
        typenh = 1
        call deinst ( typenh,
     >                seuihe, seuibe,
     >                nbarto, arsupp, arindr, arindi,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
c 5.3. ==> triangles
c
      if ( nbvtri.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINST_tr', nompro
#endif
        typenh = 2
        call deinst ( typenh,
     >                seuihe, seuibe,
     >                nbtrto, trsupp, trindr, trindi,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
c 5.4. ==> quadrangles
c
      if ( nbvqua.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINST_qu', nompro
#endif
        typenh = 4
        call deinst ( typenh,
     >                seuihe, seuibe,
     >                nbquto, qusupp, quindr, quindi,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
c 5.5. ==> tetraedres
c
      if ( nbvtet.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINST_te', nompro
#endif
        typenh = 3
        call deinst ( typenh,
     >                seuihe, seuibe,
     >                nbteto, tesupp, teindr, teindi,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
c 5.6. ==> pyramides
c
      if ( nbvpyr.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINST_py', nompro
#endif
        typenh = 5
        call deinst ( typenh,
     >                seuihe, seuibe,
     >                nbpyto, pysupp, pyindr, pyindi,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
c 5.7. ==> hexaedres
c
      if ( nbvhex.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINST_he', nompro
#endif
        typenh = 6
        call deinst ( typenh,
     >                seuihe, seuibe,
     >                nbheto, hesupp, heindr, heindi,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
c 5.8. ==> pentaedres
c
      if ( nbvpen.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINST_pe', nompro
#endif
        typenh = 7
        call deinst ( typenh,
     >                seuihe, seuibe,
     >                nbpeto, pesupp, peindr, peindi,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
c====
c 6. liberation des tableaux temporaires
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. liberation ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav1 , codre0 )
c
      codret = max ( abs(codre0), codret )
c
      endif
c
      seuilh = seuihe
c====
c 7. la fin
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
