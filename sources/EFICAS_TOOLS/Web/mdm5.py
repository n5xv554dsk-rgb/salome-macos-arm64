# coding: utf-8
#!/usr/bin/env python3
import sys, os

_no = 1

code='Essai'
#code=None

from flask import Flask, request, render_template, url_for, jsonify, make_response, session, g, Response


# File management
from   flask           import redirect, send_from_directory
from   werkzeug.utils  import secure_filename
from   lib.upload_file import uploadfile
import PIL
from   PIL import Image
import simplejson
import traceback

# from flask import ?? json, jsonify ??
import json
import os
from   pprint      import pprint
#from   forms       import BasicForm  #Essais WtForms
from   collections import OrderedDict
from   markupsafe  import escape

# Flask management of Server Side Event
# Necessite redis
from flask_sse import sse
# from flask_uploads import UploadSet, configure_uploads, IMAGES 

app = Flask(__name__)

# CATALOGS_EXT=("py","jpg") #TODO : supprimer jpg pour test
# catalogs = UploadSet("catalogs",CATALOGS_EXT)
# app.config["UPLOADED_CATALOGS_DEST"] = "data/catalogs"
# app.config["SECRET_KEY"]             = os.urandom(24)

# configure_uploads(app, catalogs)

app.config['SECRET_KEY']         = os.urandom(24)
app.config['UPLOAD_FOLDER']      = 'data/'
app.config['THUMBNAIL_FOLDER']   = 'data/thumbnail/'
app.config['MAX_CONTENT_LENGTH'] = 50 * 1024 * 1024
#PNPN
#app.config['SESSION_REFRESH_EACH_REQUEST'] = False
ALLOWED_EXTENSIONS = set(['py','comm','txt', 'gif', 'png', 'jpg', 'jpeg', 'bmp', 'rar', 'zip', '7zip', 'doc', 'docx'])
IGNORED_FILES = set(['.gitignore'])


### Server Side Event config
app.config["REDIS_URL"] = "redis://localhost"
#app.config["REDIS_URL"] = "redis://:password@localhost"
#TODO: personaliser l'url en fonction de la session utilisateur
app.register_blueprint(sse, url_prefix='/stream')


### Eficas Connector
def createWebAppli(app):
    import os
    print('Create Appli');
    sys.path.append(os.path.join(os.path.abspath(os.path.dirname(__file__)),'..'))
    from Editeur.eficas_go import getEficas
    eficasAppli=getEficas(code, langue='ang',appWeb=app)
    return eficasAppli


eficasAppli=createWebAppli(app)
debug=0
if debug : print ('eficasAppli = ', eficasAppli)

def fromConnecteur(maFonction, sessionId, externEditorId, *args,**kwargs):
  debug = 1
  if debug : 
     print ('________________________________________________________________________')
     print ('fromConnecteur : ', maFonction, sessionId, externEditorId, *args,**kwargs)
     print ('________________________________________________________________________')
  fnct=globals()[maFonction]
  fnct(sessionId, externEditorId, *args,**kwargs)

#TODO : Rattacher à une session
#         gérer un appel register callback
app.fromConnecteur=fromConnecteur

## ServerSideEvent from Eficas signals :
#    - Validite
#    - Ajouter un noeud   (et ses enfants)
#    - Supprimer un noeud (et ses enfants),
#    - ReAffichage d'un noeud (et ses enfants)
#    - Changement d'un nom de mot-cle reference

def propageValide(cId, eId, id, valid): #TODO: RENAME TO ... propagateValidation
    if debug : print ('Flask/propageValide: ', id, valid)
    sse.publish( {'eId' : eId, 'id':id, 'valid':valid, 'message': "Hello from propageValide!"}, type='propageValide', channel = str(cId))

def updateNodeInfo(cId, eId, id, info):
    if debug : print ('Flask/updateNodeInfo', cId, eId, id, info)
    sse.publish( {'eId' : eId, 'id':id, 'info':info, 'message': "Hello from updateNodeInfo!"}, type='updateNodeInfo', channel = str(cId))

def appendChildren(cId, eId, id, fcyTreeJson, pos):
    if debug : print ('Flask/appendChildren: ', id, fcyTreeJson, pos)
    sse.publish( {'eId' : eId, 'id':id, 'fcyTreeSrc':fcyTreeJson, 'pos':pos, 'message': "Hello from appendChildren!"}, type='appendChildren', channel = str(cId))

def deleteChildren(cId, eId, idList):
    if debug : print ('Flask/deleteChildren: ', idList)
    sse.publish( {'eId' : eId, 'idList':idList,'message': "Hello from deleteChildren!"}, type='deleteChildren', channel = str(cId))

#TODO: Câbler la sélection du catalogue avant d'activer les appels suivants
#      car si la page Web n'est pas rendue et que le connecteur génère une erreur... boom !
def afficheMessage(sId, txt, couleur):                     #TODO: RENAME TO ... displayWarning
    if sId != session['eficasSession']  : return
    print ('Flask/afficheMessage: ', txt, couleur)
    # sse.publish( {'txt':txt, 'color':couleur, 'messageClass':"alert-warning" ,'message': "Hello from afficheMessage!"},
    #              type='displayMessage')

def afficheAlerte(sId, titre, message):                  #TODO: RENAME TO ... displayDanger
    if sId != session['eficasSession']  : return
    print ('Flask/afficheAlerte: ', titre, message) #TODO: titre & message VS txt ?
    # sse.publish( {'txt':titre, 'color':couleur, 'messageClass':"alert-danger", 'message': "Hello from afficheAlerte!"},
    #              type='displayMessage')

#Messages Globaux ?
def afficheMessage2(cId, eId,  txt, couleur):                     #TODO: RENAME TO ... displayWarning
    if debug : print ('Flask/afficheMessage: ', txt, couleur)
    sse.publish( {'txt':txt, 'color':couleur, 'messageClass':"alert-warning" ,'message': txt},
                 type='message', channel = str(cId))

def afficheAlerte2(cId, eId, titre, message, couleur):          #TODO: RENAME TO ... displayDanger
    if debug : print ('Flask/afficheAlerte: ', titre, message) #TODO: titre & message VS txt ?
    sse.publish( {'txt':titre, 'color':couleur, 'messageClass':"alert-danger", 'message': "Hello from afficheAlerte!"},
                 type='error', channel = str(cId))



## WebApp -> Eficas  :
# Pour SIMP : Ajoute, Supprime (MC facultatif), Change la valeur
# Pour FACT : Ajoute, Supprime
# Pour PROC : Ajoute, Supprime
# Pour OPER : Ajoute, Supprime, Nomme, Renomme
# @app.route('/post/<uuid:post_id>')

@app.route("/updateSimp", methods=['POST'])
def updateSimp():
    # Validate the request body contains JSON
    if request.is_json:
        # Parse the JSON into a Python dictionary
        req = request.get_json()
        # Print the dictionary
        if debug : print("Flask/updateSimp request : ", req)
        if debug : print("Flask/updateSimp request['id'] : ",req['id'])
        eId = req['eId'];id=req['id'];value=req['value']
        # id, value = req.values()       # Dangereux correspondance implicite
        value             = str(value)   # L'utilisateur peut écrire la valeur Pi

        (eficasEditor, errorCode, errorMsg, infoMsg) = eficasAppli.getWebEditorById(session['canalId'],eId)
        if errorCode : 
            msgLevel = "alert-danger"
            message = errorMsg + infoMsg
            return make_response(json.dumps( {'errorCode' : errorCode, 'message': message,'msgLevel':msgLevel} ))

        #(rId, errorCode, errorMsg, infoMsg) = eficasEditor.changeValue(session['canalId'], eId, id,value);
        #assert(rId==id)

        #changeDone        = True
        # if debug : print ("Flask/updateSimp changeDone : ",changeDone)
        # Ne pas recuperer et ne pas renvoyer le noeud dans le cas du SIMP
        #  (le changeDone et l''ancienne valeur ds la WebApp suffit 
        #(node, errorCode, errorMsg, errorLevel)  = eficasEditor.getDicoForFancy(eficasEditor.getNodeById(id))
        #if debug : print("Flask/updateSimp node : ",node)
        # return jsonify([myTreeDico])
        
        (node, errorCode, errorMsg, infoMsg) = eficasEditor.changeValue(session['canalId'], eId, id,value);
        if errorCode : 
            msgLevel = "alert-danger"
            message = errorMsg + infoMsg
            return make_response(json.dumps( {'source':node,'errorCode' : errorCode, 'message': message,'msgLevel':msgLevel} ))
        if infoMsg != "" : msgLevel = 'alert-success'
        else : msgLevel = "alert-info"
        #PN --> a changer Eric ? je t envoie les infos dans le dico. Est-ce que ce n est pas cela qui est attendu ?
        print ('source',node, 'errorCode' , errorCode, 'message', infoMsg,'msgLevel',msgLevel)
        return make_response(json.dumps( {'source':node, 'errorCode' : errorCode, 'message': infoMsg,'msgLevel':msgLevel} ))

        # Return a string along with an HTTP status code
        # return "JSON received!", 200
    else:
        # The request body wasn't JSON so return a 400 HTTP status code
        return "Request was not JSON", 400
        #return make_response(jsonify({"message": "Request body must be JSON"}), 400)
    
@app.route("/updateSDName", methods=['POST'])
def updateSDName():
    # Validate the request body contains JSON
    if request.is_json:
        # Parse the JSON into a Python dictionary
        req = request.get_json()
        # Print the dictionary
        #print(req)
        #print(req['id'])
        eId=req['eId'];id=req['id'];sdnom=req['sdnom']
        sdnom              = str(sdnom)   #On peut écrire Pi
         # On attendant que l externalEditorId soit dans le tree
        (eficasEditor, errorCode, errorMsg, infoMsg) = eficasAppli.getWebEditorById(session['canalId'],eId)
        if errorCode : 
            msgLevel = "alert-danger"
            message = errorMsg + infoMsg
            return make_response(json.dumps( {'errorCode' : errorCode, 'message': message,'msgLevel':msgLevel} ))

        (errorCode, errorMsg, infoMsg) = eficasEditor.updateSDName(session['canalId'],eId,id,sdnom);
        if errorCode : 
            msgLevel = "alert-danger"
            message = errorMsg + infoMsg
        else :
            message = infoMsg
            msgLevel = "alert-success"
        return make_response(json.dumps( {'errorCode' : errorCode, 'message': message,'msgLevel':msgLevel} ))
    else:
        # The request body wasn't JSON so return a 400 HTTP status code
        return "Request was not JSON", 400
        #return make_response(jsonify({"message": "Request body must be JSON"}), 400)
    
    
@app.route("/removeNode", methods=['POST'])
def removeNode():
    # Validate the request body contains JSON
    if request.is_json:
        # Parse the JSON into a Python dictionary
        req = request.get_json()
        # Print the dictionary
        if debug : print("Flask/removeNode ",req);print("/removeNode ",req['eId'],req['id']);
        eId = req['eId'];
        id  = req['id'];
        (eficasEditor, errorCode, errorMsg, infoMsg) = eficasAppli.getWebEditorById(session['canalId'],eId)
        if errorCode : 
            msgLevel = "alert-danger"
            message = errorMsg + infoMsg
            return make_response(json.dumps( {'errorCode' : errorCode, 'message': message,'msgLevel':msgLevel} ))

        (errorCode, errorMsg, infoMsg) = eficasEditor.removeNode(session['canalId'],session['externEditorId'],id);
        if debug : print ("Flask/removeNode : errorCode : ",errorCode," errorMsg, : ",errorMsg, "infoMsg", infoMsg)
        if errorCode : 
            msgLevel = "alert-danger"
            message = errorMsg
        else :
            msgLevel = "alert-success"
            message = infoMsg

        return make_response(json.dumps( {'errorCode' : errorCode, 'message': message,'msgLevel':msgLevel} ))
    else:
        # The request body wasn't JSON so return a 400 HTTP status code
        return "Request was not JSON", 400
        #return make_response(jsonify({"message": "Request body must be JSON"}), 400)

@app.route("/appendChild", methods=['POST'])
def appendChild():
    # Validate the request body contains JSON
    # print ('__________________________________________')
    # print ( 'in appendChild')
    # print ('__________________________________________')
    if request.is_json:
        # Parse the JSON into a Python dictionary
        req = request.get_json()
        # Print the dictionary
        if debug :  print(__file__+"Flask/appendChild : ",req);
        eId = req['eId'];id=req['id'];name=req['name'];pos=req['pos'];
        # id, value = req.values() # Dangereux correspondance implicite
        #rId,message,changeDone  = eficasEditor.appendChild(id,name,pos);
        (eficasEditor, errorCode, errorMsg, infoMsg) = eficasAppli.getWebEditorById(session['canalId'],eId)
        if errorCode : 
            msgLevel = "alert-danger"
            message = errorMsg + infoMsg
            return make_response(json.dumps( {'errorCode' : errorCode, 'message': message,'msgLevel':msgLevel} ))
        (newId, errorCode, errorMsg,infoMsg) = eficasEditor.appendChild(session['canalId'],eId,id,name,pos);
        if debug : print (__file__+"Flask/appendChild : newId : ",newId);
        if errorCode : 
            msgLevel = "alert-danger"
            message = errorMsg + infoMsg
        else :
            msgLevel = "alert-success"
        return make_response(json.dumps( {'id':newId, 'errorCode' : errorCode, 'message': message,'msgLevel':msgLevel} )) #TODO: Code Erreur
        # return make_response(json.dumps( {'source':node, 'changeIsAccepted' : changeDone, 'message': message} ))
        # Return a string along with an HTTP status code
        # return "JSON received!", 200
    else:
        # The request body wasn't JSON so return a 400 HTTP status code
        return "Request was not JSON", 400
        #return make_response(jsonify({"message": "Request body must be JSON"}), 400)

@app.route("/newDataset", methods=['POST'])
def newDataset():
    
    # Validate the request body contains JSON
    if request.is_json:
        # Parse the JSON into a Python dictionary
        req = request.get_json()
        # Print the dictionary
        print(__file__+"/newDataset : ",req);
        #cataFile   =os.path.abspath("../Codes/WebTest/"+req['catalogName']);
        cataFile   =os.path.abspath("./data/"+req['catalogName']);
        dataSetFile =os.path.abspath("./data/"+req['datasetName']);
        #cataFile    = os.path.abspath('../Codes/WebTest/cata_essai.py')
        #dataSetFile = os.path.abspath('../Codes/WebTest/web_tres_simple_avec_2Fact.comm')
    else:
        # The request body wasn't JSON so return a 400 HTTP status code
        return "Request was not JSON", 400
        #return make_response(jsonify({"message": "Request body must be JSON"}), 400)

    cId=session['canalId'];
    (editorId, errorCode, errorMessage, messageInfo) = eficasAppli.getWebEditor(cId, cataFile, dataSetFile)
    debug = 1
    if debug :
        print ('apres getWebEditor : canalId, : ', cId,  ' editorId, : ', editorId,
               ' code Erreur : ', errorCode,'message : ', errorMessage, 'messageInfo ', messageInfo)
    if errorCode : 
        # TODO ERIC
        afficheMessage2(cId, editorId, errorMessage,'macouleur');
        return make_response(jsonify({"message": errorMessage, "code": errorCode}), 400)
        
    session['externEditorId'] = editorId;
    
    if debug :   print ('idEditor = ', session['externEditorId'])
    (eficasEditor, errorCode, errorMessage,messageInfo)  = eficasAppli.getWebEditorById(session['canalId'],editorId)
    if errorCode:
         return make_response(jsonify({"message": errorMessage, "code": errorCode}), 400)

    
    fancyTreeDict=eficasEditor.getDicoForFancy(eficasEditor.tree.racine) #TODO: changer le nom Dico en Dict
    #fancyTreeJS=json.dumps([fancyTreeDict],indent=4)                #TODO : remove indent if not DEBUG
    fancyTreeDict['eId']=editorId;
    #print("---- myFancyTreeDico ----")
    pprint(fancyTreeDict)
    #print("---- myFancyTreeJS ----")
    #pprint( myFancyTreeJS)
    commands = eficasEditor.getListeCommandes(); #TODO: Renommer la fonction

    title = os.path.basename(cataFile)+'/'+os.path.basename(dataSetFile)
    if debug : print('liste des commandes',  eficasEditor.getListeCommandes())
    return make_response(json.dumps( {'source': [fancyTreeDict], 'commands':commands, 'title':title,} ))


@app.route('/')
def index():

   #  Example :
   #  tree4Fancy = """ [
   #     {"title": "Node 1",   "key": "1"},
   #     {"title": "Folder 2", "key": "2", "folder": true, "children": [
   #       {"title": "Node 2.1", "key": "3"},
   #       {"title": "Node 2.2", "key": "4"}
   #     ]}
   # ]
   # """.replace('\n','')

    #print ('_______________________________________________')
    #cataFile    = os.path.abspath('../Codes/WebTest/cata_essai.py')
    #dataSetFile = os.path.abspath('../Codes/WebTest/web_tres_simple_avec_2Fact.comm')
    
    # En attendant la génération d'un n° de canal unique
    # notion de plage
    if not 'canalId' in session :
        global _no
        _no = _no + 1
        canalId = _no
        session['canalId']  = canalId
    else :
        canalId = session['canalId']
    #if _no == 3:
    #    dataSetFile = os.path.abspath('../Codes/WebTest/web_tres_simple_incomplet.comm')

    #(canalId, eficasEditor, errorCode, message) = eficasAppli.getWebEditor(cataFile, dataSetFile)
    #(externEditorId, errorCode, errorMsg, messageInfo) = eficasAppli.getWebEditor(canalId, cataFile, dataSetFile)
    #debug = 0
    #if debug : print ('apres getWebEditor : canalId, : ', canalId,  ' externEditorId, : ', externEditorId, ' code Erreur : ', errorCode,'message : ', errorMsg, 'messageInfo ', messageInfo)
    #if not errorCode :
    #    if debug : 
    #        print ('_______________________________________________')
    #        print ('canalId', canalId)
    #        print ('externEditorId', externEditorId)
    #        print ('_______________________________________________')
    #    session['externEditorId'] = externEditorId
    #else :
    #    # Il faudrait gerer les erreurs
    #    return render_template('commandes_2.html',
    #        titre= errorMsg,
    #        listeCommandes = [],
    #        tree= None
    #    )
    
    #if debug :   print ('idEditor = ', session['externEditorId'])
    #(eficasEditor, errorCode, message)  = eficasAppli.getWebEditorById(canalId,externEditorId) 
    #if errorCode:
    #      return render_template('commandes_2.html',
    #        titre= errorMsg,
    #        listeCommandes = [],
    #        tree= None
    #    )

    
    #myFancyTreeDico=eficasEditor.getDicoForFancy(eficasEditor.tree.racine)
    #if debug : pprint (myFancyTreeDico)
    #myFancyTreeJS=json.dumps([myFancyTreeDico],indent=4)  #TODO : remove indent if not DEBUG
    
    #print("---- myFancyTreeDico ----")
    #pprint(myFancyTreeDico)
    #print("---- myFancyTreeJS ----")
    #pprint( myFancyTreeJS)

    #if debug : print ( 'liste des commandes',  eficasEditor.getListeCommandes())
    #return render_template('commandes_2.html',
    #  titre=code,
    #  efi_update_channel = str(canalId),
    #  listeCommandes =  eficasEditor.getListeCommandes(),
    #  tree=myFancyTreeJS,
      # tree=tree4Fancy,
    #)
    myFancyTreeJS=json.dumps([{}],indent=4)  #TODO : remove indent if not DEBUG
    return render_template('commandes_2.html',
      titre=code,
      efi_update_channel = str(canalId),
      listeCommandes = [],
      tree=myFancyTreeJS,
    )
    # etape  = str(escape(request.args.get("etape", "")))



# @app.route("/forward/", methods=['POST'])
# def move_forward():
#     #Moving forward code
#     forward_message = "Moving Forward..."
#     return render_template('mdm.html', message=forward_message)



# @app.route('/form', methods=['GET', 'POST'])
# def basicform():
#    form = BasicForm(request.form)
#    if request.method == 'POST' and form.validate():
#       with open('/tmp/test.txt', 'w') as f:
#           for k in request.form:
#             f.write('{0}: {1}\n'.format(k, request.form[k]))
#    return render_template('basic.html', form=form)

# @app.route("/json", methods=["POST"])
# def json_example():

#     if request.is_json:

#         req = request.get_json()

#         response_body = {
#             "message": "JSON received!",
#             "sender": req.get("name")
#         }

#         res = make_response(jsonify(response_body), 200)

#         return res

#     else:

#         return make_response(jsonify({"message": "Request body must be JSON"}), 400)

#TODO: 
#from fileManagement import *

def allowed_file(filename):
    return '.' in filename and \
        filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


def gen_file_name(filename):
    """
    If file was exist already, rename it and return a new name
    """

    i = 1
    while os.path.exists(os.path.join(app.config['UPLOAD_FOLDER'], filename)):
        name, extension = os.path.splitext(filename)
        filename = '%s_%s%s' % (name, str(i), extension)
        i += 1

    return filename


def create_thumbnail(image):
    try:
        base_width = 80
        img = Image.open(os.path.join(app.config['UPLOAD_FOLDER'], image))
        w_percent = (base_width / float(img.size[0]))
        h_size = int((float(img.size[1]) * float(w_percent)))
        img = img.resize((base_width, h_size), PIL.Image.ANTIALIAS)
        img.save(os.path.join(app.config['THUMBNAIL_FOLDER'], image))

        return True

    except:
        print(traceback.format_exc())
        return False


@app.route("/upload", methods=['GET', 'POST'])
def upload():
    if request.method == 'POST':
        files = request.files['file']

        if files:
            filename  = secure_filename(files.filename)
            filename  = gen_file_name(filename)
            mime_type = files.content_type

            if not allowed_file(files.filename):
                result = uploadfile(name=filename, type=mime_type, size=0, not_allowed_msg="File type not allowed")

            else:
                # save file to disk
                uploaded_file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
                files.save(uploaded_file_path)

                # create thumbnail after saving
                if mime_type.startswith('image'):
                    create_thumbnail(filename)
                
                # get file size after saving
                size = os.path.getsize(uploaded_file_path)

                # return json for js call back
                result = uploadfile(name=filename, type=mime_type, size=size)
            
            return simplejson.dumps({"files": [result.get_file()]})

    if request.method == 'GET':
        # get all file in ./data directory
        files = [f for f in os.listdir(app.config['UPLOAD_FOLDER']) if os.path.isfile(os.path.join(app.config['UPLOAD_FOLDER'],f)) and f not in IGNORED_FILES ]
        
        file_display = []

        for f in files:
            size = os.path.getsize(os.path.join(app.config['UPLOAD_FOLDER'], f))
            file_saved = uploadfile(name=f, size=size)
            file_display.append(file_saved.get_file())

        return simplejson.dumps({"files": file_display})

    return redirect(url_for('index'))



@app.route("/delete/<string:filename>", methods=['DELETE'])
def delete(filename):
    file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    file_thumb_path = os.path.join(app.config['THUMBNAIL_FOLDER'], filename)

    if os.path.exists(file_path):
        try:
            os.remove(file_path)

            if os.path.exists(file_thumb_path):
                os.remove(file_thumb_path)
            
            return simplejson.dumps({filename: 'True'})
        except:
            return simplejson.dumps({filename: 'False'})


# serve static files
@app.route("/thumbnail/<string:filename>", methods=['GET'])
def get_thumbnail(filename):
    return send_from_directory(app.config['THUMBNAIL_FOLDER'], filename=filename)


@app.route("/data/<string:filename>", methods=['GET'])
def get_file(filename):
    return send_from_directory(os.path.join(app.config['UPLOAD_FOLDER']), filename=filename)


# @app.route("/_upload", methods=['POST'])
# def _upload():

#     # Validate the request body contains JSON
#     if request.is_json:
#         # Parse the JSON into a Python dictionary
#         req = request.get_json()
#         # Print the dictionary
#         uploadRequest=json.dumps([req],indent=4);  #TODO : remove indent if not DEBUG
#         pprint(uploadRequest);
        
#         return make_response(json.dumps( {'source':node, 'changeIsAccepted' : changeDone, 'message': message} ))
#         # Return a string along with an HTTP status code
#         # return "JSON received!", 200
#     else:
#         print(request)
#         files = request.files['files']
#         if files:
#             result=catalogs.save(files)
#         return make_response(json.dumps( {"files": ["coucou"]} ))
#             # if request.method == 'POST' and 'files' in request.files:
            

#         # The request body wasn't JSON so return a 400 HTTP status code
#         return "Request was not JSON", 400
#         #return make_response(jsonify({"message": "Request body must be JSON"}), 400)

# For example, you may want to override how request parameters are handled to preserve their order:
# from flask import Flask, Request
# from werkzeug.datastructures import ImmutableOrderedMultiDict
# class MyRequest(Request):
#     """Request subclass to override request parameter storage"""
#     parameter_storage_class = ImmutableOrderedMultiDict
# class MyFlask(Flask):
#     """Flask subclass using the custom request class"""
#     request_class = MyReq

def create_app(test_config=None):
    # create and configure the app
    app = Flask(__name__, instance_relative_config=True)
    app.config.from_mapping(
        SECRET_KEY='dev',
        DATABASE=os.path.join(app.instance_path, 'flaskr.sqlite'),
    )

    if test_config is None:
        # load the instance config, if it exists, when not testing
        app.config.from_pyfile('config.py', silent=True)
    else:
        # load the test config if passed in
        app.config.from_mapping(test_config)

    # ensure the instance folder exists
    try:
        os.makedirs(app.instance_path)
    except OSError:
        pass

    return app

if __name__ == "__main__":
    app.run(host="localhost", port=8321, debug=True)




#$("#386bc28a2ff811ec853cac220bca9aa6").html('<label class="form-check-label">Test1<input type="text" class="form-control form-control-sm"></label><essai>Essai</essai>')

# $("#550f63502b6611ecab61ac220bca9aa6").hover(function(){
#   alert("The text has been changed.");
# });

# $("#1f3ca24a2cf911ecab61ac220bca9aa6").hover(function(){
#   $.post("{{ url_for('static', filename='demo_test.txt') }}",
#   {
#     id: $(this).attr("id"),
#   },
#   function(data, status){
#     alert("Data: " + data + "\nStatus: " + status);
#   });
# });

# $("#e0a1f2862cfa11ecab61ac220bca9aa6").hover(function(){
#   $.post("http://127.0.0.1:8123/test1",
#   {
#     id: $(this).attr("id"),
#   },
#   function(data, status){
#     alert("Data: " + data + "\nStatus: " + status);
#   });
# });

# $(".MCSIMPValide").hover(function(){
#   alert("-5-- :"+ $(this).text() + $("#e0a1f2862cfa11ecab61ac220bca9aa6").text() + $(this).attr("class") + $(this).attr("id"));
#   $.post("http://127.0.0.1:8123/test1",
#   {
#     id: $(this).attr("id"),
#   },
#   function(data, status){
#     alert("Data: " + data + "\nStatus: " + status +"\nId :", $(this).attr("id") );
#   });
# });


# # # $("#550f63502b6611ecab61ac220bca9aa6")[0].id
# $("#e0a1f2862cfa11ecab61ac220bca9aa6").hover(function(){
#   alert("-4-- :"+ $(this).text() + $("#e0a1f2862cfa11ecab61ac220bca9aa6").text() + $(this).attr("class") + $(this).attr("id"));
# });

# $("#550f63502b6611ecab61ac220bca9aa6")[0].id

#$("#ec7abddd2dca11ecab61ac220bca9aa6").parents()[0]
# Pour obtenir le nodeid treeview a partir de l'eficasID
#$("#ec7abddd2dca11ecab61ac220bca9aa6").parent()[0].attributes['data-nodeid'].value
