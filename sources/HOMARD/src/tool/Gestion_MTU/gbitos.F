      subroutine gbitos ( nfdico, lfdico, codret)
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
c     fonction d'initialisation des tables de description des
c     types d'objet structure.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nfdico . e   . ch<200 . nom du fichier des objets structures       .
c . lfdico . e   .    1   . longueur du nom du fichier                 .
c .        .     .        . si =0, on a les tables par gmitob          .
c . codret .  s  .    1   . code de retour                             .
c .        .     .        . -6 : impossible de decoder la date du      .
c .        .     .        .      fichier des types                     .
c .        .     .        . -5 : erreur : type interdit                .
c .        .     .        . -4 : erreur : fichier de type d'objet vide .
c .        .     .        . -3 : erreur : erreur de format dans le     .
c .        .     .        .      fichier d'entree                      .
c .        .     .        . -2 : erreur : type de champ non defini     .
c .        .     .        . -1 : erreur : dimensionnement des tables   .
c .        .     .        .      insuffisant                           .
c .        .     .        .  0 : OK                                    .
c .        .     .        .  3 ou 9 : fermeture impossible du fichier  .
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
      parameter ( nompro = 'GBITOS' )
c
#include "genbla.h"
c
#include "gmmatc.h"
c
c 0.2. ==> communs
c
#include "gmtori.h"
#include "gmtoai.h"
#include "gmtors.h"
#include "gmtoas.h"
#include "gmtove.h"
c
#include "gminom.h"
#include "gmtail.h"
#include "gmindi.h"
#include "gminds.h"
c
#include "gmimpr.h"
#include "gmlang.h"
c
c 0.3. ==> arguments
c
      character*(*) nfdico
c
      integer lfdico, codret
c
c 0.4. ==> variables locales
c
#include "gmnelx.h"
c
      integer lelm(nelx), nelm, lgtot, ns
      integer nftypo, ipart, ncham, ncha, iadr, it
      integer jaux, nrolig
      character*8 datefr, heurfr, textem
      character*80 chaine,elem(nelx)
c
      integer iaux
c
      character*1 sepa(4)
      character*8 chatyp(nchpx)
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
      data sepa / ' ' , ',' , ';' , ' ' /
c
c ______________________________________________________________________
c
c====
c 1.  les messages
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,17) = '(''Decodage du fichier typobj.stu :'')'
      texte(1,4) = '(''Erreur a la ligne numero'',i6,'' :'')'
      texte(1,5) =
     > '(''Le nombre maximum de types,'',i6,'' est atteint.'',/)'
      texte(1,6) =
     > '(''Le nombre maximum de champs,'',i6,'' est atteint.'',/)'
      texte(1,7) = '(''Fin de fichier inattendue.'',/)'
      texte(1,8) =
     > '(''Chaque texte doit avoir moins de 8 caracteres.'')'
      texte(1,9) = '(''Aucun type n''''a ete trouve ?'')'
      texte(1,10) = '(''Aucun type ne correspond au champ '',a8)'
      texte(1,11) = '(''Le nom de type '',a8,'' est interdit.'')'
      texte(1,12) = '(''Impossible de decoder la date '',a8)'
      texte(1,13) =
     > '(''ATTENTION : les deux premiers caracteres d''''un nom'')'
      texte(1,14) =
     > '(''de champ ne devraient pas etre deux chiffres : '',a8)'
      texte(1,15) = '(''... nom du type : '',a8)'
      texte(1,18) = '(/,''Dictionnaire des types d''''objets :'')'
      texte(1,19) = '(''. Version : '',i11)'
      texte(1,20) = '(''. Sous-version : '',i6,/,''. Date : '',a8)'
c
      texte(2,17) = '(''Uncoding of file typobj.stu :'')'
      texte(2,4) = '(''Error on line #'',i6,'' :'')'
      texte(2,5) =
     > '(''The maximum number of types,'',i6,'' is reached.'',/)'
      texte(2,6) =
     > '(''The maximum number of fields,'',i6,'' is reached.'',/)'
      texte(2,7) = '(''Unexpected end of file.'',/)'
      texte(2,8) = '(''Each text must be less than 8 characters.'')'
      texte(2,9) = '(''No type was found ?'')'
      texte(2,10) = '(''No type is declared as field '',a8)'
      texte(2,11) =
     > '(''The name of this type '',a8,'' is forbidden.'')'
      texte(2,12) = '(''Date '',a8,'' cannot be uncoded.'')'
      texte(2,13) =
     > '(''WARNING : The first two characters of a field name'')'
      texte(2,14) =
     > '(''should not be both numeric : field name '',a8)'
      texte(2,15) = '(''... name of the type : '',a8)'
      texte(2,18) = '(/,''Object types dictionnary :'')'
      texte(2,19) = '(''. Version : '',i6)'
      texte(2,20) = '(''. Release : '',i6,/,''. Date : '',a8)'
c
      codret = 0
c
c====
c 2. - noms des types de base pour les donnees
c      l'ordre des types doit etre respecte
c    - les tailles des types de donnees sont en octets
c====
c
c 2.1. ==> les noms des types de bases
c
      ntyb = 3
c
      nomtyb(1) = 'entier  '
      nomtyb(2) = 'reel    '
      nomtyb(3) = 'chaine  '
      nomtyb(4) = 'struct  '
c
c 2.2. ==> mise de l'information dans les noms de types de base
c          et declares
c
      do 21 iaux = 1 , ntybma
        nomtbp(-iaux) = nomtyb(iaux)
   21 continue
c
c 2.3. ==> les tailles des types de donnees sont en octets
c
      call dmsize (tentie,treel,tchain)
c
c====
c 3. initialisation a des valeurs non definies des differents tableaux
c    decrivant les types et les champs declares et des numeros de
c    version et de sous-version
c====
c
      do 31 iaux = 1 , ntypx
         nomtbp(iaux) = sindef
         nomtyp(iaux) = sindef
         nbcham(iaux) = iindef
         nbratt(iaux) = iindef
         adrdst(iaux) = iindef
   31 continue
c
      do 32 iaux = 1 , nchpx
         chatyp(iaux) = sindef
         nomcha(iaux) = sindef
         typcha(iaux) = iindef
   32 continue
c
      nuveto = iindef
      nusvto = iindef
      daheto = iindef
      nuanto = iindef
c
c====
c 4. initialisation des tables d'objets
c====
c
      if ( lfdico.eq.0 ) then
c
cgn      write (ulsort,*) 'appel de gmitob'
c
        call gmitob
c
c====
c 4. lecture  du fichier de declaration des types d'objets
c====
c
      else
c
      call guoufs ( nfdico, lfdico, nftypo, codret )
c
      nrolig = 0
c
      ns = 3
      codret = 0
      nbrtyp = 0
      adrdst(1) = 1
c
c 4.1. ==> boucle 41 : jusqu'a ce que la ligne demarre par le
c          bon mot-cle
c
   41 continue
c
      nrolig = nrolig + 1
      read (nftypo,'(a)',end=50) chaine
c
      call gbpart(chaine,elem,lelm,nelm,lgtot,sepa,ns,ipart)
c
      if ( ipart.eq.-1 ) then
        goto 41
      else
        if ( elem(1)(1:6).eq.'>>TYPE' ) then
          jaux = 1
          goto 42
        else if ( elem(1)(1:9).eq.'>>VERSION' ) then
          jaux = 2
          goto 42
        else
          goto 41
        endif
      endif
c
c 4.2. ==> boucle 42 : jusqu'a ce que la ligne ne soit ni blanche,
c          ni un commentaire.
c          quand c'est bon, elle contient la description d'un type
c          ou de la version
c
   42 continue
c
c 4.2.1 ==> lecture de la ligne suivante
c
      nrolig = nrolig + 1
      read (nftypo,'(a)',end=73) chaine
c
      call gbpart(chaine,elem,lelm,nelm,lgtot,sepa,ns,ipart)
c
      if ( (ipart.eq.-1) .or. (elem(1)(1:2).eq.'$$') ) then
         goto 42
      endif
c
c 4.2.2. ==> controle de la longueur de chacun des textes
c
      if ( lelm(1).gt.8 .or.
     >     lelm(2).gt.8 .or.
     >     lelm(3).gt.8 ) then
         goto 74
      endif
c
c 4.2.3. ==> decodage d'un type
c
      if ( jaux.eq.1 ) then
c
c 4.2.3.1. ==> les trois termes de la chaine :
c              1 : nom du type
c              2 : nombre de champs
c              3 : nombre d'attributs
c
        nbrtyp = nbrtyp+1
        if (nbrtyp.gt.ntypx) then
           goto 71
        endif
c
        nomtyp(nbrtyp) = elem(1)(1:8)
c
        read (elem(2),'(i8)') ncham
        nbcham(nbrtyp) = ncham
c
        read (elem(3),'(i8)') nbratt(nbrtyp)
c
        if (nbrtyp.gt.1) then
           adrdst(nbrtyp) = adrdst(nbrtyp-1)+nbcham(nbrtyp-1)
        endif
c
c 4.2.3.2. ==> controle du nom du type
c
        do 4232 iaux = 1 , ntybma
           if ( nomtyp(nbrtyp).eq.nomtyb(iaux) ) then
              codret = -3
              write (ulsort,texte(langue,17))
              write (ulsort,*) nfdico
              write (ulsort,texte(langue,11)) nomtyp(nbrtyp)
           endif
 4232   continue
c
        nomtbp(nbrtyp) = nomtyp(nbrtyp)
c
c 4.2.3.3. ==> boucle 4233 : decodage de chacun des champs du type
c          jusqu'a ce que les ncham champs aient ete lus.
c          quand c'est fini, on repasse a une nouvelle ligne (goto 41)
c
        ncha = 0
c
 4233   continue
c
        nrolig = nrolig + 1
        read (nftypo,'(a)',end=73) chaine
c
        call gbpart(chaine,elem,lelm,nelm,lgtot,sepa,ns,ipart)
c
        if ( (ipart.eq.-1) .or. (elem(1)(1:2).eq.'$$') ) then
           goto 4233
        endif
        if ( (ncha.eq.ncham) .and. (elem(1)(1:5).eq.'>>FIN') ) then
           goto 41
        endif
        if ( (lelm(1).gt.8) .or. (lelm(2).gt.8) ) then
           goto 74
        endif
c
        iadr = adrdst(nbrtyp)+ncha
        if (iadr.gt.nchpx) then
           goto 72
        endif
        nomcha(iadr) = elem(1)(1:8)
c
c les deux premiers caracteres d'un nom de champ ne devraient pas etre
c tous deux numeriques : risque de conflit entre generateurs de noms
c d'objets (temporaires, cf. gbntcr, et voir aussi les sous-programmes
c gbgeno). Au mieux, cela risque de ralentir l'execution ...
c ... cela dit, on ne fait qu'imprimer un avertissement.
c
        if ( index('0123456789',nomcha(iadr)(1:1)).gt.0 .and.
     >       index('0123456789',nomcha(iadr)(2:2)).gt.0 ) then
          write (ulsort,texte(langue,1)) 'Sortie', nompro
          write (ulsort,texte(langue,17))
          write (ulsort,*) nfdico
          write (ulsort,texte(langue,13))
          write (ulsort,texte(langue,14)) nomcha(iadr)
          write (ulsort,texte(langue,15)) nomtbp(nbrtyp)
        endif
c
        chatyp(iadr) = elem(2)(1:8)
        ncha = ncha+1
c
        goto 4233
c
c 4.2.4. ==> decodage de la reference de la version
c
      else if ( jaux.eq.2 ) then
c
c 4.2.4.1. ==> le numero de version
c
        if ( elem(1)(1:5).eq.'>>FIN' ) then
          goto 41
c
        else
c
          if ( elem(1)(1:7).eq.'Version' ) then
            read (elem(2),'(i8)') nuveto
c
          else if ( elem(1)(1:8).eq.'SousVers' ) then
            read (elem(2),'(i8)') nusvto
c
          else if ( elem(1)(1:4).eq.'Date' ) then
            datefr = '        '
            datefr(1:2) = elem(2)(1:2)
            datefr(4:5) = elem(3)(1:2)
            datefr(7:8) = elem(4)(1:2)
c
          endif
c
          goto 42
c
        endif
c
      endif
c
c====
c 5. enregistrement des informations
c====
c
   50 continue
c
c 5.1. ==> decodage du type de chaque champ
c
      if (nbrtyp.ne.0) then
c
c 5.1.1. ==> decodage du type de chaque champ
c
         do 51 iaux = 1, nbrtyp
c
            do 511 jaux = adrdst(iaux), adrdst(iaux)+nbcham(iaux)-1
c
               call gbminu(chatyp(jaux),textem)
c
               if (textem.eq.nomtyb(1)) then
                  typcha(jaux) = -1
               else if (textem.eq.nomtyb(2)) then
                  typcha(jaux) = -2
               else if (textem.eq.nomtyb(3)) then
                  typcha(jaux) = -3
               else
c
                  do 5111 it = 1, nbrtyp
                     if (nomtyp(it).eq.chatyp(jaux)) then
                        typcha(jaux) = it
                        goto 511
                     endif
 5111             continue
c
                  write (ulsort,texte(langue,1)) 'Sortie', nompro
                  write (ulsort,texte(langue,17))
                  write (ulsort,*) nfdico
                  write (ulsort,texte(langue,10)) chatyp(jaux)
                  codret = -2
                  goto 80
c
               endif
  511       continue
c
   51    continue
c
      else
c
c 5.2. ==> probleme : aucun type n'a ete trouve dans le fichier
c
         write (ulsort,texte(langue,1)) 'Sortie', nompro
         write (ulsort,texte(langue,17))
         write (ulsort,*) nfdico
         write (ulsort,texte(langue,9))
         codret = -4
         goto 80
c
      endif
c
c====
c 6. enregistrement de la date des types d'objets
c====
c
      heurfr = '00:00:00'
      iaux = 0
c
      call ugdhfc ( daheto, nuanto,
     >              datefr, heurfr,
     >              iaux )
c
      if ( iaux.ne.0 ) then
        goto 75
      endif
c
      goto 80
c
c====
c 7. gestion des messages d'erreur
c====
c
   71 continue
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,17))
      write (ulsort,*) nfdico
      write (ulsort,texte(langue,4)) nrolig
      write (ulsort,*) chaine
      write (ulsort,texte(langue,5)) ntypx
      codret = -1
      goto 80
c
   72 continue
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,17))
      write (ulsort,*) nfdico
      write (ulsort,texte(langue,4)) nrolig
      write (ulsort,*) chaine
      write (ulsort,texte(langue,6)) nchpx
      codret = -1
      goto 80
c
   73 continue
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,17))
      write (ulsort,*) nfdico
      write (ulsort,texte(langue,4)) nrolig
      write (ulsort,*) chaine
      write (ulsort,texte(langue,7))
      codret = -3
      goto 80
c
   74 continue
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,17))
      write (ulsort,*) nfdico
      write (ulsort,texte(langue,4)) nrolig
      write (ulsort,*) chaine
      write (ulsort,texte(langue,8))
      codret = -3
      goto 80
c
   75 continue
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,17))
      write (ulsort,*) nfdico
      write (ulsort,texte(langue,12)) datefr
      codret = -6
      goto 80
c
c====
c 8. fermer le fichier dictionnaire
c====
c
   80 continue
c
      call gufefi ( nfdico, lfdico, codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,18))
      write (ulsort,texte(langue,19)) nuveto
      write (ulsort,texte(langue,20)) nusvto, datefr
#endif
c
c====
c 9. initialisation des quantites gerant les objets alloues
c               les tables    : nomobj , nomobc
c               les pointeurs : iptobj , iptchp
c                          et : indnom , iptatt
c     attention : il vaut mieux initialiser les attributs
c     a une valeur indefinie, ca evite des surprises ...
c====
c
      do 91 iaux = 1, nobjx
        typobj(iaux) = iindef
        adrdso(iaux) = iindef
        adrdsa(iaux) = iindef
        nomobj(iaux) = sindef
   91 continue
c
      do 92 iaux = 1, nobcx
        nomobc(iaux) = sindef
        valatt(iaux) = iindef
   92 continue
c
      iptobj = 1
      iptchp = 1
      iptatt = 1
      indnom = 0
c
      end
