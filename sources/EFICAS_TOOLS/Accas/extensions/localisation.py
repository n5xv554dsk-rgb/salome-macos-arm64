# -*- coding: utf-8 -*-
# copyright 2012 LOGILAB S.A. (Paris, FRANCE), all rights reserved.
# contact http://www.logilab.fr -- mailto:contact@logilab.fr
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU Lesser General Public License as published by the Free
# Software Foundation, either version 2.1 of the License, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
# details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.
"""

"""

import os

try:
    from PyQt5.QtCore import QTranslator
    code_translator = QTranslator()
    eficas_translator = QTranslator()
    from PyQt5.QtWidgets import QApplication
except:
    code_translator = None
    eficas_translator = None
    print("pas d import de qt, pas de traduction")


def localise( language=None, translatorFile=None, debug=False):
    """ 
    eficasTranslatorFile contient les traductions eficas
    translatorFile contient les traductions specifiques au code
    pour l instant ne fonctionne qu avec qt
    """
    debug=0
    if code_translator == None:
        print("qt not avalaible, no translation")
        return
    if QApplication.instance() == None :
       if debug : print ('qApplication not instancied')
       return


    monPath = os.path.join(os.path.dirname(__file__), "..","..", "UiQT5")

    if language is None : language = "fr"
    if language == "ang": language = "en"
    eficasTranslatorFile='eficas_'+language

    if eficasTranslatorFile == None and translatorFile == None 	:
        if debug: print("pas de fichier de traduction a charger")
        return

    if eficasTranslatorFile :
        if eficas_translator.load(eficasTranslatorFile, monPath) :
            if debug : print("fichier de traduction : ",  monPath, '/',eficasTranslatorFile, 'charge')
        else  : 
            if debug : print( 'pb au chargement du fichier de traduction :', monPath, '/',eficasTranslatorFile)
        if debug: print(QApplication.installTranslator(eficas_translator))
        else: QApplication.installTranslator(eficas_translator)
    else :
        if debug : print ('Fichier des traductions eficas {} non présent'.format (eficasTranslatorFile))

    if translatorFile :
        if (code_translator.load(translatorFile)) : print(translatorFile, " loaded")
        elif code_translator.load(translatorFile + "_" + language) :
            print(translatorFile + "_" + language + " loaded")
        else: print( "Unable to load Code translator! No file or No translation" + translatorFile)
        if debug: print(QApplication.installTranslator(code_translator))
        else: QApplication.installTranslator(code_translator)


if __name__ == "__main__":
    import sys
    localise(sys.argv[1])
