#!/usr/bin/env python3
import sys
sys.path.append('/home/A96028/QT5GitEficasTravail/Web/testFlask')
from connectEficas import accasConnecteur
code='Essai'

from flask import Flask, render_template
def createConnecteur():
    monConnecteur=accasConnecteur(code, langue='ang')
    return monConnecteur

monConnecteur=createConnecteur()
print (monConnecteur.getListeCommandes())

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('mdm.html',
    titre=code,
    #listeCommandes = monConnecteur.getListeCommandes(),
    message='uuuu'
    )
     


@app.route("/forward/", methods=['POST'])
def move_forward():
    #Moving forward code
    forward_message = "Moving Forward..."
    return render_template('mdm.html', message=forward_message)

if __name__ == "__main__":
    app.run()

