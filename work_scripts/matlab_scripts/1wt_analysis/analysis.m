%% general settings %%

clear;
close all
blue = [57 106 177]./255;
red = [204 37 41]./255;
black = [83 81 84]./255;
green = [62 150 81]./255;
brown = [146 36 40]./255;
purple = [107 76 154]./255;

simulation_name = "1_wt";
peptides_per_sim = 4;
lipids_per_sim = 128;
number_of_residues = 21;
current_peptide_residue_list = {['1THR', '2ARG', '3SER', '4SER', '5ARG', '6ALA', '7GLY', '8LEU', '9GLN', '10TRP', '11PRO', '12VAL', '13GLY', '14ARG', '15VAL', '16HISD', '17ARG', '18LEU', '19LEU', '20ARG', '21LYS']};


%% Box size analysis %%

% figure creation
figure('Name',simulation_name+" box size analysis",'NumberTitle','off');

% data load and processing
box_array = load("box.txt");
time = box_array(:,1);
x_and_y = box_array(:,2);
z = box_array(:,4);

% Figure settings
plot(time,x_and_y,'color',green);
hold on;
plot(time,z,'color',blue);
ax1 = gca; % generate cartesian axis aka. allows you to work with the axis
myfontsize = 15;
ax1.FontSize = myfontsize;
ylabel('Box vector length (nm)','fontsize',myfontsize);
xlabel('Time (ps)','fontsize',myfontsize);
%axis(ax1, 'tight'); %restricts the axises to be directly up on the data and then gives them some centering space
%xlim(ax1, xlim(ax1) + [-1,1]*range(xlim(ax1)).* 0.05)
%ylim(ax1, ylim(ax1) + [-1,1]*range(ylim(ax1)).* 0.05)


%% Area per lipid analysis %%

% figure creation
figure('Name',simulation_name+" area per lipid analysis",'NumberTitle','off');

% data load and processing
time = box_array(:,1);
x_and_y = box_array(:,2);
area_per_lipid = (x_and_y.*x_and_y)/(lipids_per_sim/2);
%mean_arr = movmean(area_per_lipid,1000);

% Figure settings
plot(time,area_per_lipid,'color',black);
hold on;
%plot(time,mean_arr,'color', red);
ax1 = gca; % generate cartesian axis aka. allows you to work with the axis
myfontsize = 15;
ax1.FontSize = myfontsize;
ylabel('Area per lipid (nm^2)','fontsize',myfontsize);
xlabel('Time (ps)','fontsize',myfontsize);
%axis(ax1, 'tight'); %restricts the axises to be directly up on the data and then gives them some centering space
%xlim(ax1, xlim(ax1) + [-1,1]*range(xlim(ax1)).* 0.05)
%ylim(ax1, ylim(ax1) + [-1,1]*range(ylim(ax1)).* 0.05)


%% Energy analysis %%

% figure creation
figure('Name',simulation_name+" Total energy analysis",'NumberTitle','off');

% data load and processing
energy_array = load("mdenergy.txt");
time = energy_array(:,1);
total_energy = energy_array(:,2);

% Figure settings
plot(time,total_energy,'color',purple);
ax1 = gca; % generate cartesian axis aka. allows you to work with the axis
myfontsize = 15;
ax1.FontSize = myfontsize;
ylabel('Potential energy (KJ/mol), (K)','fontsize',myfontsize);
xlabel('Time (ps)','fontsize',myfontsize);
axis(ax1, 'tight'); %restricts the axises to be directly up on the data and then gives them some centering space
xlim(ax1, xlim(ax1) + [-1,1]*range(xlim(ax1)).* -0.05)
%ylim(ax1, ylim(ax1) + [-1,1]*range(ylim(ax1)).* 0.05)


%% Temperature analysis %%

% figure creation
figure('Name',simulation_name+" Temperature analysis",'NumberTitle','off');

% data load and processing

time = energy_array(:,1);
Temperature = energy_array(:,3);

% Figure settings
plot(time,Temperature,'color',green);
ax1 = gca; % generate cartesian axis aka. allows you to work with the axis
myfontsize = 15;
ax1.FontSize = myfontsize;
ylabel('Temperature (K)','fontsize',myfontsize);
xlabel('Time (ps)','fontsize',myfontsize);
axis(ax1, 'tight'); %restricts the axises to be directly up on the data and then gives them some centering space
%xlim(ax1, xlim(ax1) + [-1,1]*range(xlim(ax1)).* -0.05)
%ylim(ax1, ylim(ax1) + [-1,1]*range(ylim(ax1)).* 0.05)

%% Density analysis %%

% figure creation
figure('Name',simulation_name+" Bilayer thickness",'NumberTitle','off');

% data load and processing
Density_array = load("density.txt");
arp = Density_array(:,1);
Density = Density_array(:,2);

% Figure settings
plot(arp,Density,'color',purple);
ax1 = gca; % generate cartesian axis aka. allows you to work with the axis
myfontsize = 15;
ax1.FontSize = myfontsize;
ylabel('Density (kg m^-3)','fontsize',myfontsize);
xlabel('Average relative position from center (nm)','fontsize',myfontsize);
axis(ax1, 'tight'); %restricts the axises to be directly up on the data and then gives them some centering space
%xlim(ax1, xlim(ax1) + [-1,1]*range(xlim(ax1)).* -0.05)
%ylim(ax1, ylim(ax1) + [-1,1]*range(ylim(ax1)).* 0.05)

%% RMSD Analysis %%

for pep = peptides_per_sim:-1:1.0

   % figure creation
    figure('Name',simulation_name+" RMSD peptide "+pep,'NumberTitle','off');

    % data load and processing
    rmsd = load(pep+"p_rmsd.txt");
    time = rmsd(:,1);
    rms_values = rmsd(:,2);

    % Figure settings
    plot(time,rms_values,'color',purple);
    ax1 = gca; % generate cartesian axis aka. allows you to work with the axis
    myfontsize = 15;
    ax1.FontSize = myfontsize;
    ylabel('RMSD (nm)','fontsize',myfontsize);
    xlabel('time (ps)','fontsize',myfontsize);
    axis(ax1, 'tight'); %restricts the axises to be directly up on the data and then gives them some centering space
    %xlim(ax1, xlim(ax1) + [-1,1]*range(xlim(ax1)).* -0.05)
    %ylim(ax1, ylim(ax1) + [-1,1]*range(ylim(ax1)).* 0.05)

end


%% RMSF Analysis %%

for pep = peptides_per_sim:-1:1.0

    %figure creation
    figure('Name',simulation_name+" RMSF peptide "+pep,'NumberTitle','off');

    % data load and processing
    rmsf = load(pep+"p_rmsf.txt");
    rmsf_nm = rmsf(:,2);
    rmsf_atom_num = rmsf(:,1);
    rmsf_array = {'T1','R2','S3','S4','R5','A6','G7','L8','Q9','10W','11P','V12','G13','R14','V15','H16','R17','L18','L19','R20','K21'};

    % Figure settings
    plot(rmsf_nm,'-o','MarkerSize',10,'MarkerFaceColor', blue,'color',purple);
    ax1 = gca; % generate cartesian axis aka. allows you to work with the axis
    myfontsize = 15;
    ax1.FontSize = myfontsize;
    ylabel('RMSF (nm)','fontsize',myfontsize);
    xlabel('Residue','fontsize',myfontsize);
    axis(ax1, 'tight'); %restricts the axises to be directly up on the data and then gives them some centering space
    xlim(ax1, xlim(ax1) + [-1,1]*range(xlim(ax1)).* 0.05)
    ylim(ax1, ylim(ax1) + [-1,1]*range(ylim(ax1)).* 0.05)
    xticks(0:length(rmsf_atom_num));
    xticklabels({'','T1','R2','S3','S4','R5','A6','G7','L8','Q9','10W','11P','V12','G13','R14','V15','H16','R17','L18','L19','R20','K21'});

end

%% Per Residue Minimum Distance %%

four_pep_sidechain_residue_array = [];
four_pep_sidechain_mean_array = [];

for pep = peptides_per_sim:-1:1.0

    %figure creation
    figure('Name',simulation_name+" mindist summary peptide "+pep,'NumberTitle','off');

    %inverse_residue_array = load(pep+"p_residue_mindist_summary.txt");
    inverse_residue_array = load(pep+"p_residue_mindist_summary.txt");
    sidechain_residue_array = inverse_residue_array.';
    Time = sidechain_residue_array(:,1);

    four_pep_sidechain_residue_array = cat(1,four_pep_sidechain_residue_array,sidechain_residue_array);

    Sidechain_Residue_data_mean = [];
    Sidechain_Residue_data_std = [];

    for residue_number = number_of_residues:-1:1.0
        dimension = residue_number + 1;
        Sidechain_Residue_mindist = sidechain_residue_array(:,dimension);
        Sidechain_Residue_data_mean(end+1) = mean(Sidechain_Residue_mindist); %#ok<*SAGROW>
        Sidechain_Residue_data_std(end+1) = std(Sidechain_Residue_mindist);
        %data_ste = data_std/sqrt(length(Residue_Average,1));

    end    
    
    four_pep_sidechain_mean_array = cat(1,four_pep_sidechain_mean_array,Sidechain_Residue_data_mean);


    myfontsize = 15;
    errorbar(Sidechain_Residue_data_mean, Sidechain_Residue_data_std, '-r.', 'MarkerSize',20, 'LineWidth',2, 'Color',brown);
    ylabel('Minimum Distance (nm)','fontsize',myfontsize);
    xlabel('BF2 residue','fontsize',myfontsize);
    ax1 = gca;
    %restricts the axises to be directly up on the data and then gives them
    %some centering space
    axis(ax1, 'tight');
    xlim(ax1, xlim(ax1) + [-1,1]*range(xlim(ax1)).* 0.05)
    ylim(ax1, ylim(ax1) + [-1,1]*range(ylim(ax1)).* 0.05)

    ax1.FontSize = myfontsize;
    xticks(0:length(Sidechain_Residue_data_mean));
    xticklabels({'','1THR', '2ARG', '3SER', '4SER', '5ARG', '6ALA', '7GLY', '8LEU', '9GLN', '10TRP', '11PRO', '12VAL', '13GLY', '14ARG', '15VAL', '16HISD', '17ARG', '18LEU', '19LEU', '20ARG', '21LYS',''});

end

%% Per Residue Backbone Minimum Distance %%

four_pep_backbone_residue_array = [];
four_pep_backbone_mean_array = [];

for pep = peptides_per_sim:-1:1.0

    %figure creation
    figure('Name',simulation_name+" backbone mindist summary peptide "+pep,'NumberTitle','off');

    %inverse_residue_array = load(pep+"p_residue_mindist_summary.txt");
    inverse_residue_array = load(pep+"p_residue_backbone_mindist_summary.txt");
    backbone_residue_array = inverse_residue_array.';
    Time = backbone_residue_array(:,1);

    four_pep_backbone_residue_array = cat(1,four_pep_backbone_residue_array,backbone_residue_array);

    backbone_Residue_data_mean = [];
    backbone_Residue_data_std = [];
  

    for residue_number = number_of_residues:-1:1.0
        dimension = residue_number + 1;
        backbone_Residue_mindist = backbone_residue_array(:,dimension);
        backbone_Residue_data_mean(end+1) = mean(backbone_Residue_mindist); %#ok<*SAGROW>
        backbone_Residue_data_std(end+1) = std(backbone_Residue_mindist);
        %data_ste = data_std/sqrt(length(Residue_Average,1));

    end    
    
    four_pep_backbone_mean_array = cat(1,four_pep_backbone_mean_array,backbone_Residue_data_mean);

    myfontsize = 15;
    errorbar(backbone_Residue_data_mean, backbone_Residue_data_std, '-r.', 'MarkerSize',20, 'LineWidth',2, 'Color',blue);
    ylabel('Minimum Distance (nm)','fontsize',myfontsize);
    xlabel('BF2 residue','fontsize',myfontsize);
    ax1 = gca;
    %restricts the axises to be directly up on the data and then gives them
    %some centering space
    axis(ax1, 'tight');
    xlim(ax1, xlim(ax1) + [-1,1]*range(xlim(ax1)).* 0.05)
    ylim(ax1, ylim(ax1) + [-1,1]*range(ylim(ax1)).* 0.05)

    ax1.FontSize = myfontsize;
    xticks(0:length(backbone_Residue_data_mean));
    xticklabels({'','1THR', '2ARG', '3SER', '4SER', '5ARG', '6ALA', '7GLY', '8LEU', '9GLN', '10TRP', '11PRO', '12VAL', '13GLY', '14ARG', '15VAL', '16HISD', '17ARG', '18LEU', '19LEU', '20ARG', '21LYS',''});

end


%% Backbone mindist - side chain

bbsc_mindist = four_pep_backbone_residue_array-four_pep_sidechain_residue_array;
scbb_mindist = four_pep_sidechain_residue_array-four_pep_backbone_residue_array;
bbsc_mean_mindist = four_pep_backbone_mean_array-four_pep_sidechain_mean_array;


%{
for pep = peptides_per_sim:-1:1.0

    %figure creation
    figure('Name',simulation_name+" difference mindist summary peptide "+pep,'NumberTitle','off');

    %inverse_residue_array = load(pep+"p_residue_mindist_summary.txt");
    end_dimension = pep * 22;
    start_dimension = (pep-1) * 22;
    if start_dimension == 0;
        start_dimension = 1;
    end

    single_peptide = bbsc_mindist(:,[start_dimension:end_dimension]);

    correct_single_peptide = single_peptide.';
    

    data_mean = [];
    data_std = [];
  

    for residue_number = number_of_residues:-1:1.0
        dimension = residue_number + 1;
        difference_Residue_mindist = correct_single_peptide(:,dimension);
        data_mean(end+1) = mean(difference_Residue_mindist); %#ok<*SAGROW>
        data_std(end+1) = std(difference_Residue_mindist);
        %data_ste = data_std/sqrt(length(Residue_Average,1));

    end    
%}

single_mean = mean(bbsc_mean_mindist);
single_std = std(bbsc_mean_mindist);
single_ste = single_std/4;



    figure('Name',"WT1 bb-sc_difference mindist summary peptide "+pep,'NumberTitle','off');

    myfontsize = 15;
    errorbar(single_mean, single_ste, '-r.', 'MarkerSize',20, 'LineWidth',2, 'Color',blue);
    ylabel('Minimum Distance Difference (bb-sc nm)','fontsize',myfontsize);
    xlabel('BF2 residue','fontsize',myfontsize);
    ax1 = gca;
    %restricts the axises to be directly up on the data and then gives them
    %some centering space
    axis(ax1, 'tight');
    xlim(ax1, xlim(ax1) + [-1,1]*range(xlim(ax1)).* 0.05)
    ylim(ax1, ylim(ax1) + [-1,1]*range(ylim(ax1)).* 0.05)

    ax1.FontSize = myfontsize;
    xticks(0:length(single_mean));
    xticklabels({'','1THR', '2ARG', '3SER', '4SER', '5ARG', '6ALA', '7GLY', '8LEU', '9GLN', '10TRP', '11PRO', '12VAL', '13GLY', '14ARG', '15VAL', '16HISD', '17ARG', '18LEU', '19LEU', '20ARG', '21LYS',''});




%{
figure('Name',"pep 1 mean difference mindist summary",'NumberTitle','off');

fontsize = 15;
    plot(bbsc_mean_mindist(:,1), '-r.', 'MarkerSize',20, 'LineWidth',2, 'Color',blue);
    ylabel('Minimum Distance (nm)','fontsize',myfontsize);
    xlabel('BF2 residue','fontsize',myfontsize);
    ax1 = gca;
    %restricts the axises to be directly up on the data and then gives them
    %some centering space
    axis(ax1, 'tight');
    xlim(ax1, xlim(ax1) + [-1,1]*range(xlim(ax1)).* 0.05)
    ylim(ax1, ylim(ax1) + [-1,1]*range(ylim(ax1)).* 0.05)

    ax1.FontSize = myfontsize;
    xticks(0:length(data_mean));
    xticklabels({'','1THR', '2ARG', '3SER', '4SER', '5ARG', '6ALA', '7GLY', '8LEU', '9GLN', '10TRP', '11PRO', '12VAL', '13GLY', '14ARG', '15VAL', '16HISD', '17ARG', '18LEU', '19LEU', '20ARG', '21LYS',''});
%}


%% Per Residue Minimum Distance analysis 2 with ste %%

% for pep = peptides_per_sim:-1:1.0
% 
%     %figure creation
%     figure('Name',simulation_name+" mindist summary peptide "+pep,'NumberTitle','off');
% 
%     %inverse_residue_array = load(pep+"p_residue_mindist_summary.txt");
%     inverse_residue_array = load(pep+"p_residue_mindist_summary.txt");
%     Residue_array = inverse_residue_array.';
%     Time = Residue_array(:,1);
% 
%     data_mean = [];
%     data_std = [];
% 
%     for residue_number = number_of_residues:-1:1.0
%         dimension = residue_number + 1;
%         Residue_mindist = Residue_array(:,dimension);
%         data_mean(end+1) = mean(Residue_mindist); %#ok<*SAGROW>
%         data_std(end+1) = std(Residue_mindist);
%         data_ste = data_std/sqrt(length(Residue_mindist));
% 
%     end    
% 
% 
%     myfontsize = 15;
%     errorbar(data_mean, data_ste, '-r.', 'MarkerSize',20, 'LineWidth',2, 'Color',brown);
%     ylabel('Minimum Distance (nm)','fontsize',myfontsize);
%     xlabel('BF2 residue','fontsize',myfontsize);
%     ax1 = gca;
%     %restricts the axises to be directly up on the data and then gives them
%     %some centering space
%     axis(ax1, 'tight');
%     xlim(ax1, xlim(ax1) + [-1,1]*range(xlim(ax1)).* 0.05)
%     ylim(ax1, ylim(ax1) + [-1,1]*range(ylim(ax1)).* 0.05)
% 
%     ax1.FontSize = myfontsize;
%     xticks(0:length(data_mean));
%     xticklabels({'','1THR', '2ARG', '3SER', '4SER', '5ARG', '6ALA', '7GLY', '8LEU', '9GLN', '10TRP', '11PRO', '12VAL', '13GLY', '14ARG', '15VAL', '16HISD', '17ARG', '18LEU', '19LEU', '20ARG', '21LYS',''});
% 
% end

% %% hbond Analysis %%
% 
% % figure creation
% figure('Name',simulation_name+" hbnum_analysis",'NumberTitle','off');
% 
% % data load and processing
% hbnum_array = load("hbnum.txt");
% time = hbnum_array(:,1);
% hbnum = hbnum_array(:,2);
% 
% % Figure settings
% plot(hbnum,'color',purple);
% ax1 = gca; % generate cartesian axis aka. allows you to work with the axis
% myfontsize = 15;
% ax1.FontSize = myfontsize;
% ylabel('number of hydrogen bonds','fontsize',myfontsize);
% xlabel('Time (ps)','fontsize',myfontsize);
% axis(ax1, 'tight'); %restricts the axises to be directly up on the data and then gives them some centering space
% %xlim(ax1, xlim(ax1) + [-1,1]*range(xlim(ax1)).* -0.05)
% %ylim(ax1, ylim(ax1) + [-1,1]*range(ylim(ax1)).* 0.05)


 %% DSSP %%


 %{

for pep = peptides_per_sim:-1:1.0
   

    pep = 1;

    %figure creation
    figure('Name',simulation_name+" DSSP peptide "+pep,'NumberTitle','off');

    % data load and processing
    DSSP = load("p"+pep+"_dssp.txt");
    time = DSSP(:,1);
    loops = DSSP(:,2);
    Breaks = DSSP(:,3);
    Bends = DSSP(:,4);
    Turns = DSSP(:,5);
    PP_Helices = DSSP(:,6);
    pi_Helices = DSSP(:,7);
    type_310_Helices = DSSP(:,8);
    b_Strands = DSSP(:,9);
    b_Bridges = DSSP(:,10);
    a_Helices = DSSP(:,11);
   

    % Figure settings
    plot(time,loops,'color',purple);
    hold on
    plot(time,Breaks,'color',brown);
    hold on
    plot(time,Bends,'color',green);
    hold on
    plot(time,Turns,'color',black);
    hold on
    plot(time,PP_Helices,'color',blue);
    hold on
    plot(time,pi_Helices,'color',red);
    hold on
    plot(time,type_310_Helices,'color',"y");
    hold on
    plot(time,b_Strands,'color',"m");
    hold on
    plot(time,b_Bridges,'color',"c");
    hold on
    plot(time,a_Helices,'color',"r");
    hold off

    ax1 = gca; % generate cartesian axis aka. allows you to work with the axis
    myfontsize = 15;
    ax1.FontSize = myfontsize;
    ylabel('prevelance (count)','fontsize',myfontsize);
    xlabel('time (ps)','fontsize',myfontsize);
    axis(ax1, 'tight'); %restricts the axises to be directly up on the data and then gives them some centering space
    %xlim(ax1, xlim(ax1) + [-1,1]*range(xlim(ax1)).* -0.05)
    %ylim(ax1, ylim(ax1) + [-1,1]*range(ylim(ax1)).* 0.05)


end

%}