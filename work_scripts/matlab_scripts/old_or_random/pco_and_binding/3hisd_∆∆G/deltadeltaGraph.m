%% general settings %%

clear;
close all
blue = [57 106 177]./255;
red = [204 37 41]./255;
black = [83 81 84]./255;
green = [62 150 81]./255;
brown = [146 36 40]./255;
purple = [107 76 154]./255;

residue_summary = load("residue_summary_all_peps.txt");
simulation_name = "3 protonated histidine";
peptides_per_sim = 4;
lipids_per_sim = 128;
Row_lengths = [12 12 12 12]; %to seperate the cumulative residue summary. 12 is the number of snapshots and there are four sets of 12 snapshots

%% ∆∆G Graphs %%

peptide_mean_array = [];

% setting up the mean,atd,ste
all_peptides_cell = mat2cell(residue_summary,Row_lengths);

for pep = peptides_per_sim:-1:1.0
    mean_peptide = mean(all_peptides_cell{pep});
    peptide_mean_array = [peptide_mean_array;mean_peptide];


    %setting up the figures

    figure('Name',"Peptide "+pep+" Residue ∆∆G",'NumberTitle','off');

    current_peptide = all_peptides_cell{pep};
    single_peptide_mean = mean(current_peptide);
    single_data_mean = mean(single_peptide_mean,1);
    single_data_std = std(current_peptide,1);

    %
    myfontsize = 15;
    errorbar(single_data_mean, single_data_std, '-r.', 'MarkerSize',20, 'LineWidth',2);
    ylabel('\Delta\DeltaG_{opt,elec}, kcal/mol','fontsize',myfontsize);
    xlabel('BF2 residue','fontsize',myfontsize);
    ax1 = gca; 
    
    %restricts the axises to be directly up on the data and then gives them some centering space
    axis(ax1, 'tight');
    xlim(ax1, xlim(ax1) + [-1,1]*range(xlim(ax1)).* 0.05)
    ylim(ax1, ylim(ax1) + [-1,1]*range(ylim(ax1)).* 0.05)

    %
    ax1.FontSize = myfontsize;
    xticks(0:length(single_data_mean));
    xticklabels({'','T1','S3','S4','A6','G7','L8','Q9','10W','11P','V12','G13','V15','H16','L18','L19',''});
end

%% Cumulative ∆∆G graph %%


figure('Name','Cumulative_Peptides','NumberTitle','off');

%
cumulative_data_mean = mean(peptide_mean_array,1);
cumulative_data_std = std(peptide_mean_array,1);
cumulative_data_ste = cumulative_data_std/sqrt(peptides_per_sim);

%
myfontsize = 15;
errorbar(cumulative_data_mean, cumulative_data_ste, '-r.', 'MarkerSize',20, 'LineWidth',2);
ylabel('\Delta\DeltaG_{opt,elec}, kcal/mol','fontsize',myfontsize);
xlabel('BF2 residue','fontsize',myfontsize);
ax1 = gca; 
    
%restricts the axises to be directly up on the data and then gives them some centering space
axis(ax1, 'tight');
xlim(ax1, xlim(ax1) + [-1,1]*range(xlim(ax1)).* 0.05)
ylim(ax1, ylim(ax1) + [-1,1]*range(ylim(ax1)).* 0.05)

%
    ax1.FontSize = myfontsize;
    xticks(0:length(cumulative_data_mean));
    xticklabels({'','T1','S3','S4','A6','G7','L8','Q9','10W','11P','V12','G13','V15','H16','L18','L19',''});

