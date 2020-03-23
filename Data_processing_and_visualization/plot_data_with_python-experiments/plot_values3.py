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

i = 0
j=0
avg_pressure = 0
avg_time = 0
new_x = []
new_y = []


fs = 5000
nyq = 0.5 * fs
low = 500 / nyq
high = 1000 / nyq
b, a = butter(5, [low , high], btype='band')
filter_pressure = lfilter(b, a, y)

plt.plot(x,filter_pressure, marker='o')    
plt.show()

