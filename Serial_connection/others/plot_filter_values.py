import matplotlib.pyplot as plt

import csv
from scipy.signal import butter, lfilter, filtfilt

x=[]
y=[]

with open('20200306-165004.csv', 'r') as csvfile:
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

all_samples = len(y)

print("number of samples -> {}".format(all_samples))

time_all_samples = x[len(x) - 1] / 1000

print("time for all samples -> {}".format(time_all_samples))


sample_period = time_all_samples / all_samples

print("sample period -> {}".format(sample_period))

order = 1 # order ???

sampling_fs = 1 / sample_period
print("sampling fs -> {}".format(int(sampling_fs)))

lowcut = 1  # 1 Hz
highcut = 2 # 2 Hz

# arguments needed: lowcut, highcut, sampling_fs, stopband_attenuation, steepness, btype, order
b, a = butter(order,[lowcut/sampling_fs, highcut/sampling_fs], btype='bandpass', analog=False, output='ba')
filter_pressure = filtfilt(b, a, y, x)



plt.plot(, marker='o')    
plt.show()

