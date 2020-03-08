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
while i < len(y)-28:
    
    
    avg_pressure = int( (x[i] + x[i+1] + x[i+2] + x[i+3] + x[i+4] + x[i+5] + x[i+6] + x[i+7] + x[i+8] + x[i+9] + x[i+10] + x[i+11] + x[i+12] + x[i+13] + x[i+14] + x[i+15] + x[i+16] + x[i+17] + x[i+18] + x[i+19] + x[i+20] + x[i+21] + x[i+22] + x[i+23] + x[i+24] + x[i+25] + x[i+26] + x[i+27] + x[i+28])/29)
    avg_time = int((y[i] + y[i+1] + y[i+2] + y[i+3] + y[i+4] + y[i+5] + y[i+6] + y[i+7] + y[i+8] + y[i+9] + y[i+10] + y[i+11] + y[i+12] + y[i+13] + y[i+14] + y[i+15] + y[i+16] + y[i+17] + y[i+18] + y[i+19] + y[i+20] + y[i+21] + y[i+22] + y[i+23] + y[i+24] + y[i+25] + y[i+26] + y[i+27] + y[i+28])/29)
    new_x.insert(j, avg_pressure)
    new_y.insert(j, avg_time)
    avg_pressure = 0
    avg_time = 0
    i+=29
    j+=1
plt.plot(new_x,new_y, marker='o')

plt.show()
