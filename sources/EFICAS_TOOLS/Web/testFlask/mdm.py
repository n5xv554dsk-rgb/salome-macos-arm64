# coding: utf-8
#!/usr/bin/env python3
import sys
sys.path.append('/home/eric/FLASK/eficas.eecj.git/testFlask') #TODO : supprimer
from   connectEficas import accasConnecteur

#code='Morgane'
code='Essai'

from   flask import Flask, request, render_template, url_for, jsonify, make_response, session, g, Response

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
from   collections import OrderedDict
from   markupsafe  import escape

#from   forms       import BasicForm  #Essais WtForms

# Flask management of Server Side Event
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

ALLOWED_EXTENSIONS = set(['py','comm','txt', 'gif', 'png', 'jpg', 'jpeg', 'bmp', 'rar', 'zip', '7zip', 'doc', 'docx'])
IGNORED_FILES = set(['.gitignore'])


### Server Side Event config
app.config["REDIS_URL"] = "redis://localhost"
#app.config["REDIS_URL"] = "redis://:password@localhost"
#TODO: personaliser l'url en fonction de la session utilisateur
app.register_blueprint(sse, url_prefix='/stream')

### Eficas Connector
def createConnecteur(app):
    monConnecteur=accasConnecteur(code, langue='ang',appWeb=app)
    return monConnecteur

monConnecteur=createConnecteur(app)
print (monConnecteur.getListeCommandes())

def fromConnecteur(maFonction,*args,**kwargs):
  fnct=globals()[maFonction]
  fnct(*args,**kwargs)

#TODO : Rattacher à une session
#         gérer un appel register callback
app.fromConnecteur=fromConnecteur

## ServerSideEvent from Eficas signals :
#    - Validite
#    - Ajouter un noeud   (et ses enfants)
#    - Supprimer un noeud (et ses enfants),
#    - ReAffichage d'un noeud (et ses enfants)
#    - Changement d'un nom de mot-cle reference

def propageValide(id, valid): #TODO: RENAME TO ... propagateValidation
    print ('Flask/propageValide: ', id, valid)
    sse.publish( {'id':id, 'valid':valid, 'message': "Hello from propageValide!"}, type='propageValide')

def updateNodeInfo(id, info):
    print ('Flask/updateNodeInfo: ', id, info)
    sse.publish( {'id':id, 'info':info, 'message': "Hello from updateNodeInfo!"}, type='updateNodeInfo')

def appendChildren(id, fcyTreeJson, pos):
    print ('Flask/appendChildren: ', id, fcyTreeJson, pos)
    sse.publish( {'id':id, 'fcyTreeSrc':fcyTreeJson, 'pos':pos, 'message': "Hello from appendChildren!"}, type='appendChildren')

def deleteChildren(idList):
    #print ('Flask/deleteChildren: ', idList)
    sse.publish( {'idList':idList,'message': "Hello from deleteChildren!"}, type='deleteChildren')

#TODO: Câbler la sélection du catalogue avant d'activer les appels suivants
#      car si la page Web n'est pas rendue et que le connecteur génère une erreur... boom !
def afficheInfos(txt, couleur):                     #TODO: RENAME TO ... displayWarning
    print ('Flask/afficheInfos: ', txt, couleur)
    # sse.publish( {'txt':txt, 'color':couleur, 'messageClass':"alert-warning" ,'message': "Hello from afficheInfos!"},
    #              type='displayMessage')

def afficheAlerte(titre, message):                  #TODO: RENAME TO ... displayDanger
    print ('Flask/afficheAlerte: ', titre, message) #TODO: titre & message VS txt ?
    # sse.publish( {'txt':titre, 'color':couleur, 'messageClass':"alert-danger", 'message': "Hello from afficheAlerte!"},
    #              type='displayMessage')


# # Pour test curl
# @app.route('/update')
# def publish_update():
#     sse.publish({"message": "Hello!"}, type='update')
#     return "Message sent!"


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
        print("Flask/updateSimp request : ", req)
        print("Flask/updateSimp request['id'] : ",req['id'])
        id=req['id'];value=req['value']
        # id, value = req.values()       # Dangereux correspondance implicite
        value             = str(value)   #On peut écrire Pi
        rId,message,changeDone       = monConnecteur.changeValeur(id,value);
        assert(rId==id)
        #changeDone        = True
        print ("changeDone : ",changeDone)
        # Ne pas recuperer et ne pas renvoyer le noeud dans le cas du SIMP
        #  (le changeDone et l''ancienne valeur ds la WebApp suffit 
        node              = monConnecteur.getDicoForFancy(monConnecteur.monEditeur.getNodeById(id))
        print("Flask/updateSimp node : ",node)
        # return jsonify([myTreeDico])
        
        return make_response(json.dumps( {'source':node, 'changeIsAccepted' : changeDone, 'message': message} ))
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
        print(req)
        print(req['id'])
        id=req['id'];sdnom=req['sdnom']
        sdnom              = str(sdnom)   #On peut écrire Pi
        changeDone,message = monConnecteur.updateSDName(id,sdnom);
        #changeDone        = True
        print ("changeDone : ",changeDone)
        
        #return make_response(json.dumps( {'id':id , 'changeIsAccepted' : changeDone, 'message': message} ))
        return make_response(json.dumps( {'changeIsAccepted' : changeDone, 'message': message} ))
        # Return a string along with an HTTP status code
        # return "JSON received!", 200
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
        print("/removeNode ",req);print("/removeNode ",req['id']);
        id  = req['id'];
        ret,message = monConnecteur.suppNode(id);
        print ("/removeNode : ret : ",ret," message : ",message)
        
        return make_response(json.dumps( {'ret':ret, 'message':message} ))
    else:
        # The request body wasn't JSON so return a 400 HTTP status code
        return "Request was not JSON", 400
        #return make_response(jsonify({"message": "Request body must be JSON"}), 400)

@app.route("/appendChild", methods=['POST'])
def appendChild():
    # Validate the request body contains JSON
    if request.is_json:
        # Parse the JSON into a Python dictionary
        req = request.get_json()
        # Print the dictionary
        print(__file__+"/appendChild : ",req);
        id=req['id'];name=req['name'];pos=req['pos'];
        # id, value = req.values() # Dangereux correspondance implicite
        #rId,message,changeDone  = monConnecteur.appendChild(id,name,pos);
        newId                    = monConnecteur.appendChild(id,name,pos);
        print (__file__+"/appendChild : newId : ",newId);
        
        return make_response(json.dumps( {'id':newId} ))
        # return make_response(json.dumps( {'source':node, 'changeIsAccepted' : changeDone, 'message': message} ))
        # Return a string along with an HTTP status code
        # return "JSON received!", 200
    else:
        # The request body wasn't JSON so return a 400 HTTP status code
        return "Request was not JSON", 400
        #return make_response(jsonify({"message": "Request body must be JSON"}), 400)

@app.route('/')
def index():

   #  tree4Fancy = """ [
   #     {"title": "Node 1",   "key": "1"},
   #     {"title": "Folder 2", "key": "2", "folder": true, "children": [
   #       {"title": "Node 2.1", "key": "3"},
   #       {"title": "Node 2.2", "key": "4"}
   #     ]}
   # ]
   # """.replace('\n','')


    monConnecteur.litFichierComm('../WebTest/web_tres_simple_avec_2Fact.comm')
    #monConnecteur.litFichierComm('../WebTest/edg_REP1300_FULL_PN.comm')
    myFancyTreeDico=monConnecteur.getDicoForFancy(monConnecteur.monEditeur.tree.racine)
    #print (myFancyTreeDico)
    
    #myFancyTreeJS=json.dumps([myFancyTreeDico])
    myFancyTreeJS=json.dumps([myFancyTreeDico],indent=4)  #TODO : remove indent if not DEBUG
    
    print("---- myFancyTreeDico ----")
    pprint(myFancyTreeDico)
    print("---- myFancyTreeJS ----")
    pprint( myFancyTreeJS)

    return render_template('commandes_2.html',
      titre=code,
      listeCommandes = monConnecteur.getListeCommandes(),
      tree=myFancyTreeJS,
      # tree=tree4Fancy,
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
