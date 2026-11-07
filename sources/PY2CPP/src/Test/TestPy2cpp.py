def f1(x, y):
  return 4, 6.7

def f2():
  return "Hello world!"

def f3(x, y, m):
  return x / y, m+" is here!"

def add1ToList(l):
  return [x+1 for x in l]

class MyClass:
  def __init__(self, names, values):
    self.names = names
    self.values = values
  
  def namesTogether(self):
    return "-".join(self.names)
  
  def valuesSum(self):
    return sum(self.values)

  def addVal(self, v):
    for i in range(len(self.values)):
      self.values[i] += v

def myObjectSize(obj):
  return len(obj.names) + len(obj.values)

def newobj(o, newVals):
  return MyClass(o.names, newVals), sum(newVals)
