      subroutine utbofa ( typenh, numead,
     >                    nbfato, nbvoto,
     >                    nivfac, filfac, perfac,
     >                    hetvol, hetpyr,
     >                    volfac, pypefa,
     >                    borfac, nbfa2d, nbfabo,
     >                    nbfav2, nbfav3, nbfav4, nbfanc,
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
c    UTilitaire - BOrd - FAces
c    --           --     --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typenh . e   .   1    . code des entites au sens homard            .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   4 : quadrangles                          .
c . numead . e   .   1    . numero de la mere adoptive                 .
c . nbfato . e   .   1    . nombre de faces total                      .
c . nbvoto . e   .   1    . nombre de volumes total                    .
c . nivfac . e   . nbfato . niveau des faces                           .
c . perfac . e   . nbfato . pere des faces                             .
c . filfac . e   . nbfato . fille des faces                            .
c . volfac . e   .2*nbfato. numeros des 2 volumes par face)             .
c .        .     .        . volfac(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre/tetraedre j                 .
c .        .     .        . j<0 : pyramide/pentaedre dans pypefa(1/2,j).
c . pypefa . e   .2*lgpype. pypefa(1,j) = numero de la pyramide voisine.
c .        .     .        . de la face k tel que volfac(1/2,k) = -j    .
c .        .     .        . pypefa(2,j) = numero du pentaedre voisin   .
c .        .     .        . de la face k tel que volfac(1/2,k) = -j    .
c . hetvol . e   . nbvoto . historique de l'etat des volumes           .
c . hetpyr . e   . nbpyto . historique de l'etat des pyramides         .
c . borfac .  s  . nbfato . reperage des faces de bord                 .
c .        .     .        . -1 : face non classee                      .
c .        .     .        .  0 : face bidimensionnelle                 .
c .        .     .        .  1 : face au bord d'un seul volume         .
c .        .     .        .  2 : face entre 2 volumes actifs           .
c .        .     .        .  3 : face entre 2 volumes dont 1 seul actif.
c .        .     .        .  4 : face entre 2 volumes inactifs         .
c .        .     .        .  5 : face de non conformite                .
c . nbfa2d .  s  .   1    . nombre de faces de regions 2D              .
c . nbfabo .  s  .   1    . nombre de faces de bord                    .
c . nbfav2 .  s  .   1    . nombre de faces entre 2 volumes actifs     .
c . nbfav3 .  s  .   1    . nombre de faces entre 1 actif et 1 inactif .
c . nbfav4 .  s  .   1    . nombre de faces entre 2 volumes inactifs   .
c . nbfanc .  s  .   1    . nombre de faces de non conformite          .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . sinon : probleme                           .
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
      parameter ( nompro = 'UTBOFA' )
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
      integer typenh, numead
      integer nbfato, nbvoto
      integer nivfac(nbfato)
      integer filfac(nbfato), perfac(nbfato)
      integer volfac(2,nbfato), pypefa(2,*)
      integer borfac(nbfato)
      integer hetvol(*), hetpyr(*)
      integer nbfa2d, nbfabo, nbfav2, nbfav3, nbfav4, nbfanc
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, laux
c
      integer laface
#ifdef _DEBUG_HOMARD_
      integer glop
#endif
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
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
      texte(1,4) =
     > '(''Nombre de '',a,'' de regions bidimensionnelles :'',i10)'
      texte(1,5) =
     > '(''Nombre de '',a,'' de bord exterieur            :'',i10)'
      texte(1,6) =
     > '(''Nombre de '',a,'' entre 2 volumes actifs       :'',i10)'
      texte(1,7) =
     > '(''Nombre de '',a,'' entre 1  actif et 1 inactif  :'',i10)'
      texte(1,8) =
     > '(''Nombre de '',a,'' entre 2 volumes inactifs     :'',i10)'
      texte(1,9) =
     > '(''Nombre de '',a,'' de non conformite            :'',i10)'
      texte(1,10) =
     > '(''Nombre de '',a,'' non classes                  :'',i10)'
      texte(1,16) = '(a,''.. Examen du '',a,''numero '',i10)'
      texte(1,17) = '(''Numero de la mere adoptive :'',i10))'
      texte(1,18) = '(a,''.... Aieul : '',a,''numero '',i10)'
      texte(1,19) = '(''Recherche des faces du bord du domaine'')'
      texte(1,20) = '(a,''.. borfac('',i10,'') = '',i10)'
c
      texte(2,4) =
     > '(''Number of '',a,'' in 2D regions     :'',i10)'
      texte(2,5) =
     > '(''Number of boundary '',a,''          :'',i10)'
      texte(2,6) =
     > '(''Number of '',a,'' inside of volume  :'',i10)'
      texte(2,6) =
     > '(''Number of '',a,'' inside of volume  :'',i10)'
      texte(2,6) =
     > '(''Number of '',a,'' inside of volume  :'',i10)'
      texte(2,9) =
     > '(''Number of non conformal '',a,''     :'',i10)'
      texte(2,10) =
     > '(''Number of '',a,'' without any place :'',i10)'
      texte(2,16) = '(a,''.. Examination of '',a,'',# '',i10)'
      texte(2,17) = '(''Number for adoptive mother :'',i10))'
      texte(2,18) = '(a,''.... Old '',a,'',# '',i10)'
      texte(2,19) = '(''Research of boundary faces'')'
      texte(2,20) = '(a,''.. borfac('',i10,'') = '',i10)'
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,19))
      write (ulsort,texte(langue,17)) numead
#endif
c
c====
c 2. la convention est la suivante :
c    . borfac(laface) vaut -1 si la face n'est pas classee
c    . borfac(laface) vaut 0 si la face ne s'appuie sur aucun
c    volume ; c'est le cas d'une portion de domaine bidimensionnel ;
c    . borfac(laface) vaut 1 si la face s'appuie sur un volume et
c    un seul ; c'est le bord d'un domaine volumique ;
c    . borfac(laface) vaut 2 si la face s'appuie sur 2 volumes ;
c    c'est une face interne a un domaine volumique ;
c    . borfac(laface) vaut 5 si la face s'appuie sur un volume et
c    un seul et est une face de non conformite.
c====
c
c 2.1. ==> en l'absence de volume, toutes les faces font partie
c          d'un domaine bidimensionnel
c
      if ( nbvoto.eq.0 ) then
c
        do 21, laface = 1, nbfato
          borfac(laface) = 0
   21   continue
c
c 2.2 ==> avec des volumes, on decide a chaque fois
c
      else
c
c 2.2.1. ==> a priori, les faces ne sont pas classees
c
        do 220, laface = 1, nbfato
          borfac(laface) = -1
  220   continue
c
        do 22, laface = 1 , nbfato
c
#ifdef _DEBUG_HOMARD_
          if ( laface.eq.17104 .or.
     >         laface.eq.20633  ) then
            glop=1
          else
            glop=0
          endif
          if ( glop.eq.1 ) then
        write (ulsort,texte(langue,16)) ' ', mess14(langue,1,typenh),
     >                                      laface
        write (ulsort,*) ' niveau : ',nivfac(laface)
        write (ulsort,*) ' volfac(*,laface) : ',
     >         volfac(1,laface),volfac(2,laface)
        write(ulsort,*) ' perfac : ',perfac(laface)
        write(ulsort,*) ' filfac : ',filfac(laface)
          endif
#endif
c
c 2.2.1. ==> Si la face ne borde aucun volume, on le note
c            on passe la face suivante dans la boucle 22
c
          if ( volfac(1,laface).eq.0 ) then
            borfac(laface) = 0
#ifdef _DEBUG_HOMARD_
          if ( glop.eq.1 ) then
        write (ulsort,texte(langue,16)) ' ', mess14(langue,1,typenh),
     >                                      laface
        write (ulsort,*) ' niveau : ',nivfac(laface)
        write (ulsort,*) ' volfac(*,laface) : ',
     >         volfac(1,laface),volfac(2,laface)
        write(ulsort,*) ' perfac : ',perfac(laface)
        write(ulsort,*) ' filfac : ',filfac(laface)
          endif
#endif
c
c 2.2.2. ==> Si la face borde deux volumes, on le note ainsi :
c            2 : face entre 2 volumes actifs
c            3 : face entre 2 volumes dont 1 seul actif
c            4 : face entre 2 volumes inactifs
c            on passe la face suivante dans la boucle 22
c
          elseif ( volfac(2,laface).ne.0 ) then
c
            do 222 , kaux = 1 , 2
              laux = volfac(kaux,laface)
              if ( laux.gt.0 ) then
                jaux = mod(hetvol(laux),100)
              else
                laux = -laux
                if ( pypefa(1,laux).ne.0 ) then
                  jaux = mod(hetpyr(pypefa(1,laux)),100)
                endif
                if ( pypefa(2,laux).ne.0 ) then
                  codret = 1793
                endif
              endif
              if ( kaux.eq.1 ) then
                iaux = jaux
              endif
  222       continue
c
#ifdef _DEBUG_HOMARD_
            if ( glop.eq.1 ) then
      write(ulsort,texte(langue,16))' ..',mess14(langue,1,typenh),laface
      write(ulsort,*) '     volfac :',volfac(1,laface),volfac(2,laface)
      write(ulsort,*) '     etats  :',iaux,jaux
      write(ulsort,*) '     nivfac : ',nivfac(iaux)
      write(ulsort,*) '     perfac : ',perfac(iaux)
           endif
#endif
            if ( iaux.eq.0 .and. jaux.eq.0 ) then
              borfac(laface) = 2
            elseif ( iaux.eq.0 .or. jaux.eq.0 ) then
              borfac(laface) = 3
            else
              borfac(laface) = 4
            endif
c
c 2.2.3. ==> Si la face borde 1 seul volume, on explore son ascendance
c            on remonte l'ascendance de la face par la pseudo boucle
c            de 223 continue, jusqu'a trouver la face mere primale.
c            Dans ce parcours, la face a examiner est iaux
c
          else
c
            iaux = laface
c
  223       continue
c
#ifdef _DEBUG_HOMARD_
            if ( glop.eq.1 ) then
      write(ulsort,texte(langue,16))' ..',mess14(langue,1,typenh),iaux
      write(ulsort,*) '     volfac :',volfac(1,iaux),volfac(2,iaux)
      write(ulsort,*) '     nivfac : ',nivfac(iaux)
      write(ulsort,*) '     perfac : ',perfac(iaux)
           endif
#endif
c
            if ( perfac(iaux).ne.0 ) then
c
              jaux = perfac(iaux)
              if ( jaux.lt.0 ) then
                if ( jaux.ne.numead ) then
                  write(ulsort,*) 'PROBLEME DE PERFAC < 0 : ', jaux
                  write (ulsort,texte(langue,17)) numead
                  codret = 1
#ifdef _DEBUG_HOMARD_
                else
                    write(ulsort,*) 'iaux vaut numead  = ',numead
#endif
                endif
              else
                iaux = jaux
                goto 223
              endif
c
            endif
c
#ifdef _DEBUG_HOMARD_
            if ( glop.eq.1 ) then
              write (ulsort,texte(langue,18)) ' ',
     >        mess14(langue,1,typenh), iaux
            endif
#endif
c
c 2.2.4. ==> On examine la face 'iaux'.
c
c           A. Si c'est la mere adoptive pour les maillages non
c              conformes d'origine, la face courante est une face du
c              bord du domaine
c
            if ( iaux.eq.numead ) then
c
#ifdef _DEBUG_HOMARD_
            if ( glop.eq.1 ) then
              write (ulsort,*) 'pas glop'
            endif
#endif
              borfac(laface) = 1
c
c           B. Si cette face aieule est de niveau 0 :
c              - si cette face aieule a 2 voisins, la face courante est
c                de limite de zone de raffinement
c              - si la face aieule a 1 seul voisin :
c                . si elle n'a pas de fille, c'est que laface = iaux,
c                  donc on est sur le bord exterieur
c                . si elle a une fille de niveau 1, c'est aussi un
c                  bord exterieur
c                . si elle a une fille de niveau 0, on est dans un cas
c                  de non conformite initiale. Donc laface est sur
c                  une limite de zone.
c
            elseif ( nivfac(iaux).eq.0 ) then
c
              if ( volfac(2,iaux).eq.0 ) then
                if ( filfac(iaux).gt.0 ) then
                  if ( nivfac(filfac(iaux)).eq.0 ) then
                    borfac(laface) = 5
                  else
                    borfac(laface) = 1
                  endif
                else
                  borfac(laface) = 1
                endif
              else
                borfac(laface) = 5
              endif
c
c           C. Sinon, c'est une face de limite de zone de raffinement
c              non conforme (on est dans le cas d'une filiation d'une
c              face qui a ete creee en interne a un volume)
c
            else
c
              borfac(laface) = 5
c
           endif
#ifdef _DEBUG_HOMARD_
           if ( glop.eq.1 ) then
             write (ulsort,texte(langue,20)) ' ', laface, borfac(laface)
           endif
#endif
c
         endif
c
   22   continue
c
      endif
c
c====
c 3. decompte des faces de bords
c====
c
      if ( nbvoto.ne.0 ) then
c
         nbfa2d = 0
         nbfabo = 0
         nbfav2 = 0
         nbfav3 = 0
         nbfav4 = 0
         nbfanc = 0
         do 31, laface = 1, nbfato
           if ( borfac(laface).eq.0 ) then
              nbfa2d = nbfa2d + 1
           elseif ( borfac(laface).eq.1 ) then
              nbfabo = nbfabo + 1
           elseif ( borfac(laface).eq.2 ) then
              nbfav2 = nbfav2 + 1
           elseif ( borfac(laface).eq.3 ) then
              nbfav3 = nbfav3 + 1
           elseif ( borfac(laface).eq.4 ) then
              nbfav4 = nbfav4 + 1
           elseif ( borfac(laface).eq.5 ) then
              nbfanc = nbfanc + 1
           endif
   31    continue
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,texte(langue,4)) mess14(langue,3,typenh), nbfa2d
      write(ulsort,texte(langue,5)) mess14(langue,3,typenh), nbfabo
      write(ulsort,texte(langue,6)) mess14(langue,3,typenh), nbfav2
      write(ulsort,texte(langue,7)) mess14(langue,3,typenh), nbfav3
      write(ulsort,texte(langue,8)) mess14(langue,3,typenh), nbfav4
      write(ulsort,texte(langue,9)) mess14(langue,3,typenh), nbfanc
      write(ulsort,texte(langue,10)) mess14(langue,3,typenh),
     > nbfato - nbfa2d - nbfabo - nbfav2 - nbfav3 - nbfav4 - nbfanc
#endif
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
