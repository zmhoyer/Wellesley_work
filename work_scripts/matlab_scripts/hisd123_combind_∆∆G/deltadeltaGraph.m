%% general settings
clear;
close all
blue = [57 106 177]./255;
red = [204 37 41]./255;
black = [83 81 84]./255;
green = [62 150 81]./255;
brown = [146 36 40]./255;
purple = [107 76 154]./255;


%% script details
peptides_per_sim = 4;
number_of_sim = 3;
Row_lengths = [12 12 12 12 12 12 12 12 12 12 12 12]; %12 simulations with 12 snapshots. This is to split the combined array into the seperate peptides for analysis

%% data and processing


peptide_mean_array = [];
total_number_of_peptides = peptides_per_sim*number_of_sim;

% setting up the mean,atd,ste
residue_summary_sim1 = load("1hisd_residue_summary_all_peps.txt");
residue_summary_sim2 = load("2hisd_residue_summary_all_peps.txt");
residue_summary_sim3 = load("3hisd_residue_summary_all_peps.txt");
residue_summary_combind_array = cat(1,residue_summary_sim1,residue_summary_sim2,residue_summary_sim3);

total_peptides = mat2cell(residue_summary_combind_array,Row_lengths);

for pep = total_number_of_peptides:-1:1.0
    mean_peptide = mean(total_peptides{pep});
    peptide_mean_array = [peptide_mean_array;mean_peptide];
end

cumulative_data_mean = mean(peptide_mean_array,1);
cumulative_data_std = std(peptide_mean_array,1);
cumulative_data_ste = cumulative_data_std/sqrt(total_number_of_peptides);


%figure settings
figure('Name','cumulative','NumberTitle','off');
myfontsize = 15;
errorbar(cumulative_data_mean, cumulative_data_ste, '-r.', 'MarkerSize',20, 'LineWidth',2, 'Color',blue);
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
xticks(0:length(cumulative_data_mean));
xticklabels({'','T1','S3','S4','A6','G7','L8','Q9','10W','11P','V12','G13','V15','H16','L18','L19',''});



