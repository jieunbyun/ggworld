function  [idqd_hist, happiness_discount_hist] = simulBan(figID, isCaseBan, nWeeks, iI, iq_min, alp_min,  dPc, donate_ratio,rv)
            
    damper_factor = 0.3; % no damper if 1 => Affects Mean recovery time / stability
    consumption_reduction = 0.7; % no reduction if 1 => Affects Mean recovery time
    government_helps = 0; %Bool => Poor suffers if goverment does not help

    %
    % Unpack rvs
    %
    weeks_to_recover= rv.weeks_to_recover_samp; % when 100% selling secured
    idQd= rv.idQd_samp;                         % individual repair quantity
    dQd_basic = rv.dQd_basic_samp;              % individual basic living cost increase
    dQd_basic = 0; %%% 230219
    dPd= rv.dPd_samp;                   % price increase due to supply chain disruption
    SupSlope=  rv.SupSlope_samp;        % individual supply slope
    iDemSlope=  rv.iDemSlope_samp;      % individual demand slope    
    nhouse = length(iI);
    %dPpg= rv.dPpg_samp;                 % price increase due to gauging
    dPpg = 0;
    dQh= rv.dQh_samp;                   % quantity increase due to hoarding
    dQh = 0; % (230223) at the moment, not considered

    %
    % Original (Predisaster) Quantity demand
    %
    
    P=1; % price
    nPop = length(iI); % population    
    minqID = 1; addqID = 2;

    iq = zeros(2,nPop); % individual demands
    iq(minqID,:) = iq_min; % basic living
    iq(addqID,:) = alp_min * (iI - iq_min*P); % additional
    tqo = sum(iq,"all"); % q represents non-normalized quantity, Q is normalized qnatity  
    
    % 
    % Original (Predisaster) Living Cost
    % 

    iLC = iq*P; % individual living cost
    Selling_amount = tqo*P; % For the supply chain to recover, they need enough selling

    % 
    % Increased demand after disaster1 - Basic demand
    %     
    
    weeks_to_recover = round(weeks_to_recover);% when post-disaster selling ratio is 100%

    % 
    % Increased demand after disaster1 - Repair cost
    % 
    
    idqd = iq(2,:).*idQd; % REPAIR COST ---- deducted every week
    
    %
    % Hoarding 
    %
    
    isSupplyLack = 0; % not yet
    
    %
    % Simulation
    %
    
    idqd_hist = [];
    happiness_discount_hist = [];
    P_hist=[];
    Q_hist=[];
    Selling_ratio_d = 0;
    restor_amount = 0;
    iI_add = 0;
    P_old=1;
    for nw=1:nWeeks 
        
        % Weekly income
        iI_tmp = iI + iI_add; % add donation & carry over
        
        %
        % WEEK nw - Post-disaster demand increase
        %
        
        if nw<weeks_to_recover
            iqd(1,:) = iq(1,:).*(1+dQd_basic);    % TODO: when is this recovered?
        else
            iqd(1,:) = iq(1,:).*(1);               % survival demand
        end

        iqd(2,:) = iq(2,:)*consumption_reduction + idqd;        % happiness + restoration demand(=unmet amount from previous stage) 
                                              % priority: survival > restoration > happiness 
        tqd = sum(iqd,"all");                % totoal quantity
        dQd = tqd/tqo-1;                     % normalize this
        

        %
        % CASE1 : demand dQ is determined by absolute demand
        %
       
        %%{
        if isSupplyLack
            % Hoarding activated
            dQt = dQd + dQh;  % increased demand after disaster
        else
            dQt = dQd;        % increased demand after disaster
        end
        %}

        %
        % CASE2 : demand dQ is determined the demand in the previous stage
        %
        %{
        if nw==1
            dQt = dQd;
        else
            dQt = dQt_previous_week;
        end
        %}
        %
       
        %
        % Post-disaster supply cost increase
        %

        restor_inc = 1/weeks_to_recover*Selling_ratio_d; % if Selling_ratio_d is 100%, supply chain is recovered in "weeks_to_recover" weeks
        restor_amount = restor_amount+ restor_inc;
        if restor_amount>1
            restor_amount = 1;
        end
        
        dPt = (dPd + dPpg)*(1-restor_amount); % TODO: Does PG also decrease?
        
        %
        % Apply damper
        %

        dPt=damper_factor*dPt;
        dQt=damper_factor*dQt;

        %
        % New price & supplied quantity based on Sup=Dem (See the figure)
        %

        DemSlope = 1/sum(1./iDemSlope);  % aggregated (markey) demand slope from individual ones.
        Pd = ( SupSlope*DemSlope*dQt+DemSlope*dPt) / (DemSlope - SupSlope) +1; % post-disaster price level
        %Qd = 1 + (DemSlope*dQt + dPt) / (DemSlope - SupSlope);                 % post-disaster available quantity
        dPt2 = ((Pd -1)*(DemSlope - SupSlope)-SupSlope*DemSlope*dQt)/DemSlope;
        Qd = 1 + (DemSlope*dQt + dPt2) / (DemSlope - SupSlope);                 % post-disaster available quantity
            
        
        if (isCaseBan) && (Pd > 1+dPc)
            isCapActivated = 1; 
        else
            isCapActivated = 0;
        end
        
        if isCapActivated
            Pc = 1+dPc; % enforce the price cap

            % update post-disaster price
            P_new = Pc;
            Q_new = Qd - 1/SupSlope*(Pd - Pc); % supplied amount 
            Q_new2 = Qd - 1/DemSlope*(Pd - Pc); % needed amount 

            %
            % increased individual quantity demand after artificial price decrease
            %
            
            iqd = (P_new-1)./iDemSlope + iqd;
            
        else
            P_new = Pd;
            Q_new = Qd;
            
            iqd = (P_new-1)./iDemSlope + iqd;            
        end

%         P_new = 1+(P_new-1)*damper_factor;


%         if P_new>2*P_old
%             P_new = 2*P_old;
%         elseif P_new<0.5*P_old
%             P_new = 0.5*P_old;
%         end

        if Q_new<0
            error("Q_new cannot be negative. change your parameters.")
        end

        % If too expensive, people don't want to buy...
        iqd(iqd<0)=0;
       
        %
        % Post-disaster Quantity-demand and Living Cost
        %   

        iLCd_exp = iqd * P_new; % new livingcost - if infinite budget
        iLCd_basic = (iLCd_exp(1,:));   % basic livingcost        
        iqd_zero_balance = min(iqd(2,:),(iI_tmp-iLCd_basic)/P_new); % if rich - buy as much as you want (former), if poor - buy only amount you can (latter)
        
        %
        % If basic living cost is not secured ... borrow money from somewhare
        %
        if min(iI_tmp-iLCd_basic)<0
           fprintf(2,'\nsome people are borrowing money to survive...\n')
           iLC_borrowed=zeros(1,nPop);
           idx_bor = (iI_tmp-iLCd_basic)<0;  % people who borrows
           iLC_borrowed(idx_bor) = iLCd_basic(idx_bor)-iI_tmp(idx_bor); % borrowed amount
           iqd_zero_balance = iqd_zero_balance+iLC_borrowed/P_new;% after borrowing
           if government_helps==1
            iLC_borrowed = 0;
           end
        else
           iLC_borrowed = 0;
        end
        
        tqd_zero_balance = sum(iqd_zero_balance); 
        t_profit = tqd_zero_balance*P_new;
    
        disp(num2str(t_profit))
        %
        % Check the status of the village
        %

        disp("* post disaster quantity status *");
        disp("  - Supplied quantity:"+num2str(Q_new*tqo));
        disp("  - Minimum required quantity:"+num2str(sum(iqd(1,:))));
        disp("  - Zero-balance quantity:"+num2str(tqd_zero_balance+sum(iqd(1,:))));
        disp("  - Total required quantity:"+num2str(tqd));
        
        if (Q_new*tqo>=sum(iqd(1,:)))*(Q_new*tqo<=tqd)
           disp("  - We have Min<=Sup<=Tot (good)"); 
        else
           %error("Ill-posed problem")
          fprintf(2,'\nI think many people are starving...\n')
        end
        if (Q_new*tqo>tqd_zero_balance)
           disp("  - Supplied quantitiy is greater than zero-balance quantity. If they have money, they can buy"); 
           isSupplyLack  = 0;
        else 
           disp("  - Supply lack occurred. We have only "+num2str(Q_new*tqo/tqd_zero_balance*100)+"% of the total demand supplied. Randomly allocating the quantity")
           isSupplyLack  = 1;
        end
        
        %
        % Distribute the quantity - Who gets the quantity under supply lack?
        %

        if isSupplyLack
           if (~isCapActivated)
               %error("Supply lack occurred without ban. Do we need to selectively allocate the quantity??");
              fprintf(2,'\nSupply lack occurred without ban. Do we want to selectively allocate the quantity??...\n')
           end
           
           %
           % Let us discretize total quantity
           %
           nDisQuantity = nPop*10000; % discretization number - TODO: try bigger chunks
           allocationID = randperm(nDisQuantity,round(nDisQuantity*Q_new*tqo/tqd_zero_balance)); % SUPPLIED AMOUNT: Q_new*tqo, NEEDED AMOUNT: tqd_zero_balance
           allocatedQuantity =histcounts(allocationID, cumsum([0 iqd_zero_balance])/sum(iqd_zero_balance)*nDisQuantity); % randomly allocating resources
           iqd_supplied = allocatedQuantity/nDisQuantity*sum(iqd_zero_balance);
           iqd_supplied = min(iqd_supplied,iqd(2,:));
        else
           iqd_supplied = iqd_zero_balance;
        end
        
        
        iqd_unmet = iqd(2,:) - iqd_supplied; % all shares similar percentage of consumption within their budgets
        iqd_bought = iqd_supplied+iqd(1,:);
        tqd_sold = sum(iqd_bought);
        
        %
        % idqd after deduction
        %

        idqd_updated = idqd;
        idqd_updated(iqd_unmet<idqd) = iqd_unmet(iqd_unmet<idqd); % The people with (iqd_unmet>idqd) couldn't repair the house this week and they are not happy (Happiness will be also reduced)
        
        %
        % happyiess reduction 
        %
        
        weekly_happiness_discount = zeros(1,nPop);
        weekly_happiness_discount(iqd_unmet>idqd) = iqd_unmet(iqd_unmet>idqd) - idqd(iqd_unmet>idqd); 

        %
        % For the supply chains to recover, they need enough selling
        %

        Selling_amount_d = tqd_sold*P_new;                  
        Selling_ratio_d = Selling_amount_d/Selling_amount; % how much is the selliing amount compared to the pre-disaster condition
        
        %
        % Donations...
        %
        
        iPayed_amount = (iqd_bought)*P_new;
        iRemaining_income = (iI_tmp-iPayed_amount);  % Can be negative due to the discretization... it's okay because it will slightly reduce next week's income
        idxDonate = (idqd_updated==0); % if repair is finished
        idxReceive = (idqd_updated>0); 
        

        %
        % Additional income = Donation + Carry over - Loan
        %

        iI_add = zeros(1,nPop);
        iI_add(idxReceive) = sum(iRemaining_income(idxDonate)*donate_ratio)/sum(idxReceive);    %Equally distribute
        iI_add(idxReceive) = iI_add(idxReceive) + iRemaining_income(idxReceive) ;
        iI_add = iI_add - iLC_borrowed;

        %
        % Update the repair demand
        %

        idqd = idqd_updated;
        dQt_previous_week = tqd_sold/tqo-1; % not used
        %
        % Make records
        %

        idqd_hist = [ idqd_hist; idqd];
        happiness_discount_hist = [ happiness_discount_hist; weekly_happiness_discount];
        P_hist = [P_hist P_new];
        Q_hist = [Q_hist Q_new];

        %plot(P_hist); hold on;
        %plot(Q_hist); hold off;

        P_old=P_new;% not used
        
    end

    %
    % plot
    %
    
    idQ1 = find((iI>quantile(iI,0.75)));
    idQ2 = find((iI>quantile(iI,0.5)).*(iI<quantile(iI,0.75)));
    idQ3 = find((iI>quantile(iI,0.25)).*(iI<quantile(iI,0.5)));
    idQ4 = find((iI<quantile(iI,0.25)));
    
    barQ1 = diff(sum(idqd_hist(:,idQ1)'==0));
    barQ2 = diff(sum(idqd_hist(:,idQ2)'==0));
    barQ3 = diff(sum(idqd_hist(:,idQ3)'==0));
    barQ4 = diff(sum(idqd_hist(:,idQ4)'==0));
    
    figure(figID+1); 
    subplot(4,1,1); bar([barQ1;barQ2;barQ3;barQ4]','stack')
    legend('Q1','Q2','Q3','Q4');
    xlabel('weeks'); ylabel('# recovered households')
    if figID==0
        title("Ban")
    elseif figID==100
        title("NoBan")
    end
    subplot(4,1,2); hold on; plot(P_hist); plot(Q_hist)
    xlabel('weeks'); ylabel('value'); legend('P','Q')
    ylim([0.5,1.5]);
    subplot(4,1,3); bar(sum(happiness_discount_hist,2),'facealpha',0.3)
    xlabel('weeks'); ylabel('lack'); legend('P','Q')
    subplot(4,1,4); plot(sum(idqd_hist(:,:)'==0)/nhouse); ylim([0,1])
    xlabel('weeks'); ylabel('ratio of recovered households')
    disp("")