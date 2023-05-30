function [] = myPlot(nf,x,y1,y2,y1_std,y2_std,xlab,ylab1,ylab2,yaxis1,yaxis2)

    if nargin < 11
        yaxis2 = [];
        if nargin < 10
            yaxis1 = [];
        end
    end

    figure(nf)

%     if ~isempty(y1_std)
%         conf_y1 = [y1+y1_std, y1(end:-1:1)-y1_std(end:-1:1)];
%         conf_y2 = [y2+y2_std, y2(end:-1:1)-y2_std(end:-1:1)];
%         conf_x = [x x(end:-1:1)] ;         
% 
%         yyaxis left
%         % hold off;
%         p = fill(conf_x,conf_y1,'red');
%         p.FaceColor = [0.8 0.8 1];      
%         p.EdgeColor = 'none';    
%         set(p,'facealpha',0.3);
%         hold on;
% 
%         yyaxis right
%         % hold off;
%         p = fill(conf_x,conf_y2,'red');
%         p.FaceColor = [0.8500 0.3250 0.0980];      
%         p.EdgeColor = 'none';    
%         set(p,'facealpha',0.2);
%         hold on;
%     end

    yyaxis left
    plot(x, y1, 'LineWidth', 1.5, "LineStyle", "-"); hold on; 
    if ~isempty(yaxis1)
        set(gca, "YLim", yaxis1)
    end
    ylabel(ylab1); 

    yyaxis right
    plot(x, y2, 'LineWidth', 1.5, "LineStyle", "--"); hold on; 
    if ~isempty(yaxis2)
        set(gca, "YLim", yaxis2)
    end
    ylabel(ylab2); 
    
    grid on; set(gcf,'color','w');
    xlabel(xlab)

    xlim([min(x),max(x)])
    set(gca,'fontname','times', "FontSize", 16)
%     fontsize(16,"points")


    if isempty(y1_std)
        if isempty(yaxis1)
            yyaxis left
            dy1 = max(y1)-min(y1);
            ylim([min(y1) max(y1)] + dy1*[-0.1 0.1])
        end
        if isempty(yaxis2)
            yyaxis right
            dy2 = max(y2)-min(y2);
            ylim([min(y2) max(y2)] + dy2*[-0.1 0.1])
            yaxis2 = [min(y2) max(y2)] + dy2*[-0.1 0.1];
        end
    end

    % To make the right-hand side axis dashed
    yyaxis right
    ax = gca;
    xaxis = ax.XLim;
    xmove = 0;
    line([xaxis(2), xaxis(2)]+xmove, yaxis2, 'color', 'w', 'LineWidth', 3);
    % Draw a dashed line on top of the white line.
    line([xaxis(2), xaxis(2)], yaxis2, 'color', [0.8500, 0.3250, 0.0980], 'LineStyle', '--', "LineWidth", 1.2);

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
    plot(x, y1, 'LineWidth', 1.5, "LineStyle", "-");

    yyaxis right
    plot(x, y2, 'LineWidth', 1.5, "LineStyle", "--");
end