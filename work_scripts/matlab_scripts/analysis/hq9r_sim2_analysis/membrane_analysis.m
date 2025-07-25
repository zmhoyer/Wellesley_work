%% General settings %% Only things you must change %% Read up to colors section though %%

% If you want the font of the figures to match your document you can change
% the default in the consistent_figures function to what your paper will be
% in. If using the latex interpreter for special characters and math
% equations you can't change the font from computer modern.
% There are some more intricate settings that need to be there as
% global variables won't be read inside functions. You shouldn't have to
% change those unless you want to have more control over figure creation.


% some figures don't look the way they're supposed to in the preview thats
% output by matlab directly. If you think there's an error, make sure to check the
% outputted pdf file just to make sure


% Great resources for good data vizualizations
% -MATLAB specific advice and explanation of figure creation - https://youtu.be/wP3jjk1O18A?si=NMwC0ml-iLanyEcG
% -Good figures - https://youtu.be/i-HAjex6VtM?si=78B6I4iWKqj19YkR
% -accessible colors - https://doi.org/10.1038/s41467-020-19160-7



clear;
close all

Conversion_factor_to_nanoseconds = 1000; %if data is in terms of picoseconds, keep 1000. If in nanoseconds, change to 1
simulation_name = "Simulation 2: HQ9R - "; % What is the name of this simulation
peptides_per_sim = 4; % Do you have more than 1 peptides? if so how many?
lipids_per_sim = 128; % Did you change the number of lipids?
number_of_residues = 21; % How many residues do you have?
current_peptide_residue_list = {'1THR', '2ARG', '3SER', '4SER', '5ARG', '6ALA', '7GLY', '8LEU', '9ARG', '10TRP', '11PRO', '12VAL', '13GLY', '14ARG', '15VAL', '16HISH', '17ARG', '18LEU', '19LEU', '20ARG', '21LYS'}; % What are the residue names in order
current_residue_one_letter_code = {'T','R','S','S','R','A','G','L','R','W','P','V','G','R','V','HH','R','L','L','R','K'};
snapshot_extration_range_start = 750; % The start time(ns) that the snapshot extraction portion of the simulation encompases. 250 means the it starts at 250 nanoseconds of the simulation.
snapshot_extration_range_end = 1000; % The end time(ns) that the snapshot extraction portion of the simulation encompases. 250 means the it starts at 250 nanoseconds of the simulation.


% Match the fontsize to the paper/presentation you're making. It can't 
% be placed here due to matlab being a baby about global variables
% The font size can be found in the consistent figures function


%% General settings you probably don't need to change %%

space_array = {''};
spaced_residue_list = [space_array current_peptide_residue_list space_array];
spaced_one_letter_residue_list = [space_array current_residue_one_letter_code space_array];

snapshot_extration_range_start_frames = (snapshot_extration_range_start*100)+1; % used 100 here since the full amount of frames aren't outputted from analysis. we usually output every 10th frame.
snapshot_extration_range_end_frames = (snapshot_extration_range_end*100)+1;

mkdir('pictures_of_data'); % This is where all png images (for presentations) and pdfs(for publications or other places where vector graphics are important) are stored.



%% Colors!!! %% 
% You can add what you want, I recommend using the batlow colors from https://zenodo.org/records/8409685
% as these colors account for color deficiencies. Theres a good paper about
% it https://doi.org/10.1038/s41467-020-19160-7



% Don't use complementary.
% If you have hexadecimal colors you can put that into google and 
% this will give you the rgb values that are needed to conform 
% to the set up below.
% To fiddle with transparency it's the fourth coulmn added after the rgb
% triplet. For the color in the plot settings type something like 
% 'Color',[The_blues_one,0.33] for the color of your choice to be set at 0.33
% transparency.


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

%% Upper and Lower leaflet mindist analysis %% peptide to phosphates, full length


for pep = 1:peptides_per_sim


    % data load and processing
    upper_leaflet_array = load("mindist/"+pep+"p_upper_leaflet_mindist.txt");
    lower_leaflet_array = load("mindist/"+pep+"p_lower_leaflet_mindist.txt");
    time = upper_leaflet_array(:,1)/Conversion_factor_to_nanoseconds;

    upper_leaflet_data = upper_leaflet_array(:,2);
    MM_upper_leaflet_data = movmean(upper_leaflet_data,100);
    lower_leaflet_data = lower_leaflet_array(:,2);
    MM_lower_leaflet_data = movmean(lower_leaflet_data,100);

    
    %MM_rms_values = movmean(rms_values,100);

    % Figure settings and creation
    Title = simulation_name+" Mindist to Leaflets -- Peptide "+pep;
    mindist_to_leafs = figure('Name',Title,'NumberTitle','off');
    %plot(time,MM_rms_values,'color',black);
    
 
    plot(time,upper_leaflet_data,'Color',[batlowS(5,:),0.33])
    hold on;
    plot(time,lower_leaflet_data,'Color',[batlowS(8,:),0.33])
    hold on;

    MM_upper_leaflet_data_plot = plot(time,MM_upper_leaflet_data,'Color',batlowS(5,:),DisplayName='Distance To Upper Leaflet');
    hold on;
    MM_lower_leaflet_data_plot = plot(time,MM_lower_leaflet_data,'Color',batlowS(8,:),DisplayName='Distance To Lower Leaflet');
    hold on;
     

    %setting the legend line widths with a set of fake data so the in-plot line
    %widths can stay the same.
    ax = gca;
    Legend_MM_upper_leaflet_data = copyobj(MM_upper_leaflet_data_plot, ax);
    Legend_MM_lower_leaflet_data = copyobj(MM_lower_leaflet_data_plot, ax);
    set(Legend_MM_upper_leaflet_data, 'XData', NaN, 'YData', NaN, 'LineWidth', 2)
    set(Legend_MM_lower_leaflet_data, 'XData', NaN, 'YData', NaN, 'LineWidth', 2)
    Mindist_leaflets_legend = legend([Legend_MM_upper_leaflet_data,Legend_MM_lower_leaflet_data],'AutoUpdate','off','Orientation','horizontal', Location='northoutside');


    ylabel('Minimum Distance ({\itnm})');
    xlabel('Time ({\itns})');
    fitting_data(tight_fitting=true,data_spacing_y=0.05);
    consistent_figures(figure_name=mindist_to_leafs, PDF_PNG_name=Title, legend_name=Mindist_leaflets_legend);

end





%% Box size analysis %%

% data load and processing
box_array = load("box.txt");
time = box_array(:,1)/Conversion_factor_to_nanoseconds;

x_and_y = box_array(:,2);
z = box_array(:,4);
MM_x_and_y = movmean(x_and_y,100);
MM_z = movmean(z,100);
Mean_x_and_y = mean(x_and_y);
Mean_z = mean(z);


% Figure settings - looks better when previewing the pdf
Title = simulation_name+"Box Size Analysis";
box_vector_fig = figure('Name',Title,'NumberTitle','off');

MM_xy = plot(time,MM_x_and_y,'color',batlowS(1,:),DisplayName='\itX and \itY Moving Mean');
hold on;
MM_z = plot(time,MM_z,'color',batlowS(3,:),DisplayName='\itZ Moving Mean');
hold on;
plot([min(xlim) max(xlim)],[1 1]*Mean_x_and_y,'color',batlowS(1,:),LineStyle=':',LineWidth=1);
hold on;
plot([min(xlim) max(xlim)],[1 1]*Mean_z,'color',batlowS(3,:),LineStyle=':',LineWidth=1);
hold on;
plot(time,x_and_y,'color',[batlowS(1,:),0.33],LineWidth=1);
hold on;
plot(time,z,'color',[batlowS(3,:),0.33],LineWidth=1);
hold on;

%setting the legend line widths with a set of fake data so the in-plot line
%widths can stay the same.
ax = gca;
Legend_MM_xy = copyobj(MM_xy, ax);
Legend_MM_z = copyobj(MM_z, ax);
set(Legend_MM_xy, 'XData', NaN, 'YData', NaN, 'LineWidth', 2)
set(Legend_MM_z, 'XData', NaN, 'YData', NaN, 'LineWidth', 2)
box_analysis_legend = legend([Legend_MM_xy,Legend_MM_z],'AutoUpdate','off','Orientation','horizontal', Location='northoutside');


ylabel('Box vector length ({\itnm})');
xlabel('Time ({\itns})');

%self defined functions
fitting_data(tight_fitting=true, data_spacing_y=0.05);
consistent_figures(figure_name=box_vector_fig, PDF_PNG_name=Title, legend_name=box_analysis_legend);



% %% tc groups %%
% 
% % data load and processing
% tc_array = load("tc.txt");
% time = tc_array(:,1)/Conversion_factor_to_nanoseconds;
% 
% POPG = tc_array(:,2);
% POPE = tc_array(:,3);
% 
% 
% 
% % Figure settings - looks better when previewing the pdf
% Title = simulation_name+"POPE and POPG";
% box_vector_fig = figure('Name',Title,'NumberTitle','off');
% 
% 
% 
% 
% plot(time,POPG,'color',[batlowS(1,:),0.33],LineWidth=1);
% hold on;
% plot(time,POPE,'color',[batlowS(3,:),0.33],LineWidth=1);
% hold on;
% 
% %setting the legend line widths with a set of fake data so the in-plot line
% %widths can stay the same.
% ax = gca;
% 
% 
% ylabel('Temp ({\itK})');
% xlabel('Time ({\itns})');
% 
% %self defined functions
% fitting_data(tight_fitting=true, data_spacing_y=0.05);
% consistent_figures(figure_name=box_vector_fig, PDF_PNG_name=Title, legend_name=box_analysis_legend);
% 
% 



%% Area per lipid analysis %% 

% data load and processing
time = box_array(:,1)/Conversion_factor_to_nanoseconds;
x_and_y = box_array(:,2);
area_per_lipid = (x_and_y.*x_and_y)/(lipids_per_sim/2);
move_mean_arr = movmean(area_per_lipid,100);

% Figure settings and creation
Title = simulation_name+" Area per Lipid Analysis";
APL_figure = figure('Name',Title,'NumberTitle','off');
plot(time,area_per_lipid,'color',[black,0.25],LineWidth=1);
hold on;
plot(time,move_mean_arr,'color',black)
ylabel('Area per lipid ({\itnm^2})');
xlabel('Time ({\itns})');

fitting_data(tight_fitting=true, data_spacing_y=0.40);
consistent_figures(figure_name=APL_figure, PDF_PNG_name=Title);




%% Energy analysis %% 
% data load and processing
energy_array = load("mdenergy.txt");
time = energy_array(:,1)/Conversion_factor_to_nanoseconds;
total_energy = energy_array(:,2);
total_energy_mean = mean(total_energy);


% Figure settings and creation
Title = simulation_name+" Total energy analysis";
Energy_figure = figure('Name',Title,'NumberTitle','off');
plot(time,total_energy,'color',[black,0.33]);
hold on;
plot([min(xlim) max(xlim)],[1 1]*total_energy_mean,'LineWidth',2,'LineStyle',':','Color',black, DisplayName='Mean Total');
ylabel('Potential energy ({\itKJ/mol}), ({\itK})');
xlabel('Time ({\itns})');

fitting_data(tight_fitting=true);
consistent_figures(figure_name=Energy_figure, PDF_PNG_name=Title);


%% Temperature analysis %%
% data load and processing

time = energy_array(:,1)/Conversion_factor_to_nanoseconds;
Temperature = energy_array(:,3);
total_temperature_mean = mean(Temperature);

% Figure settings and creation
Title = simulation_name+" Temperature analysis";
Temperature_figure = figure('Name',Title,'NumberTitle','off');
plot(time,Temperature,'color',[black,0.33]);
hold on;
plot([min(xlim) max(xlim)],[1 1]*total_temperature_mean,'LineWidth',2,'LineStyle',':','Color',black, DisplayName='Mean Total');
    ylabel('Temperature ({\itK})');
xlabel('Time ({\itns})');
fitting_data(tight_fitting=true);
consistent_figures(figure_name=Temperature_figure, PDF_PNG_name=Title);



%% Density analysis %% maybe add some limit lines

% data load and processing
Density_array = load("density.txt");
arp = Density_array(:,1);
Density = Density_array(:,2);

% Figure settings creation
Title = simulation_name+" Bilayer Thickness";
Density_figure = figure('Name',Title,'NumberTitle','off');
plot(arp,Density,'color',black,'LineWidth',2);
ylabel('Density ({\itkg/m^3})');
xlabel('Average relative position from center ({\itnm})');
fitting_data(tight_fitting=true);
consistent_figures(figure_name=Density_figure, PDF_PNG_name=Title);


%% RMSD Analysis %%

for pep = 1:peptides_per_sim


    % data load and processing
    rmsd = load(pep+"p_rmsd.txt");
    time = rmsd(:,1)/Conversion_factor_to_nanoseconds;
    rms_values = rmsd(:,2);
    MM_rms_values = movmean(rms_values,100);

    % Figure settings and creation
    Title = simulation_name+" RMSD -- Peptide "+pep;
    RMSD_figure = figure('Name',Title,'NumberTitle','off');
    plot(time,MM_rms_values,'color',black);
    hold on;
    plot(time,rms_values,'Color',[black,0.33])
    ylabel('RMSD ({\itnm})');
    xlabel('Time ({\itns})');
    fitting_data(tight_fitting=true);
    consistent_figures(figure_name=RMSD_figure, PDF_PNG_name=Title);

end


%% Summary RMSD Analysis %%


if peptides_per_sim > 1
    Title = simulation_name+" RMSD -- All Peptides from "+snapshot_extration_range_start+"ns to "+snapshot_extration_range_end+"ns";
    Summary_RMSD_figure = figure('Name',Title,'NumberTitle','off');
    line_width_for_legends = [];
    
    for pep = 1:peptides_per_sim
    
    
        % data load and processing
        rmsd = load(pep+"p_rmsd.txt");
        shortend_rmsd = rmsd(snapshot_extration_range_start_frames:snapshot_extration_range_end_frames, :);
        
        shortend_time = shortend_rmsd(:,1)/Conversion_factor_to_nanoseconds;
        shortend_rms_values = shortend_rmsd(:,2);
        MM_shortend_time = movmean(shortend_time,100);
        MM_shortend_rms_values = movmean(shortend_rms_values,100);
    
    
        % Figure settings and creation
        MM = plot(MM_shortend_time,MM_shortend_rms_values,'LineWidth',2, 'color',batlowS(pep+1,:),DisplayName="Peptide "+pep);
        hold on;
        %plot(shortend_time,shortend_rms_values,'color',[batlowS(pep,:),0.33]);
        %hold on;
        ylabel('Moving Mean RMSD ({\itnm})');
        xlabel('Time ({\itns})');
        
        ax = gca;
        MM_for_legend = copyobj(MM,ax);
        set(MM_for_legend, 'XData', NaN, 'YData', NaN, 'LineWidth', 2)
        line_width_for_legends = [line_width_for_legends, MM_for_legend];
    
    end
    
    RMSD_analysis_legend = legend(line_width_for_legends,'AutoUpdate','off','Orientation','horizontal', Location='northoutside');
    
    fitting_data(data_spacing_y=0.10);
    consistent_figures(figure_name=Summary_RMSD_figure, PDF_PNG_name=Title,legend_name=RMSD_analysis_legend);

end


%% RMSF Analysis %%

for pep = 1:peptides_per_sim


    % data load and processing
    rmsf = load(pep+"p_rmsf.txt");
    rmsf_nm = rmsf(:,2);
    rmsf_atom_num = rmsf(:,1);

    % Figure settings and creation
    Title = simulation_name+" RMSF -- Peptide "+pep+" Full Length";
    RMSF_figure = figure('Name',Title,'NumberTitle','off');
    plot(rmsf_nm,'-o','MarkerSize',7,'MarkerFaceColor', white,'color',black);

    ylabel('RMSF ({\itnm})');
    xlabel('Residue');
    xticks(0:length(rmsf_atom_num));
    xticklabels(spaced_one_letter_residue_list);

    fitting_data(tight_fitting=true, data_spacing=true);
    consistent_figures(figure_name=RMSF_figure,rotate_x_labels_by_angle=0, PDF_PNG_name=Title);

end


%% RMSF Analysis summary %%

if peptides_per_sim > 1

    Title = simulation_name+" RMSF -- All Peptides Full Length";
    RMSF_figure = figure('Name',Title,'NumberTitle','off');
    line_width_for_legends = [];
    
    
    for pep = 1:peptides_per_sim
    
    
        % data load and processing
        rmsf = load(pep+"p_rmsf.txt");
        rmsf_nm = rmsf(:,2);
        rmsf_atom_num = rmsf(:,1);
    
        % Figure settings and creation
        rmsf_plot = plot(rmsf_nm,'-','color',batlowS(pep+1,:),DisplayName="Peptide "+pep, LineWidth=2);
        hold on;
    
        %line width for legend
        ax = gca;
        rmsf_plot_for_legend = copyobj(rmsf_plot,ax);
        set(rmsf_plot_for_legend, 'XData', NaN, 'YData', NaN, 'LineWidth', 2)
        line_width_for_legends = [line_width_for_legends, rmsf_plot_for_legend];
    
    end
    
    ylabel('RMSF ({\itnm})');
    xlabel('Residue');
    
    RMSF_analysis_legend = legend(line_width_for_legends,'AutoUpdate','off','Orientation','horizontal', Location='northoutside');
    
    xticks(0:length(rmsf_atom_num));
    xticklabels(spaced_one_letter_residue_list);
    
    fitting_data(tight_fitting=true, data_spacing=true);
    consistent_figures(figure_name=RMSF_figure,rotate_x_labels_by_angle=0, PDF_PNG_name=Title, legend_name=RMSF_analysis_legend);

end


%% RMSF SE Analysis summary %%

if peptides_per_sim > 1

    Title = simulation_name+" RMSF -- All Peptides from "+snapshot_extration_range_start+"ns to "+snapshot_extration_range_end+"ns";
    RMSF_figure = figure('Name',Title,'NumberTitle','off');
    line_width_for_legends = [];
    
    
    for pep = 1:peptides_per_sim
    
    
        % data load and processing
        rmsf = load(pep+"p_se_rmsf.txt");
        rmsf_nm = rmsf(:,2);
        rmsf_atom_num = rmsf(:,1);
        
    
        % Figure settings and creation
        rmsf_plot = plot(rmsf_nm,'-','color',batlowS(pep+1,:),DisplayName="Peptide "+pep, LineWidth=2);
        hold on;
    
        %line width for legend
        ax = gca;
        rmsf_plot_for_legend = copyobj(rmsf_plot,ax);
        set(rmsf_plot_for_legend, 'XData', NaN, 'YData', NaN, 'LineWidth', 2)
        line_width_for_legends = [line_width_for_legends, rmsf_plot_for_legend];
    
    end
    
    ylabel('RMSF ({\itnm})');
    xlabel('Residue');
    
    RMSF_analysis_legend = legend(line_width_for_legends,'AutoUpdate','off','Orientation','horizontal', Location='northoutside');
    
    xticks(0:length(rmsf_atom_num));
    xticklabels(spaced_one_letter_residue_list);
    
    fitting_data(tight_fitting=true, data_spacing=true);
    consistent_figures(figure_name=RMSF_figure,rotate_x_labels_by_angle=0, PDF_PNG_name=Title, legend_name=RMSF_analysis_legend);

end


%% Per Residue Minimum Distance %%  

four_pep_sidechain_residue_array = [];
four_pep_sidechain_mean_array = [];

for pep = 1:peptides_per_sim


    %inverse_residue_array = load(pep+"p_residue_mindist_summary.txt");
    inverse_residue_array = load("mindist/mindist/"+pep+"p_residue_mindist_summary.txt");
    sidechain_residue_array = inverse_residue_array.';
    Time = sidechain_residue_array(:,1)/Conversion_factor_to_nanoseconds;

    four_pep_sidechain_residue_array = cat(1,four_pep_sidechain_residue_array,sidechain_residue_array);

    Sidechain_Residue_data_mean = [];
    Sidechain_Residue_data_std = [];

    for residue_number = 1:number_of_residues
        dimension = residue_number + 1;
        Sidechain_Residue_mindist = sidechain_residue_array(:,dimension);
        Sidechain_Residue_data_mean(end+1) = mean(Sidechain_Residue_mindist); %#ok<*SAGROW>
        Sidechain_Residue_data_std(end+1) = std(Sidechain_Residue_mindist);
        %data_ste = data_std/sqrt(length(Residue_Average,1));

    end    
    
    four_pep_sidechain_mean_array = cat(1,four_pep_sidechain_mean_array,Sidechain_Residue_data_mean);

    %figure settings and creation
    Title = simulation_name+" Sidechain Minimum Distance -- Peptide "+pep+" from "+snapshot_extration_range_start+"ns to "+snapshot_extration_range_end+"ns";
    Mindist_figure = figure('Name',Title,'NumberTitle','off');
    errorbar(Sidechain_Residue_data_mean, Sidechain_Residue_data_std, '-','LineWidth',1.2, 'Color',black);
    
    ylabel('Minimum Distance ({\itnm})');
    xlabel('Residue');
    xticks(0:length(Sidechain_Residue_data_mean));
    xticklabels(spaced_one_letter_residue_list);

    fitting_data(tight_fitting=true, data_spacing=true);
    consistent_figures(figure_name=Mindist_figure, rotate_x_labels_by_angle=1, PDF_PNG_name=Title);


end

hold off;


if peptides_per_sim > 1

    Title = simulation_name+" Sidechain Minimum Distance Summary from "+snapshot_extration_range_start+"ns to "+snapshot_extration_range_end+"ns";
    backbone_mindist_figure = figure('Name',Title,'NumberTitle','off');
    line_width_for_legends = [];
    Inverse_four_pep_sidechain_mean_array = four_pep_sidechain_mean_array.';
    
    for pep = 1:peptides_per_sim
      
    
        %Figure settings and creation
        mindist_plot = plot(Inverse_four_pep_sidechain_mean_array(:,pep), '-', 'LineWidth',2, 'Color',batlowS(pep+1,:),DisplayName="Peptide "+pep);
        hold on;   
    
        ax = gca;
        mindist_plot_plot_for_legend = copyobj(mindist_plot,ax);
        set(mindist_plot_plot_for_legend, 'XData', NaN, 'YData', NaN, 'LineWidth', 2)
        line_width_for_legends = [line_width_for_legends, mindist_plot_plot_for_legend];
    
    end
    
    
    Mindist_analysis_legend = legend(line_width_for_legends,'AutoUpdate','off','Orientation','horizontal', Location='northoutside');
    
    
    ylabel('Minimum Distance ({\itnm})');
    xlabel('Residue');
    xticks(0:length(Inverse_four_pep_sidechain_mean_array));
    xticklabels(spaced_one_letter_residue_list);
    
    
    fitting_data(tight_fitting=true, data_spacing=true);
    consistent_figures(figure_name=backbone_mindist_figure, rotate_x_labels=0, PDF_PNG_name=Title, legend_name=Mindist_analysis_legend);

end




%% Per Residue Backbone Minimum Distance %% 

four_pep_backbone_residue_array = [];
four_pep_backbone_mean_array = [];

for pep = 1:peptides_per_sim


    %inverse_residue_array = load(pep+"p_residue_mindist_summary.txt");
    inverse_residue_array = load("mindist/mindist/"+pep+"p_residue_backbone_mindist_summary.txt");
    backbone_residue_array = inverse_residue_array.';
    Time = backbone_residue_array(:,1)/Conversion_factor_to_nanoseconds;

    four_pep_backbone_residue_array = cat(1,four_pep_backbone_residue_array,backbone_residue_array);

    backbone_Residue_data_mean = [];
    backbone_Residue_data_std = [];
  

    for residue_number = 1:number_of_residues
        dimension = residue_number + 1;
        backbone_Residue_mindist = backbone_residue_array(:,dimension);
        backbone_Residue_data_mean(end+1) = mean(backbone_Residue_mindist); %#ok<*SAGROW>
        backbone_Residue_data_std(end+1) = std(backbone_Residue_mindist);
        %data_ste = data_std/sqrt(length(Residue_Average,1));

    end    

    four_pep_backbone_mean_array = cat(1,four_pep_backbone_mean_array,backbone_Residue_data_mean);


    %Figure settings and creation
    Title = simulation_name+" Backbone Minimum Distance -- Peptide "+pep+" from "+snapshot_extration_range_start+"ns to "+snapshot_extration_range_end+"ns";
    backbone_mindist_figure = figure('Name',Title,'NumberTitle','off');
    errorbar(backbone_Residue_data_mean, backbone_Residue_data_std, '-', 'MarkerSize',7, 'LineWidth',1.2, 'Color',black);
    
    ylabel('Minimum Distance ({\itnm})');
    xlabel('Residue');
    xticks(0:length(backbone_Residue_data_mean));
    xticklabels(spaced_one_letter_residue_list);

    fitting_data(tight_fitting=true, data_spacing=true);
    consistent_figures(figure_name=backbone_mindist_figure, rotate_x_labels=0, PDF_PNG_name=Title);

end

hold off;

% summary

if peptides_per_sim > 1

    Title = simulation_name+" Backbone Minimum Distance Summary from "+snapshot_extration_range_start+"ns to "+snapshot_extration_range_end+"ns";
    backbone_mindist_figure = figure('Name',Title,'NumberTitle','off');
    line_width_for_legends = [];
    Inverse_four_pep_backbone_mean_array = four_pep_backbone_mean_array.';


    for pep = 1:peptides_per_sim
      
    
        %Figure settings and creation
        mindist_plot = plot(Inverse_four_pep_backbone_mean_array(:,pep), '-', 'LineWidth',2, 'Color',batlowS(pep+1,:),DisplayName="Peptide "+pep);
        hold on;   
    
        ax = gca;
        mindist_plot_plot_for_legend = copyobj(mindist_plot,ax);
        set(mindist_plot_plot_for_legend, 'XData', NaN, 'YData', NaN, 'LineWidth', 2)
        line_width_for_legends = [line_width_for_legends, mindist_plot_plot_for_legend];
    
    end
    
    
    Mindist_analysis_legend = legend(line_width_for_legends,'AutoUpdate','off','Orientation','horizontal', Location='northoutside');
    
    
    ylabel('Minimum Distance ({\itnm})');
    xlabel('Residue');
    xticks(0:length(Inverse_four_pep_backbone_mean_array));
    xticklabels(spaced_one_letter_residue_list);
    
    
    fitting_data(tight_fitting=true, data_spacing=true);
    consistent_figures(figure_name=backbone_mindist_figure, rotate_x_labels=0, PDF_PNG_name=Title, legend_name=Mindist_analysis_legend);

end


%% Backbone mindist - side chain

BBmean_minus_SCmean_mindist = four_pep_backbone_mean_array-four_pep_sidechain_mean_array;
BBmean_minus_SCmean_mindist = BBmean_minus_SCmean_mindist.';

Title = simulation_name+" Backbone Minus Sidechain Minimum Distance from "+snapshot_extration_range_start+"ns to "+snapshot_extration_range_end+"ns";
backbone_mindist_figure = figure('Name',Title,'NumberTitle','off');

line_width_for_legends = [];


for pep = 1:peptides_per_sim
  

    %Figure settings and creation
    mindist_plot = plot(BBmean_minus_SCmean_mindist(:,pep), '-', 'LineWidth',2, 'Color',batlowS(pep+1,:),DisplayName="Peptide "+pep);
    hold on;
    %errorbar(backbone_Residue_data_mean, backbone_Residue_data_std, '-', 'MarkerSize',7, 'LineWidth',1.2, 'Color',black);
   

    ax = gca;
    mindist_plot_plot_for_legend = copyobj(mindist_plot,ax);
    set(mindist_plot_plot_for_legend, 'XData', NaN, 'YData', NaN, 'LineWidth', 2)
    line_width_for_legends = [line_width_for_legends, mindist_plot_plot_for_legend];

end


Mindist_analysis_legend = legend(line_width_for_legends,'AutoUpdate','off','Orientation','horizontal', Location='northoutside');


ylabel('Minimum Distance Difference ({\itnm})');
xlabel('Residue');
xticks(0:length(backbone_Residue_data_mean));
xticklabels(spaced_one_letter_residue_list);


fitting_data(tight_fitting=true, data_spacing=true);
consistent_figures(figure_name=backbone_mindist_figure, rotate_x_labels=0, PDF_PNG_name=Title, legend_name=Mindist_analysis_legend);


%% hbond Analysis %%
shortend_four_hbond_to_peps = [];
shortend_four_hbond_to_itself = [];
shortend_four_hbond_to_membrane = [];
shortend_four_hbond_to_water = [];
four_pep_cumulative_hbonds = [];


for pep = 1:peptides_per_sim


    %loading in data
    hbond_to_peps_full_array = load("./hbond/"+pep+"p_hbond_to_peps.txt");
    hbond_to_itself_full_array = load("./hbond/"+pep+"p_hbond_to_itself.txt");
    hbond_to_membrane_full_array = load("./hbond/"+pep+"p_hbond_to_memb.txt");
    hbond_to_water_full_array = load("./hbond/"+pep+"p_hbond_to_water.txt");

    %important data for each hbond graph
    Time = hbond_to_itself_full_array(:,1)/Conversion_factor_to_nanoseconds;
    hbonds_to_peps = hbond_to_peps_full_array(:,2);
    hbonds_to_itself = hbond_to_itself_full_array(:,2);
    hbonds_to_membrane = hbond_to_membrane_full_array(:,2);
    hbonds_to_water = hbond_to_water_full_array(:,2);

    %shortend hbond information

    shortend_hbond_to_peps = hbond_to_peps_full_array((snapshot_extration_range_start_frames/10):(snapshot_extration_range_end_frames/10), :);
    shortend_hbond_to_peps_values = shortend_hbond_to_peps(:,2);

    shortend_hbond_to_itself = hbond_to_itself_full_array((snapshot_extration_range_start_frames/10):(snapshot_extration_range_end_frames/10), :);
    shortend_hbond_to_itself_values = shortend_hbond_to_itself(:,2);

    shortend_hbond_to_membrane = hbond_to_membrane_full_array((snapshot_extration_range_start_frames/10):(snapshot_extration_range_end_frames/10), :);
    shortend_hbond_to_membrane_values = shortend_hbond_to_membrane(:,2);

    shortend_hbond_to_water = hbond_to_water_full_array((snapshot_extration_range_start_frames/10):(snapshot_extration_range_end_frames/10), :);
    shortend_hbond_to_water_values = shortend_hbond_to_water(:,2);  

    %mean arrays for seperate graph
    shortend_four_hbond_to_peps = cat(2,shortend_four_hbond_to_peps,shortend_hbond_to_peps_values);
    shortend_four_hbond_to_itself = cat(2,shortend_four_hbond_to_itself,shortend_hbond_to_itself_values);
    shortend_four_hbond_to_membrane = cat(2,shortend_four_hbond_to_membrane,shortend_hbond_to_membrane_values);
    shortend_four_hbond_to_water = cat(2,shortend_four_hbond_to_water,shortend_hbond_to_water_values);

    %some data means and cumulation
    cumulative_hbonds = hbonds_to_peps+hbonds_to_itself+hbonds_to_membrane+hbonds_to_water;
    four_pep_cumulative_hbonds = cat(2,four_pep_cumulative_hbonds,cumulative_hbonds);
    
    mean_cumulative_hbonds = mean(cumulative_hbonds);
    mean_hbonds_to_peps = mean(hbonds_to_peps);
    mean_hbonds_to_water = mean(hbonds_to_water);
    mean_hbonds_to_membrane = mean(hbonds_to_membrane);
    mean_hbonds_to_itself = mean(hbonds_to_itself);

    %Moving means
    MM_cumulative_hbonds = movmean(cumulative_hbonds,100);
    MM_hbonds_to_peps = movmean(hbonds_to_peps,100);
    MM_hbonds_to_water = movmean(hbonds_to_water,100);
    MM_hbonds_to_membrane = movmean(hbonds_to_membrane,100);
    MM_hbonds_to_itself = movmean(hbonds_to_itself,50);


    %area graph creation and settings
    Title = simulation_name+" Hydrogen Bonding -- Peptide "+pep;
    Big_figure = figure('Name',Title,'NumberTitle','off');
    h2c = area(Time, MM_cumulative_hbonds, 'LineStyle','-', 'FaceColor',green, 'LineWidth',1, EdgeColor='none', FaceAlpha=0.2, DisplayName='Tot. Hbs');
    hold on;
    plot([min(xlim) max(xlim)],[1 1]*mean_cumulative_hbonds,'LineWidth',2,'LineStyle',':','Color',[green,0.33], DisplayName='Mean Tot. Hbs');
    grid
    ylabel('Number of Hbonds');
    xlabel('Time ({\itns})');
    hold on;

    % Line plots
    h2p =plot(Time,MM_hbonds_to_peps,'LineWidth',2,'Color',red, DisplayName='Hbs to Peps');
    hold on;
    plot([min(xlim) max(xlim)],[1 1]*mean_hbonds_to_peps,'LineWidth',2,'LineStyle',':','Color',[red,0.40], DisplayName='Mean Hbs to Peps');
    hold on;


    h2w = plot(Time,MM_hbonds_to_water,'LineWidth',2,'Color',blue, DisplayName='Hbs to Water');
    hold on;
    plot([min(xlim) max(xlim)],[1 1]*mean_hbonds_to_water,'LineWidth',2,'LineStyle',':','Color',[blue,0.40], DisplayName='Mean Hbs to Water');
    hold on;


    h2m = plot(Time,MM_hbonds_to_membrane,'LineWidth',2,'Color',purple, DisplayName='Hbs to Memb');
    hold on;
    plot([min(xlim) max(xlim)],[1 1]*mean_hbonds_to_membrane,'LineWidth',2,'LineStyle',':','Color',[purple,0.40], DisplayName='Mean Hbs to Memb');
    hold on;


    h2i = plot(Time,MM_hbonds_to_itself,'LineWidth',2,'Color',black, DisplayName='Hbs to Itself');
    hold on;
    plot([min(xlim) max(xlim)],[1 1]*mean_hbonds_to_itself,'LineWidth',2,'LineStyle',':','Color',[black,0.40], DisplayName='Mean Hbs to Itself');
    hold on;
    


    %setting the legend line widths with a set of fake data so the in-plot line
    %widths can stay the same.
    ax = gca;
    Legend_MM_cumulative_hbonds = copyobj(h2c, ax);
    Legend_MM_hbonds_to_peps = copyobj(h2p, ax);
    Legend_MM_hbonds_to_water = copyobj(h2w, ax);
    Legend_MM_hbonds_to_membrane = copyobj(h2m, ax);
    Legend_MM_hbonds_to_itself = copyobj(h2i, ax);

    set(Legend_MM_hbonds_to_peps, 'XData', NaN, 'YData', NaN, 'LineWidth', 2)
    set(Legend_MM_hbonds_to_water, 'XData', NaN, 'YData', NaN, 'LineWidth', 2)
    set(Legend_MM_hbonds_to_membrane, 'XData', NaN, 'YData', NaN, 'LineWidth', 2)
    set(Legend_MM_hbonds_to_itself, 'XData', NaN, 'YData', NaN, 'LineWidth', 2)

    %some minor info
    hbond_legend = legend([h2c,Legend_MM_hbonds_to_peps,Legend_MM_hbonds_to_water,Legend_MM_hbonds_to_membrane,Legend_MM_hbonds_to_itself],'AutoUpdate','off','Orientation','horizontal',IconColumnWidth=10,Location='northoutside');
    
    fitting_data(tight_fitting=false);
    consistent_figures(figure_name=Big_figure, PDF_PNG_name=Title, legend_name=hbond_legend);
    hold off;
end


%% hbond summary stuff

if peptides_per_sim > 1

    hbond_table = table();
    mean_of_means = [];
    
        
    mean_allpeps_hbond_to_peps = mean(shortend_four_hbond_to_peps);
    mean_allpeps_hbond_to_itself = mean(shortend_four_hbond_to_itself);
    mean_allpeps_hbond_to_membrane = mean(shortend_four_hbond_to_membrane);
    mean_allpeps_hbond_to_water = mean(shortend_four_hbond_to_water);
    mean_allpeps_hbond_to_cumulative_hbonds = mean(four_pep_cumulative_hbonds);
        
    
    mean_allpeps_hbond_to_peps = mean_allpeps_hbond_to_peps.';
        mean_of_means = [mean_of_means,mean(mean_allpeps_hbond_to_peps)];
    mean_allpeps_hbond_to_itself = mean_allpeps_hbond_to_itself.';
        mean_of_means = [mean_of_means,mean(mean_allpeps_hbond_to_itself)];
    mean_allpeps_hbond_to_membrane = mean_allpeps_hbond_to_membrane.';
        mean_of_means = [mean_of_means,mean(mean_allpeps_hbond_to_membrane)];
    mean_allpeps_hbond_to_water = mean_allpeps_hbond_to_water.';
        mean_of_means = [mean_of_means,mean(mean_allpeps_hbond_to_water)];
    mean_allpeps_hbond_to_cumulative_hbonds = mean_allpeps_hbond_to_cumulative_hbonds.';
        mean_of_means = [mean_of_means,mean(mean_allpeps_hbond_to_cumulative_hbonds)];
    mean_of_means = mean_of_means.';
    
    Table_data = [mean_allpeps_hbond_to_peps,mean_allpeps_hbond_to_itself,mean_allpeps_hbond_to_membrane,mean_allpeps_hbond_to_water,mean_allpeps_hbond_to_cumulative_hbonds];
    Table_data = [Table_data.',mean_of_means].';
    
    
    
    
    Title = simulation_name+" Hydrogen Bonding Summary from "+snapshot_extration_range_start+"ns to "+snapshot_extration_range_end+"ns";
    Summary_hbond_figure = figure('Name',Title,'NumberTitle','off');
    
    Column_names = {'Peps.';'Itself';'Memb.';'Water';'Total'};
    Row_names = {'Pep. 1';'Pep. 2';'Pep. 3';'Pep. 4';'Mean'};
    hbond_heatmap = heatmap(Column_names,Row_names,Table_data,Colormap=batlow);
    
    hbond_heatmap.XLabel = 'Hbond Destinations';
    
    ax = gca;
    axp = struct(ax);
    axp.Axes.XAxisLocation = 'top';
    
    fitting_data(tight_fitting=false);
    consistent_figures(figure_name=Summary_hbond_figure,PDF_PNG_name=Title);

end