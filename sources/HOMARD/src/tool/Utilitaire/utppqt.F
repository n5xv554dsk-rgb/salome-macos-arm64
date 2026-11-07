      subroutine utppqt ( decisi, nbfato, nbvoto, nbvofa,
     >                    typvol, typfac,
     >                    facvol, hetvol,
     >                    volfac, lgpype, pypefa, nupype,
     >                    ulsort, langue, codret )
c
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
c    UTilitaire - Pyramides/Pentaedres - Quadrangles/Triangles
c    --           -         -            -           -
c ______________________________________________________________________
c
c but : complete le tableau volfac et cree le tableau pypefa
c       a partir du reciproque, facvol
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . decisi . e   .   1    . pilotage des voisins des faces :           .
c .        .     .        . 1 : on construit la table.                 .
c .        .     .        . 2 : on construit la table et on controle   .
c .        .     .        .     qu'une face n'appartient pas a plus de .
c .        .     .        .     2 volumes                              .
c . nbfato . e   .   1    . nombre de faces total                      .
c . nbvoto . e   .   1    . nombre de volumes total                    .
c . nbvofa . e   .   1    . nombre de volumes decrits par leurs faces  .
c . typvol . e   .    1   . type du volume en cours d'examen           .
c .        .     .        .   5 : pyramides                            .
c .        .     .        .   7 : pentaedres                           .
c . typfac . e   .    1   . type de la face en cours d'examen          .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   4 : quadrangles                          .
c . facvol . e   .nbvoto*5. numeros des faces des volumes              .
c . hetvol . e   . nbvoto . historique de l'etat des volumes           .
c . volfac . es  .2*nbfato. numeros des 2 volumes par face             .
c .        .     .        . volfac(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre/tetraedre j                 .
c .        .     .        . j<0 : pyramide/pentaedre dans pypefa(1/2,j).
c . lgpype . e   .   1    . taille du tableau pypefa                   .
c . pypefa .  s  .2*lgpype. pypefa(1,j) = numero de la pyramide voisine.
c .        .     .        . de la face k tel que volfac(1/2,k) = -j    .
c .        .     .        . pypefa(2,j) = numero du pentaedre voisin   .
c .        .     .        . de la face k tel que volfac(1/2,k) = -j    .
c . nupype . es  .   1    . dernier indice cree dans le tableau pypefa .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : mauvais type de face                   .
c .        .     .        . 2 : mauvais type de volume                 .
c .        .     .        . 3 : probleme de volumes decoupees          .
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
      parameter ( nompro = 'UTPPQT' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer decisi
      integer nbfato, nbvoto, nbvofa
      integer typvol, typfac
      integer hetvol(nbvoto), facvol(nbvofa,5)
      integer volfac(2,nbfato)
      integer lgpype, pypefa(2,lgpype), nupype
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer kfadeb, kfafin, nbface
      integer etat
      integer levolu, vois01, inpype, inpepy
      integer listfa(4)
      integer nbfa00, lifa00(2)
#ifdef _DEBUG_HOMARD_
      integer typvo1, typvo2
      integer glop
      character*6 saux06(2)
#endif
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
      texte(1,4) = '(''Voisinage '',a,''/ '',a)'
      texte(1,5) = '(''Le type de '',a,'',i10,'' est inconnu.'')'
      texte(1,6) = '(/,''Le '',a,'',i10,'' a plus de deux voisins ?'')'
      texte(1,7) = '(''Voisins :'',3i10,/)'
c
      texte(2,4) = '(''Neighbourhoud '',a,''/ '',a)'
      texte(2,5) = '(''Type of '',a,'',i10,'' is unknown.'')'
      texte(2,6) = '(/,a,i10,'' has more than 2 neighbours ?'')'
      texte(2,7) = '(''Neighbours :'',3i10,/)'
c
#include "impr03.h"
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'typvol', typvol
      write (ulsort,90002) 'typfac', typfac
#endif
c
c====
c 2. Grandeurs caracteristiques
c====
c 2.1. ==> Pyramides
c
      if ( typvol.eq.5 ) then
c
        if ( typfac.eq.2 ) then
          kfadeb = 1
          kfafin = 4
        elseif ( typfac.eq.4 ) then
          kfadeb = 5
          kfafin = 5
        else
          codret = 1
        endif
        inpype = 1
        inpepy = 2
c
c 2.2. ==> Pentaedres
c
      elseif ( typvol.eq.7 ) then
c
        if ( typfac.eq.2 ) then
          kfadeb = 1
          kfafin = 2
        elseif ( typfac.eq.4 ) then
          kfadeb = 3
          kfafin = 5
        else
          codret = 1
        endif
        inpype = 2
        inpepy = 1
c
c 2.3. ==> Probleme
c
      else
c
        codret = 2
c
      endif
c
c====
c 3. on parcourt les volumes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. parcours des volumes ; codret', codret
cgn      write (ulsort,90002) 'kfadeb, kfafin = ', kfadeb, kfafin
#endif
c
      if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,1,typvol),
     >                               mess14(langue,1,typfac)
      if ( typfac.eq.2 ) then
        typvo1 = 3
        saux06(1) = 'voltri'
        saux06(2) = 'pypetr'
      else
        typvo1 = 6
        saux06(1) = 'volqua'
        saux06(2) = 'pypequ'
      endif
      if ( typvol.eq.5 ) then
        typvo2 = 7
      else
        typvo2 = 5
      endif
#endif
c
      nbface = kfafin - kfadeb + 1
c
      do 30 , levolu = 1 , nbvofa
#ifdef _DEBUG_HOMARD_
        if ( levolu.ge.-1583 ) then
ccc        if ( ( typvol.eq.5 .and. typfac.eq.4 .and. levolu.lt.0 ) .or.
ccc     >       ( typvol.eq.7 .and. typfac.eq.2 .and. levolu.lt.0 ) ) then
          glop = 1
        else
          glop = 0
        endif
#endif
c
c 3.1. ==> les faces du volume en cours d'examen
c
        do 31 , iaux = kfadeb, kfafin
          listfa(iaux-kfadeb+1) = facvol(levolu,iaux)
   31   continue
c
c 3.2. ==> quand le volume est decoupe par conformite, on se preoccupe
c          des cas ou une face du volume se retrouve en tant que face
c          d'un volume fils.
c          La convention HOMARD veut que l'on ne memorise que le fils
c          dans les voisins des faces.
c          on va alors annuler le numero de la face pour ne rien
c          archiver maintenant.
c          C'est le cas dans les situations suivantes :
c          . Pentaedre
c             Etat | Face triangle | Face quadrangle
c              1   |   2           |   4 5
c              2   |   2           |   5 3
c              3   |   2           |   3 4
c              4   |   1           |   5 4
c              5   |   1           |   3 5
c              6   |   1           |   4 3
c              7   |   1 2         |   5
c              8   |   1 2         |   3
c              9   |   1 2         |   4
c             31   |   2           |
c             32   |   1           |
c
        etat = mod ( hetvol(levolu), 100 )
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,*) ' '
        write(ulsort,90015) mess14(langue,2,typvol), levolu,
     >   ', de '//mess14(langue,3,typfac), (listfa(iaux),iaux=1,nbface)
        write(ulsort,90002) 'Etat', etat
        endif
#endif
        if ( etat.ne.0 .and. etat.ne.80 .and. etat.ne.99 ) then
#ifdef _DEBUG_HOMARD_
          write(ulsort,*) 'Creation de ', saux06(1),'/', saux06(2)
#endif
c
          nbfa00 = 0
c
c 3.2.1. ==> Pentaedre et triangle
c
          if ( typvol.eq.7 .and. typfac.eq.2 ) then
c
            if ( ( etat.ge.1 .and. etat.le.3 ) .or. etat.eq.31 ) then
              nbfa00 = 1
              lifa00(1) = 2
            elseif ( ( etat.ge.4 .and. etat.le.6 ) .or.
     >               etat.eq.32 ) then
              nbfa00 = 1
              lifa00(1) = 1
            elseif ( etat.ge.7 .and. etat.le.8 ) then
              nbfa00 = 2
              lifa00(1) = 1
              lifa00(2) = 2
            endif
c
c 3.2.2. ==> Pentaedre et quadrangle
c
          elseif ( typvol.eq.7 .and. typfac.eq.4 ) then
c
            if ( etat.eq.2 .or. etat.eq.3 .or. etat.eq.5 .or.
     >           etat.eq.6 .or. etat.eq.8 ) then
              nbfa00 = nbfa00 + 1
              lifa00(nbfa00) = 3
            endif
            if ( etat.eq.1 .or. etat.eq.3 .or. etat.eq.4 .or.
     >               etat.eq.6 .or. etat.eq.9 ) then
              nbfa00 = nbfa00 + 1
              lifa00(nbfa00) = 4
            endif
            if ( etat.eq.1 .or. etat.eq.2 .or. etat.eq.4 .or.
     >               etat.eq.5 .or. etat.eq.7 ) then
              nbfa00 = nbfa00 + 1
              lifa00(nbfa00) = 5
            endif
c
          endif
c
c 3.2.3. ==> Menage
c
          do 323 , iaux = 1 , nbfa00
cgn            write (ulsort,90002) 'face', facvol(levolu,lifa00(iaux))
            do 3231 , jaux = 1 , nbface
cgn            write (ulsort,90002) '... face', listfa(jaux)
              if ( facvol(levolu,lifa00(iaux)).eq.listfa(jaux) ) then
                listfa(jaux) = 0
              endif
 3231       continue
  323     continue
c
        endif
c
c 3.3. ==> pour chaque face a traiter
c
        do 33 , iaux = 1 , nbface
c
          if ( listfa(iaux).ne.0 ) then
c
             jaux = 0
             vois01 = volfac(1,listfa(iaux))
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,*) '.. ', mess14(langue,2,typfac), listfa(iaux)
        write (ulsort,90002) '   de voisins', vois01,
     >                        volfac(2,listfa(iaux))
        endif
#endif
c
c 3.3.1. ==> aucun voisin n'a ete enregistre : on met le volume
c            courant comme premier voisin
c
            if ( vois01.eq.0 ) then
c
              jaux = 1
c
            else
c
c 3.3.2. ==> un premier voisin a ete enregistre : on met le volume
c            courant comme second voisin
c            Pour un pentaedre, trois cas de figure :
c            . Si le premier voisin est un tetraedre ou un hexaedre :
c              vois01>0, il faut creer un nouvel indice dans le
c              tableau pypefa
c            . Sinon, le premier voisin est une pyramide ou un pentaedre
c              . Si le premier voisin est une pyramide, c'est-a-dire
c                vois01<0 et pypefa(1,-vois01)/=0, il faut stocker
c                le volume dans pypefa(2,-vois01)
c              . Si le premier voisin est deja un pentaedre,
c                c'est-a-dire vois01<0 et pypefa(2,-vois01)/=0, il faut
c                creer un nouvel indice dans le tableau pypefa
c            Pour une pyramide, le raisonnement est symetrique.
c
c            C'est ainsi qu'il faut stocker pour etre coherent avec
c            le decodage des voisins (cf. infovo par exemple)
c
              if ( vois01.gt.0 ) then
                jaux = 2
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
      write (ulsort,*) '.... le ',mess14(langue,1,typfac), listfa(iaux),
     >'est deja voisin de ',mess14(langue,1,typvo1),
     > volfac(1,listfa(iaux))
        endif
#endif
              else
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
       write (ulsort,90002) '.. '//saux06(2)//'(*,-vois01)',
     >          pypefa(1,-vois01), pypefa(2,-vois01)
        endif
#endif
                if ( pypefa(inpepy,-vois01).eq.0 ) then
                  jaux = 2
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
      write (ulsort,*) '.... le ',mess14(langue,1,typfac), listfa(iaux),
     > 'est voisin de ',mess14(langue,1,typvol), pypefa(inpype,-vois01)
        endif
#endif
                else
                  jaux = -1
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
      write (ulsort,*) '.... le ',mess14(langue,1,typfac), listfa(iaux),
     > 'est voisin de ',mess14(langue,1,typvo2), pypefa(inpepy,-vois01)
        endif
#endif
                endif
              endif
c
c 3.3.2.1. ==> il y a deja un second volume comme voisin de cette face !
c
              if ( decisi.eq.2 ) then
c
                if ( volfac(2,listfa(iaux)).ne.0 ) then
c
                  write(ulsort,texte(langue,6)) mess14(langue,1,typfac),
     >                                          listfa(iaux)
                  write(ulsort,texte(langue,7)) vois01,
     >                                          volfac(2,listfa(iaux)),
     >                                          levolu
                  codret = 3
c
                endif
c
              endif
c
            endif
c
c 3.3.3. ==> mise en place du voisin
c            . Si jaux est > 0, on cree un nouvel indice dans pypefa et
c            ce sera pour le jaux-eme voisin
c            . Si jaux < 0, on complete un voisinage, donc c'est
c            forcement un second voisin.
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,90002) '.... ==> jaux', jaux
        endif
#endif
c 3.3.3.1. ==> creation d'un nouvel indice du voisin
c
            if ( jaux.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,90015) '.... ==> enregistrement d''un',jaux,
     >                   '-ieme voisin, avec nupype = ', nupype + 1
        endif
#endif
              nupype = nupype + 1
              volfac(jaux,listfa(iaux)) = -nupype
              pypefa(inpype,nupype) = levolu
c
c 3.3.3.2. ==> complement d'un existant
c
            elseif ( jaux.lt.0 ) then
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,90002)
     > '.... ==> enregistrement d''un 2-ieme voisin, avec nupype',
     > vois01
        endif
#endif
c
              volfac(2,listfa(iaux)) = vois01
              pypefa(inpype,-vois01) = levolu
c
            endif
c
          endif
c
   33   continue
c
   30 continue
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
      if ( codret.le.2 ) then
        write (ulsort,texte(langue,5)) mess14(langue,1,7+codret), iaux
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
