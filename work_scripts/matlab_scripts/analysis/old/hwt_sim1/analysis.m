%% general settings %%

clear;
close all
blue = [57 106 177]./255;
red = [204 37 41]./255;
black = [83 81 84]./255;
green = [62 150 81]./255;
brown = [146 36 40]./255;
purple = [107 76 154]./255;

simulation_name = "1 protonated histidine";
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

for pep = peptides_per_sim:-1:1.0

    %figure creation
    figure('Name',simulation_name+" mindist summary peptide "+pep,'NumberTitle','off');

    %inverse_residue_array = load(pep+"p_residue_mindist_summary.txt");
    inverse_residue_array = load(pep+"p_residue_mindist_summary.txt");
    Residue_array = inverse_residue_array.';
    Time = Residue_array(:,1)
    data_mean = [];
    data_std = [];

    for residue_number = number_of_residues:-1:1.0
        dimension = residue_number + 1;
        Residue_mindist = Residue_array(:,dimension);
        data_mean(end+1) = mean(Residue_mindist); %#ok<*SAGROW>
        data_std(end+1) = std(Residue_mindist);
        %data_ste = data_std/sqrt(length(Residue_Average,1));

    end    


    myfontsize = 15;
    errorbar(data_mean, data_std, '-r.', 'MarkerSize',20, 'LineWidth',2, 'Color',brown);
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

end

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