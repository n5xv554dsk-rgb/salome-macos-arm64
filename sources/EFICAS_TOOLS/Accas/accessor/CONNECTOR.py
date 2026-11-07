# i -*- coding: utf-8 -*-
# Copyright (C) 2007-2026   EDF R&D
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
#
# See http://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
#
"""
  La classe CONNECTOR sert a enregistrer les observateurs d'objets et a delivrer
  les messages emis a ces objets.

  Le principe general est le suivant : un objet (subscriber) s'enregistre aupres du
  connecteur global (theconnector) pour observer un objet emetteur de messages (publisher)
  sur un canal donne (channel). Il demande a etre notifie par appel d'une fonction (listener).
  La sequence est donc :

     - enregistrement du subscriber pour le publisher : theconnector.Connect(publisher,channel,listener,args)
     - emission du message par le publisher : theconnector.Emit(publisher,channel,cargs)

  args et cargs sont des tuples contenant les arguments de la fonction listener qui sera appelee
  comme suit::

     listener(cargs+args)
"""
import traceback
from copy import copy
import weakref


class ConnectorError(Exception):
    pass


class CONNECTOR:
    def __init__(self):
        self.connections = {}

    def Connect(self, object, channel, function, args):
        # print ("Connect",object, channel, function, args)
        idx = id(object)
        # if self.connections.has_key(idx):
        if idx in self.connections:
            channels = self.connections[idx]
        else:
            channels = self.connections[idx] = {}

        # if channels.has_key(channel):
        if channel in channels:
            receivers = channels[channel]
        else:
            receivers = channels[channel] = []

        for funct, fargs in receivers[:]:
            if funct() is None:
                receivers.remove((funct, fargs))
            elif (function, args) == (funct(), fargs):
                receivers.remove((funct, fargs))

        receivers.append((ref(function), args))

    def Disconnect(self, object, channel, function, args):
        try:
            receivers = self.connections[id(object)][channel]
        except KeyError:
            raise ConnectorError(
                "no receivers for channel %s of %s" % (channel, object)
            )

        for funct, fargs in receivers[:]:
            if funct() is None:
                receivers.remove((funct, fargs))

        for funct, fargs in receivers:
            if (function, args) == (funct(), fargs):
                receivers.remove((funct, fargs))
                if not receivers:
                    # the list of receivers is empty now, remove the channel
                    channels = self.connections[id(object)]
                    del channels[channel]
                    if not channels:
                        # the object has no more channels
                        del self.connections[id(object)]
                return

        raise ConnectorError(
            "receiver %s%s is not connected to channel %s of %s"
            % (function, args, channel, object)
        )

    def Emit(self, object, channel, *args):
        # print "Emit",object, channel, args
        try:
            receivers = self.connections[id(object)][channel]
        except KeyError:
            return
        # print "Emit",object, channel, receivers
        # Attention : copie pour eviter les pbs lies aux deconnexion reconnexion
        # pendant l'execution des emit
        for rfunc, fargs in copy(receivers):
            try:
                func = rfunc()
                if func:
                    # print (func,args,fargs)
                    # rint args + fargs
                    # apply(func, args + fargs)
                    if args + fargs == ():
                        func()
                    else:
                        func(args + fargs)
                else:
                    # Le receveur a disparu
                    if (rfunc, fargs) in receivers:
                        receivers.remove((rfunc, fargs))
            except:
                traceback.print_exc()


def ref(target, callback=None):
    # if hasattr(target,"im_self"):
    #   return BoundMethodWeakref(target)
    if hasattr(target, "__self__"):
        return BoundMethodWeakref(target)
    else:
        return weakref.ref(target, callback)


class BoundMethodWeakref(object):
    def __init__(self, callable):
        # self.Self=weakref.ref(callable.im_self)
        # self.Func=weakref.ref(callable.im_func)
        self.Self = weakref.ref(callable.__self__)
        self.Func = weakref.ref(callable.__func__)

    def __call__(self):
        target = self.Self()
        if not target:
            return None
        func = self.Func()
        if func:
            return func.__get__(self.Self())


_the_connector = CONNECTOR()
Connect = _the_connector.Connect
Emit = _the_connector.Emit
Disconnect = _the_connector.Disconnect

if __name__ == "__main__":

    class A:
       def lanceValid(self, appelant=None):
         Emit(self, "valid",(appelant,))

    class B:
        def __init__(self, nom) :
           self.param=0 
           self.nom=nom 

        def add(self, a):
            self.param += 1 
            print("appel de add ", self.nom, 'argument', a , 'valeur de param', self.param)

        def __del__(self):
            print (' del self.param vaut', self.param, ' pour l objet ', self.nom) 
            print(("__del__", self))

    class C(B):
        def __init__(self, nom, numero, objetA) :
           self.param=0 
           self.nom=nom 
           self.monNum = numero
           self.objetA = objetA

        def lanceValid(self):
           self.objetA.lanceValid(self.monNum)

        def onValid(self, appelant):
           print ('je suis dans onValid pour', self.nom,  ' l appelant est' , appelant)

        def onValidSansArgument(self) :
           # genere une erreur
           pass
            

    def propage(a):
        print ('param de la fonction', propage, a)

    print ('------------------- init ---------------')
    a = A()
    b = B('b')
    c = B('c')
    d = C('d',42,a)
    e = C('e',44,a)

    print ('on connecte b 2 fois)')
    Connect(a, "add", b.add, ())
    Connect(a, "add", b.add, ())
    Connect(a, "add", c.add, ())
    Connect(a, "add", d.add, ())
    Connect(a, "add", propage, ())
    Connect(a,"valid",d.onValid,())
    Connect(a,"valid",e.onValid,())
    Connect(a,"valid",d.onValidSansArgument,())

    print ('------------ 1er Emit')
    Emit(a, "add", 1)
    print ('apres 1 Emit, le param de b vaut : ', b.param)
    print ('apres 1 Emit, le param de c vaut : ', c.param)
    print ('apres 1 Emit, le param de d vaut : ', d.param)

    print ('\n\n\n------------ 2nd Emit')
    print ('on deconnecte b (1 fois)')
    Disconnect(a, "add", b.add, ())
    Emit(a, "add", 1)
    print ('apres 2 Emit, le param de b vaut : ', b.param)
    print ('apres 2 Emit, le param de c vaut : ', c.param)
    print ('apres 2 Emit, le param de d vaut : ', d.param)
    print ('b est deconnecte')

    print ('\n\n\n------------ 3nd Emit')
    print ('on detruit propage')
    del propage
    Emit(a, "add", 1)
    print ('apres 3 Emit, le param de b vaut : ', b.param)
    print ('apres 3 Emit, le param de c vaut : ', c.param)
    print ('apres 3 Emit, le param de d vaut : ', d.param)

    print ('\n\n\n------------ 4nd Emit')
    print ('on deconnecte c')
    Disconnect(a, "add", c.add, ())
    Emit(a, "add", 1)

    print ('apres 4 Emit, le param de b vaut : ', b.param)
    print ('apres 4 Emit, le param de c vaut : ', c.param)
    print ('apres 4 Emit, le param de d vaut : ', d.param)


    print ('\n\n\n ------------ passage de parametre dans la fonction')
    d.lanceValid()


    print ('\n\n\n------------ Exit')

   
