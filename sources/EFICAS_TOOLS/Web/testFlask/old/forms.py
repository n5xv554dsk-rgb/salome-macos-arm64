#from wtforms import Form, TextField, SelectField, SubmitField, PasswordField, validators
from wtforms import Form, SelectField, SubmitField, PasswordField, validators

class BasicForm(Form):
#  user   = TextField(u'Utilisateur', [validators.Length(min=4, max=20)])
  passwd = PasswordField(u'Mot de passe', [validators.Length(min=8, max=32)])
  active = SelectField(u'Actif', choices = [('yes', 'Yes'), ('no', 'No')])
  action = SubmitField(u'Register')
