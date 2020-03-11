function [output1, output2, output3, output4] = data_processing(input)
close all

%inflationary
cd = 0.593; % coefficient for diastolic blood pressure
cs = 0.717; % coeffcient for systolic blood pressure

input_data = dlmread(input,',',1,0);

st_pos = 1; 
end_pos = length(input_data);
sampling_fs = length(input_data)*1000/input_data(end,1);

% filter_data contains the filtered values of the pressure that was measured
filter_data = bandpass(input_data(st_pos:end_pos,2),[1 2],sampling_fs,'Steepness',0.95,'StopbandAttenuation',80);
%plot(filter_data)

intercepts = 0;
for i=2:length(filter_data)
    if (filter_data(i)==0 || (filter_data(i-1)*filter_data(i)<0) ) && i>=intercepts(end)+10
        intercepts(end+1) = i;
    end
end
% intercepts contains the indeces of the x-intercepts of filter_data
% if the intersection occurs in between 2 indeces, the larger of the two is
% used 
% there must be at least 10 values between 2 consecutive intercepts
intercepts = intercepts(2:end)';

plot(filter_data)
hold on
scatter(intercepts, filter_data(intercepts))

min_indexes = 0;
for i=1:length(intercepts)-1
    [minimum,index] = min(filter_data(intercepts(i):intercepts(i+1)));
    % min_indexes have to be smaller than the intercepts at both sides of them
    % and they can't be immediately after the intercept
    if minimum < filter_data(intercepts(i)) && minimum < filter_data(intercepts(i+1)) && index>5
        % either the whole section is underneath the intercepts
        if max(filter_data(intercepts(i):intercepts(i+1))) == max([filter_data(intercepts(i)) filter_data(intercepts(i+1))])
            min_indexes(end+1) = intercepts(i)+index-1;
        elseif intercepts(i+1)-intercepts(i)>6 && mean(filter_data(intercepts(i)+3:intercepts(i+1)-3))<min([filter_data(intercepts(i)) filter_data(intercepts(i+1))])
            % or the section is long enough and its mean (not considering
            % nearby peaks) is less than the smaller intercept
                min_indexes(end+1) = intercepts(i)+index-1;
        end
    end
end
% min_indexes contains the local minima of the convex parts of the graph 
% inbetween the x-intercepts (every other section of the graph)
min_indexes = min_indexes(2:end)';


%%

% spline function connecting the min_indexes
spl = spline(min_indexes,filter_data(min_indexes),1:length(filter_data))';

% data gives the absolute values of the pressure fluctuations due to pulse
data = filter_data-spl;

% in case there are too many values after the last minimum, 
% the last but one of them is used as an additional minimum
% (not sure why I've chosen the last but one instead of the last) 
% and the spline is recalculated
if length(filter_data)-min_indexes(end) > (min_indexes(end)-min_indexes(end-1))*0.8
    min_indexes(end+1) = length(filter_data)-1;
    spl = spline(min_indexes,filter_data(min_indexes),1:length(filter_data))';
    data = filter_data-spl;
end

% manually equating all values between -0.01 and 0 to 0, so that all
% elements of data are non-negative
while min(data)<0
    [~, xMin] = min(data);
    data(xMin) = 0;
end

hold on
scatter(min_indexes,filter_data(min_indexes))
plot(1:length(filter_data),spl)

figure
plot(data)

% max_indexes contains the indeces of the local peaks of data, which correspond
% to the max_indexes of the pulse wave
max_indexes = 0;
for i = 1:length(min_indexes)-1 % simpler; works fine
    [maximum,index] = max(data(min_indexes(i):min_indexes(i+1)));
    max_indexes(end+1) = min_indexes(i)+index-1;
end
max_indexes = max_indexes(2:end)';


hold on
scatter(max_indexes,data(max_indexes))


% finding the index of the max amplitude of data excluding the first and last 10% 
excluded_data = floor(length(data)*0.1);
[maxA, imaxA] = max(data(1+excluded_data:end-excluded_data)); % max amplitude (corresponds to MAP)
imaxA = imaxA+excluded_data;

% calculating the MAP(Mean Arterial Pressure) from imaxA
MAP = input_data(imaxA+st_pos-1,2) * 0.9;

% finding the index of the DAP(Diastolic Arterial Pressure)
% the first value >= the threshold
iDP = 5;
%disp(length(max_indexes))
while data(max_indexes(iDP)) < cd*maxA
    iDP = iDP+1;
end 

% more precise iDP
% assuming that the desired DP (C) is located on the line connecting the last
% peak <= the threshold (A) and the first peak >= the threshold (B)
% and finding the index corresponding to the threshold
iDP = round(max_indexes(iDP-1)+(maxA*cd-data(max_indexes(iDP-1)))*(max_indexes(iDP)-max_indexes(iDP-1))/(data(max_indexes(iDP))-data(max_indexes(iDP-1))));
% xC = xA+(yC-yA)*(xB-xA)/(yB-yA)
% x - indeces; y - pressure values
% written for inflationary BPM, but
% works for both inflationary and deflationary BPM

% hold on
% scatter(iDP,maxA*cd,'x') % not needed

% iDP+st_pos-1 is the index of the DP
DP = input_data(iDP+st_pos-1,2)*0.9;


iSP = length(max_indexes)-5;
while data(max_indexes(iSP)) < cs*maxA
    iSP = iSP-1;
end

% not needed
% iSP = round(max_indexes(iSP)+(maxA*cs-data(max_indexes(iSP)))*(max_indexes(iSP+1)-max_indexes(iSP))/(data(max_indexes(iSP+1))-data(max_indexes(iSP))));

% xC = xA+(yA-yC)*(xB-xA)/(yA-yB)
iSP = round(max_indexes(iSP)+(data(max_indexes(iSP))-cs*maxA)*(max_indexes(iSP+1)-max_indexes(iSP))/(data(max_indexes(iSP))-data(max_indexes(iSP+1))));
% written for inflationary BPM, but
% works for both inflationary and deflationary BPM

% iSP+st_pos-1 is the index of the SP
SP = input_data(iSP+st_pos-1,2)*0.9;

%Calculating pulse

start_value = round(length(input_data(st_pos:end_pos, 1)) * 50/100);

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

