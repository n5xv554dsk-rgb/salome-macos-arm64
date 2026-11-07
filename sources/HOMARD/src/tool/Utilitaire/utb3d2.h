c
c 2.3.3. ==> face f1 : plan (s2,s3,s4)
c            prmito est le produit mixte du tetraedre total ; selon
c            l'orientation, il est >0 ou <0.
c            prmilo est le produit mixte pointant sur le noeud a tester.
c            il faut que prmito et prmilo soient de meme signe pour que
c            le noeud soit du meme cote du plan (s2,s3,s4) que s1.
c            on teste le caractere strictement positif du produit
c            prmito x prmilo, pour pouvoir pieger les cas ou le
c            noeud est sur une face.
cgn      call gtdems (94)
c
            if ( logaux(7) ) then
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,*) '.... ', mess14(langue,2,-1), lenoeu
        endif
#endif
c
              daux1 = 0.d0
c
              if ( logaux(1) ) then
c
                v24(1) = v4(1)-v2(1)
                v24(2) = v4(2)-v2(2)
                v24(3) = v4(3)-v2(3)
c
                v23(1) = v3(1)-v2(1)
                v23(2) = v3(2)-v2(2)
                v23(3) = v3(3)-v2(3)
c
                v21(1) = v1(1)-v2(1)
                v21(2) = v1(2)-v2(2)
                v21(3) = v1(3)-v2(3)
c
c         v0(1,.) est le produit vectoriel s2s4 x s2s3.
c
                v0(1,1) = v24(2)*v23(3) - v24(3)*v23(2)
                v0(1,2) = v24(3)*v23(1) - v24(1)*v23(3)
                v0(1,3) = v24(1)*v23(2) - v24(2)*v23(1)
c
c         prmito est le produit mixte (s2s4,s2s3,s2s1)
c
                prmito = v0(1,1)*v21(1)
     >                 + v0(1,2)*v21(2)
     >                 + v0(1,3)*v21(3)
c
c         si le produit mixte est nul, c'est que le volume est nul
c         on ne controle donc rien
c
                if ( prmito.le.daux1 ) then
                  goto 20
                endif
c
                logaux(1) = .false.
c
              endif
c
c         prmilo est le produit mixte (s2s4,s2s3,s2sn)
c
              prmilo = v0(1,1)*(vn(1)-v2(1))
     >               + v0(1,2)*(vn(2)-v2(2))
     >               + v0(1,3)*(vn(3)-v2(3))
c
cgn      call gtfims (94)
              if ( prmito*prmilo.lt.daux1 ) then
                logaux(7) = .false.
              endif
c
            endif
c
c 2.3.4. ==> idem pour la face f2 : plan (s1,s3,s4)
cgn      call gtdems (95)
c
            if ( logaux(7) ) then
c
              if ( logaux(2) ) then
c
                v41(1) = v1(1)-v4(1)
                v41(2) = v1(2)-v4(2)
                v41(3) = v1(3)-v4(3)
c
                v43(1) = v3(1)-v4(1)
                v43(2) = v3(2)-v4(2)
                v43(3) = v3(3)-v4(3)
c
c         v0(2,.) est le produit vectoriel s4s1 x s4s3
c
                v0(2,1) = v41(2)*v43(3) - v41(3)*v43(2)
                v0(2,2) = v41(3)*v43(1) - v41(1)*v43(3)
                v0(2,3) = v41(1)*v43(2) - v41(2)*v43(1)
c
c         prmito est le produit mixte (s2s4,s2s3,s2s1)
c                                   = (s2s4,s2s4+s4s3,s2s4+s4s1)
c                                   = (s2s4,s4s3,s4s1)
c                                   = (s4s3,s4s1,s2s4)
c                                   = -(s4s1,s4s3,s2s4)
c                                   = (s4s1,s4s3,s4s2)
c
                logaux(2) = .false.
c
              endif
c
c         prmilo est le produit mixte (s4s1,s4s3,s4sn)
c
              prmilo = v0(2,1)*(vn(1)-v4(1))
     >               + v0(2,2)*(vn(2)-v4(2))
     >               + v0(2,3)*(vn(3)-v4(3))
c
cgn      call gtfims (95)
              if ( prmito*prmilo.lt.daux1 ) then
                logaux(7) = .false.
              endif
c
            endif
c
c 2.3.5. ==> idem pour la face f3 : plan (s1,s4,s2)
cgn      call gtdems (96)
c
            if ( logaux(7) ) then
c
              if ( logaux(3) ) then
c
c         v0(3,.) est le produit vectoriel s4s2 x s4s1
c
                v0(3,1) = - v24(2)*v41(3) + v24(3)*v41(2)
                v0(3,2) = - v24(3)*v41(1) + v24(1)*v41(3)
                v0(3,3) = - v24(1)*v41(2) + v24(2)*v41(1)
c
c         prmito est le produit mixte (s2s4,s2s3,s2s1)
c                                   = (s2s4,s2s4+s4s3,s2s4+s4s1)
c                                   = (s2s4,s4s3,s4s1)
c                                   = -(s4s2,s4s3,s4s1)
c                                   = (s4s2,s4s1,s4s3)
c
                logaux(3) = .false.
c
              endif
c
c         prmilo est le produit mixte (s4s2,s4s1,s4sn)
c
              prmilo = v0(3,1)*(vn(1)-v4(1))
     >               + v0(3,2)*(vn(2)-v4(2))
     >               + v0(3,3)*(vn(3)-v4(3))
c
cgn      call gtfims (96)
              if ( prmito*prmilo.lt.daux1 ) then
                logaux(7) = .false.
              endif
c
            endif
c
c 2.3.6. ==> idem pour la face f4 : plan (s1,s2,s3)
cgn      call gtdems (97)
c
            if ( logaux(7) ) then
c
              if ( logaux(4) ) then
c
c         v0(4,.) est le produit vectoriel s2s3 x s2s1
c
                v0(4,1) = v23(2)*v21(3) - v23(3)*v21(2)
                v0(4,2) = v23(3)*v21(1) - v23(1)*v21(3)
                v0(4,3) = v23(1)*v21(2) - v23(2)*v21(1)
c
c         prmito est le produit mixte (s2s4,s2s3,s2s1)
c                                   = (s2s3,s2s1,s2s4)
c
                logaux(4) = .false.
c
              endif
c
c         prmilo est le produit mixte (s2s3,s2s1,s2sn)
c
              prmilo = v0(4,1)*(vn(1)-v2(1))
     >               + v0(4,2)*(vn(2)-v2(2))
     >               + v0(4,3)*(vn(3)-v2(3))
c
cgn      call gtfims (97)
              if ( prmito*prmilo.lt.daux1 ) then
                logaux(7) = .false.
              endif
c
            endif
