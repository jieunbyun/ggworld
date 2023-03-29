function loss_sample1 = sampleLoss( myLoss_mean, myLoss_std, myMaxLoss )

nPop = length(myLoss_mean);

loss_sample1 = zeros(1,nPop);
for iPopInd = 1:nPop
    iLoss_mean = myLoss_mean(iPopInd); iLoss_std = myLoss_std(iPopInd); myMaxLoss( iPopInd );
    iLossDist = truncate( makedist( 'Normal', iLoss_mean, iLoss_std ), -inf, myMaxLoss(iPopInd) );

    iLoss_sample = random(iLossDist, 1 );
    iLoss_sample = max([0, iLoss_sample]);

    loss_sample1(iPopInd) = iLoss_sample;
end