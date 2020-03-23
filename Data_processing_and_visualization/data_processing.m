function [output1, output2, output3, output4] = data_processing(input)
close all

%inflationary
cd = 0.593; % coefficient for diastolic blood pressure
cs = 0.717; % coeffcient for systolic blood pressure

%read input data
input_data = dlmread(input,',',1,0);

st_pos = 1;
end_pos = length(input_data);
sampling_fs = length(input_data)*1000/input_data(end,1);

% filter_data contains the filtered values of the pressure that were measured
filter_data = bandpass(input_data(st_pos:end_pos,2),[1 2],sampling_fs,'Steepness',0.95,'StopbandAttenuation',80);

% find the intercepts of every oscillation with the zero line(abscissa)
intercepts = 0;
for i=2:length(filter_data)
    if (filter_data(i)==0 || (filter_data(i-1)*filter_data(i)<0) ) && i>=intercepts(end)+10
        intercepts(end+1) = i;
    end
end
intercepts = intercepts(2:end)';

% plot the filter data including the already found intercepts
plot(filter_data)
hold on
scatter(intercepts, filter_data(intercepts))

% find the indexes of the minimum of every oscillation, which is below the abscissa
min_indexes = 0;
for i=1:length(intercepts)-1
    [minimum,index] = min(filter_data(intercepts(i):intercepts(i+1)));
    % min_indexes should be smaller than the two intercepts of every
    % oscillation; also they don't have to be just after the intercept
    if minimum < filter_data(intercepts(i)) && minimum < filter_data(intercepts(i+1)) && index>5
        % additional checking whether the whole section is below the abscissa
        if max(filter_data(intercepts(i):intercepts(i+1))) == max([filter_data(intercepts(i)) filter_data(intercepts(i+1))])
            min_indexes(end+1) = intercepts(i)+index-1;
        % check if the section has average value smaller than the minimum
        % between the intercepts
        elseif intercepts(i+1)-intercepts(i)>6 && mean(filter_data(intercepts(i)+3:intercepts(i+1)-3))<min([filter_data(intercepts(i)) filter_data(intercepts(i+1))])
                min_indexes(end+1) = intercepts(i)+index-1;
        end
    end
end
min_indexes = min_indexes(2:end)';


% make a spline function, which connects the indexes of the local minimums(minimums of every oscillation) 
spl = spline(min_indexes,filter_data(min_indexes),1:length(filter_data))';

% find the absolute values of the pressure fluctuations due to pulse
data = filter_data-spl;

% in case there are too many values after the last minimum, 
% the last minimum is used as an additional one
% thus the spline function is recalculated
if length(filter_data)-min_indexes(end) > (min_indexes(end)-min_indexes(end-1))*0.8
    min_indexes(end+1) = length(filter_data)-1;
    spl = spline(min_indexes,filter_data(min_indexes),1:length(filter_data))';
    data = filter_data-spl;
end


% if there is any value above the abscissa even after spline function, this
% value is manually become zero
while min(data)<0
    [~, xMin] = min(data);
    data(xMin) = 0;
end

% add this minimums on the graphic
hold on
scatter(min_indexes,filter_data(min_indexes))
plot(1:length(filter_data),spl)

% the absolute values of the pressure fluctuations(data) are plotted on the separate graphic
figure
plot(data)

% find the indexes of the local maximums of every oscillation(pulse wave)
% on the graphic, plotted data
max_indexes = 0;
for i = 1:length(min_indexes)-1 % simpler; works fine
    [maximum,index] = max(data(min_indexes(i):min_indexes(i+1)));
    max_indexes(end+1) = min_indexes(i)+index-1;
end
max_indexes = max_indexes(2:end)';

% add the local maximums to the graphic of data 
hold on
scatter(max_indexes,data(max_indexes))

% find the index of the bigger local maximum among the data excluding its
% the first and last 10% values
excluded_data = floor(length(data)*0.1);
[maxA, imaxA] = max(data(1+excluded_data:end-excluded_data)); % maximum amplitude/bigger local maximum (corresponds to MAP)
imaxA = imaxA+excluded_data;

% calculating the MAP(Mean Arterial Pressure) from imaxA
MAP = input_data(imaxA+st_pos-1,2);

% finding the index of the DAP(Diastolic Arterial Pressure)
% find the first value, which is above the threshold - this value
% is used to calculate diastolic pressure
iDP = 5;

while data(max_indexes(iDP)) < cd*maxA
    iDP = iDP+1;
end 

% make a more precise iDP
% let's the DP is located just on the line connecting the 
% last peak(A) <= threshold and the first peak(B) >= threshold
% and the point of the DP is M
% find the abscissa cooridinates of M
% x - indexes, y - pressure values
% xM = xA + (xB-xA)*(yM-yA)/(yB-yA)
iDP = round(max_indexes(iDP-1)+(maxA*cd-data(max_indexes(iDP-1)))*(max_indexes(iDP)-max_indexes(iDP-1))/(data(max_indexes(iDP))-data(max_indexes(iDP-1))));

% iDP+st_pos-1 is the index of the DP
DP = input_data(iDP+st_pos-1,2);

% finding the index of the SAP(Systolic Arterial Pressure)
% find the first value, which is above the threshold - this value
% is used to calculate systolic pressure
iSP = length(max_indexes)-5;
while data(max_indexes(iSP)) < cs*maxA
    iSP = iSP-1;
end

% make a more precise iSP 
% using the same idea as with iDP the formula should be:
% xM = xA+(xB-xA)*(yA-yM)/(yA-yB)
iSP = round(max_indexes(iSP)+(data(max_indexes(iSP))-cs*maxA)*(max_indexes(iSP+1)-max_indexes(iSP))/(data(max_indexes(iSP))-data(max_indexes(iSP+1))));


% iSP+st_pos-1 is the index of the SP
SP = input_data(iSP+st_pos-1,2);

%Calculating pulse

start_value = round(length(input_data(st_pos:end_pos, 1)) * 40/100);

end_value = round(length(input_data(st_pos:end_pos, 1)) * 85/100);

num_1 = 0;
num_n = 0;
t1 = 0;
for i=1:length(min_indexes)-1
    if min_indexes(i) >= start_value
        num_1 = i;
        t1_index = min_indexes(i);
        t1 = input_data(t1_index, 1);
        break;
    end
end

tn = 0;
for i=1:length(min_indexes)-1
    if min_indexes(i) >= end_value
        num_n = i;
        tn_index = min_indexes(i);
        tn = input_data(tn_index, 1);
        break;
    end 
end

n = num_n - num_1 + 1;
pulse = 60 * (n - 1) /((tn - t1)/1000);

output1 = SP;
output2 = MAP;
output3 = DP; 
output4 = pulse;

end

