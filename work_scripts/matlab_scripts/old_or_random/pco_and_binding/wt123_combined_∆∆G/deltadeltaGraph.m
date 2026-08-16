%% general settings
clear;
close all
blue = [57 106 177]./255;
red = [204 37 41]./255;
black = [83 81 84]./255;
green = [62 150 81]./255;
brown = [146 36 40]./255;
purple = [107 76 154]./255;
wellesley_purple = [16 6 159]./255;
current_residue_one_letter_code = {'T1','S3','S4','A6','G7','L8','Q9','W10','P11','V12','G13','V15','H16','L18','L19'};

mkdir('./pictures_of_data/')

%% Functions %%

function fitting_data(NameValueArgs)
    arguments
        NameValueArgs.tight_fitting = false
        NameValueArgs.data_spacing = false
        NameValueArgs.data_spacing_x = false %specify spacing
        NameValueArgs.data_spacing_y = false %specify spacing
    end

    if NameValueArgs.tight_fitting == true
        ax1 = gca; % generate cartesian axis aka. allows you to work with the axis
        axis(ax1, 'tight'); %restricts the axises to be directly up on the data and then gives them some centering space
    end

    if NameValueArgs.data_spacing ~= false
        ax1 = gca; % generate cartesian axis aka. allows you to work with the axis
        xlim(ax1, xlim(ax1) + [-1,1]*range(xlim(ax1)).* 0.05)
        ylim(ax1, ylim(ax1) + [-1,1]*range(ylim(ax1)).* 0.05)
    end

    if NameValueArgs.data_spacing_x ~= false
        ax1 = gca; % generate cartesian axis aka. allows you to work with the axis
        ylim(ax1, ylim(ax1) + [-1,1]*4.5)
    end

    if NameValueArgs.data_spacing_y ~= false
        ax1 = gca; % generate cartesian axis aka. allows you to work with the axis
        ylim(ax1, ylim(ax1) + [-1,1]*range(ylim(ax1)).* NameValueArgs.data_spacing_y)
    end
end






function consistent_figures(NameValueArgs) %function to (attempt) to keep all figures consistent
    arguments
        NameValueArgs.figure_name
        NameValueArgs.rotate_x_labels_by_angle = 'nan'
        NameValueArgs.legend_name = false
        NameValueArgs.PDF_PNG_name
        NameValueArgs.fontname = 'Helvetica' % really does nothing if using the latex interpreter. If font is an issue, change to a different interpreter or add the words in post.
    end

    % Variables and general graph settings
    fontsize_of_your_paper = 18; %roughly equal to 12 point font in times new roman.
    xticklabel_fontsize = fontsize_of_your_paper - 0; % Can put this to -2, may not be good in all scenarios though
    legend_font_size = fontsize_of_your_paper - 3; % Can drop this to -5, also may not be good
    picturewidth = 20; % In Centimeters. Roughly 8 inches which is good for paper figures that span the width of the page
    hw_ratio = 0.65;

    set(findall(NameValueArgs.figure_name, '-property', 'Fontsize'),'Fontsize',fontsize_of_your_paper);
    set(findall(NameValueArgs.figure_name, '-property', 'Box'),'Box','off');
    set(findall(NameValueArgs.figure_name, '-property', 'Interpreter'),'Interpreter','tex'); %change to LaTeX if you're using that %%% can't change font if you do though
    set(findall(NameValueArgs.figure_name, '-property', 'TicklabelInterpreter'),'TicklabelInterpreter','tex');
    set(findall(NameValueArgs.figure_name, '-property', 'FontName'),'FontName',NameValueArgs.fontname);
    set(findall(NameValueArgs.figure_name, '-property', 'Theme'),'Theme',"light");


    %argument modifiers
    if isnumeric(NameValueArgs.rotate_x_labels_by_angle) == true
        axis = gca(NameValueArgs.figure_name);

        axis.XAxis.FontSize = xticklabel_fontsize;
        axis.YAxis.FontSize = xticklabel_fontsize;
        axis.XLabel.FontSize = fontsize_of_your_paper;
        axis.YLabel.FontSize = fontsize_of_your_paper;

        xtickangle(NameValueArgs.rotate_x_labels_by_angle)
    end

    if NameValueArgs.legend_name ~= false
        set(NameValueArgs.legend_name, 'fontsize',legend_font_size)
        set(NameValueArgs.legend_name, 'Box','on')
    end

    %printing stuffs
    set(NameValueArgs.figure_name,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
    pos = get(NameValueArgs.figure_name,'Position');
    set(NameValueArgs.figure_name,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
    print(NameValueArgs.figure_name,'pictures_of_data/'+NameValueArgs.PDF_PNG_name,'-dpdf','-vector','-fillpage')
    print(NameValueArgs.figure_name,'pictures_of_data/'+NameValueArgs.PDF_PNG_name,'-dpng','-vector', '-r600')
    


end


%% script details
peptides_per_sim = 4;
number_of_sim = 3;
Row_lengths = [12 12 12 12 12 12 12 12 12 12 12 12]; %12 peptides with 12 snapshots. This is to split the combined array into the seperate peptides for analysis

%% data and processing


peptide_mean_array = [];
total_number_of_peptides = peptides_per_sim*number_of_sim;

% setting up the mean,atd,ste
residue_summary_sim1 = load("1wt_residue_summary_all_peps.txt");
residue_summary_sim2 = load("2wt_residue_summary_all_peps.txt");
residue_summary_sim3 = load("3wt_residue_summary_all_peps.txt");
residue_summary_combind_array = cat(1,residue_summary_sim1,residue_summary_sim2,residue_summary_sim3);

total_peptides = mat2cell(residue_summary_combind_array,Row_lengths);

% for pep = 1:total_number_of_peptides % peptide ste
%     mean_peptide = mean(total_peptides{pep});
%     peptide_mean_array = [peptide_mean_array;mean_peptide];
    % ste_n = 12
% end

for sim = 1:number_of_sim % sim ste
    mean_peptide = mean([total_peptides{sim*1};total_peptides{sim*2};total_peptides{sim*3};total_peptides{sim*4}]);
    peptide_mean_array = [peptide_mean_array;mean_peptide];
    ste_n = 3;
end

cumulative_data_mean = mean(peptide_mean_array,1);
cumulative_data_std = std(peptide_mean_array,1);
cumulative_data_ste = cumulative_data_std/sqrt(ste_n);

%figure settings
Title = "PCO summary";
PCO_figure = figure('Name',Title,'NumberTitle','off','Theme',"light");


length_of_row = ones(length(residue_summary_combind_array(:,1)),1);
for_normalization_figure = [residue_summary_combind_array(:,1),length_of_row.*2;residue_summary_combind_array(:,4),length_of_row.*3;residue_summary_combind_array(:,6),length_of_row.*4];
for_normalization_figure_all = [residue_summary_combind_array(:,1),length_of_row.*2,length_of_row*cumulative_data_mean(:,1),length_of_row*cumulative_data_ste(:,1);residue_summary_combind_array(:,4),length_of_row.*3,length_of_row*cumulative_data_mean(:,4),length_of_row*cumulative_data_ste(:,4);residue_summary_combind_array(:,6),length_of_row.*4,length_of_row*cumulative_data_mean(:,6),length_of_row*cumulative_data_ste(:,6);residue_summary_combind_array(:,7),length_of_row.*5,length_of_row*cumulative_data_mean(:,7),length_of_row*cumulative_data_ste(:,7);residue_summary_combind_array(:,10),length_of_row.*6,length_of_row*cumulative_data_mean(:,10),length_of_row*cumulative_data_ste(:,10);residue_summary_combind_array(:,13),length_of_row.*1,length_of_row*cumulative_data_mean(:,13),length_of_row*cumulative_data_ste(:,13);residue_summary_combind_array(:,14),length_of_row.*7,length_of_row*cumulative_data_mean(:,14),length_of_row*cumulative_data_ste(:,14)];



violins = violinplot(residue_summary_combind_array); %residue_summary_combind_array for all data, peptide_mean_array for all peptide mean distributions
for vio = 1:length(violins)
    violins(vio).FaceColor = wellesley_purple;
end
hold on;
errorbar(cumulative_data_mean, cumulative_data_ste, '.','LineWidth',1.3,'MarkerSize',15, 'Color',black);
ylabel('\Delta\DeltaG_{PCO}, (kcal/mol)');
% xlabel('BF2 Residue');
xticklabels(current_residue_one_letter_code)

%restricts the axises to be directly up on the data and then gives them
%some centering space

fitting_data(tight_fitting=true, data_spacing=false);
ylim([-3,2.5])
consistent_figures(figure_name=PCO_figure, rotate_x_labels_by_angle=35, PDF_PNG_name=Title);

save('pco_fornorm.mat',"for_normalization_figure")
save('pco_fornorm_all.mat',"for_normalization_figure_all")

