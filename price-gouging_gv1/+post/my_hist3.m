function counts = my_hist3( X, Y, XEdges, YEdges )
% The original matlab's function "hist3" create strange zero rows and columns at the end.

nBin_x = length(XEdges) - 1;
nBin_y = length(YEdges) - 1;

counts = zeros(nBin_x, nBin_y);

iVal_x_old = XEdges(1);
for iBin_x = 1:nBin_x
    iVal_x_new = XEdges(iBin_x+1);

    if ~( iBin_x < nBin_x )
        iVal_x_new = iVal_x_new + 1; % arbitrary number added to include the edge value
    end

    iVal_y_old = YEdges(1);
    for jBin_y = 1:nBin_y
        iVal_y_new = YEdges( jBin_y+1 );
        
        if ~( jBin_y < nBin_y )
            iVal_y_new = iVal_y_new + 1; % arbitrary number added to include the edge value
        end

        ijCount = sum( ( X >= iVal_x_old ) & ( X < iVal_x_new ) & ( Y >= iVal_y_old ) & ( Y < iVal_y_new ) );
        counts( iBin_x, jBin_y ) = ijCount;

        iVal_y_old = iVal_y_new;

    end

    iVal_x_old = iVal_x_new;
end