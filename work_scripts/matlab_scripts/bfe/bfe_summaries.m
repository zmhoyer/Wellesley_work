%% General settings %% 


clear;
close all


peptides_per_sim = 4; % Do you have more than 1 peptides? if so how many?
mkdir('pictures_of_data'); % This is where all png images (for presentations) and pdfs(for publications or other places where vector graphics are important) are stored.
all_sims = dir('bfe_summary_all_sims'); %gets all dirs in bfe_summary
all_sims(1:2) = []; % deletes the . and .. directories
all_sim_names = {all_sims.name};

%% Colors!!! %% 

load("batlowS.mat"); %For catagorical data. Evenly chromatic and CVD sensitive
load("batlow.mat"); %For heatmap data and ditto to above

blue = [57 106 177]./255;
red = [204 37 41]./255;
green = [62 150 81]./255;
brown = [146 36 40]./255;
purple = [107 76 154]./255;

white = [255 255 255]./255;
grey1 = [223 223 223]./255;
grey2 = [191 191 191]./255;
grey3 = [159 159 159]./255;
grey4 = [128 128 128]./255;
grey5 = [96 96 96]./255;
grey6 = [64 64 64]./255;
grey7 = [32 32 32]./255;
black = [0 0 0]./255;



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
        xlim(ax1, xlim(ax1) + [-1,1]*range(xlim(ax1)).* NameValueArgs.data_spacing_x)
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
        NameValueArgs.fontname = 'Times New Roman' % really does nothing if using the latex interpreter. If font is an issue, change to a different interpreter or add the words in post.
    end

    % Variables and general graph settings
    fontsize_of_your_paper = 16; %roughly equal to 12 point font in times new roman.
    xticklabel_fontsize = fontsize_of_your_paper - 0; % Can put this to -2, may not be good in all scenarios though
    legend_font_size = fontsize_of_your_paper - 3; % Can drop this to -5, also may not be good
    picturewidth = 20; % In Centimeters. Roughly 8 inches which is good for paper figures that span the width of the page
    hw_ratio = 0.65;

    set(findall(NameValueArgs.figure_name, '-property', 'Fontsize'),'Fontsize',fontsize_of_your_paper);
    set(findall(NameValueArgs.figure_name, '-property', 'Box'),'Box','off');
    set(findall(NameValueArgs.figure_name, '-property', 'Interpreter'),'Interpreter','tex'); %change to LaTeX if you're using that %%% can't change font if you do though
    set(findall(NameValueArgs.figure_name, '-property', 'TicklabelInterpreter'),'TicklabelInterpreter','latex');
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


%% All Simulations Summary %%

all_simulation_bfe = [];


for sim = 1:length(all_sim_names)
    current_sim_bfe = [];
    
    loop_sim = all_sim_names_sorted{sim};
    last_underscore_pos = strfind(loop_sim,'_');
    current_sim_name = extractBefore(loop_sim,last_underscore_pos(end));

    for pep = 1:peptides_per_sim
        current_pep_bfe = load("bfe_summary_all_sims/"+all_sim_names{sim}+"/"+pep+"p_bfe_summary.txt");
        current_sim_bfe = cat(2,current_sim_bfe,current_pep_bfe);
    end

    current_sim_bfe_cell = {current_sim_name{1},current_sim_bfe}.';
    all_simulation_bfe = cat(2,all_simulation_bfe,current_sim_bfe_cell);

end

unique_sims = unique(all_simulation_bfe(1,:),'stable');
combined_across_sims_data_means = {};
combined_across_sims_data_std = [];
combined_across_sims_data_ste = [];
combined_across_sims_data_mean = [];

for unique_sim = 1:length(unique_sims)
    logical_single_mutation = matches(all_simulation_bfe(1,:),unique_sims{unique_sim});
    
    single_mutation = cell(size(all_simulation_bfe(1,:)));
    single_mutation(logical_single_mutation) = all_simulation_bfe(2,logical_single_mutation);
    single_mutation_data = cat(2,single_mutation{:});

    single_mutation_data_means = mean(single_mutation_data,1).';
    single_mutation_data_mean = mean(single_mutation_data_means);
    single_mutation_data_std = std(single_mutation_data_means,1);
    single_mutation_data_ste = single_mutation_data_std/sqrt(length(single_mutation_data));
    

    combined_across_sims_data_means = cat(2,combined_across_sims_data_means,single_mutation_data_means);
    combined_across_sims_data_mean = cat(2,combined_across_sims_data_mean,single_mutation_data_mean);
    combined_across_sims_data_std = cat(2,combined_across_sims_data_std,single_mutation_data_std);
    combined_across_sims_data_ste = cat(2,combined_across_sims_data_ste,single_mutation_data_ste);
    
end


Title = "All Simulations BFE Summary - Lexically sorted";
Summary_BFE_figure = figure('Name',Title,'NumberTitle','off');

for sim_data = 1:length(combined_across_sims_data_means)
    scatter(sim_data,combined_across_sims_data_means{sim_data},100,'MarkerFaceColor','b','MarkerEdgeColor','b','MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2);
    fprintf(unique_sims(sim_data)+": "+combined_across_sims_data_mean(sim_data)+" ± "+combined_across_sims_data_ste(sim_data)+" (N="+length(combined_across_sims_data_means{sim_data})+")\n")
    hold on;
end

errorbar(combined_across_sims_data_mean, combined_across_sims_data_ste, '.','LineWidth',1.2, 'Color',black);
hold off;

ylabel('Binding Free Energy ({\itkcal/mol})');
xlabel('Simulation');
string_sims = string(unique_sims);
xticks(1:length(string_sims));
xticklabels(string_sims);

fitting_data(tight_fitting=true, data_spacing=true);
consistent_figures(figure_name=Summary_BFE_figure, rotate_x_labels_by_angle=1, PDF_PNG_name=Title);

axes = gca;
pos = axes.YLabel.get.Position-[0.1,0,0];
axes.YLabel.Position = pos;



%% All Simulations Summary - sorted differently%%


all_sim_names_sorted = {"wt_sim1","wt_sim2","wt_sim3","wt_sim4","wt_sim5","wt_sim6","hwt_sim1","hwt_sim2","hwt_sim3","t1r_sim1","t1r_sim2","ht1r_sim1","ht1r_sim2","a6r_sim1","a6r_sim2","ha6r_sim1","ha6r_sim2","l8r_sim1","l8r_sim2","hl8r_sim1","hl8r_sim2","q9r_sim1","q9r_sim2","q9r_sim3","hq9r_sim1","hq9r_sim2","hq9r_sim3","v12r_sim1","v12r_sim2","v12r_sim3","hv12r_sim1","hv12r_sim2","hv12r_sim3","l18r_sim1","l18r_sim2","l18r_sim3","hl18r_sim1","hl18r_sim2","hl18r_sim3","t1r_a6r_l8r_sim1","t1r_a6r_l8r_sim2","t1r_a6r_l8r_sim3","h_t1r_a6r_l8r_sim1","h_t1r_a6r_l8r_sim2","h_t1r_a6r_l8r_sim3"};
all_simulation_bfe = [];


for sim = 1:length(all_sim_names_sorted)
    current_sim_bfe = [];

    loop_sim = all_sim_names_sorted{sim};
    last_underscore_pos = strfind(loop_sim,'_');
    current_sim_name = extractBefore(loop_sim,last_underscore_pos(end));

    for pep = 1:peptides_per_sim
        current_pep_bfe = load("bfe_summary_all_sims/"+all_sim_names_sorted{sim}+"/"+pep+"p_bfe_summary.txt");
        current_sim_bfe = cat(2,current_sim_bfe,current_pep_bfe);
        % figure;
        
        % plot(current_pep_bfe); autocorrelation

    end

    current_sim_bfe_cell = {current_sim_name{1},current_sim_bfe}.';
    all_simulation_bfe = cat(2,all_simulation_bfe,current_sim_bfe_cell);

end

unique_sims = unique(all_simulation_bfe(1,:),'stable');
combined_across_sims_data_means = {};
combined_across_sims_data_mean = [];
combined_across_sims_data_std = [];
combined_across_sims_data_ste = [];


for unique_sim = 1:length(unique_sims)
    logical_single_mutation = matches(all_simulation_bfe(1,:),unique_sims{unique_sim});
    
    single_mutation = cell(size(all_simulation_bfe(1,:)));
    single_mutation(logical_single_mutation) = all_simulation_bfe(2,logical_single_mutation);
    single_mutation_data = cat(2,single_mutation{:});

    single_mutation_data_means = mean(single_mutation_data,1).';
    single_mutation_data_mean = mean(single_mutation_data_means);
    single_mutation_data_std = std(single_mutation_data_means,1);
    single_mutation_data_ste = single_mutation_data_std/sqrt(length(single_mutation_data));
    

    combined_across_sims_data_means = cat(2,combined_across_sims_data_means,single_mutation_data_means);
    combined_across_sims_data_mean = cat(2,combined_across_sims_data_mean,single_mutation_data_mean);
    combined_across_sims_data_std = cat(2,combined_across_sims_data_std,single_mutation_data_std);
    combined_across_sims_data_ste = cat(2,combined_across_sims_data_ste,single_mutation_data_ste);
    
end


% % some type of signifigance testing for non independent data points. No
% % central limit theory due to non independence and small sample sizes, so
% % we had to do a non-parametric test for significance

longest_data_set = 0;
for sim = 1:length(combined_across_sims_data_means)
    if length(combined_across_sims_data_means{sim}) > longest_data_set
        longest_data_set = length(combined_across_sims_data_means{sim});
    end
%     figure;
%     qqplot(combined_across_sims_data_means{sim})
%     figure;
%     slog = fitdist(combined_across_sims_data_means{sim},'Normal');
%     plot(slog)
end
A = zeros(longest_data_set,length(combined_across_sims_data_means));
for sim = 1:length(combined_across_sims_data_means)
    A(1:length(combined_across_sims_data_means{sim}),sim) = combined_across_sims_data_means{sim};
end
A(A == 0) = NaN;

[p,tbl,stats] = anova1(A,unique_sims,"off");
[results,~,~,gnames]  = multcompare(stats);
tbl = array2table(results,"VariableNames", ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
tbl.("Group A") = gnames(tbl.("Group A"));
tbl.("Group B") = gnames(tbl.("Group B"))
figure;
[p,tbl,stats] = kruskalwallis(A,unique_sims,"off");
[results,~,~,gnames]  = multcompare(stats);
tbl = array2table(results,"VariableNames", ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
tbl.("Group A") = gnames(tbl.("Group A"));
tbl.("Group B") = gnames(tbl.("Group B"))


Title = "All Simulations BFE Summary";
Summary_BFE_figure = figure('Name',Title,'NumberTitle','off');

for sim_data = 1:length(combined_across_sims_data_means)
    scatter(sim_data,combined_across_sims_data_means{sim_data},100,"red",'.');
    fprintf(unique_sims(sim_data)+": "+combined_across_sims_data_mean(sim_data)+" ± "+combined_across_sims_data_ste(sim_data)+" (N="+length(combined_across_sims_data_means{sim_data})+")\n")
    hold on;

end


errorbar(combined_across_sims_data_mean, combined_across_sims_data_ste, '.','LineWidth',1.3, 'Color',black);
hold off;

ylabel('Binding Free Energy ({\itkcal/mol})');
xlabel('Simulation');
string_sims = string(unique_sims);
xticks(1:length(string_sims));
xticklabels(string_sims);

fitting_data(tight_fitting=true, data_spacing=true);
consistent_figures(figure_name=Summary_BFE_figure, rotate_x_labels_by_angle=40, PDF_PNG_name=Title);

axes = gca;
pos = axes.YLabel.get.Position-[0.15,0,0];
axes.YLabel.Position = pos;

ttest(A(:,1),A(:,2))

fprintf("hi")

ttest(A(:,1),A(:,3))
ttest(A(:,1),A(:,4))
ttest(A(:,1),A(:,5))
ttest(A(:,1),A(:,6))
ttest(A(:,1),A(:,7))
ttest(A(:,1),A(:,8))
ttest(A(:,1),A(:,9))
ttest(A(:,1),A(:,10))
ttest(A(:,1),A(:,11))
ttest(A(:,1),A(:,12))
ttest(A(:,1),A(:,13))
ttest(A(:,1),A(:,14))
ttest(A(:,1),A(:,15))
ttest(A(:,1),A(:,16))

fprintf("hi")

ttest(A(:,2),A(:,15))
ttest(A(:,2),A(:,16))

%% Hbond and bfe correlation %%

all_sim_names_sorted = {"wt_sim1","wt_sim2","wt_sim3","wt_sim4","wt_sim5","wt_sim6","hwt_sim1","hwt_sim2","hwt_sim3","t1r_sim1","t1r_sim2","ht1r_sim1","ht1r_sim2","a6r_sim1","a6r_sim2","ha6r_sim1","ha6r_sim2","l8r_sim1","l8r_sim2","hl8r_sim1","hl8r_sim2","q9r_sim1","q9r_sim2","q9r_sim3","hq9r_sim1","hq9r_sim2","hq9r_sim3","v12r_sim1","v12r_sim2","v12r_sim3","hv12r_sim1","hv12r_sim2","hv12r_sim3","l18r_sim1","l18r_sim2","l18r_sim3","hl18r_sim1","hl18r_sim2","hl18r_sim3","t1r_a6r_l8r_sim1","t1r_a6r_l8r_sim2","t1r_a6r_l8r_sim3","h_t1r_a6r_l8r_sim1","h_t1r_a6r_l8r_sim2","h_t1r_a6r_l8r_sim3"};
all_simulation_bfe = [];
all_simulation_hbond = [];
all_simulation_hbond2 = [];
all_simulation_hbond3 = [];
all_simulation_hbond4 = [];

pca_all_bfe = [];
pca_all_hbond = [];
pca_all_hbond2 = [];
pca_all_hbond3 = [];
pca_all_hbond4 = [];

for sim = 1:length(all_sim_names_sorted)
    current_sim_bfe = [];
    current_sim_hbond = [];
    current_sim_hbond2 = [];
    current_sim_hbond3 = [];
    current_sim_hbond4 = [];
   
    loop_sim = all_sim_names_sorted{sim};
    last_underscore_pos = strfind(loop_sim,'_');
    current_sim_name = extractBefore(loop_sim,last_underscore_pos(end));

    
    for pep = 1:peptides_per_sim
        current_pep_bfe = load("bfe_summary_all_sims/"+all_sim_names_sorted{sim}+"/"+pep+"p_bfe_summary.txt");
        current_pep_hbond = load("../analysis/"+all_sim_names_sorted{sim}+"_analysis/hbond/"+pep+"p_hbond_to_memb.txt");
        current_pep_hbond2 = load("../analysis/"+all_sim_names_sorted{sim}+"_analysis/hbond/"+pep+"p_hbond_to_peps.txt");
        current_pep_hbond3 = load("../analysis/"+all_sim_names_sorted{sim}+"_analysis/hbond/"+pep+"p_hbond_to_itself.txt");
        current_pep_hbond4 = load("../analysis/"+all_sim_names_sorted{sim}+"_analysis/hbond/"+pep+"p_hbond_to_water.txt");
        
        current_pep_hbond = current_pep_hbond(7501:25:10001,2); % row-start:interval:end,column-all second column
        current_pep_hbond2 = current_pep_hbond2(7501:25:10001,2);
        current_pep_hbond3 = current_pep_hbond3(7501:25:10001,2);
        current_pep_hbond4 = current_pep_hbond4(7501:25:10001,2);

        current_sim_bfe = cat(2,current_sim_bfe,current_pep_bfe);
        pca_all_bfe = cat(1,pca_all_bfe,current_pep_bfe);

        current_sim_hbond = cat(2,current_sim_hbond,current_pep_hbond);
        pca_all_hbond = cat(1,pca_all_hbond,current_pep_hbond);

        current_sim_hbond2 = cat(2,current_sim_hbond2,current_pep_hbond2);
        pca_all_hbond2 = cat(1,pca_all_hbond2,current_pep_hbond2);

        current_sim_hbond3 = cat(2,current_sim_hbond3,current_pep_hbond3);
        pca_all_hbond3 = cat(1,pca_all_hbond3,current_pep_hbond3);

        current_sim_hbond4 = cat(2,current_sim_hbond4,current_pep_hbond4);
        pca_all_hbond4 = cat(1,pca_all_hbond4,current_pep_hbond4);

    end

    current_sim_bfe_cell = {current_sim_name{1},current_sim_bfe}.';
    all_simulation_bfe = cat(2,all_simulation_bfe,current_sim_bfe_cell);
    current_sim_hbond_cell = {current_sim_name{1},current_sim_hbond}.';
    all_simulation_hbond = cat(2,all_simulation_hbond,current_sim_hbond_cell);
    current_sim_hbond2_cell = {current_sim_name{1},current_sim_hbond2}.';
    all_simulation_hbond2 = cat(2,all_simulation_hbond2,current_sim_hbond2_cell);
    current_sim_hbond3_cell = {current_sim_name{1},current_sim_hbond3}.';
    all_simulation_hbond3 = cat(2,all_simulation_hbond3,current_sim_hbond3_cell);
    current_sim_hbond4_cell = {current_sim_name{1},current_sim_hbond4}.';
    all_simulation_hbond4 = cat(2,all_simulation_hbond4,current_sim_hbond4_cell);


end


unique_sims = unique(all_simulation_bfe(1,:),'stable');
combined_across_sims_bfe_data_means = {};
combined_across_sims_bfe_data_mean = [];
combined_across_sims_hbond_data_means = {};
combined_across_sims_hbond_data_mean = [];
combined_across_sims_hbond2_data_means = {};
combined_across_sims_hbond2_data_mean = [];
combined_across_sims_hbond3_data_means = {};
combined_across_sims_hbond3_data_mean = [];
combined_across_sims_hbond4_data_means = {};
combined_across_sims_hbond4_data_mean = [];

fprintf("bfe,memb,peps,itself,water")
pca_data_object = cat(2,pca_all_hbond,pca_all_hbond2,pca_all_hbond3,pca_all_hbond4);
[coeff,score,latent,tsquared,explained,mu] = pca(pca_data_object);
pca_1 = score(:,1);
figure;
scatter(pca_1,pca_all_bfe)


for unique_sim = 1:length(unique_sims)


    logical_single_mutation_bfe = matches(all_simulation_bfe(1,:),unique_sims{unique_sim});
    logical_single_mutation_hbond = matches(all_simulation_hbond(1,:),unique_sims{unique_sim});
    logical_single_mutation_hbond2 = matches(all_simulation_hbond2(1,:),unique_sims{unique_sim});
    logical_single_mutation_hbond3 = matches(all_simulation_hbond3(1,:),unique_sims{unique_sim});
    logical_single_mutation_hbond4 = matches(all_simulation_hbond4(1,:),unique_sims{unique_sim});

    
    single_mutation_bfe = cell(size(all_simulation_bfe(1,:)));
    single_mutation_bfe(logical_single_mutation_bfe) = all_simulation_bfe(2,logical_single_mutation_bfe);
    single_mutation_data_bfe = cat(2,single_mutation_bfe{:});

    single_mutation_hbond = cell(size(all_simulation_hbond(1,:)));
    single_mutation_hbond(logical_single_mutation_hbond) = all_simulation_hbond(2,logical_single_mutation_hbond);
    single_mutation_data_hbond = cat(2,single_mutation_hbond{:});

    single_mutation_hbond2 = cell(size(all_simulation_hbond2(1,:)));
    single_mutation_hbond2(logical_single_mutation_hbond2) = all_simulation_hbond2(2,logical_single_mutation_hbond2);
    single_mutation_data_hbond2 = cat(2,single_mutation_hbond2{:});

    single_mutation_hbond3 = cell(size(all_simulation_hbond3(1,:)));
    single_mutation_hbond3(logical_single_mutation_hbond3) = all_simulation_hbond3(2,logical_single_mutation_hbond3);
    single_mutation_data_hbond3 = cat(2,single_mutation_hbond3{:});

    single_mutation_hbond4 = cell(size(all_simulation_hbond4(1,:)));
    single_mutation_hbond4(logical_single_mutation_hbond4) = all_simulation_hbond4(2,logical_single_mutation_hbond4);
    single_mutation_data_hbond4 = cat(2,single_mutation_hbond4{:});


   
    figure;
    % model = fitlm(reshape(single_mutation_data_hbond,[],1),reshape(single_mutation_data_bfe,[],1))
    scatter3(single_mutation_data_hbond,single_mutation_data_bfe,single_mutation_data_hbond2);
    xlabel('Hydrogen Bond Count to memb');
    ylabel('Binding Free Energy ({\itkcal/mol})');
    zlabel('Hydrogen Bond Count to peps');
    title(['Correlation between Hydrogen Bonds and BFE for ', unique_sims{unique_sim}]);
    grid on;



    single_mutation_data_bfe_means = mean(single_mutation_data_bfe,1).';
    single_mutation_data_bfe_mean = mean(single_mutation_data_bfe_means);
    single_mutation_data_hbond_means = mean(single_mutation_data_hbond,1).';
    single_mutation_data_hbond_mean = mean(single_mutation_data_hbond_means);


    combined_across_sims_bfe_data_means = cat(2,combined_across_sims_bfe_data_means,single_mutation_data_bfe_means);
    combined_across_sims_bfe_data_mean = cat(2,combined_across_sims_bfe_data_mean,single_mutation_data_bfe_mean);
    combined_across_sims_hbond_data_means = cat(2,combined_across_sims_hbond_data_means,single_mutation_data_hbond_means);
    combined_across_sims_hbond_data_mean = cat(2,combined_across_sims_hbond_data_mean,single_mutation_data_hbond_mean);
   

end


Title = "All Simulations BFE and hbond correlations";
Summary_BFE_figure = figure('Name',Title,'NumberTitle','off');


for sim_data = 1:length(combined_across_sims_bfe_data_means)
     scatter(combined_across_sims_hbond_data_means{sim_data}, combined_across_sims_bfe_data_means{sim_data});
     hold on;
end


hold off;

ylabel('Binding Free Energy ({\itkcal/mol})');
xlabel('Hydrogen Bond Count');

% fitting_data(tight_fitting=true, data_spacing=true);
% consistent_figures(figure_name=Summary_BFE_figure, rotate_x_labels_by_angle=1, PDF_PNG_name=Title);




%% signficance testing %%



% pep_1 = load("./bfe_summary_all_sims/wt_sim4/1p_RDP_summary.txt");
% pep_2 = load("./bfe_summary_all_sims/wt_sim4/2p_RDP_summary.txt");
% pep_3 = load("./bfe_summary_all_sims/wt_sim4/3p_RDP_summary.txt");
% pep_4 = load("./bfe_summary_all_sims/wt_sim4/4p_RDP_summary.txt");
% 
% R0 = corrcoef(pep_1,pep_1)
% 
% R1 = corrcoef(pep_1,pep_2)
% R2 = corrcoef(pep_1,pep_3)
% R3 = corrcoef(pep_1,pep_4)
% mean(pep_1)
% mean(pep_4)
% R4 = corrcoef(pep_2,pep_3)
% R5 = corrcoef(pep_2,pep_4)
% R6 = corrcoef(pep_3,pep_4)
% mean(pep_3)
% mean(pep_4)

% concat_dat = cat(1,pep_1,pep_2,pep_3,pep_4);
% 
% fprintf("Mean Median and Mode:\n")
% mean(all_data)
% median(all_data)
%  mode(all_data)
% 
% fprintf("Standard deviation and variance:\n")
%  std(all_data)
%  var(all_data)
% 
% fprintf("Frequency distribution:\n")
% range(all_data)
% figure;
% qqplot(all_data)
% 
% figure;
% slog = fitdist(all_data,'Normal')
% plot(slog)


% hypothesis testing %

% for sim_data = 1:length(combined_across_sims_data_means)
%     figure;
%     normplot(combined_across_sims_data_means{sim_data});
%     fprintf(unique_sims(sim_data)+" Test for normality:\n")
%     normality_test = lillietest(combined_across_sims_data_means{sim_data})
%     % a zero represents the failure to reject the null hypothesis that the
%     % samples are normally distributed.
% 
%     % qqplot(combined_across_sims_data_means{sim_data})
% 
%     if normality_test == 0
%         fprintf("hi\n")
%     end
% 
% end

