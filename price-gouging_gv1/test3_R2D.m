%{
Created: 19 March 2023

Apply test3 to R2D data
%}

% clear all; 
rng(1);

%% Data

R2D=load('R2D_data/R2Ddata.mat');

nPop = 1e4;
pop_inds = randsample( length(R2D.myMeanRepCost), nPop, false );
myWeeklyIncome = R2D.myWeeklyIncome(pop_inds)';
myLoss_mean = R2D.myMeanRepCost(pop_inds)';
myLoss_std = R2D.myStdRepCost(pop_inds)';
myMaxLoss = myWeeklyIncome*20;

%%% When things are peaceful %%%
tq_l = sum(myLoss_mean)*0.1; % total quantity in normality: "_l" stands for loss
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Model parameters %%%
% Normalised
dQd_b = 0.5; % Increased quantity demand after disaster - basic quantities: "_b" stands for basic living costs
dPd_b = 0.1; % Increased supply price after disaster
SupSlope_b = 1;

dPd_l = 0.1;
SupSlope_l = SupSlope_b*0.5; % assumed to be less sensitive.

pcap_b = 0.1; % Price cap for basic living. If less than "dPd_b", production decreases.
pcap_l = 0.1;

% Etc.
hoarding = 0;
donation = 0; 
%%%%%%%%%%%%%%%%%%%%%%

income_min = min(R2D.myWeeklyIncome); alp_min = 0.5; q_min = 0.8*min(R2D.myWeeklyIncome);
q_b_fun = @(incomes) min([q_min + alp_min * (incomes(:)') - income_min; 10*q_min*ones(1,length(incomes))], [], 1);

weeks_to_recover = 8; % Not anymore increase in basic quantity and supply price.


%% Generate a sample of loss
myLoss_sample1 = gg.sampleLoss( myLoss_mean, myLoss_std, myMaxLoss ); 


%% Supply restoration vs. living restoration
% Default parameters
result_ban = gg.simulation( SupSlope_b, SupSlope_l, dPd_b, dPd_l, dQd_b, weeks_to_recover, myWeeklyIncome, myLoss_sample1, q_b_fun, tq_l, pcap_b, pcap_l, hoarding, donation );
result_noban = gg.simulation( SupSlope_b, SupSlope_l, dPd_b, dPd_l, dQd_b, weeks_to_recover, myWeeklyIncome, myLoss_sample1, q_b_fun, tq_l, inf, inf, hoarding, donation );
% --> The difference of the number of recovery weeks increases with (1) the upper cap of loss and (2) SupSlope_l.
figure;
plot( myWeeklyIncome, result_ban.nWeekToRecover_pop, '.' )
figure;
plot( myWeeklyIncome, result_noban.nWeekToRecover_pop, '.' )

% Ban is not favoured when pcap is too stringent compared to dPd
pcap_l_less = 0.1; dPd_l_high = 0.595;
result_ban = gg.simulation( SupSlope_b, SupSlope_l, dPd_b, dPd_l_high, dQd_b, weeks_to_recover, myWeeklyIncome, myLoss_sample1, q_b_fun, tq_l, pcap_b, pcap_l_less, hoarding, donation );
% --> The number of recovery weeks with ban in place starts increasing when (pcap_l - dPd_l) / SupSlope_l < -0.98.

% Ban is not effective when there is not much loss
myLoss_less = 0.1 * myLoss_sample1;
result_ban = gg.simulation( SupSlope_b, SupSlope_l, dPd_b, dPd_l, dQd_b, weeks_to_recover, myWeeklyIncome, myLoss_less, q_b_fun, tq_l, pcap_b, pcap_l, hoarding, donation );
result_noban = gg.simulation( SupSlope_b, SupSlope_l, dPd_b, dPd_l, dQd_b, weeks_to_recover, myWeeklyIncome, myLoss_less, q_b_fun, tq_l, inf, inf, hoarding, donation );

% Ban is favoured when price gouging is high
dPd_b_gg = 0.5; dPd_l_gg = 0.5; nWeek_gg = 20; % price-gouging rate 
result_ban = gg.simulation( SupSlope_b, SupSlope_l, dPd_b, dPd_l, dQd_b, weeks_to_recover, myWeeklyIncome, myLoss_sample1, q_b_fun, tq_l, pcap_b, pcap_l, hoarding, donation, dPd_b_gg, dPd_l_gg, nWeek_gg );
result_noban = gg.simulation( SupSlope_b, SupSlope_l, dPd_b, dPd_l, dQd_b, weeks_to_recover, myWeeklyIncome, myLoss_sample1, q_b_fun, tq_l, inf, inf, hoarding, donation, dPd_b_gg, dPd_l_gg, nWeek_gg );
% <-- the difference is quite sensitive to "q_min"

% Ban is favoured when income inequality is high -- Not obvious
income_thre = mean( myWeeklyIncome );
myWeeklyIncome_eq = zeros(1,nPop);
myLoss_sample1_eq = zeros(1,nPop);
wealthyIncome_sum = 0;
for iPopInd = 1:nPop
    iIncome = myWeeklyIncome(iPopInd);
    if iIncome < income_thre+0.01
        iIncome_ineq = iIncome * 2;
        myWeeklyIncome_eq(iPopInd) = iIncome_ineq;
        myLoss_sample1_eq(iPopInd) = myLoss_sample1(iPopInd) * 2; % If loss is not adjusted together, it takes too long for wealthy people to recover.

%         myLoss_ineq(iPopInd) = myLoss_sample1(iPopInd) * iIncome_ineq/iIncome;
    else
        wealthyIncome_sum = wealthyIncome_sum + iIncome;
    end
end
wealthy_coeff = (sum(myWeeklyIncome) - sum(myWeeklyIncome_eq) ) / wealthyIncome_sum;
myWeeklyIncome_eq(~myWeeklyIncome_eq) = myWeeklyIncome(~myWeeklyIncome_eq) * wealthy_coeff;
myLoss_sample1_eq(~myLoss_sample1_eq) = myLoss_sample1(~myLoss_sample1_eq) * wealthy_coeff;

% incomeNonMinInds = ( myWeeklyIncome > min(myWeeklyIncome) );
% myWeeklyIncome_ineq = myWeeklyIncome; myWeeklyIncome_ineq( incomeNonMinInds ) = 2*myWeeklyIncome( incomeNonMinInds );
% myLoss_ineq = myLoss_sample1; myLoss_ineq( incomeNonMinInds ) = 2*myLoss_ineq( incomeNonMinInds ); 
result_ban = gg.simulation( SupSlope_b, SupSlope_l, dPd_b, dPd_l, dQd_b, weeks_to_recover, myWeeklyIncome_eq, myLoss_sample1_eq, q_b_fun, tq_l, pcap_b, pcap_l, hoarding, donation );
result_noban = gg.simulation( SupSlope_b, SupSlope_l, dPd_b, dPd_l, dQd_b, weeks_to_recover, myWeeklyIncome_eq, myLoss_sample1_eq, q_b_fun, tq_l, inf, inf, hoarding, donation );


%% Hoarding
hoarding = 0.2;
result_ban = gg.simulation( SupSlope_b, SupSlope_l, dPd_b, dPd_l, dQd_b, weeks_to_recover, myWeeklyIncome, myLoss_sample1, q_b_fun, tq_l, pcap_b, pcap_l, hoarding, donation );
result_noban = gg.simulation( SupSlope_b, SupSlope_l, dPd_b, dPd_l, dQd_b, weeks_to_recover, myWeeklyIncome, myLoss_sample1, q_b_fun, tq_l, inf, inf, hoarding, donation );
% --> increases "Qb_lack"
% TODO: Compare Qb_lack: 
% sum( result_ban.Qb_lack_hist )
% sum( result_noban.Q_b_def_hist(:) )

%% Donation
donation = 0.1;
result_ban = gg.simulation( SupSlope_b, SupSlope_l, dPd_b, dPd_l, dQd_b, weeks_to_recover, myWeeklyIncome, myLoss_sample1, q_b_fun, tq_l, pcap_b, pcap_l, hoarding, donation );
% --> Quickens recovery


%% Probabilistic analysis
dPd_b_gg = 0.2; dPd_l_gg = 0.2; nWeek_gg = 10; % price-gouging rate 

nSample = 1e3; % This takes some time.
loss_pop = zeros(nSample,nPop);
nWeekRec_ban = zeros(nSample,nPop);
nWeekRec_noban = zeros(nSample,nPop);
Qb_def_mag_ban = zeros(nSample, nPop); % magnitude (normalised)
Qb_def_mag_noban = zeros(nSample, nPop);
Qb_def_nWeek_ban = zeros(nSample, nPop); % time (number of weeks)
Qb_def_nWeek_noban = zeros(nSample, nPop);
Q_supply_lack_mag_Qb = zeros(nSample,1); % Lack due to supply lack so applies to ban only.
Q_supply_lack_mag_Ql = zeros(nSample,1);
Q_supply_lack_nWeek_Qb = zeros(nSample,1); % Lack due to supply lack so applies to ban only.
Q_supply_lack_nWeek_Ql = zeros(nSample,1);

for iSampInd = 1:nSample
    disp( ['[Sample ' num2str(iSampInd) '] ..'] )
    rng(iSampInd) % To retreive sampling results
    iLoss = gg.sampleLoss( myLoss_mean, myLoss_std, myMaxLoss ); 

%     iResult_ban = gg.simulation( SupSlope_b, SupSlope_l, dPd_b, dPd_l, dQd_b, weeks_to_recover, myWeeklyIncome, iLoss, q_b_fun, tq_l, pcap_b, pcap_l, hoarding, donation, dPd_b_gg, dPd_l_gg, nWeek_gg );
%     iResult_noban = gg.simulation( SupSlope_b, SupSlope_l, dPd_b, dPd_l, dQd_b, weeks_to_recover, myWeeklyIncome, iLoss, q_b_fun, tq_l, inf, inf, hoarding, donation, dPd_b_gg, dPd_l_gg, nWeek_gg );

    % To show reduction in variance even when averages are similiar
    iResult_ban = gg.simulation( SupSlope_b, SupSlope_l, dPd_b, dPd_l, dQd_b, weeks_to_recover, myWeeklyIncome, iLoss, q_b_fun, tq_l, pcap_b, pcap_l );
    iResult_noban = gg.simulation( SupSlope_b, SupSlope_l, dPd_b, dPd_l, dQd_b, weeks_to_recover, myWeeklyIncome, iLoss, q_b_fun, tq_l, inf, inf );

    % Results summary
    loss_pop(iSampInd,:) = iLoss;

    nWeekRec_ban(iSampInd,:) = iResult_ban.nWeekToRecover_pop;
    nWeekRec_noban(iSampInd,:) = iResult_noban.nWeekToRecover_pop;

    Qb_def_mag_ban(iSampInd,:) = sum(iResult_ban.Q_b_def_hist,1);
    Qb_def_mag_noban(iSampInd,:) = sum(iResult_noban.Q_b_def_hist,1);

    Qb_def_nWeek_ban(iSampInd,:) = gg.getLastNonZeroIndices( iResult_ban.Q_b_def_hist, 1 );
    Qb_def_nWeek_noban(iSampInd,:) = gg.getLastNonZeroIndices( iResult_noban.Q_b_def_hist, 1 );

    Q_supply_lack_mag_Qb(iSampInd) = sum( iResult_ban.Qb_lack_hist );
    Q_supply_lack_mag_Ql(iSampInd) = sum( iResult_ban.Ql_lack_hist );

    Q_supply_lack_nWeek_Qb(iSampInd) = find( iResult_ban.Qb_lack_hist > 0, 1, 'last' );
    Q_supply_lack_nWeek_Ql(iSampInd) = find( iResult_ban.Ql_lack_hist > 0, 1, 'last' );

    if ~rem( iSampInd, 10 )
        save outputs/test3_R2D.mat
    end

end

nWeekRec_ban_avg = zeros(1,nPop); nWeekRec_noban_avg = zeros(1,nPop);
for iPopInd = 1:nPop
    iNWeekRec_ban = nWeekRec_ban(:,iPopInd);
    nWeekRec_ban_avg(iPopInd) = mean(iNWeekRec_ban(iNWeekRec_ban>0));

    iNWeekRec_noban = nWeekRec_noban(:,iPopInd);
    nWeekRec_noban_avg(iPopInd) = mean(iNWeekRec_noban(iNWeekRec_noban>0));
end
iPopInd = 9;
figure;
hist( [nWeekRec_ban(:,iPopInd), nWeekRec_noban(:,iPopInd)] )
figure;
hist( [nWeekRec_ban_avg(:), nWeekRec_noban_avg(:)] )
% --> Ban controls worst scenarios. The effect of variance reduction does
% not depend on income levels, but it does on the average sample value (the
% variance reduction is more prominent when the average is high, i.e. the
% most affected populations).


% there is no uncertainty in the following quantities (i.e. all samples are the same)
figure;
hist( [Qb_def_mag_ban(1,:)', Qb_def_mag_noban(1,:)'] ) 
figure;
scatter( myWeeklyIncome, Qb_def_mag_ban(1,:), '.' )
hold on
% scatter( myWeeklyIncome, Qb_def_mag_ban(1,:) + Q_supply_lack_mag_Qb(1), '.' )
scatter( myWeeklyIncome, Qb_def_mag_noban(1,:), '.' )



save outputs/test3_R2D.mat