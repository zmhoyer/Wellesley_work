close all;
clear;

%% Functions

function data = bfe_comparison_last250(raw_file)
     
    size_of_data = size(raw_file);
    data = zeros(101,size_of_data(2));
     
    if size_of_data(1,1) > 101
        step_size = (size_of_data(1,1)-1)/100;
    end
    
    for current_column = 1:size_of_data(1,2)
        data(:,current_column) = raw_file(1:step_size:size_of_data(1,1),current_column);
    end
end


function data = bfe_comparison_1000ns(raw_file)
     
    size_of_data = size(raw_file);
    last_250ns_size = round(size_of_data(1)*(0.75));
    data = zeros(101,size_of_data(2));
     
    if size_of_data(1,1) > 101
        step_size = round(((size_of_data(1,1)-last_250ns_size)-1)/100);
    end
    
    for current_column = 1:size_of_data(1,2)
        data(:,current_column) = raw_file(last_250ns_size:step_size:size_of_data(1,1),current_column);
    end
end



function complete_data = construct_fulldata(sims,peps,analysis_object_constructer_dictionary)  
    k = keys(analysis_object_constructer_dictionary);
    complete_data = struct();
    peptide_iterator = 1;

    for sim = 1:length(sims)
        for pep = 1:peps
            complete_data(peptide_iterator).simulation = sims{sim};
            complete_data(peptide_iterator).peptide = "p"+pep;
            for current_analysis = 1:length(k)
                data = load(sprintf(analysis_object_constructer_dictionary(k(current_analysis)),sims{sim},pep));
                fieldname = k(current_analysis);

                if strcmp(fieldname,"Sidechain_Mindist") | strcmp(fieldname,"Backbone_Mindist")
                    data = data.';
                end 

                complete_data(peptide_iterator).(fieldname) = data;
            end
            peptide_iterator = peptide_iterator+1;
        end
    end
end


function complete_data_for_BFE = construct_fulldata_for_BFE(sims,peps,analysis_object_constructer_dictionary)  
    k = keys(analysis_object_constructer_dictionary);
    complete_data_for_BFE = struct();
    peptide_iterator = 1;

    for sim = 1:length(sims)
        for pep = 1:peps
            complete_data_for_BFE(peptide_iterator).simulation = sims{sim};
            complete_data_for_BFE(peptide_iterator).peptide = pep+"p";
            complete_data_for_BFE(peptide_iterator).time = (750000:2500:1000000).';
            complete_data_for_BFE(peptide_iterator).frame_number = (1:1:101).';
            for current_analysis = 1:length(k)
                data = load(sprintf(analysis_object_constructer_dictionary(k(current_analysis)),sims{sim},pep));
                fieldname = k(current_analysis);

        
                if strcmp(fieldname,"Sidechain_Mindist") | strcmp(fieldname,"Backbone_Mindist") | strcmp(fieldname,"all_residue_depth")
                    data = data.';
                    data = bfe_comparison_last250(data);
                elseif strcmp(fieldname,"Hbond_to_memb") | strcmp(fieldname,"Hbond_to_peps") | strcmp(fieldname,"Hbond_to_water") | strcmp(fieldname,"Hbond_to_itself") | strcmp(fieldname,"RMSD") | strcmp(fieldname,"fullpep_depth") 
                    data = bfe_comparison_1000ns(data);
                elseif (~strcmp(fieldname,"BFE")) && (~strcmp(fieldname,"BFE_components")) && (~strcmp(fieldname,"Surface_area_per_residue_over_trajectory")) && (~strcmp(fieldname,"RMSF"))
                    data = bfe_comparison_last250(data);
                end 

                complete_data_for_BFE(peptide_iterator).(fieldname) = data;
            end
            peptide_iterator = peptide_iterator+1;
        end
    end
end




function [data,column_dictionary] = compile_column_matrix(analysis_name,sims)  
    numb_of_sims = length(sims);
    column_iterator = 0;
    column_dictionary = dictionary;
    data = [];
    for current_analysis = 1:length(analysis_name)
        
        column_data = [sims(:).(analysis_name{current_analysis})];
        
        if ~isstring(column_data(1,1)) && column_data(1,1) == 750000 && ~strcmp(analysis_name{current_analysis},'time') %time based?
            columns = size(column_data,2);
            iterator = columns/numb_of_sims;
            column_data(:,1:iterator:end) = []; %delete time
            new_iterator = size(column_data,2)/numb_of_sims;
    
            if size(column_data,2) > numb_of_sims %more than one column
                for c_stack = 1:(new_iterator)
                    column_matrix = column_data(:,c_stack:new_iterator:end);
                    one_column_data = column_matrix(:);
                    data = [data,one_column_data];
                end
                columns = new_iterator;
            else %only one column from time based data
                column_data = column_data(:);
                columns = size(column_data,2);
                data = [data,column_data];
            end



        elseif size(column_data,2) > numb_of_sims % not time based, multiple columns, check if working
            columns = size(column_data,2);
            iterator = columns/numb_of_sims;
            for c_stack = 1:(iterator)
                column_matrix = column_data(:,c_stack:iterator:end);
                one_column_data = column_matrix(:);
                data = [data,one_column_data];
            end
            columns = iterator;



        else % not time based
            column_data = column_data(:);
            if ~(isempty(data)) && length(column_data(:,1))<length(data(:,1))
                multiplier = length(data(:,1))/length(column_data(:));
                column_data = repelem(column_data,multiplier);
            end
            columns = size(column_data,2);
            data = [data,column_data];
        end
        
        
    
        if columns > 1
            old_column_iterator = column_iterator+1;
            column_iterator = column_iterator+columns;
            column_dictionary(analysis_name{current_analysis}+"_start") = old_column_iterator;
            column_dictionary(analysis_name{current_analysis}+"_end") = column_iterator;
        else
            column_iterator = column_iterator+1;
            column_dictionary(analysis_name{current_analysis}) = column_iterator;
        end
    end
end

function sim_names = only_sim_names()
    % all_sim_names_sorted = {"wt_sim1","wt_sim2","wt_sim3","wt_sim4","wt_sim5","wt_sim6","hwt_sim1","hwt_sim2","hwt_sim3","t1r_sim1","t1r_sim2","t1r_sim3","ht1r_sim1","ht1r_sim2","ht1r_sim3","a6r_sim1","a6r_sim2","a6r_sim3","ha6r_sim1","ha6r_sim2","ha6r_sim3","l8r_sim1","l8r_sim2","l8r_sim3","hl8r_sim1","hl8r_sim2","hl8r_sim3","q9r_sim1","q9r_sim2","q9r_sim3","hq9r_sim1","hq9r_sim2","hq9r_sim3","v12r_sim1","v12r_sim2","v12r_sim3","hv12r_sim1","hv12r_sim2","hv12r_sim3","l18r_sim1","l18r_sim2","l18r_sim3","hl18r_sim1","hl18r_sim2","hl18r_sim3","t1r_a6r_l8r_sim1","t1r_a6r_l8r_sim2","t1r_a6r_l8r_sim3","h_t1r_a6r_l8r_sim1","h_t1r_a6r_l8r_sim2","h_t1r_a6r_l8r_sim3"};
    all_sim_names_sorted = {"wt_sim1","wt_sim2","wt_sim3","wt_sim5","wt_sim6","hwt_sim1","hwt_sim2","hwt_sim3","t1r_sim1","t1r_sim2","t1r_sim3","ht1r_sim1","ht1r_sim2","ht1r_sim3","a6r_sim1","a6r_sim2","a6r_sim3","ha6r_sim1","ha6r_sim2","ha6r_sim3","l8r_sim1","l8r_sim2","l8r_sim3","hl8r_sim1","hl8r_sim2","hl8r_sim3","q9r_sim1","q9r_sim2","q9r_sim3","hq9r_sim1","hq9r_sim2","hq9r_sim3","v12r_sim1","v12r_sim2","v12r_sim3","hv12r_sim1","hv12r_sim2","hv12r_sim3","l18r_sim1","l18r_sim2","l18r_sim3","hl18r_sim1","hl18r_sim2","hl18r_sim3","t1r_a6r_l8r_sim1","t1r_a6r_l8r_sim2","t1r_a6r_l8r_sim3","h_t1r_a6r_l8r_sim1","h_t1r_a6r_l8r_sim2","h_t1r_a6r_l8r_sim3"};
    % all_sim_names_sorted = {"wt_sim1","wt_sim2","wt_sim3","wt_sim4","wt_sim5","wt_sim6","hwt_sim1","hwt_sim2","hwt_sim3","t1r_sim1","t1r_sim2","ht1r_sim1","ht1r_sim2","a6r_sim1","a6r_sim2","ha6r_sim1","ha6r_sim2","l8r_sim1","l8r_sim2","hl8r_sim1","hl8r_sim2","q9r_sim1","q9r_sim2","q9r_sim3","hq9r_sim1","hq9r_sim2","hq9r_sim3","v12r_sim1","v12r_sim2","v12r_sim3","hv12r_sim1","hv12r_sim2","hv12r_sim3","l18r_sim1","l18r_sim2","l18r_sim3","hl18r_sim1","hl18r_sim2","hl18r_sim3","t1r_a6r_l8r_sim1","t1r_a6r_l8r_sim2","t1r_a6r_l8r_sim3","h_t1r_a6r_l8r_sim1","h_t1r_a6r_l8r_sim2","h_t1r_a6r_l8r_sim3"};
    non_unique_sim_names = [];
    for sim = 1:length(all_sim_names_sorted)
        loop_sim = all_sim_names_sorted{sim};
        last_underscore_pos = strfind(loop_sim,'_');
        current_sim_name = extractBefore(loop_sim,last_underscore_pos(end));
        non_unique_sim_names = [non_unique_sim_names,current_sim_name];
    end
    sim_names = unique(cellstr(non_unique_sim_names),'stable');
end


function rank_order_means = split_and_mean(sorted_data)
    peps = size(sorted_data,1)/101;
    rank_order_means = [];
    for pep = 1:peps
        rank_order_means = [rank_order_means;mean(sorted_data(1+(101*(pep-1)):(pep*101),:))]; % Gives us the data split into groups
    end
end




%%variables
% all_sim_names_sorted = {"wt_sim1","wt_sim2"};
peptides_per_sim = 4;

% all_sim_names_sorted = {"wt_sim1","wt_sim2","wt_sim3","wt_sim4","wt_sim5","wt_sim6","hwt_sim1","hwt_sim2","hwt_sim3","t1r_sim1","t1r_sim2","t1r_sim3","ht1r_sim1","ht1r_sim2","ht1r_sim3","a6r_sim1","a6r_sim2","a6r_sim3","ha6r_sim1","ha6r_sim2","ha6r_sim3","l8r_sim1","l8r_sim2","l8r_sim3","hl8r_sim1","hl8r_sim2","hl8r_sim3","q9r_sim1","q9r_sim2","q9r_sim3","hq9r_sim1","hq9r_sim2","hq9r_sim3","v12r_sim1","v12r_sim2","v12r_sim3","hv12r_sim1","hv12r_sim2","hv12r_sim3","l18r_sim1","l18r_sim2","l18r_sim3","hl18r_sim1","hl18r_sim2","hl18r_sim3","t1r_a6r_l8r_sim1","t1r_a6r_l8r_sim2","t1r_a6r_l8r_sim3","h_t1r_a6r_l8r_sim1","h_t1r_a6r_l8r_sim2","h_t1r_a6r_l8r_sim3"};
all_sim_names_sorted = {"wt_sim1","wt_sim2","wt_sim3","wt_sim5","wt_sim6","hwt_sim1","hwt_sim2","hwt_sim3","t1r_sim1","t1r_sim2","t1r_sim3","ht1r_sim1","ht1r_sim2","ht1r_sim3","a6r_sim1","a6r_sim2","a6r_sim3","ha6r_sim1","ha6r_sim2","l8r_sim1","l8r_sim2","l8r_sim3","hl8r_sim1","hl8r_sim2","hl8r_sim3","q9r_sim1","q9r_sim2","q9r_sim3","hq9r_sim1","hq9r_sim2","hq9r_sim3","v12r_sim1","v12r_sim2","v12r_sim3","hv12r_sim1","hv12r_sim2","hv12r_sim3","l18r_sim1","l18r_sim2","l18r_sim3","hl18r_sim1","hl18r_sim2","hl18r_sim3","t1r_a6r_l8r_sim1","t1r_a6r_l8r_sim2","t1r_a6r_l8r_sim3","h_t1r_a6r_l8r_sim1","h_t1r_a6r_l8r_sim2","h_t1r_a6r_l8r_sim3"};
%check wt_sim4 ha6r_sim3


other_analysis_path = "./other_analysis/%s/%dp/";
analysis_path = "./%s_analysis/%d";
mindist_analysis_path = "./%s_analysis/mindist/%d";
hbond_analysis_path = "./%s_analysis/hbond/%d";
bfe_path = "../bfe/bfe_summary_all_sims/%s/%d";
depth_path = "./all_depth/%s/%d";

% analysis_name = ["BFE",'BFE_components','Dipole_of_helix','Radius_of_gyration','Hbond_to_memb','Hbond_to_peps','Hbond_to_water','Hbond_to_itself','Backbone_Mindist','Sidechain_Mindist','RMSF','RMSD','RMS_of_Helix_from_ideal_alpha_helix','Radius_of_Helix','Length_of_Helix','Average_helical_angle','Average_Phi_angle','Average_Psi_angle','GROMACS_estimated_solvation_energies','Solvent_accessible_area','Surface_area_per_residue_over_trajectory','Volume_and_density','fullpep_depth'];
analysis_name = ["BFE",'fullpep_depth', 'all_residue_depth'];
% analysis_file_path = [bfe_path+"p_bfe_summary.txt",bfe_path+"p_bfe_elements_summary.txt",other_analysis_path+"dip-ahx.txt",other_analysis_path+"gyrate.txt",hbond_analysis_path+"p_hbond_to_memb.txt",hbond_analysis_path+"p_hbond_to_peps.txt",hbond_analysis_path+"p_hbond_to_water.txt",hbond_analysis_path+"p_hbond_to_itself.txt",mindist_analysis_path+"p_residue_backbone_mindist_summary.txt",mindist_analysis_path+"p_residue_mindist_summary.txt",analysis_path+"p_se_rmsf.txt",analysis_path+"p_rmsd.txt",other_analysis_path+"rms-ahx.txt",other_analysis_path+"radius.txt",other_analysis_path+"len-ahx.txt",other_analysis_path+"twist.txt",other_analysis_path+"phi.txt",other_analysis_path+"psi.txt",other_analysis_path+"estimated_solvation_energies.txt",other_analysis_path+"area.txt",other_analysis_path+"area_per_res.txt",other_analysis_path+"volume_and_density.txt",depth_path+"p_fullpep_depth.txt"];
analysis_file_path = [bfe_path+"p_bfe_summary.txt",depth_path+"p_fullpep_depth.txt",depth_path+"p_residue_depth_summary.txt"];

analysis_object_constructer_dictionary = dictionary(analysis_name,analysis_file_path);

%% analysis - run once to load all data



BFE_comparison_data = construct_fulldata_for_BFE(all_sim_names_sorted,peptides_per_sim,analysis_object_constructer_dictionary);
% full_data_struct = construct_fulldata(all_sim_names_sorted,peptides_per_sim,analysis_object_constructer_dictionary);




%% analysis - Repeatedly run this section while messing with data
clearvars -except full_data_struct BFE_comparison_data;
close all;

load("batlow.mat");
residue_one_letter_code = {'T','R','S','S','R','A','G','L','Q','W','P','V','G','R','V','H','R','L','L','R','K'};
% analysis_name = {"BFE",'BFE_components','Dipole_of_helix','Radius_of_gyration','Hbond_to_memb','Hbond_to_peps','Hbond_to_water','Hbond_to_itself','Backbone_Mindist','Sidechain_Mindist','RMSD','RMS_of_Helix_from_ideal_alpha_helix','Radius_of_Helix','Length_of_Helix','Average_helical_angle','Average_Phi_angle','Average_Psi_angle','GROMACS_estimated_solvation_energies','Solvent_accessible_area','Volume_and_density'};
analysis_name = {"BFE","fullpep_depth"};

radius_of_gyration_variables = {"RoG","Rog x","Rog y","Rog z"};
volume_and_density_variables = {"Volumne (nm3)", 'Density (g/l)'};
BFE_components_variables = {"LDP","RDP","Ave INT"};
analysis_name_for_graph = {"BFE",'LDP','RDP','Ave INT','Dipole of helix',"RoG","Rog x","Rog y","Rog z",'Hbond to memb','Hbond to peps','Hbond to water','Hbond to itself','RMSD','RMS of Helix from ideal alpha helix','Radius of Helix','Length of Helix','Average helical angle','Average Phi angle','Average Psi angle','GROMACS estimated solvation energies','Solvent accessible area',"Volumne (nm3)", 'Density (g/l)'};
sim_name_iterator = only_sim_names();








correlation_coefficients_back = [];
correlation_coefficients_side = [];
correlation_coefficients_other =[];
p_values_of_corrcoef_back = [];
p_values_of_corrcoef_side = [];
p_values_of_corrcoef_other = [];


for sim = 1:length(sim_name_iterator)
    sim_name = sim_name_iterator{sim};
    sims = BFE_comparison_data(startsWith([BFE_comparison_data.simulation],sim_name_iterator{sim}+"_sim"));
    [column_data,column_idx]= compile_column_matrix(analysis_name,sims);
    [sorted_data,sorted_data_index] = sortrows(column_data(:,:));
    [sorted_data2,sorted_data_index2] = sortrows(column_data(:,2:end));
    [sorted_data3,sorted_data_index3] = sortrows(column_data(:,3:end));
    [sorted_data4,sorted_data_index4] = sortrows(column_data(:,4:end));
    

    % figure('Theme','Light');
    % scatter(1:length(column_data),column_data(:,1));
    % title(append('unordered data for ',sim_name));
    % xlabel('Snapshot count');
    % xticks([0 101 202 303 404 505 606 707 808 909 1010 1111 1212 1313 1414 1515 1616 1717 1818 1919 2020 2121 2222 2323 2424])
    % ylabel('BFE');
    % grid on;
    % ax = gca;
    % ax.YGrid = 'off';
    % 
    %
     
    % % Sorting on differetn componenets of the binding
    % figure('Theme','Light');
    % scatter(1:length(sorted_data),sorted_data(:,1));
    % title(append('Rank ordering all data for ',sim_name));
    % xlabel('Snapshot');
    % ylabel('BFE');
    % 
    % figure('Theme','Light');
    % scatter(1:length(sorted_data),sorted_data2(:,1));
    % title(append('Rank ordering all data for ',sim_name));
    % xlabel('Snapshot');
    % ylabel('LDP');
    % 
    % figure('Theme','Light');
    % scatter(1:length(sorted_data),sorted_data3(:,1));
    % title(append('Rank ordering all data for ',sim_name));
    % xlabel('Snapshot');
    % ylabel('RDP');
    % 
    %  figure('Theme','Light');
    % scatter(1:length(sorted_data),sorted_data4(:,1));
    % title(append('Rank ordering all data for ',sim_name));
    % xlabel('Snapshot');
    % ylabel('INT');


    rank_order_means = split_and_mean(sorted_data);
    % 
    % figure('Theme','Light');
    % scatter(1:length(rank_order_means(:,1)),rank_order_means(:,1),'filled');
    % title(append('Rank ordering means (101 snapshots) for ',sim_name));
    % xlabel('Groups of 101 snapshots');
    % ylabel('Mean BFE');
    % 
    % figure('Theme','Light');
    % scatter(1:length(rank_order_means(:,1)),rank_order_means(:,7),'filled');
    % title(append('Rank ordering means (101 snapshots) for ',sim_name));
    % xlabel('Groups of 101 snapshots based on BFE ranking');
    % ylabel('Mean Hbonding to membrane');
    % 
    % figure('Theme','Light');
    % scatter(rank_order_means(:,7),rank_order_means(:,1),'filled');
    % title(append('Hbonding to membrane and BFE correlation for ',sim_name));
    % xlabel('Corresponding Means - Hbonding to membrane');
    % ylabel('Means of Rank ordered BFE');
    % 
    % figure('Theme','Light');
    % scatter(rank_order_means(:,7),rank_order_means(:,1),'filled');
    % title(append('Hbonding to membrane and BFE correlation for ',sim_name));
    % xlabel('Corresponding Means - Hbonding to membrane');
    % ylabel('Means of Rank ordered BFE');
    % 
    % figure('Theme','Light');
    % scatter(rank_order_means(:,7),rank_order_means(:,1),'filled');
    % title(append('Hbonding to membrane and BFE correlation for ',sim_name));
    % xlabel('Corresponding Means - Hbonding to membrane');
    % ylabel('Means of Rank ordered BFE');
    % 
    % figure('Theme','Light');
    % scatter(column_data(:,7),column_data(:,1));
    % title(append('unordered raw data for ',sim_name));
    % xlabel('Hbonds to membrane');
    % ylabel('BFE');
    

    % phi ps
    % figure('Theme','Light');
    % scatter(column_data(:,58),column_data(:,59));
    % title(append('unordered raw data for ',sim_name));
    % xlabel('Phi');
    % ylabel('Psi');
    % xlim([-180 180])
    % ylim([-180 180])
    % 
    % figure('Theme','Light');
    % scatter(rank_order_means(:,58),rank_order_means(:,59));
    % title(append('unordered raw data for ',sim_name));
    % xlabel('Phi');
    % ylabel('Psi');
    % xlim([-180 180])
    % ylim([-180 180])


    % all variable correlations
    [ree,pee] = corrcoef(rank_order_means);

    current_sim_BFE_correlation_with_each_residue_back = ree(1,column_idx("Backbone_Mindist_start"):column_idx("Backbone_Mindist_end"));
    correlation_coefficients_back = [correlation_coefficients_back;current_sim_BFE_correlation_with_each_residue_back];
    p_values_of_corrcoef_back = [p_values_of_corrcoef_back;pee(1,column_idx("Backbone_Mindist_start"):column_idx("Backbone_Mindist_end"))];

    current_sim_BFE_correlation_with_each_residue_side = ree(1,column_idx("Sidechain_Mindist_start"):column_idx("Sidechain_Mindist_end"));
    correlation_coefficients_side = [correlation_coefficients_side;current_sim_BFE_correlation_with_each_residue_side];
    p_values_of_corrcoef_side = [p_values_of_corrcoef_side;pee(1,column_idx("Sidechain_Mindist_start"):column_idx("Sidechain_Mindist_end"))];
    

    N = false(size(ree));
    N(1,(column_idx("Backbone_Mindist_start"):column_idx("Sidechain_Mindist_end"))) = true;
    everything_else_index = ~N(1,:);
    current_sim_BFE_correlation_with_other_data = ree(1,everything_else_index);
    correlation_coefficients_other = [correlation_coefficients_other;current_sim_BFE_correlation_with_other_data];
    % p_values_of_corrcoef_other = [p_values_of_corrcoef_back;pee(1,everything_else_index)];
    


    % %single sim backbone mindist
    % figure('Theme','Light');
    % h = heatmap(current_sim_BFE_correlation_with_each_residue_back,'XDisplayLabels',residue_one_letter_code,'Colormap', batlow);
    % h.Title = append('Rank order mean backbone minimum distance to membrane correlation to BFE for ',sim_name);
    % h.XLabel = 'Residue';
    % h.YLabel = append(sim_name,' peptides');
    % 
    % %
    % figure('Theme','Light');
    % h = heatmap(current_sim_BFE_correlation_with_each_residue_side,'XDisplayLabels',residue_one_letter_code);
    % h.Title = append('Rank order mean sidechain minimum distance to membrane correlation to BFE for ',sim_name);
    % h.XLabel = 'Residue';
    % h.YLabel = append(sim_name,' peptides');
    % 
    % %
    % figure('Theme','Light');
    % h = heatmap(current_sim_BFE_correlation_with_other_data,'XDisplayLabels',analysis_name_for_graph,'Colormap', batlow);
    % h.Title = append('Rank order mean of BFE correlated to other analysis for ',sim_name);
    % h.XLabel = 'Analysis';
    % h.YLabel = append(sim_name,' peptides');

end

%all sims - backbone mindist
figure('Theme','Light');
h = heatmap(correlation_coefficients_back,'XDisplayLabels',residue_one_letter_code,'YDisplayLabels',sim_name_iterator,'Colormap', batlow);
h.Title = 'Cumulative summary of backbone residues minimum distance to membrane - correlation to BFE';
h.XLabel = 'WT Residues';
h.YLabel = 'Simulation';

%all sims - sidechain mindist
figure('Theme','Light');
h = heatmap(correlation_coefficients_side,'XDisplayLabels',residue_one_letter_code,'YDisplayLabels',sim_name_iterator,'Colormap', batlow);
h.Title =  'Cumulative summary of sidechain residues minimum distance to membrane - correlation to BFE';
h.XLabel = 'WT Residues';
h.YLabel = 'Simulation';

%all sims - shortened backbone mindist
figure('Theme','Light');
h = heatmap(correlation_coefficients_back(:,[2 5 14 17 20 21]),'XDisplayLabels',residue_one_letter_code(:,[2 5 14 17 20 21]),'YDisplayLabels',sim_name_iterator,'Colormap', batlow);
h.Title = 'Cumulative summary of backbone residues minimum distance to membrane - correlation to BFE';
h.XLabel = 'WT Residues';
h.YLabel = 'Simulation';

%all sims - shortened sidechain mindist
figure('Theme','Light');
h = heatmap(correlation_coefficients_side(:,[2 5 14 17 20 21]),'XDisplayLabels',residue_one_letter_code(:,[2 5 14 17 20 21]),'YDisplayLabels',sim_name_iterator,'Colormap', batlow);
h.Title =  'Cumulative summary of sidechain residues minimum distance to membrane - correlation to BFE';
h.XLabel = 'WT Residues';
h.YLabel = 'Simulation';

%all sims - other analysis
figure('Theme','Light');
h = heatmap(correlation_coefficients_other,'XDisplayLabels',analysis_name_for_graph,'YDisplayLabels',sim_name_iterator,'Colormap', batlow);
h.Title = append('Cumulative Graph of Rank order of BFE means correlated to other analysis');
h.XLabel = 'Analysis';
h.YLabel = append('Simulation');

%experimental sims - shortend other analysis
figure('Theme','Light');
h = heatmap(correlation_coefficients_other([1 3 5 7 9 13 15],[1 2 3 4 21]),'XDisplayLabels',analysis_name_for_graph(:,[1 2 3 4 21]),'YDisplayLabels',sim_name_iterator([1 3 5 7 9 13 15]),'Colormap', batlow);
h.Title = append('Cumulative Graph of Rank order of BFE means correlated to other analysis');
h.XLabel = 'Analysis';
h.YLabel = append('Simulation');





%% Workflow on snapshots to analyze
clearvars -except full_data_struct BFE_comparison_data;
% find a way to compile characteristic structures for every important
% snapshot. May include finding mean extreme(first and last structure) and
% non-extreme extremes (the linear portion of the range of bfe)

% 1. select snapshot

% 2. extract snapshots from movies


load("batlow.mat");
residue_one_letter_code = {'T','R','S','S','R','A','G','L','Q','W','P','V','G','R','V','H','R','L','L','R','K'};
analysis_name = {'BFE','BFE_components','Dipole_of_helix','Radius_of_gyration','Hbond_to_memb','Hbond_to_peps','Hbond_to_water','Hbond_to_itself','Backbone_Mindist','Sidechain_Mindist','RMSD','RMS_of_Helix_from_ideal_alpha_helix','Radius_of_Helix','Length_of_Helix','Average_helical_angle','Average_Phi_angle','Average_Psi_angle','GROMACS_estimated_solvation_energies','Solvent_accessible_area','Volume_and_density','simulation','peptide','time','frame_number'};
radius_of_gyration_variables = {'RoG','Rog x','Rog y','Rog z'};
volume_and_density_variables = {'Volumne (nm3)', 'Density (g/l)'};
BFE_components_variables = {'LDP','RDP','Ave INT'};
analysis_name_for_graph = {"BFE",'LDP','RDP','Ave INT','Dipole of helix',"RoG","Rog x","Rog y","Rog z",'Hbond to memb','Hbond to peps','Hbond to water','Hbond to itself','RMSD','RMS of Helix from ideal alpha helix','Radius of Helix','Length of Helix','Average helical angle','Average Phi angle','Average Psi angle','GROMACS estimated solvation energies','Solvent accessible area',"Volumne (nm3)", 'Density (g/l)'};
sim_name_iterator = only_sim_names();


mkdir("characteristic_structures")
sidechain_min = {'S1','S2','S3','S4','S5','S6','S7','S8','S9','S10','S11','S12','S13','S14','S15','S16','S17','S18','S19','S20','S21'};
backbone_min = {'B1','B2','B3','B4','B5','B6','B7','B8','B9','B10','B11','B12','B13','B14','B15','B16','B17','B18','B19','B20','B21'};
print_analysis_name = [{'BFE'},BFE_components_variables,{'Dipole_of_helix'},radius_of_gyration_variables,{'Hbond_to_memb','Hbond_to_peps','Hbond_to_water','Hbond_to_itself'},backbone_min,sidechain_min,{'RMSD','RMS_of_Helix_from_ideal_alpha_helix','Radius_of_Helix','Length_of_Helix','Average_helical_angle','Average_Phi_angle','Average_Psi_angle','GROMACS_estimated_solvation_energies','Solvent_accessible_area'},volume_and_density_variables];
print_frame_names = {'simulation','peptide','time','frame_number','representative_percentage'};



pca_x = [];
pca_y = [];
percent_explained = [];
grouper = [];
print_analysis_name(:,[2,3,4,60,61,62,66]) = [];

for sim = 1:length(sim_name_iterator)
    sim_name = sim_name_iterator{sim};
    sims = BFE_comparison_data(startsWith([BFE_comparison_data.simulation],sim_name_iterator{sim}+"_sim"));
    [column_data,column_idx]= compile_column_matrix(analysis_name,sims);

    %have to sort seperatly so it's sill a double array and not a string
    frame_information = column_data(:,[column_idx("simulation") column_idx("peptide") column_idx("time") column_idx("frame_number")]);
    neumeric_column_data = str2double(column_data(:,1:column_idx("simulation")-1));
    [sorted_data,sorted_data_index] = sortrows(neumeric_column_data);
    sorted_frame_information = frame_information(sorted_data_index,:);

    %for qq plot
    qq_plot_BFE = sorted_data(:,1);
    % figure('Theme','Light');
    % qqplot(qq_plot_BFE)

    %for characteristic snapshots
    quantiles = [min(qq_plot_BFE) quantile(qq_plot_BFE,5) max(qq_plot_BFE)];
    quantile_percentages = [0 1/6 2/6 3/6 4/6 5/6 6/6].';
    quantile_data = [];
    quantile_frame = [];
    for curr_quantile = 1:numel(quantiles)
        quant = quantiles(curr_quantile);
        [~,row] = min(abs(qq_plot_BFE-quant));
        quantile_data = [quantile_data;sorted_data(row,:)];
        quantile_frame = [quantile_frame;sorted_frame_information(row,:)];
    end

    quantile_frame = [quantile_frame num2str(quantile_percentages,'%.5f')];

    % saving data
    % mkdir("characteristic_structures/"+sim_name)
    % quantile_data_table = array2table(quantile_data,'VariableNames',print_analysis_name);
    % quantile_frame_table = array2table(quantile_frame,'VariableNames',print_frame_names);
    % writetable(quantile_data_table,"characteristic_structures/"+sim_name+"/quantile_data.csv")
    % writetable(quantile_frame_table,"characteristic_structures/"+sim_name+"/quantile_frames.csv")

    % sorted_data(:,[1,2,3,4,60,61,62,66]) = [];
    sorted_data(:,[2,3,4,60,61,62,66]) = [];
    [coeff,score,latent,tsquared,explained,mu] = pca(sorted_data);
    pca_x = [pca_x;score(:,1)];
    pca_y = [pca_y;score(:,2)];
    pca_y2 = sorted_data(:,1);
    percent_explained = [percent_explained,explained([1 2 3])];
    grouper = [grouper,repelem({sim_name_iterator{sim}},length(sorted_data(:,1)))];

    % figure('Theme','Light');
    % scatter(score(:,1),score(:,2),'.')

    figure('Theme','Light','WindowStyle', 'normal');
    biplot(coeff(:,1:2),'VarLabels',print_analysis_name)
   
end
figure('Theme','Light');
gscatter(pca_x,pca_y,grouper.')






%lasso regression for variable selection
    % [B,FitInfo] = lasso(sorted_data(:,2:end),sorted_data(:,1) ,CV=10 ,PredictorNames=print_analysis_name(:,2:end));
    % idxLambdaMinMSE = FitInfo.IndexMinMSE;
    % minMSEModelPredictors = FitInfo.PredictorNames(B(:,idxLambdaMinMSE)~=0)
    % lassoPlot(B,FitInfo,PlotType="CV");
    % legend("show")
    %

%PCA regression and variable analysis
    % [XL,yl,XS,YS,beta,PCTVAR,MSE,stats] = plsregress(sorted_data,pca_y2,10);
    % W0 = stats.W ./ sqrt(sum(stats.W.^2,1));
    % p = size(XL,1);
    % sumSq = sum(XS.^2,1).*sum(yl.^2,1);
    % vipScore = sqrt(p* sum(sumSq.*(W0.^2),2) ./ sum(sumSq,2));
    % indVIP = find(vipScore >= 1);
    % scatter(1:length(vipScore),vipScore,'x')
    % hold on
    % scatter(indVIP,vipScore(indVIP),'rx')
    % plot([1 length(vipScore)],[1 1],'--k')
    % hold off
    % axis tight
    % xlabel('Predictor Variables')
    % ylabel('VIP Scores')

%%  LOOKING at average RMSFsss


wt_sim_iterator = {"wt_sim1","wt_sim2","wt_sim3","wt_sim4","wt_sim5","wt_sim6","t1r_sim1","t1r_sim2","t1r_sim3","q9r_sim1","q9r_sim2","q9r_sim3","l18r_sim1","l18r_sim2","l18r_sim3","t1r_a6r_l8r_sim1","t1r_a6r_l8r_sim2","t1r_a6r_l8r_sim3"};
wt_name_iterator = only_sim_names();
full_rmsf = [];

for sim = 1:length(wt_sim_iterator)
    sim_name = wt_sim_iterator{sim};
    sims = BFE_comparison_data(startsWith([BFE_comparison_data.simulation],wt_sim_iterator{sim}));
    rmsf_happy = {sims(1:end).RMSF};
    array_yummy = cell2mat(rmsf_happy);
    RMSF_yummy = array_yummy(:,[2,4,6,8]);
    mean_RMSF_yummy = mean(RMSF_yummy,2);
    full_rmsf = [full_rmsf,mean_RMSF_yummy];

end

wt_rmsf = mean(full_rmsf(:,1:6),2);
t1r_rmsf = mean(full_rmsf(:,7:9),2);
q9r_rmsf = mean(full_rmsf(:,10:12),2);
l18r_rmsf = mean(full_rmsf(:,13:15),2);
triple_rmsf = mean(full_rmsf(:,16:18),2);

plot(wt_rmsf);
hold on;
plot(t1r_rmsf);
hold on;
plot(q9r_rmsf);
hold on;
plot(l18r_rmsf);
hold on;
plot(triple_rmsf);
hold on;
legend("wt_rmsf","t1r_rmsf","q9r_rmsf","l18r_rmsf","triple_rmsf")

%% easier

sim_name_iterator = only_sim_names();
full_rmsf = [];

for sim = 1:length(sim_name_iterator)
    sim_name = sim_name_iterator{sim};
    sims = BFE_comparison_data(startsWith([BFE_comparison_data.simulation],sim_name_iterator{sim}+"_sim"));
        
    
    rmsf_happy = {sims(1:end).RMSF};
    array_yummy = cell2mat(rmsf_happy);
    RMSF_yummy = array_yummy(:, 2:2:length(array_yummy(1,:)) );
    mean_RMSF_yummy = mean(RMSF_yummy,2);
    mean_RMSF_yummy = mean(mean_RMSF_yummy)
    scatter(sim,mean_RMSF_yummy)
    hold on;

end
legend(sim_name_iterator(:,1:end))

%% easier

sim_name_iterator = only_sim_names();
full_rmsf = [];

for sim = 1:length(sim_name_iterator)
    sim_name = sim_name_iterator{sim};
    sims = BFE_comparison_data(startsWith([BFE_comparison_data.simulation],sim_name_iterator{sim}+"_sim"));


    rmsf_happy = {sims(1:end).fullpep_depth};

    array_yummy = cell2mat(rmsf_happy);
    array_yummy = array_yummy(:,4:4:end);
    RMSF_yummy = array_yummy(:, 4:5:length(array_yummy(1,:)) );
    mean_RMSF_yummy = mean(RMSF_yummy,1);
    mean_mean_rg = mean(mean_RMSF_yummy);
    ste_mean_rg = std(mean_RMSF_yummy)/sqrt(length(mean_RMSF_yummy));
    errorbar(sim,mean_mean_rg,ste_mean_rg,'Marker','.',MarkerSize=20)
    hold on;

end
% xticklabels(sim_name_iterator)
legend(sim_name_iterator)

%% easier

sim_name_iterator = only_sim_names();
full_rmsf = [];

for sim = 1:length(sim_name_iterator)
    sim_name = sim_name_iterator{sim};
    sims = BFE_comparison_data(startsWith([BFE_comparison_data.simulation],sim_name_iterator{sim}+"_sim"));


    rmsf_happy = {sims(1:end).BFE_components};
    array_yummy = cell2mat(rmsf_happy);
    RMSF_yummy = array_yummy(:, 3:3:length(array_yummy(1,:)) );
    mean_RMSF_yummy = mean(RMSF_yummy,1);
    meadian_rmsf_yummy = median(mean_RMSF_yummy(:));
    mean_mean_rg = mean(mean_RMSF_yummy);
    ste_mean_rg = std(mean_RMSF_yummy)/sqrt(length(mean_RMSF_yummy));
    errorbar(sim,mean_mean_rg,ste_mean_rg,'Marker','.',MarkerSize=20)
    hold on;
    % violinplot(sim,RMSF_yummy(:))

end
% xticklabels(sim_name_iterator)
legend(sim_name_iterator)



%% all full depth measures

sim_name_iterator = only_sim_names();
full_rmsf = [];
figure();

for sim = 1:length(sim_name_iterator)
    sim_name = sim_name_iterator{sim};
    sims = BFE_comparison_data(startsWith([BFE_comparison_data.simulation],sim_name_iterator{sim}+"_sim"));


    rmsf_happy = {sims(1:end).fullpep_depth};

    array_yummy = cell2mat(rmsf_happy);
    array_yummy = array_yummy(:,4:4:end);
    RMSF_yummy = array_yummy(:, 4:5:length(array_yummy(1,:)) );
    mean_RMSF_yummy = mean(RMSF_yummy,1);
    mean_mean_rg = mean(mean_RMSF_yummy);
    ste_mean_rg = std(mean_RMSF_yummy)/sqrt(length(mean_RMSF_yummy));
    errorbar(sim,mean_mean_rg,ste_mean_rg,'Marker','.',MarkerSize=20)
    hold on;

end
% xticklabels(sim_name_iterator)
legend(sim_name_iterator)

hold off;
figure();
% sim_name_iterator = [sim_name_iterator(1),sim_name_iterator(3)];
sim_name_iterator = [sim_name_iterator(15)];
% sim_name_iterator = [sim_name_iterator(15)];



for sim = 1:length(sim_name_iterator)
    sim_name = sim_name_iterator{sim};
    sims = BFE_comparison_data(startsWith([BFE_comparison_data.simulation],sim_name_iterator{sim}+"_sim"));
    


    [column_data,column_idx]= compile_column_matrix(analysis_name,sims);
    new_column_data = [column_data(:,4),column_data(:,1)];
    [sorted_data,sorted_data_index] = sortrows(new_column_data(:,:));
    

    % plot(sorted_data(:,1),movmean(sorted_data(:,2),20))
    hold on;
    scatter(sorted_data(:,1),sorted_data(:,2))
    set(gca, 'XDir', 'reverse');
    hold on;
end


%% Per residue pca analysis
sim_name_iterator = only_sim_names();
sim_name_iterator = [sim_name_iterator(1)];
wtresidue_one_letter_code = {'T','R','S','S','R','A','G','L','Q','W','P','V','G','R','V','H','R','L','L','R','K'};
tripleresidue_one_letter_code = {'1R','2R','3S','4S','5R','6R','7G','8R','9Q','10W','11P','12V','13G','14R','15V','16H','17R','18L','19L','20R','21K'};


for sim = 1:length(sim_name_iterator)
    sim_name = sim_name_iterator{sim};
    sims = BFE_comparison_data(startsWith([BFE_comparison_data.simulation],sim_name_iterator{sim}+"_sim"));

    [column_data,column_idx]= compile_column_matrix(analysis_name,sims);
    all_residue_data = column_data(:,[column_idx("all_residue_depth_start")]:[column_idx("all_residue_depth_end")]);
    abs_ar_data = abs(all_residue_data);
    bfe_data = column_data(:,1);
    full_pep_depth = column_data(:,2);

    

    %1. try an autocorrelation 
    %2. try 



    % Looking at the raw distributions
    % tiledlayout(5,5)
    % for res = 1:21
    %     data_thang = [all_residue_data(:,res), bfe_data];
    %     [sorted_data,sorted_data_index] = sortrows(data_thang);
    %     scatter(sorted_data(:,1),sorted_data(:,2),'.')
    %     % set(gca, 'XDir', 'reverse');
    %     nexttile
    % end

    
    %feature extraction
    % correlations = corrcoef(abs_ar_data);


    %pca
    [coeff,score,latent,tsquared,explained,mu] = pca(abs_ar_data);
    biplot(coeff(:,1:2),'Scores',score(:,1:2),"VarLabels",tripleresidue_one_letter_code)
    pca_bfe = [score(:,1),bfe_data];
    [sorted_data,sorted_data_index] = sortrows(pca_bfe);

    %mlr
    [b,bint,r,rint,stats] = regress(bfe_data,abs_ar_data);

    % scatter3(score(:,1),score(:,2),bfe_data)
    % figure()
    % scatter(sorted_data(:,1),sorted_data(:,2))
    plot(movmean(sorted_data(:,1),500),sorted_data(:,2))

end