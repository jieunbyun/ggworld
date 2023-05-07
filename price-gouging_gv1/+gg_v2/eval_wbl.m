function wbl = eval_wbl( w0, min_dem_rats, dem_fulfil_rats )
% Evaluate well-being loss

if ~isscalar(w0)
    error( "w0 (a proportion of well-being that minimum demand takes up) must remain consistent for all populations." )
elseif (w0 < 0) || (w0 > 1)
    error( "w0 (a proportion of well-being that minimum demand takes up) must be between 0 and 1." )
end

if length( min_dem_rats ) ~= length( dem_fulfil_rats )
    error( "The two given vectors for population must have the same length." )
end


nPop = length(min_dem_rats);
wbl = zeros(size(min_dem_rats));

for iPopInd = 1:nPop
    iMin = min_dem_rats(iPopInd);
    iFul = dem_fulfil_rats(iPopInd);

    if iMin < 1 - 1e-5 % 1e-5 to avoid floating issue

        if iFul < iMin
            iWb = (w0/iMin) * iFul;
        else
            iWb = w0 + (1-w0)/(1-iMin) * (iFul-iMin);
        end

    else
        iWb = iFul;
    end

    wbl(iPopInd) = 1-iWb;
end