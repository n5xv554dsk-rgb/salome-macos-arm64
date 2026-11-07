      subroutine decfs1 ( hettri, filtri,
     >                    hetqua, filqua,
     >                    hettet, filtet,
     >                    hethex, filhex, fhpyte,
     >                    hetpen, filpen, fppyte,
     >                    nbvtri, nbvqua,
     >                    nbvtet, nbvpyr,
     >                    trindr, trsupp,
     >                    quindr, qusupp,
     >                    teindr, tesupp,
     >                    heindr, hesupp,
     >                    pyindr, pysupp,
     >                    peindr, pesupp,
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
c traitement des DEcisions - mise en ConFormite - Suppression
c                --                  -  -         -
c                            des fils
c   - usacmp = 0 : norme L2
c   - usacmp = 1 : norme infinie
c ______________________________________________________________________
c On parcourt toutes les entites qui sont decoupees par conformite :
c . si un indicateur d'erreur a ete defini sur au moins un des fils,
c   on recupere la plus grande valeur
c Remarque : decfs0 et decfs1 sont des clones
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . filtri . e   . nbtrto . fils des triangles                         .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . filqua . e   . nbquto . premier fils des quadrangles               .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . filtet . e   . nbteto . premier fils des tetraedres                .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . filhex . e   . nbheto . fils des hexaedres                         .
c . fhpyte . e   .2*nbhedc. fhpyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille de l'hexaedre k tel que filhex(k) =-j.
c .        .     .        . fhpyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils de l'hexaedre k tel que filhex(k) = -j.
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . filpen . e   . nbpeto . premier fils des pentaedres                .
c . fppyte . e   .2*nbpeco. fppyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille du pentaedre k tel que filpen(k) = -j.
c .        .     .        . fppyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils du pentaedre k tel que filpen(k) = -j .
c . nbvpyr . e   .   1    . nombre de valeurs par pyramides            .
c . nbvtet . e   .   1    . nombre de valeurs par tetraedres           .
c . nbvqua . e   .   1    . nombre de valeurs par quadrangles          .
c . nbvtri . e   .   1    . nombre de valeurs par triangles            .
c . trsupp . e   . nbtrto . support pour les triangles                 .
c . trindr . es  . nbtrto . valeurs reelles pour les triangles         .
c . qusupp . e   . nbquto . support pour les quadrangles               .
c . quindr . es  . nbquto . valeurs reelles pour les quadrangles       .
c . tesupp . e   . nbteto . support pour les tetraedres                .
c . teindr . es  . nbteto . valeurs reelles pour les tetraedres        .
c . hesupp . e   . nbheto . support pour les hexaedres                 .
c . heindr . es  . nbheto . valeurs reelles pour les hexaedres         .
c . pysupp . e   . nbpyto . support pour les pyramides                 .
c . pyindr . es  . nbpyto . valeurs reelles pour les pyramides         .
c . pesupp . e   . nbpeto . support pour les pentaedres                .
c . peindr . es  . nbpeto . valeurs reelles pour les pentaedres        .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . sinon : nombre de tetraedres a problemes   .
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
      parameter ( nompro = 'DECFS1' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "infini.h"
#include "impr02.h"
c
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
#include "hexcf0.h"
c
c 0.3. ==> arguments
c
      integer hettri(nbtrto), filtri(nbtrto)
      integer hetqua(nbquto), filqua(nbquto)
      integer hettet(nbteto), filtet(nbteto)
      integer hethex(nbheto), filhex(nbheto)
      integer fhpyte(2,nbheco)
      integer hetpen(nbpeto), filpen(nbpeto)
      integer fppyte(2,nbpeco)
      integer nbvtri, nbvqua
      integer nbvtet, nbvpyr
      integer trsupp(nbtrto)
      integer qusupp(nbquto)
      integer tesupp(nbteto)
      integer hesupp(nbheto)
      integer pysupp(nbpyto)
      integer pesupp(nbpeto)
c
      integer ulsort, langue, codret
c
      double precision trindr(nbtrto)
      double precision quindr(nbquto)
      double precision teindr(nbteto)
      double precision heindr(nbheto)
      double precision pyindr(nbpyto)
      double precision peindr(nbpeto)
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, laux
      integer fils
      integer nbte, nbte0, nbte1, nbte2, nbte3, nbte4, nbte5
      integer nbpy, nbpy0, nbpy1, nbpy2, nbpy3, nbpy4, nbpy5
      integer etat, bindec
c
      double precision daux
c
      logical yaconf
      logical yaintr, yainte, yainpy, yainqu
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
      texte(1,4) = '(''Suppression des conformites pour les '',a)'
c
      texte(2,4) = '(''Suppression of the conformities for '',a)'
c
#include "impr03.h"
c
      codret = 0
c
c====
c 2. les triangles : transfert en presence d'indicateur d'erreurs
c                    sur les fils de conformite
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,2)
      write (ulsort,90002) 'nbvtri', nbvtri
#endif
c
      if ( nbvtri.gt.0 ) then
c
        yaintr = .true.
c
        do 20 , iaux = 1 , nbtrto
c
          etat = mod( hettri(iaux), 10 )
c
          if ( etat.ge.1 .and. etat.le.3 ) then
cgn      write (ulsort,90015) 'Etat du '//mess14(langue,1,2), iaux,
cgn     >                     ' : ',etat
c
            daux = vinfne
            do 201 , kaux = 0, 1
              jaux = filtri(iaux) + kaux
              if ( trsupp(jaux).ne.0 ) then
                daux = max(daux,abs(trindr(jaux)))
                trsupp(iaux) = 1
              endif
  201       continue
c
            if ( trsupp(iaux).ne.0 ) then
cgn      write (ulsort,*) 'modif de trsupp(',iaux,'), valeur = ',daux
              trindr(iaux) = daux
            endif
c
          endif
c
   20   continue
c
      else
c
        yaintr = .false.
c
      endif
c
c====
c 3. les quadrangles : transfert en presence d'indicateur d'erreurs
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. Quadrangles ; codret = ', codret
      write (ulsort,90002) 'nbvqua', nbvqua
#endif
c
      if ( nbquto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,4)
#endif
c
        if ( nbvqua.gt.0 ) then
          yainqu = .true.
        else
          yainqu = .false.
        endif
c
        if ( yainqu .or. yaintr ) then
c
        do 30 , iaux = 1 , nbquto
c
          etat = mod( hetqua(iaux), 100 )
cgn      write (ulsort,90015) 'Etat du '//mess14(langue,1,4), iaux,
cgn     >                     ' : ',etat
c
c 3.1. ==> les fils de conformite sont des quadrangles
c
          if ( ( etat.eq.21 .or. etat.eq.22 .or.
     >         ( etat.ge.41 .and. etat.le.44 ) ) .and. yainqu ) then
c
            daux = vinfne
            fils = filqua(iaux)
            if ( etat.eq.21 .or. etat.eq.22 ) then
              laux = 1
            else
              laux = 2
            endif
            do 301 , kaux = 0, laux
              jaux = fils + kaux
              if ( qusupp(jaux).ne.0 ) then
                daux = max(daux,abs(quindr(jaux)))
                qusupp(iaux) = 1
              endif
  301       continue
c
            if ( qusupp(iaux).ne.0 ) then
              quindr(iaux) = daux
            endif
c
c 3.2. ==> les fils de conformite qui sont des triangles
c
          elseif ( etat.ge.31 .and. etat.le.34 .and. yaintr ) then
c
            daux = vinfne
            fils = -filqua(iaux)
            do 302 , kaux = 0, 2
              jaux = fils + kaux
              if ( trsupp(jaux).ne.0 ) then
                daux = max(daux,abs(trindr(jaux)))
                qusupp(iaux) = 1
              endif
  302       continue
c
            if ( qusupp(iaux).ne.0 ) then
              quindr(iaux) = daux
            endif
c
          endif
c
   30   continue
c
        endif
c
      endif
c
c====
c 4. les tetraedres : transfert en presence d'indicateur d'erreurs
c                     sur les fils de conformite
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. Tetraedres ; codret = ', codret
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,3)
      write (ulsort,90002) 'nbvtet', nbvtet
#endif
c
      if ( nbvtet.gt.0 ) then
c
        yainte = .true.
c
        nbte1 = 1
        nbte2 = 3
c
        do 40 , iaux = 1 , nbteto
c
          etat = mod( hettet(iaux), 100 )
          yaconf = .false.
cgn      write (ulsort,90015) 'Etat du '//mess14(langue,1,3), iaux,
cgn     >                     ' : ',etat
c
c         nombre d'entites de conformite selon les modes de decoupage
c
          if ( ( etat.ge.21 .and. etat.le.36 ) ) then
c
            nbte = nbte1
            yaconf = .true.
c
          elseif ( etat.ge.41 .and. etat.le.47 ) then
c
            nbte = nbte2
            yaconf = .true.
c
          endif
c
          if ( yaconf ) then
c
            daux = vinfne
            do 401 , kaux = 0, nbte
              jaux = filtet(iaux) + kaux
              if ( tesupp(jaux).ne.0 ) then
                daux = max(daux,abs(teindr(jaux)))
cgn      write (ulsort,*) '... valeur = ',daux
                tesupp(iaux) = 1
              endif
  401       continue
c
            if ( tesupp(iaux).ne.0 ) then
cgn      write (ulsort,*) 'modif de tesupp(',iaux,'), valeur = ',daux
              teindr(iaux) = daux
            endif
c
          endif
c
   40   continue
c
      else
c
        yainte = .false.
c
      endif
c
c====
c 5. les pyramides : pas de transfert car pas de decoupage mais
c                    reperage de la presence d'indicateurs
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5. pyramides ; codret = ', codret
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,5)
      write (ulsort,90002) 'nbvpyr', nbvpyr
#endif
c
      if ( nbvpyr.gt.0 ) then
c
        yainpy = .true.
c
      else
c
        yainpy = .false.
c
      endif
c
c====
c 6. les hexaedres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '6. Hexaedres ; codret = ', codret
#endif
c
      if ( nbheto.ne.0 .and. ( yainte .or. yainpy ) ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,6)
      write (ulsort,90002) 'nbvtet', nbvtet
      write (ulsort,90002) 'nbvpyr', nbvpyr
#endif
c
        do 60 , iaux = 1 , nbheto
c
          etat = mod(hethex(iaux),1000)
#ifdef _DEBUG_HOMARD_
      write (ulsort,90015) 'Etat du '//mess14(langue,1,6), iaux,
     >                     ' : ',etat
#endif
c
c        nombre d'entites de conformite selon les modes de decoupage
c
          if ( etat.ge.11 ) then
c
            bindec = chbiet(etat)
#ifdef _DEBUG_HOMARD_
      write (ulsort,90015) 'etat', etat, ' ==> code binaire', bindec
#endif
c
            if ( nbvpyr.gt.0 ) then
              nbpy = chnpy(bindec)
            else
              nbpy = -1
            endif
            if ( nbvtet.gt.0 ) then
              nbte = chnte(bindec)
            else
              nbte = -1
            endif
            yaconf = .true.
c
          else
c
            yaconf = .false.
c
          endif
c
          if ( yaconf ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '... nbpy/nbte', nbpy, nbte
#endif
c
            daux = vinfne
c
            fils = fhpyte(1,-filhex(iaux))
cgn      write (ulsort,*) '.. fils pyramide = ', fils
            do 601 , kaux = 1, nbpy
cgn      write (ulsort,*) '.... pyramide ', fils, pysupp(fils)
              if ( pysupp(fils).ne.0 ) then
cgn      write (ulsort,*) '.... ', fils, pyindr(fils)
                daux = max(daux,abs(pyindr(fils)))
                hesupp(iaux) = 1
              endif
              fils = fils + 1
  601       continue
c
            fils = fhpyte(2,-filhex(iaux))
cgn      write (ulsort,*) '.. fils tetraedre = ', fils
            do 602 , kaux = 1, nbte
cgn      write (ulsort,*) '.... tetraedre ', fils, tesupp(fils)
              if ( tesupp(fils).ne.0 ) then
                daux = max(daux,abs(teindr(fils)))
                hesupp(iaux) = 1
              endif
              fils = fils + 1
  602       continue
c
            if ( hesupp(iaux).ne.0 ) then
cgn      write (ulsort,*) 'modif de hesupp(',iaux,'), valeur = ',daux
              heindr(iaux) = daux
            endif
c
          endif
c
   60   continue
c
      endif
c
c====
c 7. les pentaedres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '7. Pentaedres ; codret = ', codret
#endif
c
      if ( nbpeto.ne.0 .and. ( yainte .or. yainpy ) ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,7)
      write (ulsort,90002) 'nbvtet', nbvtet
      write (ulsort,90002) 'nbvpyr', nbvpyr
#endif
c
        if ( nbvtet.gt.0 ) then
          nbte0 = 0
          nbte1 = 1
          nbte2 = 5
          nbte3 = 9
          nbte4 = 1
          nbte5 = 10
        else
          nbte0 = -1
          nbte1 = -1
          nbte2 = -1
          nbte3 = -1
          nbte4 = -1
          nbte5 = -1
        endif
c
        if ( nbvpyr.gt.0 ) then
          nbpy0 = 1
          nbpy1 = 0
          nbpy2 = -1
          nbpy3 = 0
          nbpy4 = 3
          nbpy5 = -1
        else
          nbpy0 = -1
          nbpy1 = -1
          nbpy2 = -1
          nbpy3 = -1
          nbpy4 = -1
          nbpy5 = -1
        endif
c
        do 70 , iaux = 1 , nbpeto
c
          etat = mod( hetpen(iaux), 100 )
#ifdef _DEBUG_HOMARD_
      write (ulsort,90015) 'Etat du '//mess14(langue,1,7), iaux,
     >                     ' : ',etat
#endif
c
          yaconf = .false.
          if ( ( etat.ge. 1 .and. etat.le.6 ) ) then
c
            nbpy = nbpy0
            nbte = nbte0
            yaconf = .true.
c
          elseif ( ( etat.ge.17 .and. etat.le.19 ) ) then
c
            nbpy = nbpy1
            nbte = nbte1
            yaconf = .true.
c
          elseif ( etat.ge.21 .and. etat.le.26 ) then
c
            nbpy = nbpy2
            nbte = nbte2
            yaconf = .true.
c
          elseif ( etat.ge.31 .and. etat.le.36 ) then
c
            nbpy = nbpy3
            nbte = nbte3
            yaconf = .true.
c
          elseif ( etat.ge.43 .and. etat.le.45 ) then
c
            nbpy = nbpy4
            nbte = nbte4
            yaconf = .true.
c
          elseif ( etat.ge.51 .and. etat.le.52 ) then
c
            nbpy = nbpy5
            nbte = nbte5
            yaconf = .true.
c
          endif
c
          if ( yaconf ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '... nbpy/nbte', nbpy, nbte
#endif
c
            daux = vinfne
c
            fils = fppyte(1,-filpen(iaux))
cgn      write (ulsort,*) '.. fils pyramide = ', fils
            do 701 , kaux = 0, nbpy
              jaux = fils + kaux
cgn      write (ulsort,*) '.... pyramide ', jaux, pysupp(jaux)
              if ( pysupp(jaux).ne.0 ) then
cgn      write (ulsort,*) '.... ', jaux, pyindr(jaux)
                daux = max(daux,abs(pyindr(jaux)))
                pesupp(iaux) = 1
              endif
  701       continue
c
            fils = fppyte(2,-filpen(iaux))
cgn      write (ulsort,*) '.. fils tetraedre = ', fils
            do 702 , kaux = 0, nbte
              jaux = fils + kaux
              if ( tesupp(jaux).ne.0 ) then
cgn       write (ulsort,*) '.... ', jaux, teindr(jaux)
                daux = max(daux,abs(teindr(jaux)))
                pesupp(iaux) = 1
              endif
  702       continue
c
            if ( pesupp(iaux).ne.0 ) then
cgn      write (ulsort,*) 'modif de pesupp(',iaux,'), valeur = ',daux
              peindr(iaux) = daux
            endif
c
          endif
c
   70   continue
c
      endif
c
c====
c 8. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      write (ulsort,texte(langue,6)) codret
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
