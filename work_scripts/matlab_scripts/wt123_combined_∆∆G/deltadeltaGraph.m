%general settings
clear;
close all
blue = [57 106 177]./255;
red = [204 37 41]./255;
black = [83 81 84]./255;
green = [62 150 81]./255;
brown = [146 36 40]./255;
purple = [107 76 154]./255;


%script details
peptides = 12;
figure('Name','cumulative','NumberTitle','off');
%data and processing
data_array1 = load("1wt_residue_summary_all_peps.txt");
data_array2 = load("2wt_residue_summary_all_peps.txt");
data_array3 = load("3wt_residue_summary_all_peps.txt");

combind_array = cat(1,data_array1,data_array2,data_array3);
data_mean = mean(combind_array,1);
data_std = std(combind_array,1);
data_ste = data_std/sqrt(peptides);
%figure settings
myfontsize = 15;
errorbar(data_mean, data_ste, '-r.', 'MarkerSize',20, 'LineWidth',2, 'Color',blue);
ylabel('\Delta\DeltaG_{opt,elec}, kcal/mol','fontsize',myfontsize);
xlabel('BF2 residue','fontsize',myfontsize);
ax1 = gca;

%restricts the axises to be directly up on the data and then gives them
%some centering space
axis(ax1, 'tight');
xlim(ax1, xlim(ax1) + [-1,1]*range(xlim(ax1)).* 0.05)
ylim(ax1, ylim(ax1) + [-1,1]*range(ylim(ax1)).* 0.05)
%
ax1.FontSize = myfontsize;
xticks(0:length(data_mean));
xticklabels({'','T1','S3','S4','A6','G7','L8','Q9','10W','11P','V12','G13','V15','H16','L18','L19',''});



