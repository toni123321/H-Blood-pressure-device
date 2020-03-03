import matplotlib.pyplot as plt

import csv
from scipy.signal import butter, lfilter

x=[]
y=[]

with open('20200302-152620.csv', 'r') as csvfile:
    plots= csv.reader(csvfile, delimiter=',')
    next(plots, None)
    for row in plots:
        if row:
            x.append(float(row[0]))
            y.append(float(row[1]))

plt.plot(x,y, marker='o')    
plt.show()

