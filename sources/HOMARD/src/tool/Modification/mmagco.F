      subroutine mmagco ( option, shrink,
     >                    coonoe,
     >                    somare,
     >                    nbduno, tbau30,
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
c    Modification de Maillage - AGRegat - COordonnees
c    -               -          --        --
c    Modification eventuelle des coordonnes
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .   1    . type de modification                       .
c .        .     .        . 0 : aucune                                 .
c .        .     .        . 1 : mod_joint_qt_d1                        .
c .        .     .        . 2 : mod_joint_qua2_d1                      .
c .        .     .        . 3 : mod_joint_qua_d1                       .
c .        .     .        . 4 : mod_joint_tri_d1                       .
c .        .     .        . 5 : mod_joint_tri_d2                       .
c .        .     .        . -1 : automatique                           .
c . shrink . e   .   1    . coefficient de shrink                      .
c . coonoe . es  .nbnoto*3. coordonnees des noeuds                     .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . nbduno . e   .   1    . nombre de duplications de noeuds           .
c . tbau30 . e   .8*nbduno. Pour la i-eme duplication de noeud :       .
c .        .     .        . (1,i) : noeud a dupliquer                  .
c .        .     .        . (2,i) : arete construite sur le noeud      .
c .        .     .        . (3,i) : noeud cree cote min(fammed)        .
c .        .     .        . (4,i) : noeud cree cote max(fammed)        .
c .        .     .        . (5,i) : numero du joint simple cree        .
c .        .     .        . (6,i) : arete entrant dans le cote 1       .
c .        .     .        . (7,i) : arete entrant dans le cote 2       .
c .        .     .        . (8,i) : ordre de multiplicite              .
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
      parameter ( nompro = 'MMAGCO' )
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
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer option
      integer somare(2,nbarto)
      integer nbduno, tbau30(8,nbduno)
c
      double precision coonoe(nbnoto,sdim)
      double precision shrink
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer lenoeu, larete
      integer noebis, noeext
c
      double precision vare(3)
c
      integer nbmess
      parameter ( nbmess = 30 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
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
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Option', option
#endif
c
      codret = 0
c
c====
c 2. Modification pour mod_joint_qt_d1
c====
c
      if ( option.eq.1 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'Modif des coordonnees pour mod_joint_qt_d1'
#endif
c         decalage de 1
        coonoe(19,3) = coonoe(19,3)+0.05d2
        coonoe(20,1) = coonoe(20,1)+0.05d2
c         decalage de 3
        coonoe(35,3) = coonoe(35,3)+0.05d2
        coonoe(36,1) = coonoe(36,1)+0.05d2
c         decalage de 4
        coonoe(39,3) = coonoe(39,3)+0.05d2
        coonoe(40,1) = coonoe(40,1)-0.05d2
c         decalage de 6
        coonoe(48,3) = coonoe(48,3)+0.05d2
        coonoe(49,1) = coonoe(49,1)-0.05d2
c         decalage de 11
        coonoe(32,2) = coonoe(32,2)+0.05d2
        coonoe(33,2) = coonoe(33,2)-0.05d2
c         decalage de 14
        coonoe(45,2) = coonoe(45,2)+0.05d2
        coonoe(46,2) = coonoe(46,2)-0.05d2
c         decalage de 16
        coonoe(51,1) = coonoe(51,1)+0.05d2
        coonoe(52,1) = coonoe(52,1)-0.05d2
c         decalage de 18
        coonoe(57,1) = coonoe(57,1)+0.05d2
        coonoe(58,1) = coonoe(58,1)-0.05d2
c         decalage de 7
        coonoe(23,1) = coonoe(23,1)-0.05d2
        coonoe(24,3) = coonoe(24,3)-0.05d2
        coonoe(42,1) = coonoe(42,1)+0.05d2
c         decalage de 9
        coonoe(37,1) = coonoe(37,1)-0.05d2
        coonoe(38,3) = coonoe(38,3)-0.05d2
        coonoe(50,1) = coonoe(50,1)+0.05d2
c         decalage de 2
        coonoe(21,2) = coonoe(21,2)-0.05d2
        coonoe(21,3) = coonoe(21,3)+0.05d2
        coonoe(22,1) = coonoe(22,1)+0.05d2
        coonoe(22,2) = coonoe(22,2)-0.05d2
        coonoe(27,1) = coonoe(27,1)+0.05d2
        coonoe(27,2) = coonoe(27,2)+0.05d2
        coonoe(31,2) = coonoe(31,2)+0.05d2
        coonoe(31,3) = coonoe(31,3)+0.05d2
c         decalage de 5
        coonoe(29,1) = coonoe(29,1)-0.05d2
        coonoe(29,2) = coonoe(29,2)+0.05d2
        coonoe(30,1) = coonoe(30,1)-0.05d2
        coonoe(30,2) = coonoe(30,2)-0.05d2
        coonoe(44,2) = coonoe(44,2)+0.05d2
        coonoe(44,3) = coonoe(44,3)+0.05d2
        coonoe(41,2) = coonoe(41,2)-0.05d2
        coonoe(41,3) = coonoe(41,3)+0.05d2
c         decalage de 17
        coonoe(53,1) = coonoe(53,1)-0.05d2
        coonoe(53,2) = coonoe(53,2)+0.05d2
        coonoe(54,1) = coonoe(54,1)-0.05d2
        coonoe(54,2) = coonoe(54,2)-0.05d2
        coonoe(55,1) = coonoe(55,1)+0.05d2
        coonoe(55,2) = coonoe(55,2)-0.05d2
        coonoe(56,1) = coonoe(56,1)+0.05d2
        coonoe(56,2) = coonoe(56,2)+0.05d2
c         decalage de 8
        coonoe(25,1) = coonoe(25,1)-0.05d2
        coonoe(25,2) = coonoe(25,2)-0.05d2
        coonoe(26,2) = coonoe(26,2)-0.05d2
        coonoe(26,3) = coonoe(26,3)-0.05d2
        coonoe(28,2) = coonoe(28,2)+0.05d2
        coonoe(28,3) = coonoe(28,3)-0.05d2
        coonoe(34,1) = coonoe(34,1)-0.05d2
        coonoe(34,2) = coonoe(34,2)+0.05d2
        coonoe(43,1) = coonoe(43,1)+0.05d2
        coonoe(43,2) = coonoe(43,2)-0.05d2
        coonoe(47,1) = coonoe(47,1)+0.05d2
        coonoe(47,2) = coonoe(47,2)+0.05d2
c
c====
c 3. Modification pour mod_joint_qua2_d1
c====
c
      elseif ( option.eq.2 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'Modif des coordonnees pour mod_joint_qua2_d1'
#endif
c         decalage de 2
        coonoe(72,1) = coonoe(72,1)+0.05d2
        coonoe(73,1) = coonoe(73,1)-0.05d2
c         decalage de 3
        coonoe(76,1) = coonoe(76,1)+0.05d2
        coonoe(76,2) = coonoe(76,2)-0.05d2
        coonoe(77,1) = coonoe(77,1)-0.05d2
        coonoe(77,2) = coonoe(77,2)-0.05d2
        coonoe(80,1) = coonoe(80,1)-0.05d2
        coonoe(80,2) = coonoe(80,2)+0.05d2
        coonoe(88,1) = coonoe(88,1)+0.05d2
        coonoe(88,2) = coonoe(88,2)+0.05d2
c         decalage de 4
        coonoe(83,2) = coonoe(83,2)+0.05d2
        coonoe(84,2) = coonoe(84,2)-0.05d2
c         decalage de 5
        coonoe(100,3) = coonoe(100,3)+0.05d2
        coonoe(101,3) = coonoe(101,3)-0.05d2
c         decalage de 6
        coonoe(78,1) = coonoe(78,1)+0.05d2
        coonoe(78,3) = coonoe(78,3)-0.05d2
        coonoe(79,1) = coonoe(79,1)-0.05d2
        coonoe(79,3) = coonoe(79,3)-0.05d2
        coonoe(105,1) = coonoe(105,1)-0.05d2
        coonoe(105,3) = coonoe(105,3)+0.05d2
        coonoe(107,1) = coonoe(107,1)+0.05d2
        coonoe(107,3) = coonoe(107,3)+0.05d2
c         decalage de 7
        coonoe(85,1) = coonoe(85,1)-0.05d2
        coonoe(85,2) = coonoe(85,2)+0.05d2
        coonoe(85,3) = coonoe(85,3)-0.05d2
        coonoe(86,1) = coonoe(86,1)-0.05d2
        coonoe(86,2) = coonoe(86,2)-0.05d2
        coonoe(86,3) = coonoe(86,3)-0.05d2
        coonoe(87,1) = coonoe(87,1)+0.05d2
        coonoe(87,2) = coonoe(87,2)-0.05d2
        coonoe(87,3) = coonoe(87,3)-0.05d2
        coonoe(91,1) = coonoe(91,1)+0.05d2
        coonoe(91,2) = coonoe(91,2)+0.05d2
        coonoe(91,3) = coonoe(91,3)-0.05d2
        coonoe(106,1) = coonoe(106,1)-0.05d2
        coonoe(106,2) = coonoe(106,2)-0.05d2
        coonoe(106,3) = coonoe(106,3)+0.05d2
        coonoe(110,1) = coonoe(110,1)+0.05d2
        coonoe(110,2) = coonoe(110,2)-0.05d2
        coonoe(110,3) = coonoe(110,3)+0.05d2
        coonoe(117,1) = coonoe(117,1)-0.05d2
        coonoe(117,2) = coonoe(117,2)+0.05d2
        coonoe(117,3) = coonoe(117,3)+0.05d2
        coonoe(126,1) = coonoe(126,1)+0.05d2
        coonoe(126,2) = coonoe(126,2)+0.05d2
        coonoe(126,3) = coonoe(126,3)+0.05d2
c         decalage de 8
        coonoe(98,2) = coonoe(98,2)+0.05d2
        coonoe(98,3) = coonoe(98,3)-0.05d2
        coonoe(99,2) = coonoe(99,2)-0.05d2
        coonoe(99,3) = coonoe(99,3)-0.05d2
        coonoe(104,2) = coonoe(104,2)-0.05d2
        coonoe(104,3) = coonoe(104,3)+0.05d2
        coonoe(120,2) = coonoe(120,2)+0.05d2
        coonoe(120,3) = coonoe(120,3)+0.05d2
c         decalage de 12
        coonoe(81,2) = coonoe(81,2)+0.05d2
        coonoe(82,2) = coonoe(82,2)-0.05d2
c         decalage de 13
        coonoe(74,1) = coonoe(74,1)+0.05d2
        coonoe(75,1) = coonoe(75,1)-0.05d2
c         decalage de 14
        coonoe(102,3) = coonoe(102,3)+0.05d2
        coonoe(103,3) = coonoe(103,3)-0.05d2
c         decalage de 22
        coonoe(89,2) = coonoe(89,2)+0.05d2
        coonoe(90,2) = coonoe(90,2)-0.05d2
c         decalage de 33
        coonoe(92,2) = coonoe(92,2)+0.05d2
        coonoe(93,2) = coonoe(93,2)-0.05d2
c         decalage de 17
        coonoe(94,2) = coonoe(94,2)+0.05d2
        coonoe(95,2) = coonoe(95,2)-0.05d2
c         decalage de 18
        coonoe(113,3) = coonoe(113,3)+0.05d2
        coonoe(114,3) = coonoe(114,3)-0.05d2
c         decalage de 19
        coonoe(123,2) = coonoe(123,2)+0.05d2
        coonoe(123,3) = coonoe(123,3)-0.05d2
        coonoe(124,2) = coonoe(124,2)-0.05d2
        coonoe(124,3) = coonoe(124,3)-0.05d2
        coonoe(125,2) = coonoe(125,2)-0.05d2
        coonoe(125,3) = coonoe(125,3)+0.05d2
        coonoe(129,2) = coonoe(129,2)+0.05d2
        coonoe(129,3) = coonoe(129,3)+0.05d2
c         decalage de 24
        coonoe(108,3) = coonoe(108,3)+0.05d2
        coonoe(109,3) = coonoe(109,3)-0.05d2
c         decalage de 26
        coonoe(96,1) = coonoe(96,1)+0.05d2
        coonoe(97,1) = coonoe(97,1)-0.05d2
c         decalage de 28
        coonoe(132,1) = coonoe(132,1)+0.05d2
        coonoe(132,3) = coonoe(132,3)-0.05d2
        coonoe(133,1) = coonoe(133,1)-0.05d2
        coonoe(133,3) = coonoe(133,3)-0.05d2
        coonoe(134,1) = coonoe(134,1)-0.05d2
        coonoe(134,3) = coonoe(134,3)+0.05d2
        coonoe(135,1) = coonoe(135,1)+0.05d2
        coonoe(135,3) = coonoe(135,3)+0.05d2
c         decalage de 29
        coonoe(142,3) = coonoe(142,3)+0.05d2
        coonoe(143,3) = coonoe(143,3)-0.05d2
c         decalage de 34
        coonoe(118,3) = coonoe(118,3)+0.05d2
        coonoe(119,3) = coonoe(119,3)-0.05d2
c         decalage de 37
        coonoe(146,3) = coonoe(146,3)+0.05d2
        coonoe(147,3) = coonoe(147,3)-0.05d2
c         decalage de 41
        coonoe(127,3) = coonoe(127,3)+0.05d2
        coonoe(128,3) = coonoe(128,3)-0.05d2
c         decalage de 44
        coonoe(115,1) = coonoe(115,1)+0.05d2
        coonoe(116,1) = coonoe(116,1)-0.05d2
c         decalage de 45
        coonoe(138,1) = coonoe(138,1)-0.05d2
        coonoe(138,2) = coonoe(138,2)+0.05d2
        coonoe(139,1) = coonoe(139,1)-0.05d2
        coonoe(139,2) = coonoe(139,2)-0.05d2
        coonoe(140,1) = coonoe(140,1)+0.05d2
        coonoe(140,2) = coonoe(140,2)-0.05d2
        coonoe(141,1) = coonoe(141,1)+0.05d2
        coonoe(141,2) = coonoe(141,2)+0.05d2
c         decalage de 46
        coonoe(144,2) = coonoe(144,2)+0.05d2
        coonoe(145,2) = coonoe(145,2)-0.05d2
c         decalage de 49
        coonoe(121,2) = coonoe(121,2)+0.05d2
        coonoe(122,2) = coonoe(122,2)-0.05d2
c         decalage de 50
        coonoe(111,1) = coonoe(111,1)+0.05d2
        coonoe(112,1) = coonoe(112,1)-0.05d2
c         decalage de 54
        coonoe(148,2) = coonoe(148,2)+0.05d2
        coonoe(149,2) = coonoe(149,2)-0.05d2
c         decalage de 56
        coonoe(130,2) = coonoe(130,2)+0.05d2
        coonoe(131,2) = coonoe(131,2)-0.05d2
c         decalage de 60
        coonoe(150,1) = coonoe(150,1)+0.05d2
        coonoe(151,1) = coonoe(151,1)-0.05d2
c         decalage de 64
        coonoe(136,1) = coonoe(136,1)+0.05d2
        coonoe(137,1) = coonoe(137,1)-0.05d2
c
c====
c 4. Modification pour mod_joint_qua_d1
c====
c
      elseif ( option.eq.3 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'Modif des coordonnees pour mod_joint_qua_d1'
#endif
c         decalage de 1 et 5
        coonoe(16,1) = coonoe(16,1)+0.05d2
        coonoe(17,2) = coonoe(17,2)+0.05d2
        coonoe(22,1) = coonoe(22,1)+0.05d2
        coonoe(23,2) = coonoe(23,2)+0.05d2
c         decalage de 2 et 6
        coonoe(24,1) = coonoe(24,1)-0.05d2
        coonoe(25,2) = coonoe(25,2)+0.05d2
        coonoe(28,1) = coonoe(28,1)-0.05d2
        coonoe(29,2) = coonoe(29,2)+0.05d2
c         decalage de 3 et 7
        coonoe(30,2) = coonoe(30,2)-0.05d2
        coonoe(31,1) = coonoe(31,1)-0.05d2
        coonoe(34,2) = coonoe(34,2)-0.05d2
        coonoe(35,1) = coonoe(35,1)-0.05d2
c         decalage de 4 et 8
        coonoe(36,1) = coonoe(36,1)+0.05d2
        coonoe(37,2) = coonoe(37,2)-0.05d2
        coonoe(38,1) = coonoe(38,1)+0.05d2
        coonoe(39,2) = coonoe(39,2)-0.05d2
c         decalage de 9 et 14
        coonoe(20,2) = coonoe(20,2)-0.05d2
        coonoe(40,2) = coonoe(40,2)-0.05d2
        coonoe(21,1) = coonoe(21,1)-0.05d2
        coonoe(41,1) = coonoe(41,1)-0.05d2
        coonoe(27,1) = coonoe(27,1)+0.05d2
        coonoe(42,1) = coonoe(42,1)+0.05d2
        coonoe(33,2) = coonoe(33,2)+0.05d2
        coonoe(43,2) = coonoe(43,2)+0.05d2
c         decalage de 15
        coonoe(18,2) = coonoe(18,2)-0.05d2
        coonoe(19,1) = coonoe(19,1)-0.05d2
        coonoe(26,1) = coonoe(26,1)+0.05d2
        coonoe(32,2) = coonoe(32,2)+0.05d2
c
c====
c 5. Modification pour mod_joint_tri_d1
c====
c
      elseif ( option.eq.4 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'Modif des coordonnees pour mod_joint_tri_d1'
#endif
c         decalage de 1
        coonoe(19,3) = coonoe(19,3)+0.05d2
        coonoe(20,1) = coonoe(20,1)+0.05d2
c         decalage de 2
        coonoe(21,2) = coonoe(21,2)-0.05d2
        coonoe(21,3) = coonoe(21,3)+0.05d2
        coonoe(22,1) = coonoe(22,1)+0.05d2
        coonoe(27,2) = coonoe(27,2)+0.05d2
        coonoe(27,3) = coonoe(27,3)+0.05d2
c         decalage de 3
        coonoe(31,3) = coonoe(31,3)+0.05d2
        coonoe(32,1) = coonoe(32,1)+0.05d2
c         decalage de 4
        coonoe(35,3) = coonoe(35,3)+0.05d2
        coonoe(36,1) = coonoe(36,1)-0.05d2
c         decalage de 5
        coonoe(37,3) = coonoe(37,3)+0.05d2
        coonoe(38,1) = coonoe(38,1)-0.05d2
c         decalage de 6
        coonoe(41,3) = coonoe(41,3)+0.05d2
        coonoe(42,1) = coonoe(42,1)-0.05d2
c         decalage de 7
        coonoe(23,1) = coonoe(23,1)-0.05d2
        coonoe(23,3) = coonoe(23,3)+0.05d2
        coonoe(24,3) = coonoe(24,3)-0.05d2
        coonoe(39,1) = coonoe(39,1)+0.05d2
        coonoe(39,3) = coonoe(39,3)+0.05d2
c         decalage de 8
        coonoe(25,1) = coonoe(25,1)-0.05d2
        coonoe(25,2) = coonoe(25,2)-0.05d2
        coonoe(25,3) = coonoe(25,3)+0.05d2
        coonoe(26,3) = coonoe(26,3)-0.05d2
        coonoe(30,1) = coonoe(30,1)-0.05d2
        coonoe(30,2) = coonoe(30,2)+0.05d2
        coonoe(30,3) = coonoe(30,3)+0.05d2
        coonoe(40,1) = coonoe(40,1)+0.05d2
        coonoe(40,3) = coonoe(40,3)+0.05d2
c         decalage de 9
        coonoe(33,1) = coonoe(33,1)-0.05d2
        coonoe(33,3) = coonoe(33,3)+0.05d2
        coonoe(34,3) = coonoe(34,3)-0.05d2
        coonoe(43,1) = coonoe(43,1)+0.05d2
        coonoe(43,3) = coonoe(43,3)+0.05d2
c         decalage de 11
        coonoe(28,2) = coonoe(28,2)+0.05d2
        coonoe(29,2) = coonoe(29,2)-0.05d2
c         decalage de 16
        coonoe(45,1) = coonoe(45,1)-0.05d2
        coonoe(44,1) = coonoe(44,1)+0.05d2
c         decalage de 17
        coonoe(46,1) = coonoe(46,1)-0.05d2
        coonoe(46,2) = coonoe(46,2)+0.05d2
        coonoe(47,1) = coonoe(47,1)-0.05d2
        coonoe(47,2) = coonoe(47,2)-0.05d2
        coonoe(48,1) = coonoe(48,1)+0.05d2
c         decalage de 18
        coonoe(49,1) = coonoe(49,1)+0.05d2
        coonoe(50,1) = coonoe(50,1)-0.05d2
c
c====
c 5. Modification pour mod_joint_tri_d2
c====
c
      elseif ( option.eq.5 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'Modif des coordonnees pour mod_joint_tri_d2'
#endif
        coonoe(10,1) = coonoe(10,1)-0.05d0
        coonoe(10,2) = coonoe(10,2)-0.05d0
        coonoe(12,1) = coonoe(12,1)-0.05d0
        coonoe(12,2) = coonoe(12,2)-0.05d0
        coonoe(14,1) = coonoe(14,1)-0.05d0
        coonoe(14,2) = coonoe(14,2)-0.05d0
        coonoe(20,1) = coonoe(20,1)-0.05d0
        coonoe(20,2) = coonoe(20,2)-0.05d0
        coonoe(9,1) = coonoe(9,1)+0.05d0
        coonoe(9,2) = coonoe(9,2)+0.05d0
        coonoe(11,1) = coonoe(11,1)+0.05d0
        coonoe(11,2) = coonoe(11,2)+0.05d0
        coonoe(13,1) = coonoe(13,1)+0.05d0
        coonoe(13,2) = coonoe(13,2)+0.05d0
        coonoe(15,1) = coonoe(15,1)+0.05d0
        coonoe(15,2) = coonoe(15,2)+0.05d0
        coonoe(18,1) = coonoe(18,1)+0.05d0
        coonoe(18,2) = coonoe(18,2)+0.05d0
        coonoe(19,1) = coonoe(19,1)+0.05d0
        coonoe(19,2) = coonoe(19,2)+0.05d0
c
        coonoe(9,1) = coonoe(9,1)+0.05d0
        coonoe(9,2) = coonoe(9,2)+0.05d0
        coonoe(9,3) = coonoe(9,3)+0.05d0
        coonoe(15,1) = coonoe(15,1)-0.05d0
        coonoe(15,2) = coonoe(15,2)-0.05d0
        coonoe(15,3) = coonoe(15,3)-0.05d0
        coonoe(18,1) = coonoe(18,1)-0.05d0
        coonoe(18,2) = coonoe(18,2)-0.05d0
        coonoe(18,3) = coonoe(18,3)-0.05d0
        coonoe(11,1) = coonoe(11,1)+0.05d0
        coonoe(11,2) = coonoe(11,2)+0.05d0
        coonoe(11,3) = coonoe(11,3)+0.05d0
        coonoe(16,1) = coonoe(16,1)-0.05d0
        coonoe(16,2) = coonoe(16,2)-0.05d0
        coonoe(16,3) = coonoe(16,3)-0.05d0
        coonoe(17,1) = coonoe(17,1)+0.05d0
        coonoe(17,2) = coonoe(17,2)+0.05d0
        coonoe(17,3) = coonoe(17,3)+0.05d0
c
c====
c 6. Modification automatique des noeuds dupliques
c    Pour chacun, on explore la duplication du cote 1, puis 2
c====
c
      elseif ( option.eq.-1 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,90004) 'Modif automatique avec coeff', shrink
#endif
c
        do 6 , iaux = 1 , nbduno
c
          lenoeu = tbau30(1,iaux)
c
#ifdef _DEBUG_HOMARD_
          if ( lenoeu.le.-8 ) then
      write (ulsort,90002) mess14(langue,2,-1), lenoeu
          endif
#endif
c
          do 61 , jaux = 1 , 2
c
c 6.1. ==> Caracteristiques de l'arete qui entre dans le volume
c
            larete = tbau30(5+jaux,iaux)
            if ( larete.gt.0 ) then
              noeext = somare(2,larete)
            else
              noeext = somare(1,-larete)
            endif
#ifdef _DEBUG_HOMARD_
          if ( lenoeu.le.-8 ) then
      write (ulsort,90015) 'arete', larete,
     >                     ', de sommets', lenoeu, noeext
          endif
#endif
c
c 6.2. ==> Nouvelles coordonnees
c
c          B est le noeud lenoeu, dont la duplication donne M
c          A est le noeud noeext, autre extremite de l'arete
c               A                        M  B
c               o------------------------X--o
c
c          AM = shrink*AB
c          ==> XM = XA + shrink*(XB-XA)
c
            vare(1) = coonoe(lenoeu,1) - coonoe(noeext,1)
            vare(2) = coonoe(lenoeu,2) - coonoe(noeext,2)
            vare(3) = coonoe(lenoeu,3) - coonoe(noeext,3)
c
            noebis = tbau30(2+jaux,iaux)
#ifdef _DEBUG_HOMARD_
          if ( lenoeu.le.-8 ) then
      write (ulsort,90002) 'noeud bis', noebis
          endif
#endif
            coonoe(noebis,1) = coonoe(noeext,1) + shrink*vare(1)
            coonoe(noebis,2) = coonoe(noeext,2) + shrink*vare(2)
            coonoe(noebis,3) = coonoe(noeext,3) + shrink*vare(3)
c
   61     continue
c
    6   continue
c
      endif
c
c====
c 7. La fin
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
