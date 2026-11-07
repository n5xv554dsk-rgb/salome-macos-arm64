      subroutine mmagre ( lgopti, taopti, lgetco, taetco,
     >                    nomail,
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
c  Modification de Maillage - AGREgat
c  -               -          ----
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lgopti . e   .   1    . longueur du tableau des options entieres   .
c . taopti . e   . lgopti . tableau des options entieres               .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
c . nomail . e   . char8  . nom de l'objet maillage homard iter. n     .
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
      parameter ( nompro = 'MMAGRE' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
c
#include "impr02.h"
c
#include "envca1.h"
#include "envada.h"
c
#include "nbfami.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombte.h"
#include "nombqu.h"
#include "nombpe.h"
#include "nombhe.h"
c
c 0.3. ==> arguments
c
      integer lgopti
      integer taopti(lgopti)
c
      integer ulsort, langue, codret
      integer lgetco
      integer taetco(lgetco)
c
      character*8 nomail
c
c 0.4. ==> variables locales
c
      integer nrosec
      integer iaux, jaux
      integer nretap, nrsset
      integer codre1, codre2, codre3, codre4, codre5
      integer codre6
      integer codre0
c
      integer nuroul, lnomfl
      integer degre0
      integer nbnotn, nbartn, nbtrtn, nbqutn, nbtetn, nbpetn, nbhetn
      integer pcoono, phetno, pareno, pderno
      integer ppovos, pvoiso
      integer pposif, pfacar
      integer phetar, pfilar, pmerar, psomar
      integer phettr, pfiltr, ppertr, pnivtr, paretr
      integer phetqu, pfilqu, pperqu, pnivqu, parequ
      integer phette, ptrite, pcotrt, pfilte, pperte
      integer pquahe, pcoquh, phethe, pfilhe, pperhe
      integer pfacpe, pcofap, phetpe, pfilpe, pperpe
      integer pfamno
      integer pfamar
      integer pfamtr
      integer pfamqu
      integer pfamte, pcfate
      integer pfampe, pcfape
      integer pfamhe, pcfahe
      integer advotr, advoqu
      integer lgpptr, lgppqu, adpptr, adppqu
      integer ptrav1, ptrav2, ptrav3, ptrav4
      integer ptra30, ptra40, ptra31, ptra41
      integer ptra51, ptra52, ptra53
      integer ptraat, ptrant
      integer ptraaa, ptrana
      integer ptraan, ptrann
      integer nbduno, nbduar, nbdutr
      integer nbjois, nbpejs
      integer nbjoit, nbpejt, nbtrjt
      integer nbjoiq, nbhejq, nbqujq
      integer nbjp06, nbte06
      integer nbjp09, nbpe09
      integer nbjp12, nbhe12
      integer nbvojm, nbjoto
      integer voarno, vofaar, vovoar, vovofa
      integer ptra17, ptra18
      integer ptraw1, ptraw2, ptraw6
      integer nbgrfm, nbfmed, ngrouc
      integer adnumf
      integer adpoin, adtail, adtabl
c
      character*6 saux
      character*8 action
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
      character*8 ntrav1, ntrav2, ntrav3, ntrav4
      character*8 ntra30, ntra40, ntra31, ntra41
      character*8 ntra51, ntra52, ntra53
      character*8 ntraat, ntrant
      character*8 ntraaa, ntrana
      character*8 ntraan, ntrann
      character*8 ntra17, ntra18
      character*8 ntraw1, ntraw2, ntraw6
      character*200 nomflo
c
      double precision shrink
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
      texte(1,4) = '(/,a6,'' MAILLES DE JOINTS'')'
      texte(1,5) = '(24(''=''),/)'
      texte(1,7) = '(5x,''Nombre de '',a,'' a creer     :'',i8)'
      texte(1,8) = '(5x,''Nombre de '',a,'' a dupliquer :'',i8)'
c
      texte(2,4) = '(/,a6,'' MESHES FOR THE JUNCTIONS'')'
      texte(2,5) = '(31(''=''),/)'
      texte(2,7) = '(5x,''Number of '',a,'' to create    :'',i8)'
      texte(2,8) = '(5x,''Number of '',a,'' to duplicate :'',i8)'
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
c 1.5 ==> le titre
c
      write (ulsort,texte(langue,4)) saux
      write (ulsort,texte(langue,5))
c
c====
c 1.bis. fichier de sortie du bilan
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '1.bis. fichier bilan codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTULBI', nompro
#endif
      action = 'modi    '
      iaux = 1
      jaux = -1
      call utulbi ( nuroul, nomflo, lnomfl,
     >                iaux, action, nbiter, jaux,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 2. conversion eventuelle en degre 1
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. conversion  en degre 1 ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmliat ( nomail, 3, degre0 , codret )
c
      endif
c
      if ( degre0.eq.2 ) then
        call gtdems (60)
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'mmdeg0', nompro
#endif
c
        call mmdeg0 ( nomail,
     >                ulsort, langue, codret )
c
        endif
c
        call gtfims (60)
      endif
c
c====
c 3. structure generale
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. structure generale ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMH', nompro
#endif
c
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
c 3.2. ==> Tableaux
c
      if ( codret.eq.0 ) then
c
      iaux = 210
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_ar', nompro
#endif
      call utad02 (   iaux, nharet,
     >              phetar, psomar, pfilar, pmerar,
     >              pfamar,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      iaux = 2310
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_tr', nompro
#endif
      call utad02 (   iaux, nhtria,
     >              phettr, paretr, pfiltr, ppertr,
     >              pfamtr,   jaux,   jaux,
     >              pnivtr,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      iaux = 6734
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_te', nompro
#endif
      call utad02 (   iaux, nhtetr,
     >              phette, ptrite,  jaux, jaux,
     >              pfamte, pcfate,   jaux,
     >                jaux, pcotrt,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      endif
c
c 3.3. ==> les voisinages
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD04', nompro
#endif
      iaux = 15
      call utad04 ( iaux, nhvois,
     >                jaux,   jaux, pposif, pfacar,
     >              advotr, advoqu,
     >              lgpptr, lgppqu, adpptr, adppqu,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      iaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTVGAN', nompro
#endif
      call utvgan ( nhvois, nhnoeu, nharet,
     >              iaux,
     >              ppovos, pvoiso,
     >              ulsort, langue, codret)
c
      endif
c
c====
c 4. Verification
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. Verification ; codret = ', codret
#endif
c
c 4.1. ==> Caracteristiques des groupes dans les familles MED
ccc      call gmprsx (nompro,nhsupe//'.Tab5')
ccc      call gmprsx (nompro,nhsupe//'.Tab6')
ccc      call gmprsx (nompro,nhsupe//'.Tab9')
ccc      call gmprsx (nompro,nhsups//'.Tab2')
c
      if ( codret.eq.0 ) then
c
      call gmliat ( nhsupe, 9, nbfmed, codre1 )
      call gmadoj ( nhsupe//'.Tab9', adnumf, iaux, codre2 )
      call gmadoj ( nhsupe//'.Tab5', adpoin, iaux, codre3 )
      call gmadoj ( nhsupe//'.Tab6', adtail, iaux, codre4 )
      call gmadoj ( nhsups//'.Tab2', adtabl, iaux, codre5 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5 )
c
      endif
c
c====
c 5. Verification du maillage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5. Verification ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMAGVE', nompro
#endif
      call mmagve ( imem(pfamte), imem(pcfate),
     >              nbfmed, imem(adnumf),
     >              imem(adpoin), imem(adtail), smem(adtabl),
     >              ulsort, langue, codret )
c
      endif
c
c====
c 6. Decompte des familles et des pentaedres a creer
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '6. Decompte ; codret = ', codret
#endif
c
c 6.1. ==> allocation des tableaux
c
      if ( codret.eq.0 ) then
c
      iaux = 4*nbtrto
      call gmalot ( ntrav1, 'entier  ', iaux, ptrav1, codre1 )
      iaux = 4*2*nbftet**2
cgn      print *,iaux/4
      call gmalot ( ntrav2, 'entier  ', iaux, ptrav2, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c 6.2. ==> Decompte associe aux joints simples
c
      if ( codret.eq.0 ) then
      call gtdems (61)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMAGR0', nompro
#endif
      call mmagr0 ( imem(advotr),
     >              imem(pfamte), imem(pcfate),
     >              imem(ptrav1), imem(ptrav2),
     >              nbjois, nbpejs,
     >              ulsort, langue, codret )
      call gtfims (61)
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( nbjois.eq.0 ) then
        goto 1800
      endif
c
      endif
c
c 6.3. ==> Tableaux
c
      if ( codret.eq.0 ) then
c
      iaux = 4
      call gmmod ( ntrav1, ptrav1,
     >             iaux, iaux, nbtrto, nbpejs, codre0 )
c
      codret = max ( abs(codre0), codret )
c
      iaux = 8*3*nbpejs
      call gmalot ( ntra30, 'entier  ', iaux, ptra30, codre1 )
      iaux = 6*3*nbpejs
      call gmalot ( ntra40, 'entier  ', iaux, ptra40, codre2 )
      iaux = 2*3*nbpejs
      call gmalot ( ntra31, 'entier  ', iaux, ptra31, codre3 )
      iaux = 4*3*nbpejs
      call gmalot ( ntra41, 'entier  ', iaux, ptra41, codre4 )
      iaux = 4*3*nbpejs
      call gmalot ( ntrav3, 'entier  ', iaux, ptrav3, codre5 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5 )
cgn      call gmprsx ( nompro//' apres MMAGR0, ntrav1 :', ntrav1 )
c
      endif
c
c 6.4. ==> Decompte des noeuds, aretes, quadrangles a creer/dupliquer
c          et des familles deduites
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMAG10', nompro
#endif
      call mmag10 ( imem(psomar),
     >              imem(paretr),
     >              imem(ptrite), imem(pcotrt),
     >              nbjois, nbpejs, imem(ptrav1), imem(ptrav2),
     >              imem(ptra30), imem(ptra40),
     >              imem(ptra31), imem(ptra41),
     >              nbduno, nbduar, nbdutr,
     >              nbnotn, nbartn, nbtrtn, nbqutn,
     >              nbtetn, nbpetn, nbhetn,
     >              nbjoit, nbpejt, nbtrjt,
     >              nbjoiq, nbhejq, nbqujq,
     >              nbjp06, nbte06,
     >              nbjp09, nbpe09,
     >              nbjp12, nbhe12,
     >              nbvojm,
     >              imem(ptrav3),
     >              ntra51, ptra51, ntra52, ptra52,
     >              ntra53, ptra53,
     >              ulsort, langue, codret )
c
cgn           call gmprsx(nompro//' apres MMAG10, ntra51 :',ntra51)
cgn           call gmprsx(nompro//' apres MMAG10, ntra52 :',ntra52)
cgn           call gmprsx(nompro//' apres MMAG10, ntra53 :',ntra53)
c
      endif
c
      if ( codret.eq.0 ) then
c
      nbjoto = nbjois + nbjoit + nbjoiq + nbjp06 + nbjp09 + nbjp12
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) mess14(langue,3,-1), nbduno
      write (ulsort,texte(langue,7)) mess14(langue,3,1), nbduno
      write (ulsort,texte(langue,8)) mess14(langue,3,1), nbduar
      write (ulsort,texte(langue,8)) mess14(langue,3,2), nbdutr
      write (ulsort,texte(langue,7)) mess14(langue,3,2), nbtrjt
      write (ulsort,texte(langue,7)) mess14(langue,3,4), nbqutn
      write (ulsort,texte(langue,7)) mess14(langue,3,3), nbtetn
      write (ulsort,texte(langue,7)) mess14(langue,3,7), nbpetn
      write (ulsort,texte(langue,7)) mess14(langue,3,6), nbhetn
#endif
c
      endif
c
c 6.5. ==> On raccourcit en fonction de ce qui a ete compte
c
      if ( codret.eq.0 ) then
c
      iaux = 4
      jaux = 2*nbftet**2
      call gmmod ( ntrav2, ptrav2,
     >             iaux, iaux, jaux, nbjoto, codre1 )
      iaux = 8
      jaux = 3*nbpejs
      call gmmod ( ntra30, ptra30,
     >             iaux, iaux, jaux, nbduno, codre2 )
      iaux = 6
      jaux = 3*nbpejs
      call gmmod ( ntra40, ptra40,
     >             iaux, iaux, jaux, nbduar, codre3 )
      iaux = 2
      jaux = 3*nbpejs
      call gmmod ( ntra31, ptra31,
     >             iaux, iaux, jaux, nbtrjt, codre4 )
      iaux = 4
      jaux = 3*nbpejs
      call gmmod ( ntra41, ptra41,
     >             iaux, iaux, jaux, nbvojm, codre5 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5 )
cgn      call gmprsx ( nompro, ntrav2 )
cgn      call gmprsx ( nompro, ntrav2 )
cgn      call gmprsx ( nompro, ntra31 )
cgn      call gmprsx ( nompro, ntra41 )
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav3 , codret )
c
      endif
c
c====
c 7. Reallocation des tableaux du maillage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '7. Reallocation ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gtdems (64)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMAGR2', nompro
#endif
      call mmagr2 ( nbnotn, nbartn, nbtrtn, nbqutn,
     >              nbtetn, nbpetn, nbhetn,
     >              nhnoeu, nharet, nhtria, nhquad,
     >              nhtetr, nhpent, nhhexa,
     >              phetno, pcoono, pareno, pderno,
     >              phetar, psomar, pfilar, pmerar,
     >              phettr, paretr, pfiltr, ppertr, pnivtr,
     >              phetqu, parequ, pfilqu, pperqu, pnivqu,
     >              phette, ptrite, pfilte, pperte, pcotrt,
     >              phetpe, pfacpe, pfilpe, pperpe, pcofap,
     >              phethe, pquahe, pfilhe, pperhe, pcoquh,
     >              pfamno, pfamar, pfamtr, pfamqu,
     >              pfamte, pfampe, pfamhe,
     >              ulsort, langue, codret )
c
      call gtfims (64)
c
      endif
c
c====
c 8. Creation des noeuds, aretes, triangles, quadrangles, pentaedres,
c    hexaedres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '8. Creation ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMAG30', nompro
#endif
c
      call mmag30 ( nbduno, nbduar, nbdutr,
     >              nbpejs,
     >              nbpejt, nbtrjt, nbhejq, nbqujq,
     >              nbte06, nbpe09, nbhe12,
     >              nbvojm,
     >              nbjoto, nbjois, nbjoit, nbjoiq,
     >              nbjp06, nbjp09, nbjp12,
     >              imem(ptrav1), imem(ptrav2),
     >              imem(ptra30), imem(ptra40),
     >              imem(ptra41),
     >              imem(ptra51), imem(ptra52), imem(ptra53),
     >              rmem(pcoono), imem(phetno), imem(pareno),
     >              imem(psomar), imem(phetar),
     >              imem(pfilar), imem(pmerar),
     >              imem(paretr), imem(phettr),
     >              imem(pfiltr), imem(ppertr), imem(pnivtr),
     >              imem(parequ), imem(phetqu),
     >              imem(pfilqu), imem(pperqu), imem(pnivqu),
     >              imem(ptrite), imem(pcotrt),
     >              imem(phette), imem(pfilte), imem(pperte),
     >              imem(pfacpe), imem(pcofap),
     >              imem(phetpe), imem(pfilpe), imem(pperpe),
     >              imem(pquahe), imem(pcoquh),
     >              imem(phethe), imem(pfilhe), imem(pperhe),
     >              imem(pfamno), imem(pfamar),
     >              imem(pfamtr), imem(pfamqu),
     >              imem(pfamte), imem(pfampe), imem(pfamhe),
     >              ulsort, langue, codret )
cgn           call gmprsx(nompro//' apres MMAG30, ntra52 :',ntra52)
cgn        write (ulsort,*) mess14(langue,2,-1)
cgn        call gmprsx(nompro,nhnoeu)
cgn        call gmprsx(nompro,nhnoeu//'.Coor')
cgn        call gmprsx(nompro,nhnoeu//'.AretSupp')
cgn        call gmprsx(nompro,nhnoeu//'.Famille.EntiFamm')
cgn        write (ulsort,*) mess14(langue,2,1)
cgn        call gmprsx(nompro,nharet)
cgn        call gmprsx(nompro,nharet//'.ConnDesc')
cgn        call gmprsx(nompro,nharet//'.Famille.EntiFamm')
cgn        write (ulsort,*) mess14(langue,2,2)
cgn        call gmprsx(nompro,nhtria)
cgn        call gmprsx(nompro,nhtria//'.ConnDesc')
cgn        call gmprsx(nompro,nhtria//'.HistEtat')
cgn        call gmprsx(nompro,nhtria//'.Niveau')
cgn        call gmprsx(nompro,nhtria//'.Fille')
cgn        call gmprsx(nompro,nhtria//'.Mere')
cgn        call gmprsx(nompro,nhtria//'.Famille.EntiFamm')
cgn        write (ulsort,*) mess14(langue,2,4)
cgn        call gmprsx(nompro,nhquad)
cgn        call gmprsx(nompro,nhquad//'.ConnDesc')
cgn        call gmprsx(nompro,nhquad//'.HistEtat')
cgn        call gmprsx(nompro,nhquad//'.Niveau')
cgn        call gmprsx(nompro,nhquad//'.Fille')
cgn        call gmprsx(nompro,nhquad//'.Mere')
cgn        call gmprsx(nompro,nhquad//'.Famille')
cgn        call gmprsx(nompro,nhquad//'.Famille.EntiFamm')
cgn        write (ulsort,*) mess14(langue,2,3)
cgn        call gmprsx(nompro,nhtetr)
cgn        call gmprsx(nompro,nhtetr//'.ConnDesc')
cgn        call gmprsx(nompro,nhtetr//'.HistEtat')
cgn        call gmprsx(nompro,nhtetr//'.InfoSupp')
cgn        call gmprsx(nompro,nhtetr//'.Fille')
cgn        call gmprsx(nompro,nhtetr//'.Mere')
cgn        call gmprsx(nompro,nhtetr//'.Famille')
cgn        call gmprsx(nompro,nhtetr//'.Famille.EntiFamm')
cgn        write (ulsort,*) mess14(langue,2,6)
cgn        call gmprsx(nompro,nhhexa)
cgn        call gmprsx(nompro,nhhexa//'.ConnDesc')
cgn        call gmprsx(nompro,nhhexa//'.HistEtat')
cgn        call gmprsx(nompro,nhhexa//'.InfoSupp')
cgn        call gmprsx(nompro,nhhexa//'.Fille')
cgn        call gmprsx(nompro,nhhexa//'.Mere')
cgn        call gmprsx(nompro,nhhexa//'.Famille')
cgn        call gmprsx(nompro,nhhexa//'.Famille.EntiFamm')
cgn        write (ulsort,*) mess14(langue,2,7)
cgn        call gmprsx(nompro,nhpent)
cgn        call gmprsx(nompro,nhpent//'.ConnDesc')
cgn        call gmprsx(nompro,nhpent//'.HistEtat')
cgn        call gmprsx(nompro,nhpent//'.InfoSupp')
cgn        call gmprsx(nompro,nhpent//'.Fille')
cgn        call gmprsx(nompro,nhpent//'.Mere')
cgn        call gmprsx(nompro,nhpent//'.Famille')
cgn        call gmprsx(nompro,nhpent//'.Famille.EntiFamm')
c
      endif
c
c====
c 9. Modification eventuelle des coordonnees
c      0 : aucune
c      1 : mod_joint_qt_d1
c      2 : mod_joint_qua2_d1
c      3 : mod_joint_qua_d1
c      4 : mod_joint_tri_d1
c      5 : mod_joint_tri_d2
c     -1 : automatique
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '9. Modif coordonnees ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 0
      shrink = 0.95d0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMAGCO', nompro
#endif
      call mmagco ( iaux, shrink,
     >              rmem(pcoono),
     >              imem(psomar),
     >              nbduno, imem(ptra30),
     >              ulsort, langue, codret )
c
      endif
c
c====
c 10. Creation des familles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '10. Creation familles ; codret = ', codret
#endif
c
c 10.1. ==> Les utilitaires
c
      if ( codret.eq.0 ) then
c
      call gmalot ( ntraw1, 'entier  ', nbjoto, ptraw1, codre1 )
      call gmalot ( ntraw2, 'entier  ', nbjoto, ptraw2, codre2 )
      call gmalot ( ntraw6, 'reel    ', nbjoto, ptraw6, codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
      endif
c
c 10.2. ==> Creation effective
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMAGF0', nompro
#endif
      call mmagf0 ( nbjoto, nbjois, nbjoit, nbjoiq,
     >              nbjp06, nbjp09, nbjp12,
     >              nhnoeu, nhmapo, nharet, nhtria, nhquad,
     >              nhtetr, nhhexa, nhpyra, nhpent,
     >              nhsupe, nhsups,
     >              ulsort, langue, codret )
cgn        write (ulsort,*) mess14(langue,2,2)
cgn        call gmprsx(nompro,nhtria//'.Famille.Codes')
cgn        write (ulsort,*) mess14(langue,2,4)
cgn        call gmprsx(nompro,nhquad//'.Famille.Codes')
cgn        write (ulsort,*) mess14(langue,2,3)
cgn        call gmprsx(nompro,nhtetr//'.Famille.Codes')
cgn        write (ulsort,*) mess14(langue,2,6)
cgn        call gmprsx(nompro,nhhexa//'.Famille.Codes')
cgn        write (ulsort,*) mess14(langue,2,7)
cgn        call gmprsx(nompro,nhpent//'.Famille.Codes')
c
      endif
c
c 10.3. ==> Reactualisation
c
      if ( codret.eq.0 ) then
c
      iaux = 259
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_te', nompro
#endif
      call utad02 (   iaux, nhtetr,
     >                jaux,   jaux,  jaux, jaux,
     >              pfamte, pcfate,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 11. Reperage des grains
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '11. Reperage des grains ; codret = ', codret
#endif
c 11.1. ==> Les utilitaires
c
      if ( codret.eq.0 ) then
c
      call gmalot ( ntrav3, 'entier  ', nbarto, ptrav3, codre1 )
      call gmalot ( ntrav4, 'entier  ', nbtrto, ptrav4, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c 11.2. ==> Reperage des grains
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '11.2. Grains ; codret = ', codret
#endif

      if ( codret.eq.0 ) then
c
      call gtdems (76)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMAGR4', nompro
#endif
c
      call mmagr4 ( nbte06, imem(ptrav3), imem(ptrav4),
     >              imem(paretr),
     >              imem(ptrite), imem(pcotrt),
     >              imem(pfamte), imem(pcfate),
     >              ulsort, langue, codret )
cc              goto 5555
c
cgn      call gmprsx ( nompro, ntrav3 )
cgn      call gmprsx ( nompro, ntrav4 )
c
      call gtfims (76)
c
      endif
c
c 11.3. ==> Repercussion dans les connectivites
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '11.3. Repercussion ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gtdems (77)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMAGR5', nompro
#endif
      call mmagr5 ( nbduno, nbduar, nbdutr, nbtrjt,
     >              nbpejs, nbjoto,
     >              imem(ptrav1), imem(ptrav2),
     >              imem(ptra30), imem(ptra40),
     >              imem(ptrav3), imem(ptrav4),
     >              imem(psomar),
     >              imem(paretr),
     >              imem(ptrite), imem(pfamte), imem(pcfate),
     >              imem(ppovos), imem(pvoiso),
     >              imem(pposif), imem(pfacar),
     >              imem(advotr),
     >              ulsort, langue, codret )
c
      call gtfims (77)
c
cgn        write (ulsort,*) mess14(langue,2,-1)
cgn        call gmprsx(nompro,nhnoeu)
cgn        call gmprsx(nompro,nhnoeu//'.Coor')
cgn        call gmprsx(nompro,nhnoeu//'.HistEtat')
cgn        call gmprsx(nompro,nhnoeu//'.AretSupp')
cgn        call gmprsx(nompro,nhnoeu//'.Famille.EntiFamm')
cgn        write (ulsort,*) mess14(langue,2,1)
cgn        call gmprsx(nompro,nharet)
cgn        call gmprsx(nompro,nharet//'.ConnDesc')
cgn        call gmprsx(nompro,nharet//'.Fille')
cgn        call gmprsx(nompro,nharet//'.Mere')
cgn        call gmprsx(nompro,nharet//'.Famille.EntiFamm')
cgn        write (ulsort,*) mess14(langue,2,2)
cgn        call gmprsx(nompro,nhtria)
cgn        call gmprsx(nompro,nhtria//'.ConnDesc')
cgn        call gmprsx(nompro,nhtria//'.HistEtat')
cgn        call gmprsx(nompro,nhtria//'.Niveau')
cgn        call gmprsx(nompro,nhtria//'.Fille')
cgn        call gmprsx(nompro,nhtria//'.Mere')
cgn        call gmprsx(nompro,nhtria//'.Famille.EntiFamm')
cgn        write (ulsort,*) mess14(langue,2,4)
cgn        call gmprsx(nompro,nhquad)
cgn        call gmprsx(nompro,nhquad//'.ConnDesc')
cgn        call gmprsx(nompro,nhquad//'.HistEtat')
cgn        call gmprsx(nompro,nhquad//'.Niveau')
cgn        call gmprsx(nompro,nhquad//'.Fille')
cgn        call gmprsx(nompro,nhquad//'.Mere')
cgn        call gmprsx(nompro,nhquad//'.Famille')
cgn        call gmprsx(nompro,nhquad//'.Famille.EntiFamm')
cgn        write (ulsort,*) mess14(langue,2,3)
cgn        call gmprsx(nompro,nhtetr)
cgn        call gmprsx(nompro,nhtetr//'.ConnDesc')
cgn        call gmprsx(nompro,nhtetr//'.HistEtat')
cgn        call gmprsx(nompro,nhtetr//'.InfoSupp')
cgn        call gmprsx(nompro,nhtetr//'.Fille')
cgn        call gmprsx(nompro,nhtetr//'.Mere')
cgn        call gmprsx(nompro,nhtetr//'.Famille')
cgn        call gmprsx(nompro,nhtetr//'.Famille.EntiFamm')
cgn        write (ulsort,*) mess14(langue,2,7)
cgn        call gmprsx(nompro,nhpent)
cgn        call gmprsx(nompro,nhpent//'.ConnDesc')
cgn        call gmprsx(nompro,nhpent//'.HistEtat')
cgn        call gmprsx(nompro,nhpent//'.InfoSupp')
cgn        call gmprsx(nompro,nhpent//'.Fille')
cgn        call gmprsx(nompro,nhpent//'.Mere')
cgn        call gmprsx(nompro,nhpent//'.Famille')
cgn        call gmprsx(nompro,nhpent//'.Famille.EntiFamm')
      endif
c
c====
c 12. Taille des joints
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '12. Taille des joints ; codret = ', codret
#endif
c 12.1. ==> Les donnees
c
      if ( codret.eq.0 ) then
c
      iaux = 259
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_te', nompro
#endif
      call utad02 (   iaux, nhtetr,
     >                jaux,   jaux,  jaux, jaux,
     >              pfamte, pcfate,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      iaux = 259
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_pe', nompro
#endif
      call utad02 (   iaux, nhpent,
     >                jaux,   jaux,  jaux, jaux,
     >              pfampe, pcfape,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      iaux = 259
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_he', nompro
#endif
      call utad02 (   iaux, nhhexa,
     >                jaux,   jaux,  jaux, jaux,
     >              pfamhe, pcfahe,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmliat ( nhsupe, 6, iaux, codre1 )
      call gmliat ( nhsupe, 9, nbfmed, codre2 )
      call gmadoj ( nhsupe//'.Tab9', adnumf, iaux, codre3 )
      call gmadoj ( nhsupe//'.Tab5', adpoin, iaux, codre4 )
      call gmadoj ( nhsupe//'.Tab6', adtail, iaux, codre5 )
      call gmadoj ( nhsups//'.Tab2', adtabl, iaux, codre6 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6 )
c
       ngrouc = iaux/10
c
      endif
c
      if ( codret.eq.0 ) then
c
      iaux = 10*ngrouc
      call gmalot ( ntra17, 'chaine  ', iaux, ptra17, codre1 )
      iaux = ngrouc + nbfmed
      call gmalot ( ntra18, 'entier  ', iaux, ptra18, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c 12.2. ==> Liste des noms des groupes
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTFMLG', nompro
#endif
      call utfmlg ( nbfmed, ngrouc,
     >              imem(adpoin), imem(adtail), smem(adtabl),
     >              nbgrfm, smem(ptra17), imem(ptra18),
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'nbgrfm', nbgrfm
      call gmprsx ( nompro, ntra17 )
      call gmprsx ( nompro, ntra18 )
#endif
c
      endif
c
c 12.3. ==> Affichage
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMAG40', nompro
#endif
c
      call mmag40 ( nbpejs, nbpejt, nbhejq,
     >              nbvojm, nbjoto,
     >              nbjois, nbjoit, nbjoiq,
     >              imem(ptrav1), imem(ptra41),
     >              rmem(pcoono), imem(psomar), imem(paretr),
     >              imem(pfamhe), imem(pcfahe),
     >              imem(pfampe), imem(pcfape),
     >              nbfmed, imem(adnumf),
     >              imem(adpoin), imem(adtail), smem(adtabl),
     >              nbgrfm, smem(ptra17), imem(ptra18),
     >              imem(ptraw1), rmem(ptraw6),
     >              imem(ptraw2),
     >              nuroul,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 13. Suppression des entites dupliquees
c====
c 13.1. ==> Tableaux de travail
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '13.1. Tab de travail ; codret = ', codret
#endif
      call gtdems (78)
c
      if ( codret.eq.0 ) then
      call gmlboj ( ntrav2 , codret )
      endif
c
      if ( codret.eq.0 ) then
      call gmalot ( ntrav2, 'entier  ', nbnoto, ptrav2, codret )
      endif
c
      if ( codret.eq.0 ) then
c
      call gmalot ( ntraat, 'entier  ', nbtrto, ptraat, codre1 )
      iaux = nbtrto+1
      call gmalot ( ntrant, 'entier  ', iaux, ptrant, codre2 )
      call gmalot ( ntraaa, 'entier  ', nbarto, ptraaa, codre3 )
      iaux = nbarto+1
      call gmalot ( ntrana, 'entier  ', iaux, ptrana, codre4 )
      call gmalot ( ntraan, 'entier  ', nbnoto, ptraan, codre5 )
      iaux = nbnoto+1
      call gmalot ( ntrann, 'entier  ', iaux, ptrann, codre6 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6 )
c
      endif
c
c 13.2. ==> Nettoyage de la structure des voisins
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '13.2. Voisins ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
      call gmlboj ( nhvois, codret )
      endif
      if ( codret.eq.0 ) then
      call gmaloj ( nomail//'.Voisins' , ' ', 0, iaux, codret )
      endif
      if ( codret.eq.0 ) then
      call gmnomc ( nomail//'.Voisins' , nhvois, codret )
      endif
c
c 13.3. ==> Suppression effective
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '13.3. suppression ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMAGR6', nompro
#endif
      call mmagr6 ( nbduno, nbduar, nbdutr,
     >              imem(ptrav1), imem(ptra30), imem(ptra40),
     >              imem(ptrav2), imem(ptrav3), imem(ptrav4),
     >              rmem(pcoono), imem(pfamno),
     >              imem(psomar), imem(pfamar),
     >              imem(paretr), imem(pfamtr),
     >              imem(parequ),
     >              imem(ptrite), imem(pfacpe),
     >              imem(ptraat), imem(ptrant),
     >              imem(ptraaa), imem(ptrana),
     >              imem(ptraan), imem(ptrann),
     >              nbtrtn, nbartn, nbnotn,
     >              ulsort, langue, codret )
c
      endif
      call gtfims (78)
c
c====
c 14. Reallocation des tableaux du maillage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '14. Reallocation ; codret = ', codret
#endif
      call gtdems (64)
c
c 14.1. ==> Reallocation
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMAGR2', nompro
#endif
c
      if ( codret.eq.0 ) then
c
      nbqutn = -1
      nbpetn = -1
      call mmagr2 ( nbnotn, nbartn, nbtrtn, nbqutn,
     >              nbtetn, nbpetn, nbhetn,
     >              nhnoeu, nharet, nhtria, nhquad,
     >              nhtetr, nhpent, nhhexa,
     >              phetno, pcoono, pareno, pderno,
     >              phetar, psomar, pfilar, pmerar,
     >              phettr, paretr, pfiltr, ppertr, pnivtr,
     >              phetqu, parequ, pfilqu, pperqu, pnivqu,
     >              phette, ptrite, pfilte, pperte, pcotrt,
     >              phetpe, pfacpe, pfilpe, pperpe, pcofap,
     >              phethe, pquahe, pfilhe, pperhe, pcoquh,
     >              pfamno, pfamar, pfamtr, pfamqu,
     >              pfamte, pfampe, pfamhe,
     >              ulsort, langue, codret )
c
      endif
c
c 14.2. ==> Mise a jour
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '14.2. Mise a jour ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      nbnoma = nbnoto
      nbnop1 = nbnoto
      numap1 = nbnoto
      nbarac = nbarto
      nbarma = nbarto
      nbarpe = nbarto
      nbtrac = nbtrto
      nbtrma = nbtrto
      nbtrpe = nbtrto
      nbquac = nbquto
      nbquma = nbquto
      nbqupe = nbquto
      nbteac = nbteto
      nbtema = nbteto
      nbtepe = nbteto
      nbpeac = nbpeto
      nbpema = nbpeto
      nbpepe = nbpeto
      nbheac = nbheto
      nbhema = nbheto
      nbhepe = nbheto
c
      endif
      call gtfims (64)
cgn        write (ulsort,*) mess14(langue,2,-1)
cgn        call gmprsx(nompro,nhnoeu)
cgn        call gmprsx(nompro,nhnoeu//'.Coor')
cgn        call gmprsx(nompro,nhnoeu//'.HistEtat')
cgn        call gmprsx(nompro,nhnoeu//'.AretSupp')
cgn        call gmprsx(nompro,nhnoeu//'.Famille.EntiFamm')
cgn        write (ulsort,*) mess14(langue,2,1)
cgn        call gmprsx(nompro,nharet)
cgn        call gmprsx(nompro,nharet//'.ConnDesc')
cgn        call gmprsx(nompro,nharet//'.Fille')
cgn        call gmprsx(nompro,nharet//'.Mere')
cgn        call gmprsx(nompro,nharet//'.Famille.EntiFamm')
cgn        write (ulsort,*) mess14(langue,2,2)
cgn        call gmprsx(nompro,nhtria)
cgn        call gmprsx(nompro,nhtria//'.ConnDesc')
cgn        call gmprsx(nompro,nhtria//'.HistEtat')
cgn        call gmprsx(nompro,nhtria//'.Niveau')
cgn        call gmprsx(nompro,nhtria//'.Fille')
cgn        call gmprsx(nompro,nhtria//'.Mere')
cgn        call gmprsx(nompro,nhtria//'.Famille.EntiFamm')
cgn        write (ulsort,*) mess14(langue,2,4)
cgn        call gmprsx(nompro,nhquad)
cgn        call gmprsx(nompro,nhquad//'.ConnDesc')
cgn        call gmprsx(nompro,nhquad//'.HistEtat')
cgn        call gmprsx(nompro,nhquad//'.Niveau')
cgn        call gmprsx(nompro,nhquad//'.Fille')
cgn        call gmprsx(nompro,nhquad//'.Mere')
cgn        call gmprsx(nompro,nhquad//'.Famille')
cgn        call gmprsx(nompro,nhquad//'.Famille.EntiFamm')
cgn        write (ulsort,*) mess14(langue,2,3)
cgn        call gmprsx(nompro,nhtetr)
cgn        call gmprsx(nompro,nhtetr//'.ConnDesc')
cgn        call gmprsx(nompro,nhtetr//'.HistEtat')
cgn        call gmprsx(nompro,nhtetr//'.InfoSupp')
cgn        call gmprsx(nompro,nhtetr//'.Fille')
cgn        call gmprsx(nompro,nhtetr//'.Mere')
cgn        call gmprsx(nompro,nhtetr//'.Famille')
cgn        call gmprsx(nompro,nhtetr//'.Famille.EntiFamm')
cgn        write (ulsort,*) mess14(langue,2,7)
cgn        call gmprsx(nompro,nhpent)
cgn        call gmprsx(nompro,nhpent//'.ConnDesc')
cgn        call gmprsx(nompro,nhpent//'.HistEtat')
cgn        call gmprsx(nompro,nhpent//'.InfoSupp')
cgn        call gmprsx(nompro,nhpent//'.Fille')
cgn        call gmprsx(nompro,nhpent//'.Mere')
cgn        call gmprsx(nompro,nhpent//'.Famille')
cgn        call gmprsx(nompro,nhpent//'.Famille.EntiFamm')
c
c====
c 15. Conversion eventuelle en degre 2
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '15. Conversion degre 2 ; codret = ', codret
#endif
c
      if ( degre0.eq.2 ) then
c
      call gtdems (79)
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMDEG0', nompro
#endif
c
        call mmdeg0 ( nomail,
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMH', nompro
#endif
c
        call utnomh ( nomail,
     >                sdim,   mdim,
     >               degre, maconf, homolo, hierar,
     >              rafdef, nbmane, typcca, typsfr, maextr,
     >              mailet,
     >                norenu,
     >                nhnoeu, nhmapo, nharet,
     >                nhtria, nhquad,
     >                nhtetr, nhhexa, nhpyra, nhpent,
     >                nhelig,
     >                nhvois, nhsupe, nhsups,
     >                ulsort, langue, codret)
c
        endif
c
      call gtfims (79)
c
      endif
c
c====
c 16. mise a jour des grandeurs caracteristiques
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '16. mise a jour ; codret = ', codret
#endif
c
c 16.1. ==> nbmane : nombre maximal de noeuds par element
c
      if ( codret.eq.0 ) then
c
      if ( degre.eq.1 ) then
        if ( nbjoiq.eq.0 ) then
          nbmane = 6
        else
          nbmane = 8
        endif
      else
        if ( nbjoiq.eq.0 ) then
          nbmane = 15
        else
          nbmane = 20
        endif
      endif
c
cgn      print *, nbmane
      call gmecat ( nomail, 8, nbmane , codret )
c
      endif
c
c 16.2. ==> determination des voisinages
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '15.2. ; codret = ', codret
#endif
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
      endif
cgn      call gmprsx (nompro, nhvois )
cgn      call gmprsx (nompro, nhvois//'.0D/1D' )
cgn      call gmprsx (nompro, nhvois//'.0D/1D.Pointeur' )
cgn      call gmprsx (nompro, nhvois//'.0D/1D.Table' )
cgn      call gmprsx (nompro, nhvois//'.1D/2D' )
cgn      call gmprsx (nompro, nhvois//'.Vol/Tri' )
cgn      call gmprsx (nompro, nhvois//'.Vol/Qua' )
cgn      call gmprsx (nompro, nhvois//'.PyPe/Tri' )
cgn      call gmprsx (nompro, nhvois//'.PyPe/Qua' )
c
c====
c 17. Menage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '17. Menage ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav1 , codre1 )
      call gmlboj ( ntrav2 , codre2 )
      call gmlboj ( ntrav3 , codre3 )
      call gmlboj ( ntrav4 , codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      call gmlboj ( ntraw1 , codre1 )
      call gmlboj ( ntraw2 , codre2 )
      call gmlboj ( ntraw6 , codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
cgn      print *,codre1, codre2, codre3
c
      call gmlboj ( ntra30 , codre1 )
      call gmlboj ( ntra40 , codre2 )
      call gmlboj ( ntra31 , codre3 )
      call gmlboj ( ntra41 , codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
cgn      print *,codre1, codre2, codre3, codre4
c
      call gmlboj ( ntra51 , codre1 )
      call gmlboj ( ntra52 , codre2 )
      call gmlboj ( ntra53 , codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
cgn      print *,codre1, codre2
c
      call gmlboj ( ntraat , codre1 )
      call gmlboj ( ntrant , codre2 )
      call gmlboj ( ntraaa , codre3 )
      call gmlboj ( ntrana , codre4 )
      call gmlboj ( ntraan , codre5 )
      call gmlboj ( ntrann , codre6 )
cgn      print *,codre1, codre2, codre3, codre4, codre5,
cgn     >               codre6
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6 )
c
      call gmlboj ( ntra17, codre1 )
      call gmlboj ( ntra18, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c====
c 18. la fin
c====
c
 1800 continue
c
c 18.1. ==> erreurs
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
c 18.2. ==> fin des mesures de temps de la section
c
      call gtfims (nrosec)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
