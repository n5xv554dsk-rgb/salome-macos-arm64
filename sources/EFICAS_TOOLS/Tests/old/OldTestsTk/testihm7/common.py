# -*- coding: utf-8 -*-

from tkMessageBox import showinfo
root=None
jdcdisplay=None

class UnKnownNode(Exception):pass

def init_common(r,j):
    global root,jdcdisplay
    root=r
    jdcdisplay=j

def KP_return():
    root.event_generate("<Return>")
    root.update()

def delete_node(panel):
    panel.node.delete()

def uncomment_command(panel):
    panel.bouton_unc.invoke()
    root.update()
    panel=jdcdisplay.panel_courant
    return panel

def comment_command(panel):
    panel.nb.selectpage('Commentaire')
    panel.comment_commande()
    root.update()
    panel=jdcdisplay.panel_courant
    return panel

def create_mocle(nom,panel):
    panel.nb.selectpage('Mocles')
    panel.Liste.afficheMot(nom)
    root.update()
    label=panel.Liste.dico_labels[nom]
    label.event_generate("<Enter>")
    root.event_generate("<KeyPress-Return>")
    root.update()
    return jdcdisplay.panel_courant

def change_commandcomm(text,panel):
    panel.widget_text.setvalue(text)
    root.update()
    panel.bouton_val.invoke()
    return panel

def create_command(nom,panel):
    panel.nb.selectpage('Commande')
    root.update()
    panel.command_entry.setentry(nom)
    panel.command_entry.component('entry').focus_set()
    root.event_generate("<Return>")
    root.update()
    label=panel.liste_command.dico_labels[nom]
    label.event_generate("<Enter>")
    label.event_generate("<Return>")
    #root.event_generate("<Return>")
    root.update()
    panel=jdcdisplay.panel_courant
    return panel

def create_comment(text,panel):
    panel.nb.selectpage('Commentaire')
    panel.ajout_commentaire()
    root.update()
    panel=jdcdisplay.panel_courant
    panel.widget_text.setvalue(text)
    root.update()
    panel.bouton_val.invoke()
    #panel.change_valeur()
    return panel

def create_param(nom,valeur,panel):
    panel.nb.selectpage('Commentaire')
    panel.ajout_parametre()
    root.update()
    panel=jdcdisplay.panel_courant
    if nom:
        panel.entry_nom.delete(0,"end")
        panel.entry_nom.insert(0,nom)
        panel.entry_nom.event_generate("<Return>")
    panel.entry_val.delete(0,"end")
    panel.entry_val.insert(0,valeur)
    panel.entry_val.event_generate("<Return>")
    panel.bouton_val.invoke()
    root.update()
    return panel

def create_formule(nom,args,expr,panel):
    panel=create_command("FORMULE",panel)
    panel.entry_nom.delete(0,"end")
    panel.entry_nom.insert(0,nom)
    panel.entry_nom.event_generate("<Return>")
    panel.entry_arg.delete(0,"end")
    panel.entry_arg.insert(0,args)
    panel.entry_arg.event_generate("<Return>")
    panel.entry_exp.delete(0,"end")
    panel.entry_exp.insert(0,expr)
    panel.entry_exp.event_generate("<Return>")
    panel.bouton_val.invoke()
    root.update()
    return panel

def nomme_concept(nom,panel):
    panel.nb.selectpage('Concept')
    root.update()
    panel._any.delete(0,"end")
    panel._any.insert(0,nom)
    panel.but_ok.invoke()
    root.update()
    return jdcdisplay.panel_courant

def select_mcf(nom,ind,node):
    panel=select_child(nom,node)
    parent=panel.node
    parent.expand()
    parent.select_next(ind)
    panel=jdcdisplay.panel_courant
    panel.node.expand()
    return panel

def select_child(nom,node):
    """node est le parent dont on veut le fils nom"""
    for n in node.children:
        if n.item.nom == nom:
            n.select()
            root.update()
            panel= jdcdisplay.panel_courant
            panel.node.expand()
            return panel
    raise UnKnownNode(nom)

def select_node(node):
    node.select()
    node.expand()
    root.update()
    return jdcdisplay.panel_courant

def choose_valeur(valeur,panel):
    panel.Liste_choix.afficheMot(valeur)
    root.update()
    label=panel.Liste_choix.dico_labels[valeur]
    label.event_generate("<Button-1>")
    label.event_generate("<Return>")
    root.update()

def choose_sdco(valeur,panel):
    i = list(panel.listbox.get(0, 'end')).index(valeur)
    panel.listbox.component("listbox").selection_set(i)
    panel.listbox.component("listbox").focus_set()
    panel.listbox.component("listbox").event_generate("<Return>")
    root.update()

def choose_assd(valeur,panel):
    i = list(panel.listbox.get(0, 'end')).index(valeur)
    panel.listbox.component("listbox").selection_set(i)
    panel.but_val.invoke()
    root.update()

def set_valeur(valeur,panel):
    panel.entry.delete(0,"end")
    panel.entry.insert(0,valeur)
    panel.entry.event_generate("<Return>")
    root.update()

def set_sdco(valeur,panel):
    panel.b_co.invoke('OUI')
    root.update()
    panel.entry_co.delete(0,"end")
    panel.entry_co.insert(0,valeur)
    panel.entry_co.event_generate("<Return>")
    root.update()

def set_complexe(valeur,panel):
    panel.entry3.setentry(valeur)
    panel.entry3.component('entry').focus_set()
    panel.entry3.event_generate("<Return>")
    root.update()

def add_valeur_into(valeur,panel):
    label=panel.Liste_choix.dico_labels[valeur]
    panel.Liste_choix.afficheMot(valeur)
    root.update()
    label.event_generate("<1>")
    panel.bouton_add.invoke()
    root.update()

def add_valeur(valeur,panel):
    panel.entry.delete(0,"end")
    panel.entry.insert(0,valeur)
    panel.entry.event_generate("<Return>")
    root.update()

def valider_valeur(panel):
    panel.bouton_accepter.invoke()
    root.update()

def copier_coller():
    root.event_generate("<Control-c>")
    root.event_generate("<Control-v>")
    root.update()
    return jdcdisplay.panel_courant

