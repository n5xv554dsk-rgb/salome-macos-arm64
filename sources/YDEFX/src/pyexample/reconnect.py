import pydefx

with open("mystudy.txt", "r") as f:
  job_description = f.read()

myStudy = pydefx.PyStudy()
myStudy.loadFromString(job_description)

print("Avancement:", myStudy.getProgress())
print("Etat:", myStudy.getJobState())
myStudy.wait()
myStudy.getResult()
print(myStudy.sample)
print(myStudy.sample._input)
print(myStudy.sample._output)
print(myStudy.sample._messages)
