import sys
sys.path.append('/home/eric/FLASK/eficas.eecj.git/testFlask')
from connectEficas import accasConnecteur
code='Essai'

from flask import Flask, request, render_template, url_for, jsonify
# from flask import Flask, request, render_template, url_for, json, jsonify
import json
import pprint
#from forms import BasicForm
from collections import OrderedDict

def createConnecteur(app):    
    monConnecteur=accasConnecteur(code, langue='ang',appWeb=app)
    return monConnecteur


app = Flask(__name__)
monConnecteur=createConnecteur(app)
monConnecteur.envoieMsg()

def fromConnecteur(maFonction,*args,**kwargs):
  fnct=globals()[maFonction]
  fnct(*args,**kwargs)

app.fromConnecteur=fromConnecteur
#app.config['SERVER_NAME'] = "127.0.0.1:8123"


@app.route('/')
def index():
    tree = """ [
      {
        "text": "Parent 1",
        "nodes": [
          {
            "text": "Child 1.1",
            "nodes": [
              {
                "text": "Grandchild 1.1"
              },
              {
                "text": "Grandchild 1.2"
              }
            ]
          },
          {
            "text": "Child 1.2",
            "nodes": [
              {
                "text": "Grandchild 1.1"
              },
              {
                "text": "Grandchild 1.2"
              }
            ]
          },
          {
            "text": "Child 2"
          }
        ]
      },
      {
        "text": "Parent 2"
      },
      {
        "text": "<span class='icon node-icon' id='idtest0'>Parent 3</span>",
        "nodes":   [{"text":"<span class='icon node-icon' id='idtest1'>3.5</span>"}]
      },
      {
        "txt": "Parent 4"
      },
      {
        "text": "Parent 5"
      }
    ]
    """.replace('\n','')

    treeB = """ [
      {
        "nodes": [
          {
            "text": "Child 1.1",
            "nodes": [
              {
                "text": "Grandchild 1.1"
              },
              {
                "text": "Grandchild 1.2"
              }
            ]
          }
        ]
      }
    ]
    """.replace('\n','')

    dictC={'nodes': [{'text': 'Child 1.1', 'nodes': [{'text': 'Grandchild 1.1'}, {'text': 'Grandchild 1.2'}]}]}
    treeC=[dictC]
    print("treeB : %s"%treeB);

    # print("mytree : %s"%mytree);
    mcTraite={'MonProc2': {'s1': ('I', 2), 'F2': {'s2': ('I', 3), 'F3': {'s3': ('I', 4)}}}};

    monConnecteur.litFichierComm('../WebTest/web_tres_simple_avec_2Fact.comm')
    myTreeDico=monConnecteur.getDicoObjetsCompletsPourTree(monConnecteur.monEditeur.tree.racine)
    myTreeJS=json.dumps([myTreeDico])
    # myNewTreeDico=OrderedDict([('text', 'MonProc2'), ('nodes', OrderedDict([('text', 'MonProc22'), ('nodes', [{'text': 'param1 1.0'}, [OrderedDict([('text', 'Fact1'), ('nodes', [{'text': 'param3 43.0'}])]), OrderedDict([('text', 'Fact1'), ('nodes', [{'text': 'param3 44.0'}])])]])]))])
    # myNewTreeJS=json.dumps([myNewTreeDico])
    print("---- tree     : ", tree)
    print("---- myTreeDico : ")
    pprint.pprint(myTreeDico)
    print("---- myTreeJS : ", myTreeJS)
    # print("---- myNewTreeDico : ", myNewTreeDico)
    # print("---- myNewTreeJS : ", myNewTreeJS)

    return render_template('commandes_3.html',
      titre=code,
      listeCommandes = monConnecteur.getListeCommandes(),
      profondeur=4,
      mcTraite={'MonProc2': {'s1': ('I', 2), 'F2': {'s2': ('I', 3), 'F3': {'s3': ('I', 4)}}}},
      # tree='{text: "Parent 1"}'
      mcTraiteJson=json.dumps(mcTraite),
      tree=myTreeJS
      # tree='['+myTreeJS+']'
    )
    # etape  = str(escape(request.args.get("etape", "")))


@app.route("/forward/", methods=['POST'])
def move_forward():
    #Moving forward code
    forward_message = "Moving Forward..."
    return render_template('mdm.html', message=forward_message)



@app.route('/form', methods=['GET', 'POST'])
def basicform():
   form = BasicForm(request.form)
   if request.method == 'POST' and form.validate():
      with open('/tmp/test.txt', 'w') as f:
          for k in request.form:
            f.write('{0}: {1}\n'.format(k, request.form[k]))
   return render_template('basic.html', form=form)


@app.route('/stream')
def stream():
    def eventStream():
        while True:
            # wait for source data to be available, then push it
            yield 'data: {}\n\n'.format(get_message())
    return Response(eventStream(), mimetype="text/event-stream")

def get_message():
    import time
    time.sleep(1.0)
    s = time.ctime(time.time())
    return s

def ecritMessageRecu(id,**kwargs):
    print ('dans la fonction ecritMessageRecu: ', idUnique, kwargs)

def propageValide(idUnique,valid):
    print ('dans propageValide: ', idUnique, valid)

def retourChangeValeur(, dUnique, commentaire, validite ):
    print ('dans retourChangeValeur: ', idUnique, commentaire,validite)

if __name__ == "__main__":
    app.run(host="localhost", port=8123, debug=True,threaded=True)

