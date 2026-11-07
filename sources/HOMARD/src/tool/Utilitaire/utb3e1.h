c
c 2.1. ==> les aretes et les sommets de cet hexaedre actif
c          vi(1->3) = coordonnees du sommet si
c
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,90002) mess14(langue,1,typenh), lehexa
        endif
#endif
c
          if ( lehexa.le.nbhecf ) then
c
            call utarhe ( lehexa,
     >                    nbquto, nbhecf,
     >                    arequa, quahex, coquhe,
     >                    listar )
c
          else
c
            do 210 , iaux = 1 , 12
              listar(iaux) = arehex(lehexa-nbhecf,iaux)
  210       continue
c
          endif
c
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,90002) 'listar', (listar(iaux),iaux=1,10)
        write (ulsort,90002) 'listar', (listar(iaux),iaux=11,12)
        endif
#endif
c
          call utsohe ( somare, listar, sommet )
c
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,90002) 'sommet', sommet
        endif
#endif
c
          if ( degre.eq.2 ) then
            do 211 , iaux = 1 , 12
              sommet(8+iaux) = np2are(listar(iaux))
  211       continue
          endif
c
c 2.2. ==> le parallelepipede enveloppe
c
          v1(1) = coonoe(sommet(1),1)
          v1(2) = coonoe(sommet(1),2)
          v1(3) = coonoe(sommet(1),3)
c
          v2(1) = coonoe(sommet(2),1)
          v2(2) = coonoe(sommet(2),2)
          v2(3) = coonoe(sommet(2),3)
c
          v3(1) = coonoe(sommet(3),1)
          v3(2) = coonoe(sommet(3),2)
          v3(3) = coonoe(sommet(3),3)
c
          v4(1) = coonoe(sommet(4),1)
          v4(2) = coonoe(sommet(4),2)
          v4(3) = coonoe(sommet(4),3)
c
          v5(1) = coonoe(sommet(5),1)
          v5(2) = coonoe(sommet(5),2)
          v5(3) = coonoe(sommet(5),3)
c
          v6(1) = coonoe(sommet(6),1)
          v6(2) = coonoe(sommet(6),2)
          v6(3) = coonoe(sommet(6),3)
c
          v7(1) = coonoe(sommet(7),1)
          v7(2) = coonoe(sommet(7),2)
          v7(3) = coonoe(sommet(7),3)
c
          v8(1) = coonoe(sommet(8),1)
          v8(2) = coonoe(sommet(8),2)
          v8(3) = coonoe(sommet(8),3)
c
          xmin = min(v1(1),v2(1),v3(1),v4(1),v5(1),v6(1),v7(1),v8(1))
          xmax = max(v1(1),v2(1),v3(1),v4(1),v5(1),v6(1),v7(1),v8(1))
          ymin = min(v1(2),v2(2),v3(2),v4(2),v5(2),v6(2),v7(2),v8(2))
          ymax = max(v1(2),v2(2),v3(2),v4(2),v5(2),v6(2),v7(2),v8(2))
          zmin = min(v1(3),v2(3),v3(3),v4(3),v5(3),v6(3),v7(3),v8(3))
          zmax = max(v1(3),v2(3),v3(3),v4(3),v5(3),v6(3),v7(3),v8(3))
c
          logaux(1) = .true.
          logaux(2) = .true.
          logaux(3) = .true.
          logaux(4) = .true.
          logaux(5) = .true.
          logaux(6) = .true.
c
c 2.3. ==> on passe en revue tous les autres sommets qui ne sont pas des
c          sommets isoles.
c       . on ne s'interesse qu'a ceux qui sont contenus dans le
c         parallelepide enveloppe de l'hexaedre
c       . ensuite, on elimine les noeuds coincidents
c       . on recherche si le noeud est a l'interieur de l'hexaedre
c         cela est vrai si le noeud et un sommet sont du meme cote du
c         plan forme par les quatre autres sommets. pour cela, on
c         regarde si les produits mixtes (ab,ac,ad) et (ab,ac,an) sont
c         de meme signe pour les quatre permutations circulaires
c         sur (a,b,c,d)
c       . on elimine les huit noeuds de l'hexaedre
c
c         Remarque hyper importante : il ne faut faire les affectations
c         de vn(2) et vn(3) que si c'est utile car elles coutent
c         tres cheres (30% du temps total !)
c         Remarque hyper importante : il vaut mieux mettre en dernier
c         le test sur l'identite de lenoeu avec les noeuds de l'hexaedre
c         car on gagne aussi 40% !
c         En revanche, inutile de deplier davantage les tests
c
cgn      call gtfims (93)
