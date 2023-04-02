function counts = my_hist( X, XEdges )
% The original matlab's function "hist3" create strange zero rows and columns at the end.

nBin_x = length(XEdges) - 1;

counts = zeros(1, nBin_x);

iVal_x_old = XEdges(1);
for iBin_x = 1:nBin_x
    iVal_x_new = XEdges(iBin_x+1);

    if ~( iBin_x < nBin_x )
        iVal_x_new = iVal_x_new + 1; % arbitrary number added to include the edge value
    end

    iCount = sum( ( X >= iVal_x_old ) & ( X < iVal_x_new ) );
    counts( iBin_x ) = iCount;

    iVal_x_old = iVal_x_new;
end