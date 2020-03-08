function [data, minima,spl] = recalculateSpline(data, previousData, minima,spl)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% data should be an 1D array
[~, xMin] = min(data);
%finding the intercept nearest to xMin
n=1; %counter
if xMin>minima(end)
    if xMin>minima(end)+10
    minima(end+1) = xMin;
    else minima(end) = xMin;
    end
    n = 0;
else
    while xMin>minima(n)
        n=n+1;
    end
end
% xMin is between intercepts(n-1) and intercepts(n)
if n==1
    minima(2:end+1) = minima;
    minima(1) = xMin;
else
    if n==0
        
    else
    if xMin-minima(n-1)<minima(n)-xMin % xMin is closer to intercepts(n-1)
        minima(n-1) = xMin;
    else % xMin is closer to intercepts(n)
        minima(n) = xMin;
    end
    end
end


% ? is the nearest intercept
%recalculating the spline function and the results
spl = spline(minima,previousData(minima),1:length(previousData))';
data = previousData-spl;
end
