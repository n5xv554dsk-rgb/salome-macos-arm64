c
            if ( etanp1.ge.31 .and. etanp1.le.34 ) then
c           .................         .................
c           .       .       .         .      . .      .
c           .       .       .         .     .   .     .
c           .       .       .         .    .     .    .
c           .................  ===>   .   .       .   .
c           .       .       .         .  .         .  .
c           .       .       .         . .           . .
c           .       .       .         ..             ..
c           .................         .................
c
c    quadrangle predecoupe en 4 quad et decoupe en trois triangles
c    a l'arete a1
c
            f1hp = -filqua(quhnp1)
            f1cp = ntrsca(f1hp)
            f2cp = ntrsca(f1hp+1)
            f3cp = ntrsca(f1hp+2)
            prftrp(f1cp) = 1
            prftrp(f2cp) = 1
            prftrp(f3cp) = 1
c
            q1t = 1
            q2t = 2
            q3t = 3
            q4t = 4
            q5t = 5
            q6t = 6

            if (etanp1 .eq. 31) then
c
            f3cn = nqueca(f1hn+2)
            prf3cn = prfcan(f3cn)
            f4cn = nqueca(f1hn+3)
                 prf4cn = prfcan(f4cn)
            g1 = 0
            d1 = 0
cgn            write(6,*) 'etanp1', etanp1
cgn            write(6,*) 'f1hn+2=',f1hn+2,
cgn     > 'mod(anhetr(f1hn+2),10)',mod(anhetr(f1hn+2),10)
            if ( mod(anhequ(f1hn),10).eq.0 ) then
              f1cn = nqueca(f1hn)
              prf1cn = prfcan(f1cn)
            elseif ( mod(anhequ(f1hn),10).eq.etanp1 ) then
              pf = anfiqu(f1hn)
              g1 = nqueca(pf)
              prfg1n = prfcan(g1)
              g2 = nqueca(pf+1)
              prfg2n = prfcan(g2)
              g3 = nqueca(pf+2)
              prfg3n = prfcan(g3)
            else
              codret = codret + 1
cgn           write(ulsort,*) '_7h A codret', codret
cgn           write (ulsort,texte(langue,4)) 'n  ', trhn
cgn           write (ulsort,texte(langue,5)) 'n  ', etan
cgn           write (ulsort,texte(langue,4)) 'n+1', trhnp1
cgn           write (ulsort,texte(langue,5)) 'n+1', etanp1
            endif
cgn            write(6,*) 'etanp1', etanp1
cgn            write(6,*) 'mod(anhetr(f1hn+3),10)',mod(anhetr(f1hn+3),10)
            if ( mod(anhequ(f1hn+1),10).eq.0 ) then
              f2cn = nqueca(f1hn+1)
              prf2cn = prfcan(f2cn)
            elseif ( mod(anhequ(f1hn+1),10).eq.etanp1 ) then
              pf = anfiqu(f1hn+1)
              d1 = nqueca(pf)
              prfd1n = prfcan(d1)
              d2 = nqueca(pf+1)
              prfd2n = prfcan(d2)
              d3 = nqueca(pf+2)
              prfd3n = prfcan(d3)
            else
              codret = codret + 1
cgn           write (ulsort,*) '_5h B codret', codret
cgn           write (ulsort,texte(langue,4)) 'n  ', trhn
cgn           write (ulsort,texte(langue,5)) 'n  ', etan
cgn           write (ulsort,texte(langue,4)) 'n+1', trhnp1
cgn           write (ulsort,texte(langue,5)) 'n+1', etanp1
            endif
c
            if  ( g1.eq.0 .and. d1.eq.0 ) then
c
            do 2611 , nrofon = 1 , nbfonc
c
c    dans le triangle NT1
c
              vatrtt(nrofon,q1t,f1cp) = vafoen(nrofon,q1,prf4cn)
c
              vatrtt(nrofon,q2t,f1cp) = unsde*(vafoen(nrofon,q2,prf1cn)+
     >                                        vafoen(nrofon,q4,prf2cn))
c
              vatrtt(nrofon,q3t,f1cp) = vafoen(nrofon,q1,prf3cn)
c
              vatrtt(nrofon,q4t,f1cp) = unsde*(vafoen(nrofon,q7,prf1cn)+
     >                                        vafoen(nrofon,q6,prf4cn))
c
              vatrtt(nrofon,q5t,f1cp) = unsde*(vafoen(nrofon,q6,prf2cn)+
     >                                        vafoen(nrofon,q7,prf3cn))
c
              vatrtt(nrofon,q6t,f1cp) = unsde*(vafoen(nrofon,q2,prf3cn)+
     >                                        vafoen(nrofon,q4,prf4cn))
c
c    dans le triangle NT2
c
              vatrtt(nrofon,q1t,f2cp) = vafoen(nrofon,q1,prf3cn)
c
              vatrtt(nrofon,q2t,f2cp) = vafoen(nrofon,q2,prf4cn)
c
              vatrtt(nrofon,q3t,f2cp) = vafoen(nrofon,q1,prf2cn)
c
              vatrtt(nrofon,q4t,f2cp) = unsde*(vafoen(nrofon,q6,prf2cn)+
     >                                        vafoen(nrofon,q7,prf3cn))
c
              vatrtt(nrofon,q5t,f2cp) = vafoen(nrofon,q8,prf2cn)
c
              vatrtt(nrofon,q6t,f2cp) = unsde*(vafoen(nrofon,q2,prf2cn)+
     >                                        vafoen(nrofon,q4,prf3cn))
c
c    dans le triangle NT3
c
              vatrtt(nrofon,q1t,f3cp) = vafoen(nrofon,q1,prf4cn)
c
              vatrtt(nrofon,q2t,f3cp) = vafoen(nrofon,q1,prf1cn)
c
              vatrtt(nrofon,q3t,f3cp) = vafoen(nrofon,q2,prf1cn)
c
              vatrtt(nrofon,q4t,f3cp) = unsde*(vafoen(nrofon,q4,prf1cn)+
     >                                        vafoen(nrofon,q2,prf4cn))
c
              vatrtt(nrofon,q5t,f3cp) = vafoen(nrofon,q5,prf1cn)
c
              vatrtt(nrofon,q6t,f3cp) = unsde*(vafoen(nrofon,q7,prf1cn)+
     >                                         vafoen(nrofon,q6,prf4cn))
c
2611        continue
c
            elseif  ( g1.ne.0 .and. d1.eq.0 ) then
            do 26111 , nrofon = 1 , nbfonc
c
c    dans le triangle NT1
c
              vatrtt(nrofon,q1t,f1cp) = vafoen(nrofon,q1,prf4cn)
c
              vatrtt(nrofon,q2t,f1cp) = unsde*(vatren(nrofon,q3,prfg2n)+
     >                                         vafoen(nrofon,q4,prf2cn))
c
              vatrtt(nrofon,q3t,f1cp) = vafoen(nrofon,q1,prf3cn)
c
              vatrtt(nrofon,q4t,f1cp) = unsde*(vafoen(nrofon,q6,prf4cn)
     >                                        +vatren(nrofon,q6,prfg1n))
c
              vatrtt(nrofon,q5t,f1cp) = unsde*(vafoen(nrofon,q6,prf2cn)+
     >                                         vafoen(nrofon,q7,prf3cn))
c
              vatrtt(nrofon,q6t,f1cp) = unsde*(vafoen(nrofon,q2,prf3cn)
     >                                        +vafoen(nrofon,q4,prf4cn))
c
c    dans le triangle NT2
c
              vatrtt(nrofon,q1t,f2cp) = vafoen(nrofon,q1,prf3cn)
c
              vatrtt(nrofon,q2t,f2cp) = vafoen(nrofon,q2,prf4cn)
c
              vatrtt(nrofon,q3t,f2cp) = vafoen(nrofon,q1,prf2cn)
c
              vatrtt(nrofon,q4t,f2cp) = unsde*(vafoen(nrofon,q6,prf2cn)+
     >                                        vafoen(nrofon,q7,prf3cn))
c
              vatrtt(nrofon,q5t,f2cp) = vafoen(nrofon,q8,prf2cn)
c
              vatrtt(nrofon,q6t,f2cp) = unsde*(vafoen(nrofon,q2,prf2cn)+
     >                                        vafoen(nrofon,q4,prf3cn))
c
c
c    dans le triangle NT3
c
              vatrtt(nrofon,q1t,f3cp) = vafoen(nrofon,q1,prf4cn)
c
              vatrtt(nrofon,q2t,f3cp) = vatren(nrofon,q2,prfg3n)
c
              vatrtt(nrofon,q3t,f3cp) = vatren(nrofon,q3,prfg2n)
c
              vatrtt(nrofon,q4t,f3cp) = unstr*(vatren(nrofon,q1,prfg1n)
     >                                        +vatren(nrofon,q1,prfg3n)
     >                                        +vafoen(nrofon,q2,prf4cn))
c
              vatrtt(nrofon,q5t,f3cp) = unstr*(vatren(nrofon,q2,prfg1n)
     >                                        +vatren(nrofon,q2,prfg2n)
     >                                        +vatren(nrofon,q3,prfg3n))
c
              vatrtt(nrofon,q6t,f3cp) = unsde*(vatren(nrofon,q6,prfg1n)
     >                                        +vafoen(nrofon,q6,prf4cn))
c
26111       continue
c
            elseif  ( g1.eq.0 .and. d1.ne.0 ) then
            do 26112 , nrofon = 1 , nbfonc
c
c    dans le triangle NT1
c
              vatrtt(nrofon,q1t,f1cp) = vafoen(nrofon,q1,prf4cn)
c
              vatrtt(nrofon,q2t,f1cp) = unsde*(vafoen(nrofon,q2,prf1cn)
     >                                        +vatren(nrofon,q2,prfd3n))
c
              vatrtt(nrofon,q3t,f1cp) = vafoen(nrofon,q1,prf3cn)
c
              vatrtt(nrofon,q4t,f1cp) = unsde*(vafoen(nrofon,q7,prf1cn)
     >                                        +vatren(nrofon,q6,prf4cn))
c
              vatrtt(nrofon,q5t,f1cp) = unsde*(vafoen(nrofon,q7,prf3cn)
     >                                        +vatren(nrofon,q6,prfd1n))
c
              vatrtt(nrofon,q6t,f1cp) = unsde*(vafoen(nrofon,q2,prf3cn)
     >                                        +vafoen(nrofon,q4,prf4cn))
c
c    dans le triangle NT2
c
              vatrtt(nrofon,q1t,f2cp) = vafoen(nrofon,q1,prf3cn)
c
              vatrtt(nrofon,q2t,f2cp) = vatren(nrofon,q3,prfg2n)
c
              vatrtt(nrofon,q3t,f2cp) = vatren(nrofon,q3,prfd2n)
c
              vatrtt(nrofon,q4t,f2cp) = unsde*(vatren(nrofon,q6,prfd1n)
     >                                        +vafoen(nrofon,q7,prf3cn))
c
              vatrtt(nrofon,q5t,f2cp) = unstr*(vatren(nrofon,q2,prfd1n)
     >                                        +vatren(nrofon,q5,prfd2n)
     >                                        +vatren(nrofon,q3,prfd3n))
c
              vatrtt(nrofon,q6t,f2cp) = unstr*(vafoen(nrofon,q4,prf3cn)
     >                                        +vatren(nrofon,q3,prfd1n)
     >                                        +vatren(nrofon,q1,prfd2n))
c
c    dans le triangle NT3
c
              vatrtt(nrofon,q1t,f3cp) = vafoen(nrofon,q1,prf4cn)
c
              vatrtt(nrofon,q2t,f3cp) = vafoen(nrofon,q1,prf1cn)
c
              vatrtt(nrofon,q3t,f3cp) = vafoen(nrofon,q2,prf1cn)
c
              vatrtt(nrofon,q4t,f3cp) = unsde*(vafoen(nrofon,q4,prf1cn)+
     >                                        vafoen(nrofon,q2,prf4cn))
c
              vatrtt(nrofon,q5t,f3cp) = vafoen(nrofon,q5,prf1cn)
c
              vatrtt(nrofon,q6t,f3cp) = unsde*(vafoen(nrofon,q7,prf1cn)+
     >                                         vafoen(nrofon,q6,prf4cn))
c
26112       continue
c
            elseif  ( g1.ne.0 .and. d1.ne.0 ) then
            do 26113 , nrofon = 1 , nbfonc
c
c    dans le triangle NT1
c
              vatrtt(nrofon,q1t,f1cp) = vafoen(nrofon,q1,prf4cn)
c
              vatrtt(nrofon,q2t,f1cp) = unsde*(vatren(nrofon,q3,prfg2n)
     >                                        +vatren(nrofon,q2,prfd3n))
c
              vatrtt(nrofon,q3t,f1cp) = vafoen(nrofon,q1,prf3cn)
c
              vatrtt(nrofon,q4t,f1cp) = unsde*(vafoen(nrofon,q6,prf4cn)
     >                                        +vatren(nrofon,q6,prfg1n))
c
              vatrtt(nrofon,q5t,f1cp) = unsde*(vafoen(nrofon,q7,prf3cn)
     >                                        +vatren(nrofon,q6,prfd1n))
c
              vatrtt(nrofon,q6t,f1cp) = unsde*(vafoen(nrofon,q2,prf3cn)
     >                                        +vafoen(nrofon,q4,prf4cn))
c
c    dans le triangle NT2
c
              vatrtt(nrofon,q1t,f2cp) = vafoen(nrofon,q1,prf3cn)
c
              vatrtt(nrofon,q2t,f2cp) = vatren(nrofon,q2,prfd3n)
c
              vatrtt(nrofon,q3t,f2cp) = vatren(nrofon,q3,prfd2n)
c
              vatrtt(nrofon,q4t,f2cp) = unsde*(vatren(nrofon,q6,prfd1n)
     >                                        +vafoen(nrofon,q7,prf3cn))
c
              vatrtt(nrofon,q5t,f2cp) = unstr*(vatren(nrofon,q2,prfd1n)
     >                                        +vatren(nrofon,q2,prfd2n)
     >                                        +vatren(nrofon,q3,prfd3n))
c
              vatrtt(nrofon,q6t,f2cp) = unstr*(vafoen(nrofon,q4,prf3cn)
     >                                        +vatren(nrofon,q3,prfd1n)
     >                                        +vatren(nrofon,q1,prfd2n))
c
c    dans le triangle NT3
c
              vatrtt(nrofon,q1t,f3cp) = vafoen(nrofon,q1,prf4cn)
c
              vatrtt(nrofon,q2t,f3cp) = vatren(nrofon,q2,prfg3n)
c
              vatrtt(nrofon,q3t,f3cp) = vatren(nrofon,q3,prfg2n)
c
              vatrtt(nrofon,q4t,f3cp) = unstr*(vatren(nrofon,q1,prfg1n)
     >                                        +vatren(nrofon,q1,prfg3n)
     >                                        +vafoen(nrofon,q2,prf4cn))
c
              vatrtt(nrofon,q5t,f3cp) = unstr*(vatren(nrofon,q2,prfg1n)
     >                                        +vatren(nrofon,q2,prfg2n)
     >                                        +vatren(nrofon,q3,prfg3n))
c
              vatrtt(nrofon,q6t,f3cp) = unsde*(vatren(nrofon,q6,prfg1n)
     >                                        +vafoen(nrofon,q6,prf4cn))
c
26113       continue
            endif

c    quadrangle predecoupe en 4 quad et decoupe en trois triangles
c    a l'arete a2
c
            elseif (etanp1 .eq. 32) then
c
            f1cn = nqueca(f1hn)
            prf1cn = prfcan(f1cn)
                 f4cn = nqueca(f1hn+3)
                 prf4cn = prfcan(f4cn)
            g1 = 0
            d1 = 0
cgn            write(6,*) 'etanp1', etanp1
cgn            write(6,*) 'f1hn+2=',f1hn+2,
cgn     > 'mod(anhetr(f1hn+1),10)',mod(anhetr(f1hn+1),10)
            if ( mod(anhequ(f1hn+1),10).eq.0 ) then
              f2cn = nqueca(f1hn+1)
              prf2cn = prfcan(f2cn)
            elseif ( mod(anhequ(f1hn+1),10).eq.etanp1 ) then
              pf = anfiqu(f1hn+1)
              g1 = nqueca(pf)
              prfg1n = prfcan(g1)
              g2 = nqueca(pf+1)
              prfg2n = prfcan(g2)
              g3 = nqueca(pf+2)
              prfg3n = prfcan(g3)
            else
              codret = codret + 1
cgn           write(ulsort,*) '_7h A codret', codret
cgn           write (ulsort,texte(langue,4)) 'n  ', trhn
cgn           write (ulsort,texte(langue,5)) 'n  ', etan
cgn           write (ulsort,texte(langue,4)) 'n+1', trhnp1
cgn           write (ulsort,texte(langue,5)) 'n+1', etanp1
            endif
cgn            write(6,*) 'etanp1', etanp1
cgn            write(6,*) 'mod(anhetr(f1hn+2),10)',mod(anhetr(f1hn+2),10)
            if ( mod(anhequ(f1hn+2),10).eq.0 ) then
              f3cn = nqueca(f1hn+2)
              prf3cn = prfcan(f3cn)
            elseif ( mod(anhequ(f1hn+2),10).eq.etanp1 ) then
              pf = anfiqu(f1hn+2)
              d1 = nqueca(pf)
              prfd1n = prfcan(d1)
              d2 = nqueca(pf+1)
              prfd2n = prfcan(d2)
              d3 = nqueca(pf+2)
              prfd3n = prfcan(d3)
            else
              codret = codret + 1
cgn           write (ulsort,*) '_5h B codret', codret
cgn           write (ulsort,texte(langue,4)) 'n  ', trhn
cgn           write (ulsort,texte(langue,5)) 'n  ', etan
cgn           write (ulsort,texte(langue,4)) 'n+1', trhnp1
cgn           write (ulsort,texte(langue,5)) 'n+1', etanp1
            endif
c
c
            if  ( g1.eq.0 .and. d1.eq.0 ) then
c
            do 2612 , nrofon = 1 , nbfonc
c    dans le triangle NT1
c
              vatrtt(nrofon,q1t,f1cp) = vafoen(nrofon,q1,prf1cn)
c
              vatrtt(nrofon,q2t,f1cp) = unsde*(vafoen(nrofon,q2,prf2cn)+
     >                                        vafoen(nrofon,q4,prf3cn))
c
              vatrtt(nrofon,q3t,f1cp) = vafoen(nrofon,q1,prf4cn)
c
              vatrtt(nrofon,q4t,f1cp) = unsde*(vafoen(nrofon,q6,prf1cn)+
     >                                        vafoen(nrofon,q7,prf2cn))
c
              vatrtt(nrofon,q5t,f1cp) = unsde*(vafoen(nrofon,q6,prf3cn)+
     >                                        vafoen(nrofon,q7,prf4cn))
c
              vatrtt(nrofon,q6t,f1cp) = unsde*(vafoen(nrofon,q4,prf1cn)+
     >                                        vafoen(nrofon,q2,prf4cn))
c
c    dans le triangle NT2
c
              vatrtt(nrofon,q1t,f2cp) = vafoen(nrofon,q1,prf4cn)
c
              vatrtt(nrofon,q2t,f2cp) = vafoen(nrofon,q4,prf3cn)
c
              vatrtt(nrofon,q3t,f2cp) = vafoen(nrofon,q1,prf3cn)
c
              vatrtt(nrofon,q4t,f2cp) = unsde*(vafoen(nrofon,q6,prf3cn)+
     >                                        vafoen(nrofon,q7,prf4cn))
c
              vatrtt(nrofon,q5t,f2cp) = vafoen(nrofon,q8,prf3cn)
c
              vatrtt(nrofon,q6t,f2cp) = unsde*(vafoen(nrofon,q2,prf3cn)+
     >                                        vafoen(nrofon,q4,prf4cn))
c
c    dans le triangle NT3
c
              vatrtt(nrofon,q1t,f3cp) = vafoen(nrofon,q1,prf1cn)
c
              vatrtt(nrofon,q2t,f3cp) = vafoen(nrofon,q1,prf2cn)
c
              vatrtt(nrofon,q3t,f3cp) = vafoen(nrofon,q2,prf2cn)
c
              vatrtt(nrofon,q4t,f3cp) = unsde*(vafoen(nrofon,q2,prf1cn)+
     >                                        vafoen(nrofon,q4,prf2cn))
c
              vatrtt(nrofon,q5t,f3cp) = vafoen(nrofon,q5,prf2cn)
c
              vatrtt(nrofon,q6t,f3cp) = unsde*(vafoen(nrofon,q6,prf1cn)+
     >                                        vafoen(nrofon,q7,prf2cn))
c
2612        continue
c
            elseif  ( g1.ne.0 .and. d1.eq.0 ) then
            do 26121 , nrofon = 1 , nbfonc
c
c    dans le triangle NT1
c
              vatrtt(nrofon,q1t,f1cp) = vafoen(nrofon,q1,prf1cn)
c
              vatrtt(nrofon,q2t,f1cp) = unsde*(vatren(nrofon,q3,prfg2n)+
     >                                         vafoen(nrofon,q4,prf3cn))
c
              vatrtt(nrofon,q3t,f1cp) = vafoen(nrofon,q1,prf4cn)
c
              vatrtt(nrofon,q4t,f1cp) = unsde*(vatren(nrofon,q6,prfg1n)+
     >                                         vafoen(nrofon,q6,prf1cn))
c
              vatrtt(nrofon,q5t,f1cp) = unsde*(vafoen(nrofon,q6,prf3cn)+
     >                                         vafoen(nrofon,q7,prf4cn))
c
              vatrtt(nrofon,q6t,f1cp) = unsde*(vafoen(nrofon,q4,prf1cn)+
     >                                         vafoen(nrofon,q2,prf4cn))
c
c    dans le triangle NT2
c
              vatrtt(nrofon,q1t,f2cp) = vafoen(nrofon,q1,prf4cn)
c
              vatrtt(nrofon,q2t,f2cp) = vafoen(nrofon,q4,prf3cn)
c
              vatrtt(nrofon,q3t,f2cp) = vafoen(nrofon,q1,prf3cn)
c
              vatrtt(nrofon,q4t,f2cp) = unsde*(vafoen(nrofon,q6,prf3cn)+
     >                                        vafoen(nrofon,q7,prf4cn))
c
              vatrtt(nrofon,q5t,f2cp) = vafoen(nrofon,q8,prf3cn)
c
              vatrtt(nrofon,q6t,f2cp) = unsde*(vafoen(nrofon,q2,prf3cn)+
     >                                        vafoen(nrofon,q4,prf4cn))
c
c    dans le triangle NT3
c
              vatrtt(nrofon,q1t,f3cp) = vafoen(nrofon,q1,prf1cn)
c
              vatrtt(nrofon,q2t,f3cp) = vatren(nrofon,q2,prfg3n)
c
              vatrtt(nrofon,q3t,f3cp) = vatren(nrofon,q3,prfg2n)
c
              vatrtt(nrofon,q4t,f3cp) = unstr*(vafoen(nrofon,q2,prf1cn)
     >                                        +vatren(nrofon,q1,prfg3n)
     >                                        +vatren(nrofon,q1,prfg1n))
c
              vatrtt(nrofon,q5t,f3cp) = unstr*(vatren(nrofon,q3,prfg3n)
     >                                        +vatren(nrofon,q2,prfg2n)
     >                                        +vatren(nrofon,q1,prfg1n))
c
              vatrtt(nrofon,q6t,f3cp) = unsde*(vafoen(nrofon,q6,prf1cn)+
     >                                         vafoen(nrofon,q6,prfg1n))
cc
26121       continue
c
            elseif  ( g1.eq.0 .and. d1.ne.0 ) then
            do 26122 , nrofon = 1 , nbfonc
c
c    dans le triangle NT1
c
              vatrtt(nrofon,q1t,f1cp) = unsde*(vafoen(nrofon,q2,prf2cn)+
     >                                         vatren(nrofon,q2,prfd3n))
c
              vatrtt(nrofon,q2t,f1cp) = unsde*(vatren(nrofon,q3,prfg2n)+
     >                                         vatren(nrofon,q2,prfd3n))
c
              vatrtt(nrofon,q3t,f1cp) = vafoen(nrofon,q1,prf4cn)
c
              vatrtt(nrofon,q4t,f1cp) = unsde*(vafoen(nrofon,q7,prf2cn)+
     >                                         vafoen(nrofon,q6,prf1cn))
c
              vatrtt(nrofon,q5t,f1cp) = unsde*(vatren(nrofon,q6,prfd1n)+
     >                                         vafoen(nrofon,q7,prf4cn))
c
              vatrtt(nrofon,q6t,f1cp) = unsde*(vafoen(nrofon,q4,prf1cn)+
     >                                         vafoen(nrofon,q2,prf4cn))
c
c    dans le triangle NT2
c
              vatrtt(nrofon,q1t,f2cp) = vafoen(nrofon,q1,prf4cn)
c
              vatrtt(nrofon,q2t,f2cp) = vatren(nrofon,q2,prfd3n)
c
              vatrtt(nrofon,q3t,f2cp) = vatren(nrofon,q3,prfd2n)
c
              vatrtt(nrofon,q4t,f2cp) = unsde*(vatren(nrofon,q6,prfd1n)+
     >                                         vafoen(nrofon,q7,prf4cn))
c
              vatrtt(nrofon,q5t,f2cp) = unstr*(vafoen(nrofon,q4,prf4cn)
     >                                        +vatren(nrofon,q3,prfd1n)
     >                                        +vatren(nrofon,q1,prfd2n))
c
              vatrtt(nrofon,q6t,f2cp) = unstr*(vafoen(nrofon,q3,prfd3n)
     >                                        +vatren(nrofon,q2,prfd2n)
     >                                        +vatren(nrofon,q2,prfd1n))
c
c    dans le triangle NT3
c
              vatrtt(nrofon,q1t,f3cp) = vafoen(nrofon,q1,prf1cn)
c
              vatrtt(nrofon,q2t,f3cp) = vafoen(nrofon,q1,prf2cn)
c
              vatrtt(nrofon,q3t,f3cp) = vafoen(nrofon,q2,prf2cn)
c
              vatrtt(nrofon,q4t,f3cp) = unsde*(vafoen(nrofon,q2,prf1cn)+
     >                                        vafoen(nrofon,q4,prf2cn))
c
              vatrtt(nrofon,q5t,f3cp) = vafoen(nrofon,q5,prf2cn)
c
              vatrtt(nrofon,q6t,f3cp) = unsde*(vafoen(nrofon,q6,prf1cn)+
     >                                        vafoen(nrofon,q7,prf2cn))
c
26122       continue
c
            elseif  ( g1.ne.0 .and. d1.ne.0 ) then
            do 26123 , nrofon = 1 , nbfonc
c
c    dans le triangle NT1
c
              vatrtt(nrofon,q1t,f1cp) = vafoen(nrofon,q1,prf1cn)
c
              vatrtt(nrofon,q2t,f1cp) = unsde*(vatren(nrofon,q3,prfg2n)+
     >                                         vatren(nrofon,q2,prfd3n))
c
              vatrtt(nrofon,q3t,f1cp) = vafoen(nrofon,q1,prf4cn)
c
              vatrtt(nrofon,q4t,f1cp) = unsde*(vatren(nrofon,q6,prfg1n)+
     >                                         vafoen(nrofon,q6,prf1cn))
c
              vatrtt(nrofon,q5t,f1cp) = unsde*(vatren(nrofon,q6,prfd1n)+
     >                                         vafoen(nrofon,q7,prf4cn))
c
              vatrtt(nrofon,q6t,f1cp) = unsde*(vafoen(nrofon,q4,prf1cn)+
     >                                         vafoen(nrofon,q2,prf4cn))
c
c    dans le triangle NT2
c
              vatrtt(nrofon,q1t,f2cp) = vafoen(nrofon,q1,prf4cn)
c
              vatrtt(nrofon,q2t,f2cp) = vatren(nrofon,q2,prfd3n)
c
              vatrtt(nrofon,q3t,f2cp) = vatren(nrofon,q3,prfd2n)
c
              vatrtt(nrofon,q4t,f2cp) = unsde*(vatren(nrofon,q6,prfd1n)+
     >                                         vafoen(nrofon,q7,prf4cn))
c
              vatrtt(nrofon,q5t,f2cp) = unstr*(vafoen(nrofon,q3,prfd3n)
     >                                        +vatren(nrofon,q2,prfd2n)
     >                                        +vatren(nrofon,q2,prfd1n))
c
              vatrtt(nrofon,q6t,f2cp) = unstr*(vafoen(nrofon,q4,prf4cn)
     >                                        +vatren(nrofon,q3,prfd1n)
     >                                        +vatren(nrofon,q1,prfd2n))
c    dans le triangle NT3
c
              vatrtt(nrofon,q1t,f3cp) = vafoen(nrofon,q1,prf1cn)
c
              vatrtt(nrofon,q2t,f3cp) = vatren(nrofon,q2,prfg3n)
c
              vatrtt(nrofon,q3t,f3cp) = vatren(nrofon,q3,prfg2n)
c
              vatrtt(nrofon,q4t,f3cp) = unstr*(vafoen(nrofon,q2,prf1cn)
     >                                        +vatren(nrofon,q1,prfg3n)
     >                                        +vatren(nrofon,q1,prfg1n))
c
              vatrtt(nrofon,q5t,f3cp) = unstr*(vatren(nrofon,q3,prfg3n)
     >                                        +vatren(nrofon,q2,prfg2n)
     >                                        +vatren(nrofon,q1,prfg1n))
c
              vatrtt(nrofon,q6t,f3cp) = unsde*(vafoen(nrofon,q6,prf1cn)+
     >                                         vafoen(nrofon,q6,prfg1n))
c
26123       continue
            endif
c
c    quadrangle predecoupe en 4 quad et decoupe en trois triangles
c    a l'arete a3
c
            elseif (etanp1 .eq. 33) then
c
            f1cn = nqueca(f1hn)
            prf1cn = prfcan(f1cn)
                 f2cn = nqueca(f1hn+1)
                 prf2cn = prfcan(f2cn)
            g1 = 0
            d1 = 0
cgn            write(6,*) 'etanp1', etanp1
cgn            write(6,*) 'f1hn+2=',f1hn+2,
cgn     > 'mod(anhetr(f1hn+2),10)',mod(anhetr(f1hn+2),10)
            if ( mod(anhequ(f1hn+2),10).eq.0 ) then
              f3cn = nqueca(f1hn+2)
              prf3cn = prfcan(f3cn)
            elseif ( mod(anhequ(f1hn+2),10).eq.etanp1 ) then
              pf = anfiqu(f1hn+2)
              g1 = nqueca(pf)
              prfg1n = prfcan(g1)
              g2 = nqueca(pf+1)
              prfg2n = prfcan(g2)
              g3 = nqueca(pf+2)
              prfg3n = prfcan(g3)
            else
              codret = codret + 1
cgn           write(ulsort,*) '_7h A codret', codret
cgn           write (ulsort,texte(langue,4)) 'n  ', trhn
cgn           write (ulsort,texte(langue,5)) 'n  ', etan
cgn           write (ulsort,texte(langue,4)) 'n+1', trhnp1
cgn           write (ulsort,texte(langue,5)) 'n+1', etanp1
            endif
cgn            write(6,*) 'etanp1', etanp1
cgn            write(6,*) 'mod(anhetr(f1hn+3),10)',mod(anhetr(f1hn+3),10)
            if ( mod(anhequ(f1hn+3),10).eq.0 ) then
              f4cn = nqueca(f1hn+3)
              prf4cn = prfcan(f4cn)
            elseif ( mod(anhequ(f1hn+3),10).eq.etanp1 ) then
              pf = anfiqu(f1hn+3)
              d1 = nqueca(pf)
              prfd1n = prfcan(d1)
              d2 = nqueca(pf+1)
              prfd2n = prfcan(d2)
              d3 = nqueca(pf+2)
              prfd3n = prfcan(d3)
            else
              codret = codret + 1
cgn           write (ulsort,*) '_5h B codret', codret
cgn           write (ulsort,texte(langue,4)) 'n  ', trhn
cgn           write (ulsort,texte(langue,5)) 'n  ', etan
cgn           write (ulsort,texte(langue,4)) 'n+1', trhnp1
cgn           write (ulsort,texte(langue,5)) 'n+1', etanp1
            endif
c
c
            if  ( g1.eq.0 .and. d1.eq.0 ) then
c
            do 2613 , nrofon = 1 , nbfonc
c    dans le triangle NT1
c
              vatrtt(nrofon,q1t,f1cp) = vafoen(nrofon,q1,prf2cn)
c
              vatrtt(nrofon,q2t,f1cp) = unsde*(vafoen(nrofon,q2,prf3cn)+
     >                                        vafoen(nrofon,q4,prf4cn))
c
              vatrtt(nrofon,q3t,f1cp) = vafoen(nrofon,q1,prf1cn)
c
              vatrtt(nrofon,q4t,f1cp) = unsde*(vafoen(nrofon,q6,prf2cn)+
     >                                        vafoen(nrofon,q7,prf3cn))
c
              vatrtt(nrofon,q5t,f1cp) = unsde*(vafoen(nrofon,q7,prf1cn)+
     >                                        vafoen(nrofon,q6,prf4cn))
c
              vatrtt(nrofon,q6t,f1cp) = unsde*(vafoen(nrofon,q2,prf1cn)+
     >                                        vafoen(nrofon,q4,prf2cn))
c
c    dans le triangle NT2
c
              vatrtt(nrofon,q1t,f2cp) = vafoen(nrofon,q1,prf1cn)
c
              vatrtt(nrofon,q2t,f2cp) = vafoen(nrofon,q4,prf4cn)
c
              vatrtt(nrofon,q3t,f2cp) = vafoen(nrofon,q1,prf4cn)
c
              vatrtt(nrofon,q4t,f2cp) = vatrtt(nrofon,q5t,f1cp)
c
              vatrtt(nrofon,q5t,f2cp) = vafoen(nrofon,q8,prf4cn)
c
              vatrtt(nrofon,q6t,f2cp) = unsde*(vafoen(nrofon,q4,prf1cn)+
     >                                        vafoen(nrofon,q2,prf4cn))
c
c    dans le triangle NT3
c
              vatrtt(nrofon,q1t,f3cp) = vafoen(nrofon,q1,prf2cn)
c
              vatrtt(nrofon,q2t,f3cp) = vafoen(nrofon,q1,prf3cn)
c
              vatrtt(nrofon,q3t,f3cp) = vafoen(nrofon,q2,prf3cn)
c
              vatrtt(nrofon,q4t,f3cp) = unsde*(vafoen(nrofon,q2,prf2cn)+
     >                                        vafoen(nrofon,q4,prf3cn))
c
              vatrtt(nrofon,q5t,f3cp) = vafoen(nrofon,q5,prf3cn)
c
              vatrtt(nrofon,q6t,f3cp) = vatrtt(nrofon,q4t,f1cp)
c
2613        continue
c
            elseif  ( g1.ne.0 .and. d1.eq.0 ) then
            do 26131 , nrofon = 1 , nbfonc
c
c    dans le triangle NT1
c
              vatrtt(nrofon,q1t,f1cp) = vafoen(nrofon,q1,prf2cn)
c
              vatrtt(nrofon,q2t,f1cp) = unsde*(vatren(nrofon,q3,prfg2n)+
     >                                         vafoen(nrofon,q4,prf4cn))
c
              vatrtt(nrofon,q3t,f1cp) = vatren(nrofon,q3,prfg2n)
c
              vatrtt(nrofon,q4t,f1cp) = unstr*(vafoen(nrofon,q2,prf2cn)+
     >                                         vatren(nrofon,q1,prfg1n)+
     >                                         vatren(nrofon,q1,prfg3n))
c
              vatrtt(nrofon,q5t,f1cp) = unsde*(vafoen(nrofon,q7,prf1cn)+
     >                                         vafoen(nrofon,q6,prf4cn))
c
              vatrtt(nrofon,q6t,f1cp) = unsde*(vafoen(nrofon,q6,prf2cn)+
     >                                         vatren(nrofon,q6,prfg1n))
c
c    dans le triangle NT2
c
              vatrtt(nrofon,q1t,f2cp) = vafoen(nrofon,q1,prf1cn)
c
              vatrtt(nrofon,q2t,f2cp) = vafoen(nrofon,q4,prf4cn)
c
              vatrtt(nrofon,q3t,f2cp) = vafoen(nrofon,q1,prf4cn)
c
              vatrtt(nrofon,q4t,f2cp) = vatrtt(nrofon,q5t,f1cp)
c
              vatrtt(nrofon,q5t,f2cp) = vafoen(nrofon,q8,prf4cn)
c
              vatrtt(nrofon,q6t,f2cp) = unsde*(vafoen(nrofon,q4,prf1cn)+
     >                                        vafoen(nrofon,q2,prf4cn))
c
c    dans le triangle NT3
c
              vatrtt(nrofon,q1t,f3cp) = vafoen(nrofon,q1,prf2cn)
c
              vatrtt(nrofon,q2t,f3cp) = vatren(nrofon,q2,prfg3n)
c
              vatrtt(nrofon,q3t,f3cp) = vafoen(nrofon,q3,prfg2n)
c
              vatrtt(nrofon,q4t,f3cp) = unstr*(vafoen(nrofon,q2,prf2cn)+
     >                                         vatren(nrofon,q1,prfg1n)+
     >                                         vatren(nrofon,q1,prfg3n))
c
              vatrtt(nrofon,q5t,f3cp) = unstr*(vatren(nrofon,q2,prfg1n)+
     >                                         vatren(nrofon,q2,prfg2n)+
     >                                         vatren(nrofon,q3,prfg3n))
c
              vatrtt(nrofon,q6t,f3cp) = unsde*(vafoen(nrofon,q6,prf2cn)+
     >                                         vatren(nrofon,q6,prfg1n))
c
26131       continue
c
            elseif  ( g1.eq.0 .and. d1.ne.0 ) then
            do 26132 , nrofon = 1 , nbfonc
c
c    dans le triangle NT1
c
              vatrtt(nrofon,q1t,f1cp) = vafoen(nrofon,q1,prf2cn)
c
              vatrtt(nrofon,q2t,f1cp) = unsde*(vafoen(nrofon,q2,prf3cn)+
     >                                         vatren(nrofon,q2,prfd3n))
c
              vatrtt(nrofon,q3t,f1cp) = vatren(nrofon,q3,prfg2n)
c
              vatrtt(nrofon,q4t,f1cp) = unsde*(vafoen(nrofon,q6,prf2cn)+
     >                                         vatren(nrofon,q7,prf3cn))
c
              vatrtt(nrofon,q5t,f1cp) = unstr*(vatren(nrofon,q3,prfg3n)+
     >                                         vatren(nrofon,q2,prfg1n)+
     >                                         vatren(nrofon,q2,prfg2n))
c
              vatrtt(nrofon,q6t,f1cp) = unsde*(vafoen(nrofon,q6,prf2cn)+
     >                                         vatren(nrofon,q6,prfg1n))
c
c    dans le triangle NT2
c
              vatrtt(nrofon,q1t,f2cp) = vafoen(nrofon,q1,prf1cn)
c
              vatrtt(nrofon,q2t,f2cp) = vatren(nrofon,q2,prfd3n)
c
              vatrtt(nrofon,q3t,f2cp) = vatren(nrofon,q3,prfd2n)
c
              vatrtt(nrofon,q4t,f2cp) = unsde*(vafoen(nrofon,q7,prf1cn)+
     >                                         vatren(nrofon,q6,prfd1n))
c
              vatrtt(nrofon,q5t,f2cp) = unstr*(vatren(nrofon,q2,prfd2n)+
     >                                         vatren(nrofon,q2,prfd1n)+
     >                                         vatren(nrofon,q3,prfd3n))
c
              vatrtt(nrofon,q6t,f2cp) = unstr*(vafoen(nrofon,q4,prf1cn)+
     >                                         vatren(nrofon,q3,prfd1n)+
     >                                         vatren(nrofon,q1,prfd2n))
c
c    dans le triangle NT3
c
              vatrtt(nrofon,q1t,f3cp) = vafoen(nrofon,q1,prf2cn)
c
              vatrtt(nrofon,q2t,f3cp) = vafoen(nrofon,q1,prf3cn)
c
              vatrtt(nrofon,q3t,f3cp) = vafoen(nrofon,q2,prf3cn)
c
              vatrtt(nrofon,q4t,f3cp) = unsde*(vafoen(nrofon,q2,prf2cn)+
     >                                        vafoen(nrofon,q4,prf3cn))
c
              vatrtt(nrofon,q5t,f3cp) = vafoen(nrofon,q5,prf3cn)
c
              vatrtt(nrofon,q6t,f3cp) = vatrtt(nrofon,q4t,f1cp)
c
26132       continue
c
            elseif  ( g1.ne.0 .and. d1.ne.0 ) then
            do 26133 , nrofon = 1 , nbfonc
c    dans le triangle NT1
c
              vatrtt(nrofon,q1t,f1cp) = vafoen(nrofon,q1,prf2cn)
c
              vatrtt(nrofon,q2t,f1cp) = unsde*(vatren(nrofon,q3,prfg2n)+
     >                                         vatren(nrofon,q2,prfd3n))
c
              vatrtt(nrofon,q3t,f1cp) = vafoen(nrofon,q1,prf1cn)
c
              vatrtt(nrofon,q4t,f1cp) = unstr*(vafoen(nrofon,q2,prf2cn)+
     >                                         vatren(nrofon,q1,prfg1n)+
     >                                         vatren(nrofon,q1,prfg3n))
c
              vatrtt(nrofon,q5t,f1cp) = unstr*(vatren(nrofon,q3,prfg3n)+
     >                                         vatren(nrofon,q2,prfg1n)+
     >                                         vatren(nrofon,q2,prfg2n))
c
              vatrtt(nrofon,q6t,f1cp) = unsde*(vafoen(nrofon,q6,prf2cn)+
     >                                         vatren(nrofon,q6,prfg1n))
c
c    dans le triangle NT2
c
              vatrtt(nrofon,q1t,f2cp) = vafoen(nrofon,q1,prf1cn)
c
              vatrtt(nrofon,q2t,f2cp) = vatren(nrofon,q2,prfd3n)
c
              vatrtt(nrofon,q3t,f2cp) = vatren(nrofon,q3,prfd2n)
c
              vatrtt(nrofon,q4t,f2cp) = unsde*(vafoen(nrofon,q7,prf1cn)+
     >                                         vatren(nrofon,q6,prfd1n))
c
              vatrtt(nrofon,q5t,f2cp) = unstr*(vatren(nrofon,q2,prfd2n)+
     >                                         vatren(nrofon,q2,prfd1n)+
     >                                         vatren(nrofon,q3,prfd3n))
c
              vatrtt(nrofon,q6t,f2cp) = unstr*(vafoen(nrofon,q4,prf1cn)+
     >                                         vatren(nrofon,q3,prfd1n)+
     >                                         vatren(nrofon,q1,prfd2n))
c
c    dans le triangle NT3
c
              vatrtt(nrofon,q1t,f3cp) = vafoen(nrofon,q1,prf2cn)
c
              vatrtt(nrofon,q2t,f3cp) = vatren(nrofon,q2,prfg3n)
c
              vatrtt(nrofon,q3t,f3cp) = vafoen(nrofon,q3,prfg2n)
c
              vatrtt(nrofon,q4t,f3cp) = unstr*(vafoen(nrofon,q2,prf2cn)+
     >                                         vatren(nrofon,q1,prfg1n)+
     >                                         vatren(nrofon,q1,prfg3n))
c
              vatrtt(nrofon,q5t,f3cp) = unstr*(vatren(nrofon,q2,prfg1n)+
     >                                         vatren(nrofon,q2,prfg2n)+
     >                                         vatren(nrofon,q3,prfg3n))
c
              vatrtt(nrofon,q6t,f3cp) = unsde*(vafoen(nrofon,q6,prf2cn)+
     >                                         vatren(nrofon,q6,prfg1n))
c
26133       continue
            endif
c
c    quadrangle predecoupe en 4 quad et decoupe en trois triangles
c    a l'arete a4
c
            elseif (etanp1 .eq. 34) then
c
            f2cn = nqueca(f1hn+1)
            prf2cn = prfcan(f2cn)
                 f3cn = nqueca(f1hn+2)
                 prf3cn = prfcan(f3cn)
            g1 = 0
            d1 = 0
cgn            write(6,*) 'etanp1', etanp1
cgn            write(6,*) 'f1hn+2=',f1hn+2,
cgn     > 'mod(anhetr(f1hn),10)',mod(anhetr(f1hn),10)
            if ( mod(anhequ(f1hn),10).eq.0 ) then
              f1cn = nqueca(f1hn)
              prf1cn = prfcan(f1cn)
            elseif ( mod(anhequ(f1hn),10).eq.etanp1 ) then
              pf = anfiqu(f1hn)
              g1 = nqueca(pf)
              prfg1n = prfcan(g1)
              g2 = nqueca(pf+1)
              prfg2n = prfcan(g2)
              g3 = nqueca(pf+2)
              prfg3n = prfcan(g3)
            else
              codret = codret + 1
cgn           write(ulsort,*) '_7h A codret', codret
cgn           write (ulsort,texte(langue,4)) 'n  ', trhn
cgn           write (ulsort,texte(langue,5)) 'n  ', etan
cgn           write (ulsort,texte(langue,4)) 'n+1', trhnp1
cgn           write (ulsort,texte(langue,5)) 'n+1', etanp1
            endif
cgn            write(6,*) 'etanp1', etanp1
cgn            write(6,*) 'mod(anhetr(f1hn+3),10)',mod(anhetr(f1hn+3),10)
            if ( mod(anhequ(f1hn+3),10).eq.0 ) then
              f4cn = nqueca(f1hn+3)
              prf4cn = prfcan(f4cn)
            elseif ( mod(anhequ(f1hn+3),10).eq.etanp1 ) then
              pf = anfiqu(f1hn+3)
              d1 = nqueca(pf)
              prfd1n = prfcan(d1)
              d2 = nqueca(pf+1)
              prfd2n = prfcan(d2)
              d3 = nqueca(pf+2)
              prfd3n = prfcan(d3)
            else
              codret = codret + 1
cgn           write (ulsort,*) '_5h B codret', codret
cgn           write (ulsort,texte(langue,4)) 'n  ', trhn
cgn           write (ulsort,texte(langue,5)) 'n  ', etan
cgn           write (ulsort,texte(langue,4)) 'n+1', trhnp1
cgn           write (ulsort,texte(langue,5)) 'n+1', etanp1
            endif
c
c
            if  ( g1.eq.0 .and. d1.eq.0 ) then
c
            do 2614 , nrofon = 1 , nbfonc
c    dans le triangle NT1
c
              vatrtt(nrofon,q1t,f1cp) = vafoen(nrofon,q1,prf3cn)
c
              vatrtt(nrofon,q2t,f1cp) = unsde*(vafoen(nrofon,q4,prf1cn)+
     >                                         vafoen(nrofon,q2,prf4cn))
c
              vatrtt(nrofon,q3t,f1cp) = vafoen(nrofon,q1,prf2cn)
c
              vatrtt(nrofon,q4t,f1cp) = unsde*(vafoen(nrofon,q6,prf3cn)+
     >                                        vafoen(nrofon,q7,prf4cn))
c
              vatrtt(nrofon,q5t,f1cp) = unsde*(vafoen(nrofon,q6,prf1cn)+
     >                                        vafoen(nrofon,q7,prf2cn))
c
              vatrtt(nrofon,q6t,f1cp) = unsde*(vafoen(nrofon,q2,prf2cn)+
     >                                        vafoen(nrofon,q4,prf3cn))
c
c    dans le triangle NT2
c
              vatrtt(nrofon,q1t,f2cp) = vafoen(nrofon,q1,prf2cn)
c
              vatrtt(nrofon,q2t,f2cp) = vafoen(nrofon,q4,prf1cn)
c
              vatrtt(nrofon,q3t,f2cp) = vafoen(nrofon,q1,prf1cn)
c
              vatrtt(nrofon,q4t,f2cp) = vatrtt(nrofon,q5t,f1cp)
c
              vatrtt(nrofon,q5t,f2cp) = vafoen(nrofon,q8,prf1cn)
c
              vatrtt(nrofon,q6t,f2cp) = unsde*(vafoen(nrofon,q2,prf1cn)+
     >                                        vafoen(nrofon,q4,prf2cn))
c
c    dans le triangle NT3
c
              vatrtt(nrofon,q1t,f3cp) = vafoen(nrofon,q1,prf3cn)
c
              vatrtt(nrofon,q2t,f3cp) = vafoen(nrofon,q1,prf4cn)
c
              vatrtt(nrofon,q3t,f3cp) = vafoen(nrofon,q2,prf4cn)
c
              vatrtt(nrofon,q4t,f3cp) = unsde*(vafoen(nrofon,q2,prf3cn)+
     >                                        vafoen(nrofon,q4,prf4cn))
c
              vatrtt(nrofon,q5t,f3cp) = vafoen(nrofon,q5,prf4cn)
c
              vatrtt(nrofon,q6t,f3cp) = vatrtt(nrofon,q4t,f1cp)
c
2614        continue
c
            elseif  ( g1.ne.0 .and. d1.eq.0 ) then
            do 26141 , nrofon = 1 , nbfonc
c
c    dans le triangle NT1
c
              vatrtt(nrofon,q1t,f1cp) = vafoen(nrofon,q1,prf3cn)
c
              vatrtt(nrofon,q2t,f1cp) = unsde*(vafoen(nrofon,q2,prf4cn)+
     >                                         vatren(nrofon,q2,prfg3n))
c
              vatrtt(nrofon,q3t,f1cp) = vafoen(nrofon,q1,prf2cn)
c
              vatrtt(nrofon,q4t,f1cp) = unsde*(vafoen(nrofon,q6,prf3cn)+
     >                                         vafoen(nrofon,q7,prf4cn))
c
              vatrtt(nrofon,q5t,f1cp) = unsde*(vafoen(nrofon,q7,prf2cn)+
     >                                         vatren(nrofon,q6,prfg1n))
c
              vatrtt(nrofon,q6t,f1cp) = unsde*(vafoen(nrofon,q2,prf2cn)+
     >                                         vafoen(nrofon,q4,prf3cn))
c
c    dans le triangle NT2
c
              vatrtt(nrofon,q1t,f2cp) = vafoen(nrofon,q1,prf2cn)
c
              vatrtt(nrofon,q2t,f2cp) = vatren(nrofon,q2,prfg3n)
c
              vatrtt(nrofon,q3t,f2cp) = vatren(nrofon,q3,prfg2n)
c
              vatrtt(nrofon,q4t,f2cp) = unsde*(vafoen(nrofon,q7,prf2cn)+
     >                                         vatren(nrofon,q6,prfg1n))
c
              vatrtt(nrofon,q5t,f2cp) = unstr*(vatren(nrofon,q2,prfg1n)+
     >                                         vatren(nrofon,q2,prfg2n)+
     >                                         vatren(nrofon,q3,prfg3n))
c
              vatrtt(nrofon,q6t,f2cp) = unstr*(vafoen(nrofon,q4,prf2cn)+
     >                                         vatren(nrofon,q1,prfg2n)+
     >                                         vatren(nrofon,q3,prfg1n))
c
c    dans le triangle NT3
c
              vatrtt(nrofon,q1t,f3cp) = vafoen(nrofon,q1,prf3cn)
c
              vatrtt(nrofon,q2t,f3cp) = vafoen(nrofon,q1,prf4cn)
c
              vatrtt(nrofon,q3t,f3cp) = vafoen(nrofon,q2,prf4cn)
c
              vatrtt(nrofon,q4t,f3cp) = unsde*(vafoen(nrofon,q2,prf3cn)+
     >                                        vafoen(nrofon,q4,prf4cn))
c
              vatrtt(nrofon,q5t,f3cp) = vafoen(nrofon,q5,prf4cn)
c
              vatrtt(nrofon,q6t,f3cp) = vatrtt(nrofon,q4t,f1cp)
c
26141       continue
c
            elseif  ( g1.eq.0 .and. d1.ne.0 ) then
            do 26142 , nrofon = 1 , nbfonc
c
c    dans le triangle NT1
c
              vatrtt(nrofon,q1t,f1cp) = vafoen(nrofon,q1,prf3cn)
c
              vatrtt(nrofon,q2t,f1cp) = unsde*(vafoen(nrofon,q4,prf1cn)+
     >                                         vatren(nrofon,q3,prfd2n))
c
              vatrtt(nrofon,q3t,f1cp) = vafoen(nrofon,q1,prf2cn)
c
              vatrtt(nrofon,q4t,f1cp) = unsde*(vafoen(nrofon,q6,prf3cn)+
     >                                         vatren(nrofon,q6,prfd1n))
c
              vatrtt(nrofon,q5t,f1cp) = unsde*(vafoen(nrofon,q6,prf1cn)+
     >                                         vafoen(nrofon,q7,prf2cn))
c
              vatrtt(nrofon,q6t,f1cp) = unsde*(vafoen(nrofon,q2,prf2cn)+
     >                                         vafoen(nrofon,q4,prf3cn))
c
c    dans le triangle NT2
c
              vatrtt(nrofon,q1t,f2cp) = vafoen(nrofon,q1,prf2cn)
c
              vatrtt(nrofon,q2t,f2cp) = vafoen(nrofon,q4,prf1cn)
c
              vatrtt(nrofon,q3t,f2cp) = vafoen(nrofon,q1,prf1cn)
c
              vatrtt(nrofon,q4t,f2cp) = vatrtt(nrofon,q5t,f1cp)
c
              vatrtt(nrofon,q5t,f2cp) = vafoen(nrofon,q8,prf1cn)
c
              vatrtt(nrofon,q6t,f2cp) = unsde*(vafoen(nrofon,q1,prf1cn)+
     >                                        vafoen(nrofon,q4,prf2cn))
c
c    dans le triangle NT3
c
              vatrtt(nrofon,q1t,f3cp) = vafoen(nrofon,q1,prf3cn)
c
              vatrtt(nrofon,q2t,f3cp) = vatren(nrofon,q2,prfd3n)
c
              vatrtt(nrofon,q3t,f3cp) = vatren(nrofon,q3,prfd2n)
c
              vatrtt(nrofon,q4t,f3cp) = unstr*(vafoen(nrofon,q2,prf3cn)+
     >                                         vatren(nrofon,q1,prfd1n)+
     >                                         vatren(nrofon,q1,prfd3n))
c
              vatrtt(nrofon,q5t,f3cp) = unstr*(vafoen(nrofon,q2,prfd1n)+
     >                                         vatren(nrofon,q2,prfd2n)+
     >                                         vatren(nrofon,q3,prfd3n))
c
              vatrtt(nrofon,q6t,f3cp) = unsde*(vafoen(nrofon,q6,prf3cn)+
     >                                         vatren(nrofon,q6,prfd1n))
c
26142       continue
c
            elseif  ( g1.ne.0 .and. d1.ne.0 ) then
            do 26143 , nrofon = 1 , nbfonc
c    dans le triangle NT1
c
              vatrtt(nrofon,q1t,f1cp) = vafoen(nrofon,q1,prf3cn)
c
              vatrtt(nrofon,q2t,f1cp) = unsde*(vatren(nrofon,q3,prfg2n)+
     >                                         vatren(nrofon,q2,prfd3n))
c
              vatrtt(nrofon,q3t,f1cp) = vafoen(nrofon,q1,prf2cn)
c
              vatrtt(nrofon,q4t,f1cp) = unsde*(vafoen(nrofon,q6,prf3cn)+
     >                                         vatren(nrofon,q6,prfg1n))
c
              vatrtt(nrofon,q5t,f1cp) = unsde*(vafoen(nrofon,q7,prf2cn)+
     >                                         vatren(nrofon,q6,prfd1n))
c
              vatrtt(nrofon,q6t,f1cp) = unsde*(vafoen(nrofon,q2,prf2cn)+
     >                                         vafoen(nrofon,q4,prf3cn))
c
c    dans le triangle NT2
c
              vatrtt(nrofon,q1t,f2cp) = vafoen(nrofon,q1,prf2cn)
c
              vatrtt(nrofon,q2t,f2cp) = vatren(nrofon,q2,prfd3n)
c
              vatrtt(nrofon,q3t,f2cp) = vatren(nrofon,q3,prfd2n)
c
              vatrtt(nrofon,q4t,f2cp) = unsde*(vafoen(nrofon,q7,prf2cn)+
     >                                         vatren(nrofon,q6,prfg1n))
c
              vatrtt(nrofon,q5t,f2cp) = unstr*(vatren(nrofon,q2,prfg1n)+
     >                                         vatren(nrofon,q2,prfg2n)+
     >                                         vatren(nrofon,q3,prfg3n))
c
              vatrtt(nrofon,q6t,f2cp) = unstr*(vafoen(nrofon,q4,prf2cn)+
     >                                         vatren(nrofon,q1,prfg2n)+
     >                                         vatren(nrofon,q3,prfg1n))
c
c    dans le triangle NT3
c
              vatrtt(nrofon,q1t,f3cp) = vafoen(nrofon,q1,prf3cn)
c
              vatrtt(nrofon,q2t,f3cp) = vatren(nrofon,q2,prfd3n)
c
              vatrtt(nrofon,q3t,f3cp) = vatren(nrofon,q3,prfd2n)
c
              vatrtt(nrofon,q4t,f3cp) = unstr*(vafoen(nrofon,q2,prf3cn)+
     >                                         vatren(nrofon,q1,prfd1n)+
     >                                         vatren(nrofon,q1,prfd3n))
c
              vatrtt(nrofon,q5t,f3cp) = unstr*(vafoen(nrofon,q2,prfd1n)+
     >                                         vatren(nrofon,q2,prfd2n)+
     >                                         vatren(nrofon,q3,prfd3n))
c
              vatrtt(nrofon,q6t,f3cp) = unsde*(vafoen(nrofon,q6,prf3cn)+
     >                                         vatren(nrofon,q6,prfd1n))
c
26143       continue
            endif
c
            endif
c
            endif
