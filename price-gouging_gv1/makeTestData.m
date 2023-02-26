clear all

%% test_evalPQ
% % Default setting
nPop = 5;
myWeeklyIncome = [1 2 3 4 5];
myLoss = myWeeklyIncome * 10;
myLoss([2,4]) = 0; % there are some unaffected people.

q_min = 0.8*min(myWeeklyIncome); % Parameter - Min. living quantity 
alp_min = 0.8; %  Quantity needs increase per unit income 

%%% When things are peaceful %%%
tq_l = sum(myLoss)*0.2; % total quantity in normality: "_l" stands for loss
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% All normalised %%%
dQd_b = 0.5; % Increased quantity demand after disaster - basic quantities: "_b" stands for basic living costs
dPd_b = 0.2; % Increased supply price after disaster
SupSlope_b = 1; 

dPd_l = 0.2;
SupSlope_l = SupSlope_b*0.1; % assumed to be less sensitive.
%%%%%%%%%%%%%%%%%%%%%%

weeks_to_recover = 8; % Not anymore increase in basic quantity and supply price.

save("test_data/evalPQ.mat")

% % Variant % %
load( "test_data/evalPQ.mat" )
myLoss = myLoss * 2;
save("test_data/evalPQ_highLoss.mat")

% % Variant % %
load( "test_data/evalPQ.mat" )
dQd_b = dQd_b*2;
save("test_data/evalPQ_highDQ.mat")

% % Variant % %
load( "test_data/evalPQ.mat" )
tq_l = tq_l*2;
save("test_data/evalPQ_highTql.mat")

% % Variant % %
load( "test_data/evalPQ.mat" )
dPd_b = dPd_b*4;
save("test_data/evalPQ_highDPdb.mat")

% % Variant % %
load( "test_data/evalPQ.mat" )
dPd_l = dPd_l*2;
save("test_data/evalPQ_highDPdl.mat")

% % Variant % %
load( "test_data/evalPQ.mat" )
SupSlope_l = SupSlope_l*2;
save("test_data/evalPQ_highSupSlopel.mat")