/* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% */
/*        Commentaires sur les dépendances aux machines              */
/*  1. Les programmes C ne sont appelés que par les programmes       */
/*     fortran du répertoire Dependance_Machine                      */
/*  2. Les programmes en dm...c sont appelés par dm....              */
/*  3. Les dépendances des source_c pour les arguments :             */
/*          _POSIX, extern_stdcall, autres                           */
/*  4. Les autres dépendances des source_c sont :                    */
/*     . Le programme d'abort (dmaboc)                               */
/*       _POSIX, autres                                              */
/*     . Le vidage des buffers (dmflsc)                              */
/*       _POSIX, autres                                              */
/*     . Le vidage des buffers (dmflsc)                              */
/*       _POSIX, autres                                              */
/*     . Les caractéristiques des machines (dmmacc)                  */
/*       _POSIX, autres                                              */
/*     . La précision des machines (dmprmc)                          */
/*       _USE_64_BITS, autres                                        */
/*     . Le caractère de séparation des répertoires (dmsepc)         */
/*       _POSIX, autres                                              */
/*     . Le temps système (dmtemc)                                   */
/*       CLK_TCK,  _POSIX                                            */
/* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% */
