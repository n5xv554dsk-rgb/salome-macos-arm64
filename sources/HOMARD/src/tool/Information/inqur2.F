      subroutine inqur2 ( choix, numdeb, numfin,
     >                    ulfido, ulenst, ulsost,
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
c   INformation : QUestions / Reponses - phase 2
c   --            --          -                -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . choix  .   s .   2    . choix                                      .
c . numdeb .   s .   1    . 1er numero ou 0 si qualite                 .
c . numfin .   s .   1    . 2nd numero (eventuellement)                .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . ulfido . e   .   1    . unite logique du fichier de donnees correct.
c . ulenst . e   .   1    . unite logique de l'entree standard         .
c . ulsost . e   .   1    . unite logique de la sortie standard        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme dans les memoires             .
c .        .     .        . 3 : probleme dans les fichiers             .
c .        .     .        . 5 : probleme autre                         .
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
#ifdef _DEBUG_HOMARD_
      character*6 nompro
      parameter ( nompro = 'INQUR2' )
#endif
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#ifdef _DEBUG_HOMARD_
#include "envex1.h"
#endif
c
#include "nombmp.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      character*2 choix
c
      integer numdeb, numfin
c
      integer ulfido, ulenst, ulsost
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer nbsign
      integer typsig(3), valent(3)
c
      character*2 valcha(3)
      character*80 chaine
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
      texte(1,4) = '(''Quel choix : '''''',a,'''''' ?'')'
      texte(1,5) = '(''Quel choix apres '''''',a,'''''' ?'')'
      texte(1,6) = '(''Information '',i1,'' illisible'')'
      texte(1,7) = '(''Qualite impossible avec le choix '',a)'
      texte(1,8) = '(''Uniquement faces ou tetraedres.'')'
      texte(1,9) =
     > '(''Numero'',i10,'' impossible. Il faut un nombre >0.'')'
c
      texte(2,4) = '(''What choice : '''''',a,'''''' ?'')'
      texte(2,5) = '(''What choice after '''''',a,'''''' ?'')'
      texte(2,6) = '(''Information '',i1,'' cannot be read.'')'
      texte(2,7) = '(''Quality impossible with choice '',a)'
      texte(2,8) = '(''Only faces or tetraedra.'')'
      texte(2,9) = '(''#'',i10,'' impossible. A >0 # is required.'')'
c
#include "impr03.h"
c
10001 format (
     >/,'Choisir . soit ''q'' pour quitter,',
     >/,'        . soit une sequence de type : ''a n1 (n2)'',',
     >/,'        . soit une sequence de type : ''a q +-n2''.',
     >/,'        . soit ''h'' pour un mode d''emploi.',/)
11000 format (60('='))
11001 format (
     >/,'a : designe le type d''entite voulue, a choisir parmi :',
     >/,'    no pour les noeuds',
     >/,'    mp pour les mailles-points',
     >/,'    ar pour les aretes',
     >/,'    tr pour les triangles',
     >/,'    qu pour les quadrangles',
     >/,'    te pour les tetraedres',
     >/,'    he pour les hexaedres',
     >/,'    py pour les pyramides',
     >/,'    pe pour les pentaedres',/,
     >/,'n1 : vaut le numero de l''entite voulue',
     >/,'n2 : vaut le numero de la derniere entite examinee ;',
     >/,'     on aura les infos sur les entites de n1 a n2 ; si n2 est',
     >/,'     absent, on les aura pour la seule entite numero n1',
     >/,'Pour les codes : minuscules : numerotation dans HOMARD',
     >/,'                 MAJUSCULES : numerotation du calcul',/,
     >/,'''q'' pour des informations sur la qualite des entites a',
     >/,' +n2 : on affichera les n2 meilleures,',
     >/,' -n2 : on affichera les n2 pires.')
11011 format (
     >/,'Exemples :',
     >/,'''NO 14''      : description du noeud 14 dans le calcul',
     >/,'''te 345 350'' : description des tetraedres',
     >/,'                de 345 a 350 dans HOMARD',
     >/,'''tr q 10''    : reperage des 10 meilleurs triangles,',
     >/,'''te q -5''    : reperage des 10 tetraedres les pires.',/)
c
10002 format (
     >/,'Choose  . either ''q'' to quit,',
     >/,'        . either sequence like : ''a n1 (n2)'',',
     >/,'        . either sequence like : ''a q +-n2''.',
     >/,'        . either ''h'' for help,')
11002 format (
     >/,'a : indicates the kind of entity, in :',
     >/,'    no for nodes',
     >/,'    mp for points-meshes',
     >/,'    ar for edges',
     >/,'    tr for triangles',
     >/,'    qu for quadrangles',
     >/,'    te for tetrahedron',
     >/,'    he for hexahedron',
     >/,'    py for pyramids',
     >/,'    pe for pentahedrons',/,
     >/,'n1 : is the # of the choosen entity',
     >/,'n2 : is the # of the last entity ;',
     >/,'     infos will be displayed for entities # from n1 to n2 ;',
     >/,'     if n2 is not given, infos will only be displayed for',
     >/,'     entity # n1.',
     >/,'     lower case : numerotation in HOMARD',
     >/,'     UPPER CASE : numerotation in calculation',/,
     >/,'''q'' for information about quality of entity ''a''',
     >/,' +n2 : n2 best will be displayed,',
     >/,' -n2 : n2 worst will be displayed.')
11012 format (
     >/,'Examples :',
     >/,'''NO 14''  : description of node # 14 in calculation',
     >/,'''te 345 350'' : description of tetraedra',
     >/,'                from 345 to 350 in HOMARD',
     >/,'''tr q 10''  : information about 10 best triangles,',
     >/,'''te q -5''  : information about 5 worst tetraedra.',/)
c
20080 format (a80)
c
      codret = 0
c
c====
c 2. Decodage
c====
c
   20 continue
c
c 2.1. ==> lecture de la demande
c
      if ( codret.eq.0 ) then
c
      if ( langue.eq.2 ) then
        write (ulsost,10002)
      else
        write (ulsost,10001)
      endif
c
      endif
c
      if ( codret.eq.0 ) then
      read (ulenst,20080,err=20,end=20) chaine
      endif
c
c 2.2. ==> decoupage de la chaine
c          nbsign : nombre de signes dans la chaine
c          typsig : type des signes :
c                   -1 : rien
c                    0 : entier
c                    1 : caractere*1
c                    2 : caractere*2
c          valcha : valeur du signe s'il est caractere
c          valent : valeur du signe s'il est entier
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTQURE', nompro
#endif
      call utqure ( chaine,
     >              nbsign, typsig, valcha, valent,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbsign', nbsign
      write (ulsort,90002) 'typsig', typsig
      write (ulsort,90003) 'valcha', valcha
      write (ulsort,90002) 'valent', valent
#endif
c
      if ( nbsign.eq.0 ) then
        goto 20
      endif
c
c 2.3. ==> le choix
c
      if ( codret.eq.0 ) then
c
      if ( typsig(1).ne.0 ) then
c
        choix = valcha(1)
c
        if ( choix.eq.'h ' ) then
c
          write (ulsost,11000)
          if ( langue.eq.2 ) then
            write (ulsost,11002)
            write (ulsost,11012)
          else
            write (ulsost,11001)
            write (ulsost,11011)
          endif
          write (ulsost,11000)
          goto 20
c
        elseif ( choix.eq.'q ' ) then
c
          goto 30
c
        elseif ( choix.eq.'no' .or.
     >           choix.eq.'NO' .or.
     >           choix.eq.'ar' .or.
     >           choix.eq.'AR' .or.
     >           choix.eq.'E ' ) then
c
          codret = 0
c
        elseif ( nbmpto.ne.0 .and.
     >           ( choix.eq.'mp' .or.choix.eq.'MP' ) ) then
c
          codret = 0
c
        elseif ( nbtrto.ne.0 .and.
     >           ( choix.eq.'tr' .or.choix.eq.'TR' ) ) then
c
          codret = 0
c
        elseif ( nbquto.ne.0 .and.
     >           ( choix.eq.'qu' .or.choix.eq.'QU' ) ) then
c
          codret = 0
c
        elseif ( nbteto.ne.0 .and.
     >             ( choix.eq.'te' .or.choix.eq.'TE' ) ) then
c
          codret = 0
c
        elseif ( nbheto.ne.0 .and.
     >           ( choix.eq.'he' .or.choix.eq.'HE' ) ) then
c
          codret = 0
c
        elseif ( nbpyto.ne.0 .and.
     >           ( choix.eq.'py' .or.choix.eq.'PY' ) ) then
c
          codret = 0
c
        elseif ( nbpeto.ne.0 .and.
     >           ( choix.eq.'pe' .or.choix.eq.'PE' ) ) then
c
          codret = 0
c
        else
c
          write (ulsost,texte(langue,4)) choix
          codret = 1
          goto 30
c
        endif
c
      else
c
        write (ulsost,texte(langue,6)) 1
        codret = 1
        goto 30
c
      endif
c
      endif
c
c 2.4. ==> le premier numero ou la qualite
c
      if ( codret.eq.0 ) then
c
      if ( nbsign.ge.2 ) then
c
        if ( typsig(2).ne.0 ) then
c
          if ( valcha(2).eq.'q ' .or.
     >         valcha(2).eq.'Q ' ) then
            if ( choix.eq.'tr' .or.
     >           choix.eq.'TR' .or.
     >           choix.eq.'qu' .or.
     >           choix.eq.'QU' .or.
     >           choix.eq.'te' .or.
     >           choix.eq.'TE' .or.
     >           choix.eq.'he' .or.
     >           choix.eq.'HE' .or.
     >           choix.eq.'py' .or.
     >           choix.eq.'PY' .or.
     >           choix.eq.'pe' .or.
     >           choix.eq.'PE' ) then
              numdeb = 0
            else
              write (ulsost,texte(langue,7)) choix
              write (ulsost,texte(langue,8))
              codret = 1
              goto 30
            endif
          else
            write (ulsost,texte(langue,6)) 2
            codret = 1
            goto 30
          endif
c
        elseif ( typsig(2).eq.0 ) then
c
          numdeb = valent(2)
          if ( numdeb.le.0 ) then
            write (ulsost,texte(langue,9)) numdeb
            codret = 1
            goto 30
          endif
c
        else
c
          write (ulsost,texte(langue,6)) 2
          codret = 1
          goto 30
c
        endif
c
      else
c
        write (ulsost,texte(langue,5)) choix
        codret = 1
        goto 30
c
      endif
c
      endif
c
c 2.5. ==> l'eventuel second numero
c
      if ( codret.eq.0 ) then
c
      if ( nbsign.ge.3 ) then
c
        if ( typsig(3).eq.0 ) then
c
          numfin = valent(3)
c
        else
c
          write (ulsost,texte(langue,6)) 3
          codret = 1
          goto 30
c
        endif
c
      else
c
        if ( numdeb.ne.0 ) then
          numfin = numdeb
        else
          write (ulsost,texte(langue,5)) choix//' q'
          codret = 1
        endif
        goto 30
c
      endif
c
      endif
c
c====
c 3. fin
c====
c
   30 continue
c
      if ( codret.eq.0 ) then
c
      call utlgut ( iaux, chaine,
     >              ulsort, langue, codret )
      write(ulfido,1000) chaine(1:iaux)
c
      endif
c
 1000 format(a)
c
#ifdef _DEBUG_HOMARD_
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
c
      endif
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
