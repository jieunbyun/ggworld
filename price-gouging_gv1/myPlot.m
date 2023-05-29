function [] = myPlot(nf,x,y1,y2,y1_std,y2_std,xlab,ylab1,ylab2)

    figure(nf)

    if ~isempty(y1_std)
        conf_y1 = [y1+y1_std, y1(end:-1:1)-y1_std(end:-1:1)];
        conf_y2 = [y2+y2_std, y2(end:-1:1)-y2_std(end:-1:1)];
        conf_x = [x x(end:-1:1)] ;         

        yyaxis left
        % hold off;
        p = fill(conf_x,conf_y1,'red');
        p.FaceColor = [0.8 0.8 1];      
        p.EdgeColor = 'none';    
        set(p,'facealpha',0.3);
        hold on;

        yyaxis right
        % hold off;
        p = fill(conf_x,conf_y2,'red');
        p.FaceColor = [0.8500 0.3250 0.0980];      
        p.EdgeColor = 'none';    
        set(p,'facealpha',0.2);
        hold on;
    end

    yyaxis left
    plot(x, y1); hold on; 
    ylabel(ylab1); 

    yyaxis right
    plot(x, y2); hold on; 
    ylabel(ylab2); 
    
    grid on; set(gcf,'color','w');
    xlabel(xlab)

    xlim([min(x),max(x)])
    set(gca,'fontname','times')
    fontsize(16,"points")


    if isempty(y1_std)

        yyaxis left
        dy1 = max(y1)-min(y1);
        ylim([min(y1) max(y1)] + dy1*[-0.1 0.1])
        yyaxis right
        dy2 = max(y2)-min(y2);
        ylim([min(y2) max(y2)] + dy2*[-0.1 0.1])
    end
end