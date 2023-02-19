
% Currently, 1 - 19970
% TODO: Randomly mix the building info and run for 20000 buildings again 
% TODO: Extract only residential buildings...
% TODO: Match the income scale https://www.sfchronicle.com/sf/article/income-inequality-San-Francisco-17462495.php#:~:text=According%20to%20the%20data%2C%20San,made%20no%20more%20than%20%2453%2C000.
%       95% 574K/year 
%       20% 53K/year
%       median 119K/year (2020)  https://datausa.io/profile/geo/san-francisco-ca
% TODO: COnsider variation of DV such that some households have zero damage
% TODO: Duplicate story number

clear all
close all

DV=readtable('DV_1-19970.csv','NumHeaderLines',4); % 2 is mean repair cost
info=readtable('SanFrancisco_buildings_full.csv','NumHeaderLines',3); % 

nasset = size(DV,1);
ResID = find(startsWith(convertCharsToStrings(table2array(info(1:nasset,9))),"RES"));

meanRepCost = table2array(DV(ResID,2));
stdRepCost = table2array(DV(ResID,3));
meanRepTime = table2array(DV(ResID,14));
% 
lat =table2array( info(ResID,2));
lon = table2array(info(ResID,3));
buildingValue = table2array(info(ResID,7)); 
numStory = table2array(info(ResID,5)); 
% Let us assume that (1) replacement cost is proportional to building value (2) income is proportional to the building value
%
% Histogram of repiar cost
%

figure(1);
histogram(log((meanRepCost)));
xlabel('log-meanRepCost');

disp(['log mean of mean Repair cost is ', num2str(mean(log(log(meanRepCost))))])
disp(['log var of mean Repair cost is ', num2str(var(log(log(meanRepCost))))])

%
% Spatial Plot of repair cost
%

figure(2);
geoscatter(lat,lon,5,(log(meanRepCost)),'.','SizeData',50);
colorbar(); set(gcf,'color','w');
title('log-meanRepCost');

%
% Divide by number of household (num storeies)
%

myMeanRepCost=zeros(sum(numStory),1);
myStdRepCost=zeros(sum(numStory),1);
myBuildingValue=zeros(sum(numStory),1);
idx=0;
for i=1:length(ResID)
    for j=1:numStory(i)
        idx=idx+1;
        myMeanRepCost(idx) = meanRepCost(i)/numStory(i);
        myStdRepCost(idx) = stdRepCost(i)/numStory(i);
        myBuildingValue(idx) = buildingValue(i)/numStory(i);
    end
end



%
% Spatial Plot of building value
%

% rP = building value / weekly income
rP20 = prctile(myBuildingValue,0.20)/(26500/52);
rP40 = prctile(myBuildingValue,0.40)/(65000/52);
rP50 = prctile(myBuildingValue,0.50)/(87700/52);
rP60 = prctile(myBuildingValue,0.60)/(112000/52);
rP80 = prctile(myBuildingValue,0.80)/(190000/52);
factor = mean([rP20,rP40,rP50,rP60,rP80]);

figure(3);
histogram(log(((myBuildingValue))));
xlabel('log-buildingValue');

% figure(4);
% geoscatter(lat,lon,5,log((myBuildingValue)),'.','SizeData',50);
% colorbar(); set(gcf,'color','w');
% title('log-buildingValue');
% 
myWeeklyIncome = myBuildingValue/factor;
figure(5);
histogram(log((myWeeklyIncome)));
xlabel('log-monthlyIncome');

income_perc_v = [26500, 65000, 87700, 112000, 190000]/52;
income_perc_p = [20, 40, 50, 60, 80]/100;

perc = @(a) norm(logninv(income_perc_p,a(1),a(2)) - income_perc_v);
params=fminsearch(perc,[20,10]);

myWeeklyIncome_unsorted = lognrnd( params(1), params(2), length(myBuildingValue), 1 );
myWeeklyIncome_unsorted = sort(myWeeklyIncome_unsorted, 'ascend');
[~,myBuildingValue_sInd] = sort(myBuildingValue, 'ascend');
myWeeklyIncome = zeros(size(myWeeklyIncome_unsorted));
myWeeklyIncome(myBuildingValue_sInd) = myWeeklyIncome_unsorted;
myWeeklyIncome(myWeeklyIncome<income_perc_v(1)) = income_perc_v(1);

figure;
plot( myBuildingValue, log(myWeeklyIncome), '.' )
figure;
plot( log(myMeanRepCost), log(myWeeklyIncome), '.' )
% corr(log(myMeanRepCost), log(myWeeklyIncome))=0.2043


disp(['log mean of monthlyIncome is ', num2str(mean(log((meanRepCost))))])
disp(['log std of monthlyIncome is ', num2str(std(log((meanRepCost))))])

%{
nsamp = 10;
% Marginal Dist of weekly income
[alpha1, xmin1, L] = plfit(weeklyIncome);
x1 = xmin1*(1-rand(nsamp,1)).^(-1/(alpha1-1));

% Marginal Dist of 
[alpha2, xmin2, L] = plfit(meanRepCost);
x2 = xmin2*(1-rand(nsamp,1)).^(-1/(alpha2-1));

%
% Inverse Nataf
%
}%
% U1 = norminv(1-(weeklyIncome/xmin1).^(-(alpha1-1)));
% U2 = norminv(1-(meanRepCost/xmin2).^(-(alpha2-1)));
% figure(6);
% scatter(U1,U2);
%}


save('R2Ddata','myMeanRepCost','myStdRepCost','myWeeklyIncome');



