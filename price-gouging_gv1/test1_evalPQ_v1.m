%{
Development in progress
%}

%{
Created: 23 Feb 2023 - JB
Last udpate: 16 March 2023 - JB
Evaluation price and quantity
%}


% clear all; 
rng(1);

load("test_data/evalPQ.mat")
% load("test_data/evalPQ_highLoss.mat")
% load("test_data/evalPQ_highDQ.mat")
% load("test_data/evalPQ_highTql.mat")
% load("test_data/evalPQ_highDPdb.mat")
% load("test_data/evalPQ_highDPdl.mat")
% load("test_data/evalPQ_highSupSlopel.mat")

%% Evaluation of price
loss_rem_hist = zeros(0,nPop); % History of remaining loss 
pr_b_def_hist = zeros(0,nPop); % History of monetary deficit for basic living
Q_b_def_hist = zeros(0,nPop); % History of (normalised) quantity deficit for basic living

q = q_min + alp_min * (myWeeklyIncome - q_min); % individual demands
loss_rem = myLoss;
iWeek = 0;
while sum(loss_rem) > 0
    iWeek = iWeek+1;

    iIncome_remain = myWeeklyIncome;
    
    % % (1) basic living first
    dPt_b = max([0, dPd_b*(1-(iWeek-1)/weeks_to_recover)]);
    dQt_b = max([0, dQd_b*(1-(iWeek-1)/weeks_to_recover)]);
    Prd_b = SupSlope_b * (1+dQt_b -1) + dPt_b +1; % Increased percentage price after disasters
    
    prd_b_pop = Prd_b*q*(1+dQt_b); % actual prices for basic living for each population
    iIncome_remain = iIncome_remain - prd_b_pop;
    qb_dfc_inds = (iIncome_remain<0);
    
    iQb_dfc = zeros(1,nPop); % Normalised quantity of basic living deficit
    iQb_dfc(qb_dfc_inds) = abs(iIncome_remain(qb_dfc_inds) ./ prd_b_pop(qb_dfc_inds));
    
    iprb_dfc = zeros(1,nPop); % Monetary value of basic living deficit
    iprb_dfc(qb_dfc_inds) = abs(iIncome_remain(qb_dfc_inds));
    iIncome_remain(qb_dfc_inds) = 0;
    
    % % (2) Repair cost
    dQd_l = sum(loss_rem)/tq_l;
    Prd_l = SupSlope_l * (1+dQd_l -1) + dPd_l +1; % Increased percentage price after disasters - repair
    
    ipr_l = loss_rem*Prd_l;
    ircv_l = min([iIncome_remain; ipr_l]); % recovered loss
    iRcv_l = ircv_l / Prd_l; % recovered loss - normalised
    loss_rem = loss_rem - iRcv_l;
    
    % % Record
    loss_rem_hist = [loss_rem_hist; loss_rem];
    pr_b_def_hist = [pr_b_def_hist; iprb_dfc];
    Q_b_def_hist = [Q_b_def_hist; iQb_dfc];
end

nWeekToRecover_pop = zeros(nPop,1);
for ii = 1:nPop
    nWeekToRecover_pop(ii) = find( ~(loss_rem_hist(:,ii)>0), 1 ) - 1;
end

nBin = 5;
figure(1);
histogram(nWeekToRecover_pop,nBin)
figure(2);
scatter( myWeeklyIncome, nWeekToRecover_pop, 'filled' )
grid on
disp( "Weeks for all to recover: "+num2str(max(nWeekToRecover_pop)) )
