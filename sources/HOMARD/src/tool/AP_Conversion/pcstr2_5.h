#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', 'pcstr2_5'
#endif
c
c         on repere le numero dans le calcul pour le fils aine
c         a l'iteration n
c
          f1hn = anfitr(trhn)
          f1hp = filtri(trhnp1)
          f1cn = ntreca(f1hn)
          prf1cn = prfcan(f1cn)
cgn          print 17893, prf1cn
cgn17893 format('prf1cn = ',i8)
c
          if ( etanp1.eq.0 ) then
            trcnp1 = ntrsca(trhnp1)
            prfcap(trcnp1) = 1
          elseif ( etanp1.eq.1 .or. etanp1.eq.2 .or. etanp1.eq.3 ) then
            f1cp = ntrsca(f1hp)
            f2cp = ntrsca(f1hp+1)
cgn          print 17894, f1cp,f2cp
cgn17894 format('f1cp = ',i8,', f2cp = ',i8)
            prfcap(f1cp) = 1
            prfcap(f2cp) = 1
          endif
c
c doc.4.0. ===> etanp1 = 0 : le triangle est actif ; il est reactive.
c               remarque : cela arrive seulement avec du deraffinement.
c                   .                         .
c                  . .                       . .
c                 .   .                     .   .
c                .     .                   .     .
c               .........      ===>       .       .
c              . .     . .               .         .
c             .   .   .   .             .           .
c            .     . .     .           .             .
c           .................         .................
c
          if ( etanp1.eq.0 ) then
cgn        print *,'Passage par etanp1.eq.0'
c
            f2cn = ntreca(f1hn+1)
            f3cn = ntreca(f1hn+2)
            f4cn = ntreca(f1hn+3)
            prf2cn = prfcan(f2cn)
            prf3cn = prfcan(f3cn)
            prf4cn = prfcan(f4cn)
c
            do 241 , nrofon = 1 , nbfonc
c
              vafott(nrofon,q1,trcnp1) = vafoen(nrofon,q1,prf2cn) 
              vafott(nrofon,q2,trcnp1) = vafoen(nrofon,q2,prf3cn)
              vafott(nrofon,q3,trcnp1) = vafoen(nrofon,q3,prf4cn)
              vafott(nrofon,q4,trcnp1) = 
     >                    unstr * ( vafoen(nrofon,q1,prf3cn)
     >                            + vafoen(nrofon,q2,prf2cn)
     >                            + vafoen(nrofon,q3,prf1cn) )
              vafott(nrofon,q5,trcnp1) =
     >                    unstr * ( vafoen(nrofon,q1,prf1cn)
     >                            + vafoen(nrofon,q2,prf4cn)
     >                            + vafoen(nrofon,q3,prf3cn) )
              vafott(nrofon,q6,trcnp1) = 
     >                    unstr * ( vafoen(nrofon,q1,prf4cn)
     >                            + vafoen(nrofon,q2,prf1cn)
     >                            + vafoen(nrofon,q3,prf2cn) )
c
  241       continue
c
c doc.4.1/2/3. ===> etanp1 = 1 : le triangle est decoupe en deux selon
c                                l'arete 1
c                  remarque : il y a 4 cas de figure selon les decoupages
c                             eventuels des fils a l'iteration n
c                  remarque : cela arrive seulement avec du
c                             deraffinnement.
c
          elseif ( etanp1.eq.1 ) then
cgn        print *,'Passage par etanp1.eq.1'
c
            f2cn = ntreca(f1hn+1)
            prf2cn = prfcan(f2cn)
            g1 = 0
            d1 = 0
cgn            write(6,*) 'etanp1', etanp1
cgn            write(6,*) 'f1hn+2=',f1hn+2,
cgn     > 'mod(anhetr(f1hn+2),10)',mod(anhetr(f1hn+2),10)
            if ( mod(anhetr(f1hn+2),10).eq.0 ) then
              f3cn = ntreca(f1hn+2)
              prf3cn = prfcan(f3cn)
            elseif ( mod(anhetr(f1hn+2),10).eq.etanp1 ) then
              pf = anfitr(f1hn+2)
              g2 = ntreca(pf)
              prfg2n = prfcan(g2)
              g1 = ntreca(pf+1)
              prfg1n = prfcan(g1)
            else
              codret = codret + 1
              write(ulsort,*) '_5h A codret', codret
              write (ulsort,texte(langue,4)) 'n  ', trhn
              write (ulsort,texte(langue,5)) 'n  ', etan
              write (ulsort,texte(langue,4)) 'n+1', trhnp1
              write (ulsort,texte(langue,5)) 'n+1', etanp1
            endif
cgn            write(6,*) 'etanp1', etanp1
cgn            write(6,*) 'mod(anhetr(f1hn+3),10)',mod(anhetr(f1hn+3),10)
            if ( mod(anhetr(f1hn+3),10).eq.0 ) then
              f4cn = ntreca(f1hn+3)
              prf4cn = prfcan(f4cn)
            elseif ( mod(anhetr(f1hn+3),10).eq.etanp1 ) then
              pf = anfitr(f1hn+3)
              d2 = ntreca(pf)
              prfd2n = prfcan(d2)
              d1 = ntreca(pf+1)
              prfd1n = prfcan(d1)
            else
              codret = codret + 1
              write (ulsort,*) '_5h B codret', codret
              write (ulsort,texte(langue,4)) 'n  ', trhn
              write (ulsort,texte(langue,5)) 'n  ', etan
              write (ulsort,texte(langue,4)) 'n+1', trhnp1
              write (ulsort,texte(langue,5)) 'n+1', etanp1
            endif
c
            if  ( g1.eq.0 .and. d1.eq.0 ) then
c
c                   .                         .
c                  . .                       ...
c                 .   .                     . . .
c                .     .                   .  .  .
c               .........      ===>       .   .   .
c              . .     . .               .    .    .
c             .   .   .   .             .     .     .
c            .     . .     .           .      .      .
c           .................         .................
c                  A1                         A1
c
c            
              do 24210 , nrofon = 1 , nbfonc
c            
c        Pour le triangle fils aine NF
c            
                vafott(nrofon,q1,f1cp) = vafoen(nrofon,q1,prf2cn)
c
                vafott(nrofon,q2,f1cp) = unstr*vafoen(nrofon,q1,prf1cn)
     >                                  +destr*vafoen(nrofon,q2,prf4cn)
c
                vafott(nrofon,q3,f1cp) = vafoen(nrofon,q3,prf4cn)
c
                vafott(nrofon,q4,f1cp) = unsde*(vafoen(nrofon,q5,prf1cn)
     >                                        +vafoen(nrofon,q5,prf2cn))
c
                vafott(nrofon,q5,f1cp) = vafoen(nrofon,q5,prf4cn)
c
                vafott(nrofon,q6,f1cp) = unstr*(vafoen(nrofon,q1,prf4cn)
     >                                        +vafoen(nrofon,q2,prf1cn)
     >                                        +vafoen(nrofon,q3,prf2cn))
c            
c        Pour le triangle fils NF+1
c            
                vafott(nrofon,q1,f2cp) = vafoen(nrofon,q1,prf2cn)
c
                vafott(nrofon,q2,f2cp) = vafoen(nrofon,q2,prf3cn)
c
                vafott(nrofon,q3,f2cp) = unstr*vafoen(nrofon,q1,prf1cn)+
     >                                   destr*vafoen(nrofon,q3,prf3cn)
c
                vafott(nrofon,q4,f2cp) = unstr*(vafoen(nrofon,q1,prf3cn)
     >                                        +vafoen(nrofon,q2,prf2cn)
     >                                        +vafoen(nrofon,q3,prf1cn))
c
              vafott(nrofon,q5,f2cp) = vafoen(nrofon,q5,prf3cn)
c
              vafott(nrofon,q6,f2cp) = vafott(nrofon,q4,f1cp)
c            
24210         continue
c
            elseif  ( g1.ne.0 .and. d1.eq.0 ) then
c
c                   .                         .
c                  . .                       ...
c                 .   .                     . . .
c                .     .                   .  .  .
c               .........      ===>       .   .   .
c              ...     . .               .    .    .
c             . . .   .   .             .     .     .
c            .  .  . .     .           .      .      .
c           .................         .................
c                  A1                         A1
c
              do 24211 , nrofon = 1 , nbfonc
c            
c        Pour le triangle fils aine NF
c            
                vafott(nrofon,q1,f1cp) = vafoen(nrofon,q1,prf2cn)
c
                vafott(nrofon,q2,f1cp) = unstr*vafoen(nrofon,q1,prf1cn)+
     >                                   destr*vafoen(nrofon,q2,prf4cn)
c
                vafott(nrofon,q3,f1cp) = vafoen(nrofon,q3,prf4cn)
c
                vafott(nrofon,q4,f1cp) = unsde*(vafoen(nrofon,q5,prf1cn)
     >                                        +vafoen(nrofon,q5,prf2cn))
c
                vafott(nrofon,q5,f1cp) = vafoen(nrofon,q5,prf4cn)
c
                vafott(nrofon,q6,f1cp) = unstr*(vafoen(nrofon,q1,prf4cn)
     >                                        +vafoen(nrofon,q2,prf1cn)
     >                                        +vafoen(nrofon,q3,prf2cn))
c            
c        Pour le triangle fils NF+1
c            
                vafott(nrofon,q1,f2cp) = vafoen(nrofon,q1,prf2cn)
c
                vafott(nrofon,q2,f2cp) = vafoen(nrofon,q2,prfg1n)
c
                vafott(nrofon,q3,f2cp) = unstr*vafoen(nrofon,q1,prf1cn)
     >                                  +destr*vafoen(nrofon,q3,prfg2n)
c
                vafott(nrofon,q4,f2cp) = unstr*(vafoen(nrofon,q3,prf1cn)
     >                                      +vafoen(nrofon,q2,prf2cn))+
     >                           unsqu*destr*(vafoen(nrofon,q1,prfg1n)
     >                                      +vafoen(nrofon,q2,prfg2n))
c
              vafott(nrofon,q5,f2cp) = unsde*(vafoen(nrofon,q5,prfg1n)+
     >                                        vafoen(nrofon,q5,prfg2n))
c
              vafott(nrofon,q6,f2cp) = vafott(nrofon,q4,f1cp)
c            
24211         continue
c
c
            elseif  ( g1.eq.0 .and. d1.ne.0 ) then
c                   .                         .
c                  . .                       ...
c                 .   .                     . . .
c                .     .                   .  .  .
c               .........      ===>       .   .   .
c              . .     ...               .    .    .
c             .   .   . . .             .     .     .
c            .     . .  .  .           .      .      .
c           .................         .................
c                  A1                         A1
c
              do 24212 , nrofon = 1 , nbfonc
c            
c        Pour le triangle fils aine NF
c            
                vafott(nrofon,q1,f1cp) = vafoen(nrofon,q1,prf2cn)
c
                vafott(nrofon,q2,f1cp) = unstr*vafoen(nrofon,q1,prf1cn)+
     >                                   destr*vafoen(nrofon,q2,prfd1n)
c
                vafott(nrofon,q3,f1cp) = vafoen(nrofon,q3,prfd2n)
c
                vafott(nrofon,q4,f1cp) = unsde*(vafoen(nrofon,q5,prf1cn)
     >                                        +vafoen(nrofon,q5,prf2cn))
c
                vafott(nrofon,q5,f1cp) = unsde*(vafoen(nrofon,q3,prfd1n)
     >                                        +vafoen(nrofon,q2,prfd2n))
c
                vafott(nrofon,q6,f1cp) = unstr*(vafoen(nrofon,q3,prf2cn)
     >                                       +vafoen(nrofon,q2,prf1cn))+
     >                            unsqu*destr*(vafoen(nrofon,q1,prfd1n)
     >                                       +vafoen(nrofon,q1,prfd2n))
c            
c        Pour le triangle fils NF+1
c            
                vafott(nrofon,q1,f2cp) = vafoen(nrofon,q1,prf2cn)
c
                vafott(nrofon,q2,f2cp) = vafoen(nrofon,q2,prf3cn)
c
                vafott(nrofon,q3,f2cp) = unstr*vafoen(nrofon,q1,prf1cn)+
     >                                   destr*vafoen(nrofon,q3,prf3cn)
c
                vafott(nrofon,q4,f2cp) = unstr*(vafoen(nrofon,q1,prf3cn)
     >                                        +vafoen(nrofon,q2,prf2cn)
     >                                        +vafoen(nrofon,q3,prf1cn))
c
              vafott(nrofon,q5,f2cp) = vafoen(nrofon,q5,prf3cn)
c
              vafott(nrofon,q6,f2cp) = vafott(nrofon,q4,f1cp)
c            
24212         continue
c

            else
c
c                   .                         .
c                  . .                       ...
c                 .   .                     . . .
c                .     .                   .  .  .
c               .........      ===>       .   .   .
c              ...     ...               .    .    .
c             . . .   . . .             .     .     .
c            .  .  . .  .  .           .      .      .
c           .................         .................
c                  A1                         A1
c
              do 24213 , nrofon = 1 , nbfonc
c            
c        Pour le triangle fils aine NF
c            
                vafott(nrofon,q1,f1cp) = vafoen(nrofon,q1,prf2cn)
c
                vafott(nrofon,q2,f1cp) = unstr*vafoen(nrofon,q1,prf1cn)+
     >                                   destr*vafoen(nrofon,q2,prfd1n)
c
                vafott(nrofon,q3,f1cp) = vafoen(nrofon,q3,prfd2n)
c
                vafott(nrofon,q4,f1cp)=unsde*(vafoen(nrofon,q5,prf1cn)+
     >                                       vafoen(nrofon,q5,prf2cn))
c
                vafott(nrofon,q5,f1cp)=unsde*(vafoen(nrofon,q3,prfd1n)+
     >                                        vafoen(nrofon,q2,prfd2n))
c
                vafott(nrofon,q6,f1cp) = unstr*(vafoen(nrofon,q3,prf2cn)
     >                                      +vafoen(nrofon,q2,prf1cn))+
     >                           unsqu*destr*(vafoen(nrofon,q1,prfd1n)
     >                                      +vafoen(nrofon,q1,prfd2n))
c            
c        Pour le triangle fils NF+1
c            
                vafott(nrofon,q1,f2cp) = vafoen(nrofon,q1,prf2cn)
c
                vafott(nrofon,q2,f2cp) = vafoen(nrofon,q2,prfg1n)
c
                vafott(nrofon,q3,f2cp) = unstr*vafoen(nrofon,q1,prf1cn)+
     >                                   destr*vafoen(nrofon,q3,prfg2n)
c
                vafott(nrofon,q4,f2cp) = unstr*(vafoen(nrofon,q3,prf1cn)
     >                                       +vafoen(nrofon,q2,prf2cn))+
     >                             unsqu*destr*(vafoen(nrofon,q1,prfg1n)
     >                                       +vafoen(nrofon,q2,prfg2n))
c
                vafott(nrofon,q5,f2cp) = unsde*(vafoen(nrofon,q5,prfg1n)
     >                                        +vafoen(nrofon,q5,prfg2n))
c
                vafott(nrofon,q6,f2cp) = vafott(nrofon,q4,f1cp)
c            
24213         continue
c
            endif
c
c doc.4.1/2/3. ===> etanp1 = 2 : le triangle est decoupe en deux selon
c                                l'arete 2
c
          elseif ( etanp1.eq.2  ) then
cgn        print *,'Passage par etanp1.eq.2'
c          
            f3cn = ntreca(f1hn+2)
            prf3cn = prfcan(f3cn)
            g1 = 0
            d1 = 0
            if ( mod(anhetr(f1hn+1),10).eq.0 ) then
              f2cn = ntreca(f1hn+1)
              prf2cn = prfcan(f2cn)
            elseif ( mod(anhetr(f1hn+1),10).eq.etanp1 ) then
              pf = anfitr(f1hn+1)
              d2 = ntreca(pf+1)
              prfd2n = prfcan(d2)
              d1 = ntreca(pf)
              prfd1n = prfcan(d1)
            else
              codret = codret + 1
              write (ulsort,*) '_5h C codret', codret
              write (ulsort,texte(langue,4)) 'n  ', trhn
              write (ulsort,texte(langue,5)) 'n  ', etan
              write (ulsort,texte(langue,4)) 'n+1', trhnp1
              write (ulsort,texte(langue,5)) 'n+1', etanp1
            endif
            if ( mod(anhetr(f1hn+3),10).eq.0 ) then
              f4cn = ntreca(f1hn+3)
              prf4cn = prfcan(f4cn)
            elseif ( mod(anhetr(f1hn+3),10).eq.etanp1 ) then
              pf = anfitr(f1hn+3)
              g2 = ntreca(pf+1)
              prfg2n = prfcan(g2)
              g1 = ntreca(pf)
              prfg1n = prfcan(g1)
            else
              codret = codret + 1
              write (ulsort,*) '_5h D codret', codret
              write (ulsort,texte(langue,4)) 'n  ', trhn
              write (ulsort,texte(langue,5)) 'n  ', etan
              write (ulsort,texte(langue,4)) 'n+1', trhnp1
              write (ulsort,texte(langue,5)) 'n+1', etanp1
            endif
c
            if  ( g1.eq.0 .and. d1.eq.0 ) then
c
c
c                   .                         .
c                  . .                       ...
c                 .   .                     . . .
c                .     .                   .  .  .
c               .........      ===>       .   .   .
c              . .     . .               .    .    .
c             .   .   .   .             .     .     .
c            .     . .     .           .      .      .
c           .................         .................
c                  A2                         A2
c
c            
c            
              do 24220 , nrofon = 1 , nbfonc
c            
c        Pour le triangle fils aine NF
c            
                vafott(nrofon,q1,f1cp) = destr*vafoen(nrofon,q1,prf4cn)+
     >                                   unstr*vafoen(nrofon,q2,prf1cn)
c
                vafott(nrofon,q2,f1cp) = vafoen(nrofon,q2,prf3cn)
c
                vafott(nrofon,q3,f1cp) = vafoen(nrofon,q3,prf4cn)
c
                vafott(nrofon,q4,f1cp) = unsde*(vafoen(nrofon,q6,prf1cn)
     >                                        +vafoen(nrofon,q6,prf3cn))
                vafott(nrofon,q5,f1cp) = unstr*(vafoen(nrofon,q1,prf1cn)
     >                                        +vafoen(nrofon,q2,prf4cn)
     >                                        +vafoen(nrofon,q3,prf3cn))
c
                vafott(nrofon,q6,f1cp) = vafoen(nrofon,q6,prf4cn)
c            
c        Pour le triangle fils NF+1
c            
                vafott(nrofon,q1,f2cp) = vafoen(nrofon,q1,prf2cn)
c
                vafott(nrofon,q2,f2cp) = vafoen(nrofon,q2,prf3cn)
c
                vafott(nrofon,q3,f2cp) = destr*vafoen(nrofon,q3,prf2cn)+
     >                                   unstr*vafoen(nrofon,q2,prf1cn) 
c
                vafott(nrofon,q4,f2cp) = unstr*(vafoen(nrofon,q1,prf3cn)
     >                                        +vafoen(nrofon,q2,prf2cn)
     >                                        +vafoen(nrofon,q3,prf1cn))
c
                vafott(nrofon,q5,f2cp) = vafott(nrofon,q4,f1cp)
c
                vafott(nrofon,q6,f2cp) = vafoen(nrofon,q6,prf2cn)
c            
24220        continue
c
c
            elseif  ( g1.ne.0 .and. d1.eq.0 ) then
c
c                   .                         .
c                  . .                       ...
c                 .   .                     . . .
c                .     .                   .  .  .
c               .........      ===>       .   .   .
c              ...     . .               .    .    .
c             . . .   .   .             .     .     .
c            .  .  . .     .           .      .      .
c           .................         .................
c                  A2                         A2
c
c            
              do 24221 , nrofon = 1 , nbfonc
c            
c        Pour le triangle fils aine NF
c            
                vafott(nrofon,q1,f1cp) = destr*vafoen(nrofon,q1,prf4cn)+
     >                                   unstr*vafoen(nrofon,q2,prf1cn)
c
                vafott(nrofon,q2,f1cp) = vafoen(nrofon,q2,prf3cn)
c
                vafott(nrofon,q3,f1cp) = vafoen(nrofon,q3,prf4cn)
c
                vafott(nrofon,q4,f1cp) = unsde*(vafoen(nrofon,q6,prf1cn)
     >                                        +vafoen(nrofon,q6,prf3cn))
                vafott(nrofon,q5,f1cp) = unstr*(vafoen(nrofon,q1,prf1cn)
     >                                        +vafoen(nrofon,q2,prf4cn)
     >                                        +vafoen(nrofon,q3,prf3cn))
c
                vafott(nrofon,q6,f1cp) = vafoen(nrofon,q6,prf4cn)
c            
c        Pour le triangle fils NF+1
c            
                vafott(nrofon,q1,f2cp) = vafoen(nrofon,q1,prfd2n)
c
                vafott(nrofon,q2,f2cp) = vafoen(nrofon,q2,prf3cn)
c
                vafott(nrofon,q3,f2cp) = destr*vafoen(nrofon,q3,prfd1n)+
     >                                   unstr*vafoen(nrofon,q2,prf1cn) 
c
                vafott(nrofon,q4,f2cp) = unstr*(vafoen(nrofon,q1,prf3cn)
     >                                      +vafoen(nrofon,q3,prf1cn))+
     >                            unsqu*destr*(vafoen(nrofon,q2,prfd1n)+
     >                                        vafoen(nrofon,q2,prfd2n))
c
                vafott(nrofon,q5,f2cp) = vafott(nrofon,q4,f1cp)
c
                vafott(nrofon,q6,f2cp) = unsde*(vafoen(nrofon,q1,prfd1n)
     >                                        +vafoen(nrofon,q3,prfd2n))
c            
24221        continue
c
            elseif  ( g1.eq.0 .and. d1.ne.0 ) then
c                   .                         .
c                  . .                       ...
c                 .   .                     . . .
c                .     .                   .  .  .
c               .........      ===>       .   .   .
c              . .     ...               .    .    .
c             .   .   . . .             .     .     .
c            .     . .  .  .           .      .      .
c           .................         .................
c                  A2                         A2
c
c            
              do 24222 , nrofon = 1 , nbfonc
c            
c        Pour le triangle fils aine NF
c            
                vafott(nrofon,q1,f1cp) = destr*vafoen(nrofon,q3,prfg2n)+
     >                                   unstr*vafoen(nrofon,q2,prf1cn)
c
                vafott(nrofon,q2,f1cp) = vafoen(nrofon,q2,prf3cn)
c
                vafott(nrofon,q3,f1cp) = vafoen(nrofon,q3,prfg1n)
c
                vafott(nrofon,q4,f1cp) = unsde*(vafoen(nrofon,q6,prf1cn)
     >                                       +vafoen(nrofon,q6,prf3cn))
                vafott(nrofon,q5,f1cp) = unstr*(vafoen(nrofon,q1,prf1cn)
     >                                       +vafoen(nrofon,q3,prf3cn))+
     >                            unsqu*destr*(vafoen(nrofon,q2,prfg1n)
     >                                       +vafoen(nrofon,q2,prfg2n))
c
                vafott(nrofon,q6,f1cp) = unsde*(vafoen(nrofon,q3,prfg1n)
     >                                        +vafoen(nrofon,q3,prfg2n))
c            
c        Pour le triangle fils NF+1
                vafott(nrofon,q1,f2cp) = vafoen(nrofon,q1,prf2cn)
c
                vafott(nrofon,q2,f2cp) = vafoen(nrofon,q2,prf3cn)
c
                vafott(nrofon,q3,f2cp) = destr*vafoen(nrofon,q3,prf2cn)+
     >                                   unstr*vafoen(nrofon,q2,prf1cn) 
c
                vafott(nrofon,q4,f2cp) = unstr*(vafoen(nrofon,q1,prf3cn)
     >                                        +vafoen(nrofon,q2,prf2cn)
     >                                        +vafoen(nrofon,q3,prf1cn))
c
                vafott(nrofon,q5,f2cp) = vafott(nrofon,q4,f1cp)
c
                vafott(nrofon,q6,f2cp) = vafoen(nrofon,q6,prf2cn)
24222        continue
c
            else
c
c                   .                         .
c                  . .                       ...
c                 .   .                     . . .
c                .     .                   .  .  .
c               .........      ===>       .   .   .
c              ...     ...               .    .    .
c             . . .   . . .             .     .     .
c            .  .  . .  .  .           .      .      .
c           .................         .................
c                  A2                         A2
c
c            
              do 24223 , nrofon = 1 , nbfonc
c            
c        Pour le triangle fils aine NF
c            
                vafott(nrofon,q1,f1cp) = destr*vafoen(nrofon,q3,prfg2n)+
     >                                   unstr*vafoen(nrofon,q2,prf1cn)
c
                vafott(nrofon,q2,f1cp) = vafoen(nrofon,q2,prf3cn)
c
                vafott(nrofon,q3,f1cp) = vafoen(nrofon,q3,prfg1n)
c
                vafott(nrofon,q4,f1cp) = unsde*(vafoen(nrofon,q6,prf1cn)
     >                                       +vafoen(nrofon,q6,prf3cn))
                vafott(nrofon,q5,f1cp) = unstr*(vafoen(nrofon,q1,prf1cn)
     >                                      +vafoen(nrofon,q3,prf3cn))+
     >                             unsqu*destr*(vafoen(nrofon,q2,prfg1n)
     >                                        +vafoen(nrofon,q2,prfg2n))
c
                vafott(nrofon,q6,f1cp) = unsde*(vafoen(nrofon,q3,prfg1n)
     >                                       +vafoen(nrofon,q3,prfg2n))
c            
                vafott(nrofon,q6,f1cp) = vafoen(nrofon,q6,prf4cn)
c            
c        Pour le triangle fils NF+1
c            
                vafott(nrofon,q1,f2cp) = vafoen(nrofon,q1,prfd2n)
c
                vafott(nrofon,q2,f2cp) = vafoen(nrofon,q2,prf3cn)
c
                vafott(nrofon,q3,f2cp) = destr*vafoen(nrofon,q3,prfd1n)+
     >                                   unstr*vafoen(nrofon,q2,prf1cn) 
c
                vafott(nrofon,q4,f2cp) = unstr*(vafoen(nrofon,q1,prf3cn)
     >                                      +vafoen(nrofon,q3,prf1cn))+
     >                           unsqu*destr*(vafoen(nrofon,q2,prfd1n)+
     >                                        vafoen(nrofon,q2,prfd2n))
c
                vafott(nrofon,q5,f2cp) = vafott(nrofon,q4,f1cp)
c
                vafott(nrofon,q6,f2cp) = unsde*(vafoen(nrofon,q1,prfd1n)
     >                                       +vafoen(nrofon,q3,prfd2n))
c            
24223        continue
            endif
c doc.4.1/2/3. ===> etanp1 = 3 : le triangle est decoupe en deux selon
c                                l'arete 3
c
          elseif ( etanp1.eq.3  ) then
cgn        print *,'Passage par etanp1.eq.3'
c
            f4cn = ntreca(f1hn+3)
            prf4cn = prfcan(f4cn)
            g1 = 0
            d1 = 0
cgn            write(6,*) 'etanp1', etanp1
cgn            write(6,*) 'mod(anhetr(f1hn+1),10)',mod(anhetr(f1hn+1),10)
            if ( mod(anhetr(f1hn+1),10).eq.0 ) then
              f2cn = ntreca(f1hn+1)
              prf2cn = prfcan(f2cn)
            elseif ( mod(anhetr(f1hn+1),10).eq.etanp1 ) then
              pf = anfitr(f1hn+1)
              g1 = ntreca(pf+1)
              prfg1n = prfcan(g1)
              g2 = ntreca(pf)
              prfg2n = prfcan(g2)
            else
              codret = codret + 1
              write (ulsort,*) '_5h E codret', codret
              write (ulsort,texte(langue,4)) 'n  ', trhn
              write (ulsort,texte(langue,5)) 'n  ', etan
              write (ulsort,texte(langue,4)) 'n+1', trhnp1
              write (ulsort,texte(langue,5)) 'n+1', etanp1
            endif
cgn            write(6,*) 'etanp1', etanp1
cgn            write(6,*) 'mod(anhetr(f1hn+2),10)',mod(anhetr(f1hn+2),10)
            if ( mod(anhetr(f1hn+2),10).eq.0 ) then
              f3cn = ntreca(f1hn+2)
              prf3cn = prfcan(f3cn)
            elseif ( mod(anhetr(f1hn+2),10).eq.etanp1 ) then
              pf = anfitr(f1hn+2)
              d1 = ntreca(pf+1)
              prfd1n = prfcan(d1)
              d2 = ntreca(pf)
              prfd2n = prfcan(d2)
            else
              codret = codret + 1
              write (ulsort,*) '_5h F codret', codret
              write (ulsort,texte(langue,4)) 'n  ', trhn
              write (ulsort,texte(langue,5)) 'n  ', etan
              write (ulsort,texte(langue,4)) 'n+1', trhnp1
              write (ulsort,texte(langue,5)) 'n+1', etanp1
            endif
c
            if  ( g1.eq.0 .and. d1.eq.0 ) then
c
c
c                   .                         .
c                  . .                       ...
c                 .   .                     . . .
c                .     .                   .  .  .
c               .........      ===>       .   .   .
c              . .     . .               .    .    .
c             .   .   .   .             .     .     .
c            .     . .     .           .      .      .
c           .................         .................
c                  A3                         A3
c            
c            
              do 24230 , nrofon = 1 , nbfonc
c            
c        Pour le triangle fils aine NF
c            
                vafott(nrofon,q1,f1cp) = destr*vafoen(nrofon,q1,prf3cn)+
     >                                   unstr*vafoen(nrofon,q3,prf1cn)
c
                vafott(nrofon,q2,f1cp) = vafoen(nrofon,q2,prf3cn)
c
                vafott(nrofon,q3,f1cp) = vafoen(nrofon,q3,prf4cn)
c
                vafott(nrofon,q4,f1cp) = vafoen(nrofon,q4,prf3cn)
c
                vafott(nrofon,q5,f1cp) = unstr*(vafoen(nrofon,q1,prf1cn)
     >                                        +vafoen(nrofon,q2,prf4cn)
     >                                        +vafoen(nrofon,q3,prf3cn))
c
                vafott(nrofon,q6,f1cp) = unsde*(vafoen(nrofon,q4,prf1cn)
     >                                        +vafoen(nrofon,q4,prf4cn))
c            
c        Pour le triangle fils NF+1
c            
                vafott(nrofon,q1,f2cp) = vafoen(nrofon,q1,prf2cn)
c
                vafott(nrofon,q2,f2cp) = destr*vafoen(nrofon,q2,prf2cn)+
     >                                   unstr*vafoen(nrofon,q3,prf1cn)
c
               vafott(nrofon,q3,f2cp) = vafoen(nrofon,q3,prf4cn)
c
                vafott(nrofon,q4,f2cp) = vafoen(nrofon,q4,prf2cn)
c
                vafott(nrofon,q5,f2cp) = vafott(nrofon,q6,f1cp)
c
                vafott(nrofon,q6,f2cp) = unstr*(vafoen(nrofon,q1,prf4cn)
     >                                        +vafoen(nrofon,q2,prf1cn)
     >                                        +vafoen(nrofon,q3,prf2cn))
c            
24230         continue
c
            elseif  ( g1.ne.0 .and. d1.eq.0 ) then
c
c                   .                         .
c                  . .                       ...
c                 .   .                     . . .
c                .     .                   .  .  .
c               .........      ===>       .   .   .
c              ...     . .               .    .    .
c             . . .   .   .             .     .     .
c            .  .  . .     .           .      .      .
c           .................         .................
c                  A3                         A3
c
c            
              do 24231 , nrofon = 1 , nbfonc
c            
c        Pour le triangle fils aine NF
c            
                vafott(nrofon,q1,f1cp) = destr*vafoen(nrofon,q1,prf3cn)+
     >                                   unstr*vafoen(nrofon,q3,prf1cn)
c
                vafott(nrofon,q2,f1cp) = vafoen(nrofon,q2,prf3cn)
c
                vafott(nrofon,q3,f1cp) = vafoen(nrofon,q3,prf4cn)
c
                vafott(nrofon,q4,f1cp) = vafoen(nrofon,q4,prf3cn)
c
                vafott(nrofon,q5,f1cp) = unstr*(vafoen(nrofon,q1,prf1cn)
     >                                        +vafoen(nrofon,q2,prf4cn)
     >                                        +vafoen(nrofon,q3,prf3cn))
c
                vafott(nrofon,q6,f1cp) = unsde*(vafoen(nrofon,q4,prf1cn)
     >                                        +vafoen(nrofon,q4,prf4cn))
c            
c        Pour le triangle fils NF+1
c            
                vafott(nrofon,q1,f2cp) = vafoen(nrofon,q1,prfg1n)
c
                vafott(nrofon,q2,f2cp) = destr*vafoen(nrofon,q2,prfg2n)+
     >                                   unstr*vafoen(nrofon,q3,prf1cn)
c
               vafott(nrofon,q3,f2cp) = vafoen(nrofon,q3,prf4cn)
c
                vafott(nrofon,q4,f2cp) = unsde*(vafoen(nrofon,q1,prfg1n)
     >                                        +vafoen(nrofon,q1,prfg2n))
c
                vafott(nrofon,q5,f2cp) = vafott(nrofon,q6,f1cp)
c
                vafott(nrofon,q6,f2cp) = unstr*(vafoen(nrofon,q1,prf4cn)
     >                                       +vafoen(nrofon,q2,prf1cn))+
     >                            unsqu*destr*(vafoen(nrofon,q3,prfg1n)+
     >                                        vafoen(nrofon,q3,prfg2n))
c            
24231         continue
            elseif  ( g1.eq.0 .and. d1.ne.0 ) then
c            
c                   .                         .
c                  . .                       ...
c                 .   .                     . . .
c                .     .                   .  .  .
c               .........      ===>       .   .   .
c              . .     ...               .    .    .
c             .   .   . . .             .     .     .
c            .     . .  .  .           .      .      .
c           .................         .................
c                  A3                         A3
c
              do 24232 , nrofon = 1 , nbfonc
c            
c        Pour le triangle fils aine NF
c            
                vafott(nrofon,q1,f1cp) = destr*vafoen(nrofon,q1,prfd1n)+
     >                                   unstr*vafoen(nrofon,q3,prf1cn)
c
                vafott(nrofon,q2,f1cp) = vafoen(nrofon,q2,prfd2n)
c
                vafott(nrofon,q3,f1cp) = vafoen(nrofon,q3,prf4cn)
c
                vafott(nrofon,q4,f1cp) = unsde*(vafoen(nrofon,q1,prfd2n)
     >                                        +vafoen(nrofon,q2,prfd1n))
c
                vafott(nrofon,q5,f1cp) = unstr*(vafoen(nrofon,q1,prf1cn)
     >                                      +vafoen(nrofon,q2,prf4cn))+
     >                           unsqu*destr*(vafoen(nrofon,q3,prfd1n)+
     >                                        vafoen(nrofon,q3,prfd2n))
c
                vafott(nrofon,q6,f1cp) = unsde*(vafoen(nrofon,q4,prf1cn)
     >                                       +vafoen(nrofon,q4,prf4cn))
c            
c        Pour le triangle fils NF+1
c            
                vafott(nrofon,q1,f2cp) = vafoen(nrofon,q1,prf2cn)
c
                vafott(nrofon,q2,f2cp) = destr*vafoen(nrofon,q2,prf2cn)+
     >                                   unstr*vafoen(nrofon,q3,prf1cn)
c
               vafott(nrofon,q3,f2cp) = vafoen(nrofon,q3,prf4cn)
c
                vafott(nrofon,q4,f2cp) = vafoen(nrofon,q4,prf2cn)
c
                vafott(nrofon,q5,f2cp) = vafott(nrofon,q6,f1cp)
c
                vafott(nrofon,q6,f2cp) = unstr*(vafoen(nrofon,q1,prf4cn)
     >                                        +vafoen(nrofon,q2,prf1cn)+
     >                                        vafoen(nrofon,q3,prf2cn))
c            
24232         continue
            else
c
c                   .                         .
c                  . .                       ...
c                 .   .                     . . .
c                .     .                   .  .  .
c               .........      ===>       .   .   .
c              ...     ...               .    .    .
c             . . .   . . .             .     .     .
c            .  .  . .  .  .           .      .      .
c           .................         .................
c                  A3                         A3
c            
              do 24233 , nrofon = 1 , nbfonc
c            
c        Pour le triangle fils aine NF
c            
                vafott(nrofon,q1,f1cp) = destr*vafoen(nrofon,q1,prfd1n)+
     >                                   unstr*vafoen(nrofon,q3,prf1cn)
c
                vafott(nrofon,q2,f1cp) = vafoen(nrofon,q2,prfd2n)
c
                vafott(nrofon,q3,f1cp) = vafoen(nrofon,q3,prf4cn)
c
                vafott(nrofon,q4,f1cp) = unsde*(vafoen(nrofon,q1,prfd2n)
     >                                        +vafoen(nrofon,q2,prfd1n))
c
                vafott(nrofon,q5,f1cp) = unstr*(vafoen(nrofon,q1,prf1cn)
     >                                       +vafoen(nrofon,q2,prf4cn))+
     >                            unsqu*destr*(vafoen(nrofon,q3,prfd1n)+
     >                                        vafoen(nrofon,q3,prfd2n))
c
                vafott(nrofon,q6,f1cp) = unsde*(vafoen(nrofon,q4,prf1cn)
     >                                        +vafoen(nrofon,q4,prf4cn))
c                       
c        Pour le triangle fils NF+1
c            
                vafott(nrofon,q1,f2cp) = vafoen(nrofon,q1,prfg1n)
c
                vafott(nrofon,q2,f2cp) = destr*vafoen(nrofon,q2,prfg2n)+
     >                                   unstr*vafoen(nrofon,q3,prf1cn)
c
               vafott(nrofon,q3,f2cp) = vafoen(nrofon,q3,prf4cn)
c
                vafott(nrofon,q4,f2cp) = unsde*(vafoen(nrofon,q1,prfg1n)
     >                                       +vafoen(nrofon,q1,prfg2n))
c
                vafott(nrofon,q5,f2cp) = vafott(nrofon,q6,f1cp)
c
                vafott(nrofon,q6,f2cp) = unstr*(vafoen(nrofon,q1,prf4cn)
     >                                      +vafoen(nrofon,q2,prf1cn))+
     >                           unsqu*destr*(vafoen(nrofon,q3,prfg1n)+
     >                                        vafoen(nrofon,q3,prfg2n))
c            
24233         continue
            endif
cgn          else
cgn        print *,'Passage tout droit !'
          endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', 'pcstr2_5'
#endif
