import matplotlib.pyplot as plt

import csv

x=[]
y=[]

with open('20200302-141531.csv', 'r') as csvfile:
    plots= csv.reader(csvfile, delimiter=',')
    next(plots, None)
    for row in plots:
        if row:
            x.append(float(row[0]))
            y.append(float(row[1]))

i = 0
j=0
avg_pressure = 0
avg_time = 0
new_x = []
new_y = []
while i < len(y)-9:
    
    avg_pressure = int( (x[i] + x[i+1] + x[i+2] + x[i+3] + x[i+4] + x[i+5] + x[i+6] + x[i+7] + x[i+8] + x[i+9])/10)
    avg_time = int((y[i] + y[i+1] + y[i+2] + y[i+3])/4)
    new_x.insert(j, avg_pressure)
    new_y.insert(j, avg_time)
    avg_pressure = 0
    avg_time = 0
    i+=1
    j+=1
plt.plot(new_x,new_y, marker='o')

plt.show()
