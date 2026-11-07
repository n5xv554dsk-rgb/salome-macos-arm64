      subroutine eslmho ( typobs, nrosec, nretap, nrsset,
     >                    nomail, typecc,
     >                    suifro, nocdfr, ncafdg,
     >                    ulsort, langue, codret)
c
c  on peut ne stocker que des listes restreintes pour les
c  homologues si on veut optimiser le stockage
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
c  Entree-Sortie : Lecture du Maillage HOmard
c  -      -        -          -        --
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typobs . e   . char*8 . mot-cle correspondant a l'objet a lire     .
c . nrosec . e   .   1    . numero de section pour les mesures de temps.
c . nretap . e   .   1    . numero d'etape                             .
c . nrsset . e   .   1    . numero de sous-etape                       .
c . nomail .   s . char*8 . nom de l'objet maillage homard lu          .
c . typecc .   s .   1    . type de code de calcul associe             .
c . suifro . e   .   1    . 1 : pas de suivi de frontiere              .
c .        .     .        . 2x : frontiere discrete                    .
c .        .     .        . 3x : frontiere analytique                  .
c .        .     .        . 5x : frontiere cao                         .
c . nocdfr .  s  . char8  . nom de l'objet description de la frontiere .
c . ncafdg .  s  . char*8 . nom de l'objet groupes frontiere           .
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
      parameter ( nompro = 'ESLMHO' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nomber.h"
#include "nombar.h"
#include "envca1.h"
c
c 0.3. ==> arguments
c
      character*8 typobs
c
      integer nrosec, nretap, nrsset
      integer typecc
      integer suifro
c
      character*8 nomail
      character*8 nocdfr
      character*8 ncafdg
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer codava
c
      integer numead
      integer voarno, vofaar, vovoar, vovofa
      integer ppovos, pvoiso
      integer pposif, pfacar
      integer adnohn
      integer admphn
      integer adarhn
      integer adtrhn
      integer adquhn
      integer adtehn
      integer adhehn
      integer adpyhn
      integer adpehn
      integer iaux, jaux, kaux
      integer codre1
c
      character*6 saux
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
c
      logical exiren
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. les initialisations
c====
c
      codava = codret
c
c=======================================================================
      if ( codava.eq.0 ) then
c=======================================================================
c
c 1.1. ==> le debut des mesures de temps
c
      if ( nrosec.gt.0 ) then
        call gtdems (nrosec)
      endif
c
c 1.2. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(/,a6,'' RECUPERATION DU MAILLAGE HOMARD'')'
      texte(1,5) = '(38(''=''),/)'
      texte(1,6) = '(''Mot-cle : '',a8)'
c
      texte(2,4) = '(/,a6,'' READINGS OF HOMARD MESH'')'
      texte(2,5) = '(30(''=''),/)'
      texte(2,6) = '(''Keyword : '',a8)'
c
      call utcvne ( nretap, nrsset, saux, iaux, codret )
c
c 1.5. ==> le titre
c
      write (ulsort,texte(langue,4)) saux
      write (ulsort,texte(langue,5))
c
#include "impr03.h"
c
c====
c 2. Lecture du maillage
c====
c 2.1. ==> Lecture
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMH1', nompro
#endif
      call eslmh1 ( typobs, nomail,
     >              suifro, nocdfr, ncafdg,
     >              ulsort, langue, codret)
c
c 2.2. ==> Les structures
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMH', nompro
#endif
      call utnomh ( nomail,
     >                sdim,   mdim,
     >               degre, maconf, homolo, hierar,
     >              rafdef, nbmane, typcca, typsfr, maextr,
     >              mailet,
     >              norenu,
     >              nhnoeu, nhmapo, nharet,
     >              nhtria, nhquad,
     >              nhtetr, nhhexa, nhpyra, nhpent,
     >              nhelig,
     >              nhvois, nhsupe, nhsups,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
      typecc = typcca
      endif
c
c====
c 3. Reconstitution des informations supprimees a l'ecriture
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Reconstitution ; codret', codret
#endif
c
c 3.1. ==> les parentes
c
c 3.1.1. ==> filles des aretes
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTMFAR', nompro
#endif
      call utmfar ( nomail, ulsort, langue, codret)
c
      endif
c
c 3.1.2. ==> filles des faces
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTMFFA', nompro
#endif
      call utmffa ( nomail, ulsort, langue, codret)
c
      endif
c
c 3.1.3. ==> fils des volumes
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTMFVO', nompro
#endif
      call utmfvo ( nomail, ulsort, langue, codret)
c
cgn      call gmprsx(nompro,nhtetr//'.Mere')
cgn      call gmprsx(nompro,nhhexa//'.Fille')
cgn      call gmprsx(nompro,nhhexa//'.InfoSup2')
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Apres 3.1. parentes : codret', codret
#endif
c
c 3.2. ==> les voisinages
c
      if ( codret.eq.0 ) then
c
      voarno = 1
      vofaar = 1
      vovoar = 0
      vovofa = 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTVOIS', nompro
#endif
      call utvois ( nomail, nhvois,
     >              voarno, vofaar, vovoar, vovofa,
     >              ppovos, pvoiso,
     >              nbfaar, pposif, pfacar,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Apres 3.2. voisinages : codret', codret
#endif
c
      endif
c
c 3.3. ==> la renumerotation
c
c 3.3.1. ==> existe-t-il une renumerotation ?
c            attention : il faut utiliser le nom compose, car si la
c                        structure n'existe pas, norenu vaut 'Indefini'
c
      if ( codret.eq.0 ) then
c
      call gmobal ( nomail//'.RenuMail', codre1 )
      if ( codre1.eq.1 ) then
        exiren = .true.
      elseif ( codre1.eq.0 ) then
        exiren = .false.
      else
        codret = 1
      endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'Apres 3.3.1 : codret', codret
#endif
c
      endif
c
c 3.3.2. ==> reactualisation des communs en attendant une vraie
c            exploitation de la structure partout
c
      if ( exiren ) then
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      call gmprsx (nompro, norenu )
      endif
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_no', nompro
#endif
      iaux = -1
      jaux = 30
      call utre03 ( iaux, jaux, norenu,
     >              renoac, renoto, adnohn,   kaux,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_mp', nompro
#endif
      iaux = 0
      jaux = -30
      call utre03 ( iaux, jaux, norenu,
     >              rempac, rempto, admphn,   kaux,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_ar', nompro
#endif
      iaux = 1
      jaux = -30
      call utre03 ( iaux, jaux, norenu,
     >              rearac, rearto, adarhn,   kaux,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_tr', nompro
#endif
      iaux = 2
      jaux = -30
      call utre03 ( iaux, jaux, norenu,
     >              retrac, retrto, adtrhn,   kaux,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_te', nompro
#endif
      iaux = 3
      jaux = -30
      call utre03 ( iaux, jaux, norenu,
     >              reteac, reteto, adtehn,   kaux,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_qu', nompro
#endif
      iaux = 4
      jaux = -30
      call utre03 ( iaux, jaux, norenu,
     >              requac, requto, adquhn,   kaux,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_py', nompro
#endif
      iaux = 5
      jaux = -30
      call utre03 ( iaux, jaux, norenu,
     >              repyac, repyto, adpyhn,   kaux,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_he', nompro
#endif
      iaux = 6
      jaux = -30
      call utre03 ( iaux, jaux, norenu,
     >              reheac, reheto, adhehn,   kaux,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_pe', nompro
#endif
      iaux = 7
      jaux = -30
      call utre03 ( iaux, jaux, norenu,
     >              repeac, repeto, adpehn,   kaux,
     >              ulsort, langue, codret)
c
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Apres 3.3.2 : codret', codret
#endif
c
c 3.3.3. ==> creation des tableaux reciproques
c
      if ( codret.eq.0 ) then
c
      if ( exiren ) then
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMH5_no', nompro
#endif
      iaux = -1
      call eslmh5 ( iaux, norenu, renoto, renoac, adnohn,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMH5_mp', nompro
#endif
      iaux = 0
      call eslmh5 ( iaux, norenu, rempto, rempac, admphn,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMH5_ar', nompro
#endif
      iaux = 1
      call eslmh5 ( iaux, norenu, rearto, rearac, adarhn,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMH5_tr', nompro
#endif
      iaux = 2
      call eslmh5 ( iaux, norenu, retrto, retrac, adtrhn,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMH5_te', nompro
#endif
      iaux = 3
      call eslmh5 ( iaux, norenu, reteto, reteac, adtehn,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMH5_qu', nompro
#endif
      iaux = 4
      call eslmh5 ( iaux, norenu, requto, requac, adquhn,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMH5_py', nompro
#endif
      iaux = 5
      call eslmh5 ( iaux, norenu, repyto, repyac, adpyhn,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMH5_he', nompro
#endif
      iaux = 6
      call eslmh5 ( iaux, norenu, reheto, reheac, adhehn,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMH5_pe', nompro
#endif
      iaux = 7
      call eslmh5 ( iaux, norenu, repeto, repeac, adpehn,
     >              ulsort, langue, codret)
c
      endif
c
      endif
c
      endif
c
c====
c 5. meres adoptives des faces pour la non conformite initiale
c    Il faut le faire seulement maintenant, une fois que toutes les
c    autres grandeurs ont ete initialisees
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. meres adoptives ; codret', codret
#endif
c
      if ( ( maconf.eq.-2 ) .or. ( maconf.ge.1 ) ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTNC08', nompro
#endif
        call utnc08 ( nharet, nhtria, nhquad, nhvois,
     >                numead,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c====
c 6. verification de la conformite
c    les messages sont toujours imprimes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. verification conformite ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCOMA', nompro
#endif
      call utcoma ( nomail,
     >              iaux,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 7. la fin
c====
c
c 7.1. ==> message si erreur
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      write (ulsort,texte(langue,6)) typobs
c
      endif
c
c 7.2. ==> fin des mesures de temps de la section
c
      if ( nrosec.gt.0 ) then
        call gtfims (nrosec)
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
c=======================================================================
      endif
c=======================================================================
c
      end
