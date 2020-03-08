function [output1, output2, output3] = main3(input)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

close all

% cs = 0.593; cd = 0.717; %deflationary
cd = 0.593; cs = 0.717; %inflationary


% raw = dlmread('20200304-204839.csv',',',1,0);
% % st = 2485; en = 9479;
% st = 1; en = length(raw);

% raw = dlmread('20200304-204839.csv',',',1,0);
% % st = ?; en = ?;
% st = 1; en = length(raw);

% raw = dlmread('20200305-131526.csv',',',1,0);
% % st = ?; en = ?;
% st = 1; en = length(raw);

% raw = dlmread('20200305-163826.csv',',',1,0);
% % st = ?; en = ?;
% st = 1; en = length(raw);

% raw = dlmread('20200305-192229.csv',',',1,0);
% % st = ?; en = ?;
% st = 1; en = length(raw);

% raw = dlmread('20200305-192739.csv',',',1,0);
% % st = ?; en = ?;
% st = 1; en = length(raw);

% raw = dlmread('20200306-155819.csv',',',1,0);
% % st = ?; en = ?;
% st = 1; en = length(raw);

raw = dlmread(input,',',1,0);
% st = ?; en = ?;
st = 1; en = length(raw);








% usable contains the filtered values of the pressure that was measured
% mean(usable)~0
% usable = bandpass(raw(st:en,2),[1 5],100,'Steepness',0.95,'StopbandAttenuation',80);
usable = bandpass(raw(st:en,2),[1 2],length(raw)*1000/raw(end,1),'Steepness',0.95,'StopbandAttenuation',80);
plot(usable)


%%

intercepts = 0;
for i=2:length(usable)
    if (usable(i)==0 || (usable(i-1)*usable(i)<0) ) && i>=intercepts(end)+10
        intercepts(end+1) = i;
    end
end
% intercepts contains the indeces of the x-intercepts of usable
% if the intersection occurs in between 2 indeces, the larger of the two is
% used 
% there must be at least 10 values between 2 consecutive intercepts
intercepts = intercepts(2:end)';

plot(usable)
hold on
scatter(intercepts, usable(intercepts))

%%

minima = 0;
for i=1:length(intercepts)-1
    [minimum,index] = min(usable(intercepts(i):intercepts(i+1)));
    % minima have to be smaller than the intercepts at both sides of them
    % and they can't be immediately after the intercept
    if minimum < usable(intercepts(i)) && minimum < usable(intercepts(i+1)) && index>5
        % either the whole section is underneath the intercepts
        if max(usable(intercepts(i):intercepts(i+1))) == max([usable(intercepts(i)) usable(intercepts(i+1))])
            minima(end+1) = intercepts(i)+index-1;
        elseif intercepts(i+1)-intercepts(i)>6 && mean(usable(intercepts(i)+3:intercepts(i+1)-3))<min([usable(intercepts(i)) usable(intercepts(i+1))])
            % or the section is long enough and its mean (not considering
            % nearby peaks) is less than the smaller intercept
                minima(end+1) = intercepts(i)+index-1;
        end
    end
end
% minima contains the local minima of the convex parts of the graph 
% inbetween the x-intercepts (every other section of the graph)
minima = minima(2:end)';


%%

% spline function connecting the minima
spl = spline(minima,usable(minima),1:length(usable))';

% data gives the absolute values of the pressure fluctuations due to pulse
data = usable-spl;

% recalculating spl in case data contains values below -0.01
% (in some cases it is impossible to find a spline such that all values
% will be non-negative)
while min(data)<-0.01
    [data, minima, spl] = recalculateSpline(data, usable, minima,spl);
end

% in case there are too many values after the last minimum, 
% the last but one of them is used as an additional minimum
% (not sure why I've chosen the last but one instead of the last) 
% and the spline is recalculated
if length(usable)-minima(end) > (minima(end)-minima(end-1))*0.8
    minima(end+1) = length(usable)-1;
    spl = spline(minima,usable(minima),1:length(usable))';
    data = usable-spl;
end

% manually equating all values between -0.01 and 0 to 0, so that all
% elements of data are non-negative
while min(data)<0
    [~, xMin] = min(data);
    data(xMin) = 0;
end

hold on
scatter(minima,usable(minima))
plot(1:length(usable),spl)

figure
plot(data)

%dlmwrite('20190121094508edited.txt',data,'delimiter','\n');

%%

% maxima contains the indeces of the local peaks of data, which correspond
% to the maxima of the pulse wave
maxima = 0;
% for i=1:length(intercepts)-1 % more complex; unnecessary
%     [maximum,index] = max(data(intercepts(i):intercepts(i+1)));
%     % maxima have to be larger than the intercepts at both sides of them
%     if maximum > data(intercepts(i)) && maximum > data(intercepts(i+1))
%         % either the whole section is above (smaller of the) the intercepts
%         if min(data(intercepts(i):intercepts(i+1))) == min([data(intercepts(i)) data(intercepts(i+1))])
%             maxima(end+1) = intercepts(i)+index-1;
%         elseif intercepts(i+1)-intercepts(i)>6 && mean(data(intercepts(i)+3:intercepts(i+1)-3))>max([data(intercepts(i)) data(intercepts(i+1))])
%             % or the section is long enough and its mean (not considering
%             % nearby peaks) is larger than the larger intercept
%                 maxima(end+1) = intercepts(i)+index-1;
%         end
%     end
% end
for i = 1:length(minima)-1 % simpler; works fine
    [maximum,index] = max(data(minima(i):minima(i+1)));
    maxima(end+1) = minima(i)+index-1;
end
maxima = maxima(2:end)';


hold on
scatter(maxima,data(maxima))

% for i=1:length(maxima)-1 % not needed
%     means(i,2) = mean(data(maxima(i):maxima(i+1)));
%     means(i,1) = (maxima(i)+maxima(i+1))/2;
% end

% finding the index of the max amplitude of data excluding the first and last 10% 
buff = floor(length(data)*0.1);
[maxA, imaxA] = max(data(1+buff:end-buff)); % max amplitude (corresponds of MP)
imaxA = imaxA+buff;

% calculating the MP from imaxA
MP = (raw(imaxA+st-1,2)-147)*0.0843;

% finding the index of the DP
% the first value >= the threshold
iDP = 5;
% while means(iDP,2) < cd*maxA % not needed
while data(maxima(iDP)) < cd*maxA
    iDP = iDP+1;
end 

% more precise iDP
% assuming that the desired DP (C) is located on the line connecting the last
% peak <= the threshold (A) and the first peak >= the threshold (B)
% and finding the index corresponding to the threshold
iDP = round(maxima(iDP-1)+(maxA*cd-data(maxima(iDP-1)))*(maxima(iDP)-maxima(iDP-1))/(data(maxima(iDP))-data(maxima(iDP-1))));
% xC = xA+(yC-yA)*(xB-xA)/(yB-yA)
% x - indeces; y - pressure values
% written for inflationary BPM, but
% works for both inflationary and deflationary BPM

% not needed
% iDP = round(means(iDP-1,1)+(maxA*cd-means(iDP-1,2))*(means(iDP,1)-means(iDP-1,1))/(means(iDP,2)-means(iDP-1,2)));

% hold on
% scatter(iDP,maxA*cd,'x') % not needed

% iDP+st-1 is the index of the DP
DP = (raw(iDP+st-1,2)-147)*0.0843;


iSP = length(maxima)-5;
while data(maxima(iSP)) < cs*maxA
    iSP = iSP-1;
end

% not needed
% iSP = round(maxima(iSP)+(maxA*cs-data(maxima(iSP)))*(maxima(iSP+1)-maxima(iSP))/(data(maxima(iSP+1))-data(maxima(iSP))));

% xC = xA+(yA-yC)*(xB-xA)/(yA-yB)
iSP = round(maxima(iSP)+(data(maxima(iSP))-cs*maxA)*(maxima(iSP+1)-maxima(iSP))/(data(maxima(iSP))-data(maxima(iSP+1))));
% written for inflationary BPM, but
% works for both inflationary and deflationary BPM

% iSP+st-1 is the index of the SP
SP = (raw(iSP+st-1,2)-147)*0.0843;

output1 = SP/0.0843+147;
output2 = MP/0.0843+147;
output3 = DP/0.0843+147; 




end

