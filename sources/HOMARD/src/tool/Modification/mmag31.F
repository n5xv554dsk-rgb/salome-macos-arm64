      subroutine mmag31 ( indtri, indpen,
     >                    nbduno, nbduar, nbpejs,
     >                    tbaux1, tbau30, tbau40,
     >                    coonoe, hetnoe, arenoe,
     >                    somare, hetare,
     >                    filare, merare,
     >                    aretri, hettri,
     >                    filtri, pertri, nivtri,
     >                    arequa, hetqua,
     >                    filqua, perqua, nivqua,
     >                    tritet, cotrte,
     >                    facpen, cofape,
     >                    hetpen, filpen, perpen,
     >                    famnoe, famare, famtri,
     >                    famqua, fampen,
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
c    Modification de Maillage - AGRegat - phase 3.1
c    -               -          --              - -
c    Creation des mailles pour les joints simples :
c    . pentaedres
c    Et donc des noeuds, aretes, triangles, quadrangles
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . indtri . es  .   1    . indice du dernier triangle cree            .
c . indpen . es  .   1    . indice du dernier pentaedre cree           .
c . nbduno . e   .   1    . nombre de duplication de noeuds            .
c . nbduar . e   .   1    . nombre de duplications d'aretes            .
c . nbpejs . e   .   1    . nombre de pentaedres de joints simples     .
c . tbaux1 . e   .4*nbpejs. Pour le i-eme pentaedre de joint simple :  .
c .        .     .        . (1,i) : numero du triangle a dupliquer     .
c .        .     .        . (2,i) : numero du joint simple cree        .
c .        .     .        . (3,i) : tetraedre du cote min(fammed)      .
c .        .     .        . (4,i) : tetraedre du cote max(fammed)      .
c . tbau30 . e   .8*nbduno. Pour la i-eme duplication de noeud :       .
c .        .     .        . (1,i) : noeud a dupliquer                  .
c .        .     .        . (2,i) : arete construite sur le noeud      .
c .        .     .        . (3,i) : noeud cree cote min(fammed)        .
c .        .     .        . (4,i) : noeud cree cote max(fammed)        .
c .        .     .        . (5,i) : numero du joint simple cree        .
c .        .     .        . (6,i) : arete entrant dans le cote 1       .
c .        .     .        . (7,i) : arete entrant dans le cote 2       .
c .        .     .        . (8,i) : ordre de multiplicite              .
c . tbau40 . e   .6*nbduar. Pour la i-eme duplication d'arete :        .
c .        .     .        . (1,i) : arete a dupliquer                  .
c .        .     .        . (2,i) : arete creee cote min(fammed)       .
c .        .     .        . (3,i) : arete creee cote max(fammed)       .
c .        .     .        . (4,i) : numero du joint simple cree        .
c .        .     .        . (5,i) : ordre de multiplicite              .
c .        .     .        . (6,i) : arete d'orientation de joint       .
c . coonoe . es  .nbnoto*3. coordonnees des noeuds                     .
c . hetnoe . es  . nbnoto . historique de l'etat des noeuds            .
c . arenoe . es  . nbnoto . arete liee a un nouveau noeud              .
c . somare . es  .2*nbarto. numeros des extremites d'arete             .
c . hetare . es  . nbarto . historique de l'etat des aretes            .
c . filare . es  . nbarto . premiere fille des aretes                  .
c . merare . es  . nbarto . mere des aretes                            .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . hettri . es  . nbtrto . historique de l'etat des triangles         .
c . filtri . es  . nbtrto . premier fils des triangles                 .
c . pertri . es  . nbtrto . pere des triangles                         .
c . nivtri . es  . nbtrto . niveau des triangles                       .
c . arequa . es  .nbquto*4. numeros des 4 aretes des quadrangles       .
c . hetqua . es  . nbquto . historique de l'etat des quadrangles       .
c . filqua . es  . nbquto . premier fils des quadrangles               .
c . perqua . es  . nbquto . pere des quadrangles                       .
c . nivqua . es  . nbquto . niveau des quadrangles                     .
c . tritet . e   .nbtecf*4. numeros des triangles des tetraedres       .
c . cotrte . e   .nbtecf*4. codes des triangles des tetraedres         .
c . facpen . es  .nbpecf*5. numeros des 5 faces des pentaedres         .
c . cofape . es  .nbpecf*5. code des 5 faces des pentaedres            .
c . hetpen . es  . nbpeto . historique de l'etat des pentaedres        .
c . filpen . es  . nbpeto . premier fils des pentaedres                .
c . perpen . es  . nbpeto . pere des pentaedres                        .
c . famnoe . es  . nbnoto . famille des noeuds                         .
c . famare . es  . nbarto . famille des aretes                         .
c . famtri . es  . nbtrto . famille des triangles                      .
c . famqua . es  . nbquto . famille des quadrangles                    .
c . fampen . es  . nbpeto . famille des pentaedres                     .
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
      parameter ( nompro = 'MMAG31' )
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
#include "nombpe.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer indtri, indpen
      integer nbduno, nbduar, nbpejs
      integer tbaux1(4,nbpejs)
      integer tbau30(8,nbduno), tbau40(6,nbduar)
      integer hetnoe(nbnoto), arenoe(nbnoto)
      integer somare(2,nbarto), hetare(nbarto)
      integer filare(nbarto), merare(nbarto)
      integer aretri(nbtrto,3), hettri(nbtrto)
      integer filtri(nbtrto), pertri(nbtrto), nivtri(nbtrto)
      integer arequa(nbquto,4), hetqua(nbquto)
      integer filqua(nbquto), perqua(nbquto), nivqua(nbquto)
      integer tritet(nbtecf,4), cotrte(nbtecf,4)
      integer facpen(nbpecf,5), cofape(nbpecf,5)
      integer hetpen(nbpeto), filpen(nbpeto), perpen(nbpeto)
      integer famnoe(nbnoto), famare(nbarto)
      integer famtri(nbtrto), famqua(nbquto), fampen(nbpeto)
c
      double precision coonoe(nbnoto,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer sommet
      integer lenoeu, larete, letria, letet1
      integer nucode
      integer indnoe, indqua
c
      integer som(4), are(9), qua(3)
      integer sa1a2, sa2a3, sa3a1
      integer sompen(6)
      integer tabcod(6)
c
      integer nbmess
      parameter ( nbmess = 30 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
      data tabcod / 4, 5, 6, 1, 2, 3 /
c
c====
c 1. initialisations
c====
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "mmag01.h"
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) mess14(langue,3,-1), nbduno
      write (ulsort,texte(langue,7)) mess14(langue,3,1), nbduno
      write (ulsort,texte(langue,8)) mess14(langue,3,1), nbduar
      write (ulsort,texte(langue,7)) mess14(langue,3,4), nbduar
#endif
c
      codret = 0
c
cgn      write(ulsort,*) 'nbnoto, nbarto, nbtrto',nbnoto, nbarto,nbtrto
cgn      write(ulsort,91010) (iaux,iaux=1,20)
cgn      write(ulsort,90002) 'tbaux1',4,nbduno
cgn      write(ulsort,91010) tbaux1
cgn      write(ulsort,90002) 'tbau30',8,nbduno
cgn      do 1101 , kaux = 1,nbduno
cgn       write(ulsort,91010) (tbau30(jaux,kaux),jaux=1,8)
cgn 1101 continue
cgn      write(ulsort,90002) 'tbau40',6,nbduar
cgn      do 1102 , kaux = 1,nbduar
cgn       write(ulsort,91010) (tbau40(jaux,kaux),jaux=1,5)
cgn 1102  continue
c
c====
c 2. Parcours des noeuds a dupliquer
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,3,-1)
#endif
c
      do 2 , iaux = 1 , nbduno
c
        lenoeu = tbau30(1,iaux)
c
#ifdef _DEBUG_HOMARD_
          if ( tbau30(5,iaux).eq.-4444 ) then
cgn          if ( lenoeu.eq.2 .or. lenoeu.eq.8 ) then
      write (ulsort,texte(langue,4)) ' ', mess14(langue,1,-1), lenoeu
      write (ulsort,texte(langue,18)) ' pour ',mess14(langue,1,7),
     >                                tbau30(5,iaux)
              endif
#endif
c
c 2.1. ==> Duplications du noeud
c          Remarque : dans le cas de points multiples, on recree
c                     plusieurs fois le meme noeud. Pas grave.
c
        do 21 , jaux = 1 , 2
c
          indnoe = tbau30(2+jaux,iaux)
c
#ifdef _DEBUG_HOMARD_
          if ( tbau30(5,iaux).eq.-4444 ) then
cgn          if ( lenoeu.eq.2 .or. lenoeu.eq.8 ) then
      write (ulsort,texte(langue,16)) mess14(langue,1,-1), indnoe, jaux
              endif
#endif
c
          arenoe(indnoe) = 0
          hetnoe(indnoe) = 1
          do 210 , kaux = 1 , 3
            coonoe(indnoe,kaux) = coonoe(lenoeu,kaux)
  210     continue
c
          famnoe(indnoe) = famnoe(lenoeu)
c
   21   continue
c
c 2.2. ==> Creation de l'arete entre ces 2 noeuds
c
        jaux = tbau30(2,iaux)
c
#ifdef _DEBUG_HOMARD_
          if ( tbau30(5,iaux).eq.-4444 ) then
cgn          if ( lenoeu.eq.2 .or. lenoeu.eq.8 ) then
      write (ulsort,texte(langue,16)) mess14(langue,1,1), jaux,
     >                               tbau30(5,iaux)
      write (ulsort,texte(langue,17))min(tbau30(3,iaux),tbau30(4,iaux)),
     >                               max(tbau30(3,iaux),tbau30(4,iaux))
              endif
#endif
c
        somare(1,jaux) = min(tbau30(3,iaux),tbau30(4,iaux))
        somare(2,jaux) = max(tbau30(3,iaux),tbau30(4,iaux))
c
        famare(jaux) = 1
c
        hetare(jaux) = 0
        merare(jaux) = 0
        filare(jaux) = 0
c
    2 continue
c
c====
c 3. Parcours des aretes a dupliquer
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Parcours des aretes ; codret', codret
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,3,1)
#endif
c
      indqua = 0
c
      do 3 , iaux = 1 , nbduar
c
        larete = tbau40(1,iaux)
c
#ifdef _DEBUG_HOMARD_
          if ( larete.eq.-8 ) then
      write (ulsort,texte(langue,4)) ' ', mess14(langue,1,1), larete
      write (ulsort,texte(langue,18)) ' ' ,mess14(langue,1,7),
     >                                tbau40(4,iaux)
              endif
#endif
c
c 3.1. ==> Reperage des noeuds
c
c        are(1) et are(2) : aretes entre les noeuds dupliques
c        are(3) et are(4) : aretes apres duplication
c
c                             are(3)
c          som(1)------ arete tbau40(2,iaux) ------som(2)
c               .                                  .
c        are(1) .                                  . are(2)
c               .                                  .
c          som(3)------ arete tbau40(3,iaux) ------som(4)
c                           are(4)
c
        do 31 , jaux = 1 , 2
c         sommet = numero absolu du jaux-eme sommet de l'arete
c                  a dupliquer, de numero absolu larete
          sommet  = somare(jaux,larete)
cgn            print *,'sommet ',sommet
c         boucle 311 : on cherche parmi tous les noeuds dupliques celui
c                    qui correspond a 'sommet', en verifiant que l'on
c                    traite le meme joint tbau30(5,kaux)=tbau40(4,iaux)
c                    on stocke les numeros absolus des sommets crees
c                    par la duplication et de l'arete qui les relie
          do 311 , kaux = 1 , nbduno
cgn            print *,tbau30(1,kaux),tbau30(2,kaux),tbau30(3,kaux)
cgn            print *,tbau30(4,kaux),tbau30(5,kaux)
            if ( tbau30(1,kaux).eq.sommet ) then
              if ( tbau30(5,kaux).eq.tbau40(4,iaux) ) then
cgn            print *,'ok pour ',kaux
                are(jaux) = tbau30(2,kaux)
                som(jaux  ) = tbau30(3,kaux)
                som(jaux+2) = tbau30(4,kaux)
                goto 31
              endif
            endif
  311     continue
          write (ulsort,texte(langue,4)) ' ', mess14(langue,1,1),larete
          write (ulsort,texte(langue,4)) ' ', mess14(langue,1,-1),sommet
          codret = 31
          goto 5555
   31   continue
c
c       som(1) et som(2) sont les sommets de la future arete mais
c       il faut les trier car rien ne dit qu'ils sont dans le bon ordre
c       meme remarque pour som(3) et som(4)
c
        if ( som(1).gt.som(2) ) then
          jaux = som(1)
          som(1) = som(2)
          som(2) = jaux
          jaux = som(3)
          som(3) = som(4)
          som(4) = jaux
          jaux = are(1)
          are(1) = are(2)
          are(2) = jaux
        endif
c
c 3.2. ==> Duplications de l'arete
c          Remarque : dans le cas d'aretes multiples, on recree
c                     plusieurs fois la meme arete. Pas grave.
c
          are(3) = tbau40(2,iaux)
c
          somare(1,are(3)) = som(1)
          somare(2,are(3)) = som(2)
          famare(are(3)) = 1
          hetare(are(3)) = 0
          merare(are(3)) = 0
          filare(are(3)) = 0
c
#ifdef _DEBUG_HOMARD_
          if ( larete.eq.-8 ) then
      write (ulsort,texte(langue,16)) mess14(langue,1,1), are(3), 0
      write (ulsort,texte(langue,17)) som(1), som(2)
        endif
#endif
c
          are(4) = tbau40(3,iaux)
c
          somare(1,are(4)) = som(3)
          somare(2,are(4)) = som(4)
          famare(are(4)) = 1
          hetare(are(4)) = 0
          merare(are(4)) = 0
          filare(are(4)) = 0
c
#ifdef _DEBUG_HOMARD_
          if ( larete.eq.-8 ) then
      write (ulsort,texte(langue,16)) mess14(langue,1,1), are(4), 0
      write (ulsort,texte(langue,17)) som(3), som(4)
        endif
#endif
c
c 3.2. ==> Creation du quadrangle
c          On fait les choix suivants :
c          Sa 1ere arete est celle issue de la duplication d'une arete
c          pour le cote 1 : are(3)
c          Sa 2eme arete est celle dont une extremite est la fin de
c          la 1ere arete : are(2)
c          Ensuite, il n'y a plus de choix : are(4), are(1)
c
          indqua = indqua + 1
c
#ifdef _DEBUG_HOMARD_
          if ( larete.eq.-8 ) then
      write (ulsort,texte(langue,16)) mess14(langue,1,4), indqua,
     >                               tbau40(4,iaux)
      write (ulsort,texte(langue,17)) are(3),are(2),are(4),are(1)
        endif
#endif
c
          arequa(indqua,1) = are(3)
          arequa(indqua,2) = are(2)
          arequa(indqua,3) = are(4)
          arequa(indqua,4) = are(1)
c
          famqua(indqua) = 1
c
          hetqua(indqua) = 0
          filqua(indqua) = 0
          perqua(indqua) = 0
          nivqua(indqua) = 0
c
    3 continue
c
c====
c 4. Parcours des triangles base des pentaedres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. Parcours des triangles ; codret', codret
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,3,2)
#endif
c
c   Triangle a dupliquer
c
c          St3
c           x
c          .
c         .  .
c   art3 .
c       .     .
c      .
c     .        .art1
c    .
cSt2.           .
c  x
c     .          .
c          .
c      art2    .  .
c                  x
c                 St1
c
c
c    S3=tbau30(3,i/St3)   a9=tbau30(2,i/St3)        S6=tbau30(4,i/St3)
c           x------------------------------------------x
c          .                                          .
c         .  .                                       .  .
c     a3=tbau40(2,i/art3)                 a6=tbau40(3,i/art3)
c       .     .                                    .     .
c      .                                          .
c     .        .a1=tbau40(2,i/art1)              .   a4=tbau40(3,i/art1)
c    .                                          .
c S2.           .   a8=tbau30(2,i/St2)       S5.=tbau30(4,i/St2)
c  x - - - - - - - - - - - - - - - - - - - - -x
ctbau30(3,i/St2).                               .           .
c          .                                          .
c           a2=tbau40(2,i/art2)        a5=tbau40(3,i/art2).  .
c                  x------------------------------------------x
c       S1=tbau30(3,i/St1)       a7=tbau30(2,i/St1)   S4=tbau30(4,i/St1)
c
c voir utarpe pour le croquis ci-dessus
c
      do 4 , iaux = 1 , nbpejs
c
        letria = tbaux1(1,iaux)
c
#ifdef _DEBUG_HOMARD_
         if ( letria.eq.-27 ) then
      write (ulsort,texte(langue,4)) ' ', mess14(langue,1,2), letria
      write (ulsort,texte(langue,18)) ' ',mess14(langue,1,7),
     >                                tbaux1(2,iaux)
            endif
#endif
c
c 4.1. ==> Reperage des noeuds, aretes et faces
c
        do 41 , jaux = 1 , 3
          larete  = aretri(letria,jaux)
cgn          write (ulsort,*)'larete ',larete
          do 411 , kaux = 1 , nbduar
cgn            write (ulsort,*)tbau40(1,kaux),tbau40(4,kaux)
            if ( tbau40(1,kaux).eq.larete ) then
              if ( tbau40(4,kaux).eq.tbaux1(2,iaux) ) then
cgn            print *,'ok pour ',kaux
                are(jaux  ) = tbau40(2,kaux)
                are(jaux+3) = tbau40(3,kaux)
                qua(jaux) = kaux
                goto 41
              endif
            endif
  411     continue
          codret = 41
          goto 5555
   41   continue
cgn       write (ulsort,*)(are(jaux), jaux = 1 , 6)
cgn       write (ulsort,*)(qua(jaux), jaux = 1 , 3)
c
c 4.2. ==> Triangle entrant ou sortant dans le tetraedre du cote 1 ?
c
        letet1 = tbaux1(3,iaux)
c
        do 421 , jaux = 1 , 3 , 2
          if ( tritet(letet1,jaux).eq.letria ) then
            if ( cotrte(letet1,jaux).le.3 ) then
              nucode = -1
            else
              nucode =  1
            endif
            goto 420
          endif
  421   continue
          do 422 , jaux = 2 , 4 , 2
          if ( tritet(letet1,jaux).eq.letria ) then
            if ( cotrte(letet1,jaux).le.3 ) then
              nucode =  1
            else
              nucode = -1
            endif
            goto 420
          endif
  422   continue
        codret = 24
        goto 5555
c
  420   continue
c
#ifdef _DEBUG_HOMARD_
         if ( letria.eq.-27 ) then
      write (ulsort,90002) mess14(langue,1,3)//'cote 1', letet1
      write (ulsort,90002) 'entrant/sortant', nucode
            endif
#endif
c
c 4.3. ==> Duplication du triangle
c
        do 43 , jaux = 1 , 2
c
          indtri = indtri + 1
c
#ifdef _DEBUG_HOMARD_
         if ( letria.eq.-27 ) then
      write (ulsort,texte(langue,16)) mess14(langue,1,2), indtri, jaux
      write (ulsort,90002) mess14(langue,3,1),
     >           (are(kaux),kaux=3*jaux-2,3*jaux)
            endif
#endif
c
          aretri(indtri,1) = are(3*jaux-2)
          aretri(indtri,2) = are(3*jaux-1)
          aretri(indtri,3) = are(3*jaux)
c
          famtri(indtri) = famtri(letria)
c
          hettri(indtri) = 0
          filtri(indtri) = 0
          pertri(indtri) = 0
          nivtri(indtri) = 0
c
   43   continue
c
c 4.4. ==> Creation du pentaedre
c
        indpen = indpen + 1
c
c 4.4.1. ==> Face 1 : c'est le triangle en cours de traitement.
c   On impose : la 1ere arete du pentaedre est la 1ere arete du triangle
c   le code sera donc 1 ou 4.
c   Si le triangle entrait dans le tetraedre, il va sortir du pentaedre.
c   On lui donnera donc le code 4.
C   Inversement, si le triangle sortait dans le tetraedre, il entre
c   dans le pentaedre. On lui donnera alors le code 1.
c
c   Avec utsotr, on recupere les sommets du triangle dans l'ordre de
c   ses aretes. On en deduit les 3 premiers sommets du pentaedre selon
c   le positionnement du triangle.
c
        facpen(indpen,1) = indtri-1
        if ( nucode.eq.1 ) then
          cofape(indpen,1) = 4
        else
          cofape(indpen,1) = 1
        endif
c
        call utsotr ( somare, are(1), are(2), are(3),
     >                sa1a2, sa2a3, sa3a1 )
        if ( nucode.eq.1 ) then
          sompen(1) = sa3a1
          sompen(3) = sa1a2
        else
          sompen(1) = sa1a2
          sompen(3) = sa3a1
        endif
        sompen(2) = sa2a3
#ifdef _DEBUG_HOMARD_
         if ( letria.eq.-27 ) then
      write (ulsort,90002)'sommets tria ',sa1a2, sa2a3, sa3a1
      write (ulsort,90002)'sommets penta',(sompen(jaux),jaux=1,3)
            endif
#endif
c
c 4.4.2. ==> Face 2 : c'est le 2nd triangle qui est translate de celui
c                     en cours de traitement.
c   Suite aux choix faits sur f1, sa 1ere arete est a4.
c   Si le code du triangle en tant que face 1 est 1, alors sa 2eme arete
c   est la translatee de a2, donc a5, ce qui fait un code 4.
c   Si le code du triangle en tant que face 1 est 4, alors sa 2eme arete
c   est la translatee de a3, donc a5, ce qui fait un code 1.
c
        facpen(indpen,2) = indtri
        cofape(indpen,2) = tabcod(cofape(indpen,1))
c
c 4.4.3. ==> Face 3 : par definition du pentaedre, elle s'appuie sur a1.
c   Par construction, qua(1) a pour 1ere arete a1, donc f3=qua(1)
c   Il reste deux possibilites de positionnement :
c      (a1,a9,a4,a7) donnant le code 1
c      (a1,a7,a4,a9) donnant le code 5
c   Par construction, l'arete 2 du quadrangle est celle qui part de la
c   fin de a1, donc du max(sompen(1),sompen(3)).
c   Si le max est sompen(1), l'arete 2 est a7 donc le code est 5 ;
c   sinon, c'est le code 1.
c
        facpen(indpen,3) = qua(1)
        if ( sompen(1).gt.sompen(3) ) then
          cofape(indpen,3) = 5
        else
          cofape(indpen,3) = 1
        endif
c
c 4.4.4. ==> Face 4 : par definition du pentaedre, elle s'appuie sur a2.
c   Si le code du triangle en tant que face 1 est 1, alors sa 2eme arete
c   est a2, donc f4=qua(2). Sinon, sa 3eme arete est a2, donc f4=qua(3).
c   Il reste deux possibilites de positionnement :
c      (a2,a7,a5,a8) donnant le code 1
c      (a2,a8,a5,a7) donnant le code 5
c   Par construction, l'arete 2 du quadrangle est celle qui part de la
c   fin de a2, donc du max(sompen(2),sompen(1)).
c   Si le max est sompen(2), l'arete 2 est a8 donc le code est 5 ;
c   sinon, c'est le code 1.
c
        if ( cofape(indpen,1).eq.1 ) then
          facpen(indpen,4) = qua(2)
        else
          facpen(indpen,4) = qua(3)
        endif
        if ( sompen(2).gt.sompen(1) ) then
          cofape(indpen,4) = 5
        else
          cofape(indpen,4) = 1
        endif
c
c 4.4.5. ==> Face 5 : par definition du pentaedre, elle s'appuie sur a3.
c   Si le code du triangle en tant que face 1 est 1, alors sa 3eme arete
c   est a3, donc f5=qua(3). Sinon, sa 2eme arete est a3, donc f5=qua(2).
c   Il reste deux possibilites de positionnement :
c      (a3,a8,a6,a9) donnant le code 1
c      (a3,a9,a6,a8) donnant le code 5
c   Par construction, l'arete 2 du quadrangle est celle qui part de la
c   fin de a3, donc du max(sompen(3),sompen(2)).
c   Si le max est sompen(3), l'arete 2 est a9 donc le code est 5 ;
c   sinon, c'est le code 1.
        if ( cofape(indpen,1).eq.1 ) then
          facpen(indpen,5) = qua(3)
        else
          facpen(indpen,5) = qua(2)
        endif
        if ( sompen(3).gt.sompen(2) ) then
          cofape(indpen,5) = 5
        else
          cofape(indpen,5) = 1
        endif
         if ( letria.eq.27 ) then
        endif
c
c 4.4.6. ==> tbaux1(2,iaux) est le numero du joint parmi tous les
c            joints. Il faut ajouter 1 pour tenir compte de la famille
c            libre.
c
        fampen(indpen) = tbaux1(2,iaux) + 1
c
        hetpen(indpen)  = 0
        filpen(indpen)  = 0
        perpen(indpen)  = 0
c
#ifdef _DEBUG_HOMARD_
         if ( letria.eq.-27 ) then
      write (ulsort,texte(langue,16)) mess14(langue,1,7), indpen,
     >                               tbaux1(2,iaux)
      do 4444 , jaux = 1, 5
        write (ulsort,90001) 'face/code', jaux,
     >                       facpen(indpen,jaux),cofape(indpen,jaux)
 4444 continue
      write (ulsort,90002)'aretes 1/2/3',are(1),are(2),are(3)
      write (ulsort,90002)'aretes 4/5/6',are(4),are(5),are(6)
      write (ulsort,90002)'sommets f1', (sompen(jaux),jaux=1,3)
        endif
#endif
c
    4 continue
c
c====
c 5. la fin
c====
c
 5555 continue
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
