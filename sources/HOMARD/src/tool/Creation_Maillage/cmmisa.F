      subroutine cmmisa ( nomail,
     >                    lgetco, taetco,
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
c    Creation du Maillage - MISe A jour de la structure de donnees
c    -           -          ---  -
c ______________________________________________________________________
c
c but : mise a jour de la structure de donnees pour le maillage adapte
c       dont :
c              - reconstruction des voisinages
c              - traitement des homologues
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   .  ch8   . nom de l'objet contenant le maillage       .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c ______________________________________________________________________
c
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
      parameter ( nompro = 'CMMISA' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
c
#include "envca1.h"
#include "envada.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
#include "nouvnb.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      character*8 nomail
c
      integer lgetco
      integer taetco(lgetco)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer codava
      integer nrosec
      integer nretap, nrsset
      integer iaux, jaux
c
      integer codre0, codre1, codre2, codre3, codre4
      integer codre5, codre6, codre7, codre8
      integer phetno, pcoono
      integer psomar, phetar, pfilar, pnp2ar
      integer pposif, pfacar
      integer phettr, paretr, pfiltr, ppertr, pnivtr
      integer phetqu, parequ, pfilqu, pperqu, pnivqu
      integer ptrite, phette, pfilte
      integer pquahe, phethe, pfilhe
      integer pfacpy, phetpy, pfilpy
      integer pfacpe, phetpe, pfilpe
      integer adhono, adhoar, adhotr, adhoqu
      integer numead
c
      integer nvacar, nvactr, nvacqu, nvacte, nvache, nvacpy, nvacpe
      integer vofaar, vovofa
c
      character*6 saux
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
      character*14 saux14
c
      integer nbmess
      parameter ( nbmess = 11 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. messages
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
      nrosec = taetco(4)
      call gtdems (nrosec)
c
c 1.3. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =
     > '(/,a6,'' MISE A JOUR DES DONNEES DU MAILLAGE ADAPTE'')'
      texte(1,5) = '(49(''=''),/)'
c
      texte(1,6) = '(5x,''Nombre de noeuds                 :'',i10)'
      texte(1,7) = '(5x,''Nombre de '',a,'' actifs  :'',i10)'
      texte(1,8) = '(5x,''Niveau minimum des '',a,'':'',i10)'
      texte(1,9) = '(5x,''Niveau minimum des '',a,'':'',i10,''.5'')'
      texte(1,10) = '(5x,''Niveau maximum des '',a,'':'',i10)'
      texte(1,11) = '(5x,''Niveau maximum des '',a,'':'',i10,''.5'')'
c
      texte(2,4) = '(/,a6,'' UPDATING OF DATA ON ADAPTED MESH'')'
      texte(2,5) = '(39(''=''),/)'
      texte(2,6) = '(5x,''Number of nodes                :'',i10)'
      texte(2,7) = '(5x,''Number of active '',a,'':'',i10)'
      texte(2,8) = '(5x,''Minimum level of '',a,'':'',i10)'
      texte(2,9) = '(5x,''Minimum level of '',a,'':'',i10,''.5'')'
      texte(2,10) = '(5x,''Maximum level of '',a,'':'',i10)'
      texte(2,11) = '(5x,''Maximum level of '',a,'':'',i10,''.5'')'
c
#include "impr03.h"
c
c 1.4. ==> le numero de sous-etape
c
      nretap = taetco(1)
      nrsset = taetco(2) + 1
      taetco(2) = nrsset
c
      call utcvne ( nretap, nrsset, saux, iaux, codret )
c
c 1.5. ==> le titre
c
      write ( ulsort,texte(langue,4)) saux
      write ( ulsort,texte(langue,5))
c
c====
c 2. recuperation des pointeurs
c====
c
c 2.1. ==> structure generale
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
c 2.2. ==> tableaux
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2. tableaux ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 6
      if ( homolo.ge.1 ) then
        iaux = iaux*11
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD01', nompro
#endif
      call utad01 ( iaux, nhnoeu,
     >              phetno,
     >                jaux,   jaux,   jaux,
     >              pcoono,   jaux, adhono,  jaux,
     >              ulsort, langue, codret )
c
      iaux = 6
      if ( degre.eq.2 ) then
        iaux = iaux*13
      endif
      if ( homolo.ge.2 ) then
        iaux = iaux*29
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_ar', nompro
#endif
      call utad02 ( iaux, nharet,
     >              phetar, psomar, pfilar, jaux,
     >                jaux,   jaux,   jaux,
     >                jaux, pnp2ar,   jaux,
     >                jaux, adhoar,   jaux,
     >              ulsort, langue, codret )
c
      if ( nouvtr.ne.0 ) then
c
        iaux = 330
        if ( homolo.ge.3 ) then
          iaux = iaux*29
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_tr', nompro
#endif
        call utad02 ( iaux, nhtria,
     >                phettr, paretr, pfiltr, ppertr,
     >                  jaux,   jaux,   jaux,
     >                pnivtr, jaux,  jaux,
     >                  jaux, adhotr, jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nouvqu.ne.0 ) then
c
        iaux = 330
        if ( homolo.ge.3 ) then
          iaux = iaux*29
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_qu', nompro
#endif
        call utad02 ( iaux, nhquad,
     >                phetqu, parequ, pfilqu, pperqu,
     >                  jaux,   jaux,   jaux,
     >                pnivqu, jaux,  jaux,
     >                  jaux, adhoqu, jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nouvte.ne.0 ) then
c
        iaux = 6
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_te', nompro
#endif
        call utad02 ( iaux, nhtetr,
     >                phette, ptrite, pfilte, jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nouvhe.ne.0 ) then
c
        iaux = 6
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_he', nompro
#endif
        call utad02 ( iaux, nhhexa,
     >                phethe, pquahe, pfilhe, jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nouvpy.ne.0 ) then
c
        iaux = 6
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_py', nompro
#endif
        call utad02 ( iaux, nhpyra,
     >                phetpy, pfacpy, pfilpy, jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nouvpe.ne.0 ) then
c
        iaux = 6
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_pe', nompro
#endif
        call utad02 ( iaux, nhpent,
     >                phetpe, pfacpe, pfilpe, jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 3. comptage des entites actives du maillage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. comptage entites active ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCACT', nompro
#endif
      call cmcact ( imem(phetno),
     >              imem(pfilar),
     >              imem(pfiltr), imem(pnivtr),
     >              imem(pfilqu), imem(pnivqu),
     >              imem(pfilte), imem(pfilhe),
     >              imem(pfilpy), imem(pfilpe),
     >              nvacar, nvactr, nvacqu,
     >              nvacte, nvache, nvacpy, nvacpe,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 4. mise a jour des nombres d'entites du maillage adapte
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. mise a jour des nombres ; codret', codret
      call dmflsh (iaux)
#endif
c
      if ( codret.eq.0 ) then
c
c 4.1. commun "nombno" --> noeuds
c
c     nbpnho = mis a jour en 5.1
c     nbnois = non modifie
c     nbnoei = non modifie
c     nbnoma = non modifie
c     nbnomp = non modifie
cgn      write (ulsort,90002) 'nouvno,provp1',nouvno,provp1
cgn      write (ulsort,90002) 'nouvp2,nouvim',nouvp2,nouvim
cgn      write (ulsort,90002) 'nbnoei,nbnois',nbnoei,nbnois
      nbnop1 = nouvno - nouvp2 - nouvim - nbnomp - nbnoei - nbnois
      nbnop2 = nouvp2
      nbnoim = nouvim
      nbnoto = nouvno
      nbnoin = provp1 - nbquq5/3
cgn      write (ulsort,90002) 'p1,p2,im,to',nbnop1,nbnop2,nbnoim,nbnoto
c
c 4.2. commun "nombar" --> aretes
c
      nbarac = nvacar
      nbarde = permar - nbarma
c     nbart2 = calcule dans utplco
c     nbarq2 = calcule dans utplco
c     nbarq3 = calcule dans utplco
c     nbarq5 = calcule dans utplco
c     nbpaho = mis a jour en 5.1
c     nbarin = calcule dans utplco
c     nbarma = non modifie
      nbarpe = permar
      nbarto = nouvar
cgn      write (ulsort,*) nbarac,nbarde,nbarpe,nbarto
c
c 4.3. commun "nombtr" --> triangles
c
      nbtrac = nvactr
      nbtrde = permtr - nbtrma
c     nbtrt2 = calcule dans utplco
c     nbtrq3 = calcule dans utplco
c     nbptho = mis a jour en 5.1
c     nbtrhc = calcule dans utplco
c     nbtrpc = calcule dans utplco
c     nbtrtc = calcule dans utplco
c     nbtrma = non modifie
      nbtrpe = permtr
      nbtrto = nouvtr
cgn      write (ulsort,*) nbtrac,nbtrde,nbtrpe,nbtrto
c
c 4.4. commun "nombqu" --> quadrangles
c
      nbquac = nvacqu
      nbqude = permqu - nbquma
c     nbquq2 = calcule dans utplco
c     nbquq5 = calcule dans utplco
      nbqupe = permqu
      nbquto = nouvqu
cgn      write (ulsort,*) nbquac,nbqude,nbqupe,nbquto
c
c 4.5. commun "nombte" --> tetraedres
c
      nbteac = nvacte
c     nbtea2 = calcule dans utplco
c     nbtea4 = calcule dans utplco
      nbtede = permte - nbtema
c     nbtef4 = calcule dans utplco
c     nbtema = non modifie
      nbtepe = permte
      nbteto = nouvte
      nbteca = provta
      nbtecf = nbteto - nbteca
cgn      write (ulsort,90002) 'nbteac,nbtepe,nbteto,nbtecf,nbteca',
cgn     >                      nbteac,nbtepe,nbteto,nbtecf,nbteca
c
c 4.6. commun "nombhe" --> hexaedres
c
      nbheac = nvache
      nbhede = permhe - nbhema
c     nbhema = non modifie
      nbhepe = permhe
      nbheto = nouvhe
      nbheca = provha
      nbhecf = nbheto - nbheca
cgn      write (ulsort,90002) 'nbheac,nbhepe,nbheto,nbhecf,nbheca',
cgn     >                      nbheac,nbhepe,nbheto,nbhecf,nbheca
c
c 4.7. commun "nombpy" --> pyramides
c
      nbpyac = nvacpy
c     nbpyma = non modifie
      nbpype = permpy
      nbpyto = nouvpy
      nbpyca = provya
      nbpycf = nbpyto - nbpyca
cgn      write (ulsort,90002) 'nbpyac,nbpype,nbpyto,nbpycf,nbpyca',
cgn     >                      nbpyac,nbpype,nbpyto,nbpycf,nbpyca
c
c 4.8. commun "nombpe" --> pentaedres
c
      nbpeac = nvacpe
      nbpede = permpe - nbpema
c     nbpema = non modifie
      nbpepe = permpe
      nbpeto = nouvpe
      nbpeto = nouvpe
      nbpeca = provpa
      nbpecf = nbpeto - nbpeca
cgn      write (ulsort,90002) 'nbpeac,nbpepe,nbpeto,nbpecf,nbpeca',
cgn     >                      nbpeac,nbpepe,nbpeto,nbpecf,nbpeca
c
c 4.9. ==> stockage
c
      call gmecat ( nhnoeu, 1 , nbnoto, codre1 )
      call gmecat ( nharet, 1 , nbarto, codre2 )
      call gmecat ( nhtria, 1 , nbtrto, codre3 )
      call gmecat ( nhquad, 1 , nbquto, codre4 )
      call gmecat ( nhtetr, 1 , nbteto, codre5 )
      call gmecat ( nhhexa, 1 , nbheto, codre6 )
      call gmecat ( nhpyra, 1 , nbpyto, codre7 )
      call gmecat ( nhpent, 1 , nbpeto, codre8 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7, codre8 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7, codre8 )
c
      call gmecat ( nhtetr, 2, nbteca, codre1 )
      call gmecat ( nhhexa, 2, nbheca, codre2 )
      call gmecat ( nhpyra, 2, nbpyca, codre3 )
      call gmecat ( nhpent, 2, nbpeca, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      endif
c
c====
c 5. determination des voisinages
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. voisinages ; codret', codret
#endif
c
c 5.1. ==> determination des faces voisines des aretes
c
      if ( codret.eq.0 ) then
c
      vofaar = 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTVGFA', nompro
#endif
c
      call utvgfa ( nhvois, nharet, nhtria, nhquad,
     >              vofaar,
     >              nbfaar, pposif, pfacar,
     >              ulsort, langue, codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      iaux = 2
      write (ulsort,texte(langue,3)) 'UTVERI_UTVGFA_apres', nompro
      call utveri ( 'adap    ', nomail, 'UTVGFA', iaux,
     >              ulsort, langue, codret )
      endif
#endif
c
c 5.2. ==> determination des volumes voisins des faces
c
      if ( codret.eq.0 ) then
c
      vovofa = 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTVGVF', nompro
#endif
c
      call utvgvf ( nhvois, nhtria, nhquad,
     >              nhtetr, nhhexa, nhpyra, nhpent,
     >              vovofa,
     >              ulsort, langue, codret)
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      iaux = 2
      write (ulsort,texte(langue,3)) 'UTVERI_UTVGVF_apres', nompro
      call utveri ( 'adap    ', nomail, 'UTVGVF', iaux,
     >              ulsort, langue, codret )
      endif
#endif
c
c====
c 6. mise a jour eventuelle pour les homologues
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. homologues ; codret', codret
#endif
c
      if ( homolo.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
c 6.1. ==> comptage des entites du maillage concernees par une
c          condition homologue et mise a jour des tables
c          provisoires de correspondance
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMHOMO', nompro
#endif
        call cmhomo (
     >           imem(adhono), imem(adhoar), imem(adhotr), imem(adhoqu),
     >           imem(psomar), imem(pfilar), imem(phetar), imem(pnp2ar),
     >           imem(paretr), imem(pfiltr), imem(phettr),
     >           imem(parequ), imem(pfilqu), imem(phetqu),
     >           ulsort, langue, codret )
c
        endif
c
      endif
c
c====
c 7. mise a jour eventuelle pour les non conformites
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. maj non-conformite ; codret', codret
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
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,texte(langue,3)) 'UTVERI_UTNC08_apres', nompro
      iaux = 2
      call utveri ( 'adap    ', nomail, 'UTNC08', iaux,
     >              ulsort, langue, codret )
      endif
#endif
c
      endif
c
c====
c 8. impressions
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '8. Impressions ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      write(ulsort,texte(langue,6)) nbnoto
      write(ulsort,texte(langue,7)) mess14(langue,3,1), nbarac
      if ( nbtrto.ne.0 ) then
        write(ulsort,texte(langue,7)) mess14(langue,3,2), nbtrac
      endif
      if ( nbquto.ne.0 ) then
        write(ulsort,texte(langue,7)) mess14(langue,3,4), nbquac
      endif
      if ( nbteto.ne.0 ) then
        write(ulsort,texte(langue,7)) mess14(langue,3,3), nbteac
      endif
      if ( nbheto.ne.0 ) then
        write(ulsort,texte(langue,7)) mess14(langue,3,6), nbheac
      endif
      if ( nbpyto.ne.0 ) then
        write(ulsort,texte(langue,7)) mess14(langue,3,5), nbpyac
      endif
      if ( nbpeto.ne.0 ) then
        write(ulsort,texte(langue,7)) mess14(langue,3,7), nbpeac
      endif
      if ( nbtrto.ne.0 .or. nbquto.ne.0 ) then
        if ( nbquto.eq.0 ) then
          saux14 = mess14(langue,3,2)
        elseif ( nbtrto.eq.0 ) then
          saux14 = mess14(langue,3,4)
        else
          saux14 = mess14(langue,3,8)
        endif
        iaux = mod(niincf,10)
        if ( iaux.ne.0 ) then
          if ( nivinf.le.((niincf-5)/10) ) then
            iaux = 0
          endif
        endif
        if ( iaux.eq.0 ) then
          write (ulsort,texte(langue,8)) saux14, nivinf
        else
          write (ulsort,texte(langue,9)) saux14, (niincf-5)/10
        endif
        iaux = mod(nisucf,10)
        if ( iaux.eq.0 ) then
          write (ulsort,texte(langue,10)) saux14, nivsup
        else
          write (ulsort,texte(langue,11)) saux14, (nisucf-5)/10
        endif
      endif
c
      endif
c
c====
c 9. la fin
c====
c
c 9.1. ==> message si erreur
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
c 9.2. ==> fin des mesures de temps de la section
c
      call gtfims (nrosec)
c
c=======================================================================
      endif
c=======================================================================
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
