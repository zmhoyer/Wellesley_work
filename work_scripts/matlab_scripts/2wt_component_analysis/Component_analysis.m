%% general settings %%

blue = [57 106 177]./255;
red = [204 37 41]./255;
black = [83 81 84]./255;
green = [62 150 81]./255;
brown = [146 36 40]./255;
purple = [107 76 154]./255;


% figure creation
figure('Name',"765000ps and 937500ps Component analysis",'NumberTitle','off');

% data load and processing

ps765000 = load("765000ps_component_analysis.txt");
ps937500 = load("937500ps_component_analysis.txt");

ps765000_array = ps765000(:,1);
ps765000_array = ps765000_array * (-1);
ps937500_array = ps937500(:,1);
ps937500_array = ps937500_array * (-1);


    myfontsize = 15;
    plot(ps765000_array, '-b.', 'MarkerSize',20, 'LineWidth',2, 'Color',blue);
    hold on;
    plot(ps937500_array, '-r.', 'MarkerSize',20, 'LineWidth',2, 'Color',red);

    ylabel('∆∆G (BFE - Zeroed residue)','fontsize',myfontsize);
    xlabel('BF2 residue','fontsize',myfontsize);
    ax1 = gca;
    %restricts the axises to be directly up on the data and then gives them
    %some centering space
    axis(ax1, 'tight');
    xlim(ax1, xlim(ax1) + [-1,1]*range(xlim(ax1)).* 0.05)
    ylim(ax1, ylim(ax1) + [-1,1]*range(ylim(ax1)).* 0.05)

    ax1.FontSize = myfontsize;
    xticks(0:21);
    xticklabels({'','1THR', '2ARG', '3SER', '4SER', '5ARG', '6ALA', '7GLY', '8LEU', '9GLN', '10TRP', '11PRO', '12VAL', '13GLY', '14ARG', '15VAL', '16HISD', '17ARG', '18LEU', '19LEU', '20ARG', '21LYS',''});