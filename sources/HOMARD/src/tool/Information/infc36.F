      subroutine infc36 ( numcas, nbcomp, nbentc,
     >                    profil, vafoti, vafotr,
     >                    quahex, coquhe, arehex,
     >                    perhex, nhexca,
     >                    coonoe, somare,
     >                    arequa, nivqua,
     >                    npherc, hexrec,
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
c  INformation - inFormations Complementaires - phase 36
c  --              -          -                       --
c  Valeurs sur les hexaedres
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . numcas . e   .   1    . numero du cas en cours de traitement       .
c .        .     .        . 1 : niveau                                 .
c .        .     .        . 2 : qualite                                .
c .        .     .        . 3 : diametre                               .
c .        .     .        . 4 : parente                                .
c .        .     .        . 5 : voisins des recollements               .
c . nbcomp . e   .   1    . nombre de composantes                      .
c . nbentc . e   .   1    . nombre total d'entites du calcul           .
c . profil .  s  . nbentc . pour chaque entite du calcul :             .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . vafoti .  s  . nbentc . tableau temporaire de la fonction          .
c . vafotr .  s  . nbentc . tableau temporaire de la fonction          .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . arehex . e   .nbheca12. numeros des 12 aretes des hexaedres        .
c . perhex . e   . nbheto . pere des hexaedres                         .
c . nhexca . e   .   *    . nro des hexaedres dans le calcul           .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . nivqua . e   . nbquto . niveau dans le raffinement/deraffinement   .
c . npherc . e   .   1    . nombre de paires d'hexaedres recolles      .
c . hexrec . e   .3*npherc. paires des hexa. voisins faces a recoller  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 5 : mauvais type de code de calcul associe .
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
      parameter ( nompro = 'INFC36' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envca1.h"
#include "impr02.h"
#include "nombno.h"
#include "nombar.h"
#include "nombqu.h"
#include "nombhe.h"
c
c 0.3. ==> arguments
c
      integer numcas
      integer nbcomp, nbentc
      integer profil(nbentc)
      integer vafoti(nbentc)
      integer quahex(nbhecf,6), coquhe(nbhecf,6), arehex(nbheca,12)
      integer perhex(nbheto), nhexca(*)
      integer somare(2,nbarto)
      integer arequa(nbquto,4), nivqua(nbquto)
      integer npherc, hexrec(3,npherc)
c
      double precision coonoe(nbnoto,sdim)
      double precision vafotr(nbentc)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, laux
      integer indice, lmax
      integer levolu, laface
c
      double precision niveau, qualit, qualij, diamet
      double precision volume
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
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
      texte(1,4) = '(''.. Valeurs sur les '',a)'
c
      texte(2,4) = '(''.. Values over the '',a)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,6)
      write (ulsort,90002) 'numcas', numcas
      write (ulsort,90002) 'nbheto', nbheto
      write (ulsort,90002) 'nbhepe', nbhepe
      write (ulsort,90002) 'nbcomp', nbcomp
      write (ulsort,90002) 'nbentc', nbentc
      write (ulsort,90002) 'npherc', npherc
#endif
c
      codret = 0
c
c====
c 2. Rien par defaut
c====
c
      do 21 , iaux = 1 , nbentc
        profil(iaux) = 0
   21 continue
c
c====
c 3. Niveau
c====
c
      if ( numcas.eq.1 ) then
c
c 3.1. ==> Les hexaedres de depart ou issus d'un decoupage en 8
c          Les faces sont toutes du meme niveau
c          Remarque : ils sont toujours decrits par faces
c
        do 31 , iaux = 1 , nbhepe
c
cgn      write (ulsort,90015) 'nhexca(',iaux,') =', nhexca(iaux)
c
          jaux = nhexca(iaux)
          if ( jaux.ne.0 ) then
cgn      write (ulsort,90015) 'nivqua(',iaux,') =', nivqua(quahex(iaux,1))
            vafotr(jaux) = dble(nivqua(quahex(iaux,1)))
            profil(jaux) = 1
          endif
c
   31   continue
c
c 3.2. ==> Les hexaedres issus d'un decoupage de conformite
c          Remarque : ils sont toujours actifs
c
        do 32 , iaux = nbhepe+1 , nbheto
c
          call utnhex ( iaux, niveau,
     >                  quahex, perhex,
     >                  nivqua )
c
          jaux = nhexca(iaux)
          vafotr(jaux) = niveau
          profil(jaux) = 1
c
   32   continue
c
c====
c 4. Qualite
c====
c
      elseif ( numcas.eq.2 ) then
c
        do 41 , iaux = 1 , nbheto
c
          jaux = nhexca(iaux)
          if ( jaux.ne.0 ) then
            kaux = iaux
            call utqhex (   kaux, qualit, qualij, volume,
     >                    coonoe, somare, arequa,
     >                    quahex, coquhe, arehex )
            vafotr(jaux) = qualit
            profil(jaux) = 1
          endif
c
   41   continue
c
c====
c 5. Diametre
c====
c
      elseif ( numcas.eq.3 ) then
c
        do 51 , iaux = 1 , nbheto
c
          jaux = nhexca(iaux)
          if ( jaux.ne.0 ) then
            kaux = iaux
            call utdhex ( kaux, diamet,
     >                    coonoe, somare, arequa,
     >                    quahex, coquhe, arehex )
            vafotr(jaux) = diamet
            profil(jaux) = 1
c
          endif
c
   51   continue
c
c====
c 6. Parente
c====
c
      elseif ( numcas.eq.4 ) then
c
        do 61 , iaux = 1 , nbheto
c
          jaux = nhexca(iaux)
          if ( jaux.ne.0 ) then
            vafoti(jaux) = perhex(iaux)
            profil(jaux) = 1
          endif
c
   61   continue
c
c====
c 7. Voisins par recollement
c====
c
      elseif ( numcas.eq.5 ) then
c
c 7.1. ==> On met des valeurs nulles par defaut
c
        do 71 , iaux = 1 , nbheto
c
          jaux = nhexca(iaux)
          if ( jaux.ne.0 ) then
            indice = nbcomp*(jaux-1) + 1
            do 711 , kaux = 1 , nbcomp
              vafoti(indice) = 0
              indice = indice + 1
  711       continue
            profil(jaux) = 1
          endif
c
   71   continue
c
c 7.2. ==> Parcours des paires enregistrees
c
        lmax = nbcomp / 2
c
cgn      write (ulsort,*) 'boucle 720'
cgn      write (ulsort,90002) 'npherc', npherc
cgn      do 720 , iaux = 1 , npherc
cgn          if ( ( hexrec(3,iaux).eq.291 ) .or.
cgn     >         ( hexrec(3,iaux).eq.296 ) ) then
cgn      write (ulsort,90022) 'iaux', iaux, hexrec(1,iaux),
cgn     >                          hexrec(2,iaux), hexrec(3,iaux)
cgn          endif
cgn  720 continue
        do 72 , iaux = 1 , npherc
c
          jaux = hexrec(1,iaux)
          kaux = hexrec(2,iaux)
cgn          write (ulsort,90002) 'iaux, jaux, kaux, face',
cgn     >                          iaux, jaux, kaux, hexrec(3,iaux)
c
          if ( jaux.ne.0 ) then
c
cgn            write (ulsort,*) 'boucle 721'
            levolu = kaux
            laface = hexrec(3,iaux)
            indice = nbcomp*(jaux-1) + 1
            do 721 , laux = 1, lmax
              if ( vafoti(indice).eq.0 ) then
                vafoti(indice) = levolu
                vafoti(indice+1) = laface
cgn      if ( ( hexrec(3,iaux).eq.291 ) .or.
cgn     >     ( hexrec(3,iaux).eq.296 ) ) then
cgn      write (ulsort,90022) 'iaux', iaux, hexrec(1,iaux),
cgn     >                          hexrec(2,iaux), hexrec(3,iaux)
cgn      write (ulsort,90002) ' ==> indice A', indice, laux
cgn      write (ulsort,90002) ' ==> ecriture de', kaux, hexrec(3,iaux)
cgn      endif
                goto 722
              elseif ( vafoti(indice+1).eq.laface ) then
cgn      if ( ( hexrec(3,iaux).eq.291 ) .or.
cgn     >     ( hexrec(3,iaux).eq.296 ) ) then
cgn      write (ulsort,90022) 'iaux', iaux, hexrec(1,iaux),
cgn     >                          hexrec(2,iaux), hexrec(3,iaux)
cgn      write (ulsort,90002) ' ==> indice A', indice
cgn      write (ulsort,90002) ' ==> non ecriture de', kaux, hexrec(3,iaux)
cgn      endif
                goto 723
#ifdef _DEBUG_HOMARD_
              else
      if ( ( hexrec(3,iaux).eq.-291 ) .or.
     >     ( hexrec(3,iaux).eq.-296 ) ) then
      write (ulsort,90022) 'iaux', iaux, hexrec(1,iaux),
     >                          hexrec(2,iaux), hexrec(3,iaux)
      write (ulsort,*) '    indice A deja connu',indice,vafoti(indice)
      write (ulsort,*) '    recherche d''un autre indice'
      endif
#endif
              endif
              indice = indice + 2
  721       continue
            codret = 721
            write (ulsort,*) 'Ecriture impossible'
            write (ulsort,90002) 'iaux', iaux
            write (ulsort,90002) '1', hexrec(1,iaux)
            write (ulsort,90002) '2', hexrec(2,iaux)
            write (ulsort,90002) '3', hexrec(3,iaux)
            goto 7999
  722       continue
  723       continue
c
          endif
c
          if ( kaux.ne.0 ) then
c
cgn            write (ulsort,*) 'boucle 724'
            levolu = jaux
            laface = hexrec(3,iaux)
            indice = nbcomp*(kaux-1) + 1
            do 724 , laux = 1, lmax
              if ( vafoti(indice).eq.0 ) then
                vafoti(indice) = levolu
                vafoti(indice+1) = laface
cgn         write (ulsort,90002) ' ==> indice B', indice, laux
                goto 725
cgn            else
cgn          write (ulsort,90112) '    vafoti',indice,vafoti(indice)
cgn          write (ulsort,*) '    indice B deja connu'
              endif
              indice = indice + 2
  724       continue
            codret = 724
            write (ulsort,*) 'Ecriture impossible'
            write (ulsort,90002) 'iaux', iaux
            write (ulsort,90002) '1', hexrec(1,iaux)
            write (ulsort,90002) '2', hexrec(2,iaux)
            write (ulsort,90002) '3', hexrec(3,iaux)
            goto 7999
  725       continue
c
          endif
c
   72   continue
c
cgn        do 73 , iaux = 1,nbentc
cgn          write(ulsort,90112)'profil',iaux,profil(iaux)
cgn       write (ulsort,90002) 'indices', nbcomp*(iaux-1)+1,nbcomp*iaux
cgn          write(ulsort,90112)'vafoti',iaux,
cgn     >(vafoti(jaux),jaux=nbcomp*(iaux-1)+1,nbcomp*iaux)
cgn   73 continue
c
 7999   continue
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
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
