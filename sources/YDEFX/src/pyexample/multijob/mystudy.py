import os
def root_dir():
  return os.getcwd()

#def case_dir(*args):
  #import hashlib
  #h = hashlib.md5(repr(args).encode('utf-8'))
  #return os.path.join(root_dir(), h.hexdigest())

def case_dir(v):
  case_name = "c_"+repr(v)
  return os.path.join(root_dir(), case_name)

class Study:
  def __init__(self, value):
    self.value = value
    self.caseDir = case_dir(self.value)
    self.rootDir = root_dir()

  def getResults(self):
    result_file = os.path.join(self.caseDir, "result.txt")
    with open(result_file, 'r') as f:
      result = float(f.read())
    return result

  def caseExists(self):
    ok = True
    if os.path.isdir(self.caseDir):
      try:
        self.getResults()
        ok = True
      except:
        ok = False
    else:
      ok = False
    return ok

  def prepareCase(self):
    if not os.path.isdir(self.caseDir):
      os.mkdir(self.caseDir)
    template_file = os.path.join(self.rootDir, "template_jdd.txt")
    case_file = os.path.join(self.caseDir, "jdd.txt")
    with open(template_file,'r') as f:
      filedata = f.read()
    filedata = filedata.format(**{'value':repr(self.value)})
    with open(case_file,'w') as f:
      f.write(filedata)

  def runCase(self):
    import subprocess
    command = "{} {} {}".format(
              os.path.join(self.rootDir, "mysolver.py"),
              os.path.join(self.caseDir, "jdd.txt"),
              os.path.join(self.caseDir, "result.txt"))
    subprocess.run(command, shell=True)

def _exec(x):
  e = Study(x)
  if not e.caseExists():
    e.prepareCase()
    e.runCase()
  r = e.getResults()
  return r
