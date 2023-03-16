% clear all; 
rng(1);

load("test_data/evalPQ.mat")
% load("test_data/evalPQ_highLoss.mat")
% load("test_data/evalPQ_highDQ.mat")
% load("test_data/evalPQ_highTql.mat")
% load("test_data/evalPQ_highDPdb.mat")
% load("test_data/evalPQ_highDPdl.mat") % Does not run: sigular point
% load("test_data/evalPQ_highSupSlopel.mat")


q_b_fun = @(incomes) q_min + alp_min * (incomes - q_min);

pcap_b = 0.1; % Price cap for basic living. If less than "dPd_b", production decreases.
% pcap_l = 0.101; % Price cap for repair
pcap_l = 0.11;
% pcap_b = inf; pcap_l = inf;
hoarding = 0; % --> increases "Qb_lack"
donation = 0; 

result = gg.simulation( SupSlope_b, SupSlope_l, dPd_b, dPd_l, dQd_b, weeks_to_recover, myWeeklyIncome, myLoss, q_b_fun, tq_l, pcap_b, pcap_l, hoarding, donation );