% Random code I liked


%% Mesh fit multiple linear regression


        % culled_singlePep_gyrate = bfe_comparison_last250(current_gyrate);
        % culled_singlePep_hbond = bfe_comparison_1000ns(current_pep_hbond);
        % 
        % X = [ones(size(culled_singlePep_hbond(:,2))) culled_singlePep_hbond(:,2) culled_singlePep_gyrate(:,2) culled_singlePep_hbond(:,2).*culled_singlePep_gyrate(:,2)];
        % b = regress(current_pep_bfe,X);
        % scatter3(culled_singlePep_hbond(:,2),culled_singlePep_gyrate(:,2),current_pep_bfe,'filled')
        % hold on
        % x1fit = min(culled_singlePep_hbond(:,2)):1:max(culled_singlePep_hbond(:,2));
        % x2fit = min(culled_singlePep_gyrate(:,2)):0.01:max(culled_singlePep_gyrate(:,2));
        % [X1FIT,X2FIT] = meshgrid(x1fit,x2fit);
        % YFIT = b(1) + b(2)*X1FIT + b(3)*X2FIT + b(4)*X1FIT.*X2FIT;
        % mesh(X1FIT,X2FIT,YFIT)
        % xlabel('Hbonds')
        % ylabel('gyration')
        % zlabel('BFE')
        % hold off










%% pca analysis %%
% 
% 
% function [eiganvalue_array,Delta_G_Matrix,bin_edge] = deltaGify(Title,varargin)
% 
%     proj2d_iterator = length(varargin);
%     eiganvalue_array = [];
%     load("batlow.mat");
% 
% 
%     for current_2dproj = 1:proj2d_iterator
% 
%         if length(varargin{current_2dproj}) > 25001
%             eigenvector_1 = varargin{current_2dproj}(50000:1:100001,1);
%             eigenvector_2 = varargin{current_2dproj}(50000:1:100001,2);
%         else
%             eigenvector_1 = varargin{current_2dproj}(:,1);
%             eigenvector_2 = varargin{current_2dproj}(:,2);
%         end        
% 
% 
%         if length(eigenvector_1) > 25001
%             eigenvector_1_our_sampling = eigenvector_1(25000:250:50001);
%             eigenvector_2_our_sampling = eigenvector_2(25000:250:50001);
%         else
%             eigenvector_1_our_sampling = eigenvector_1(1:250:25001);
%             eigenvector_2_our_sampling = eigenvector_2(1:250:25001);
%         end
% 
%         bin_edge = max(abs(max(max(eigenvector_1),max(eigenvector_2))),abs(min(min(eigenvector_1),min(eigenvector_2))))+1;
%         edges = -bin_edge:0.5:bin_edge;
%         [N,Xedges,Yedges] = histcounts2(eigenvector_1,eigenvector_2,edges,edges,'Normalization','probability');
%         Delta_G_Matrix = N;
%         % max_occupancy = max(max(N));
%         % suma = sum(N,"all");
%         % max_probob = max_occupancy/sum(N,"all");
%         % this = N(10,6)/sum(N,"all");
%         % total = this/max_probob;
% 
% 
%         for current_row = 1:length(N)
%             for current_column = 1:length(N)
%                 Delta_G_Matrix(current_row,current_column) = (((298)*(-1.380649*(10^-23))*log(N(current_row,current_column)/max(max(N))))/4184)*(6.022*(10^23));
%                 %Delta_G_Matrix(current_row,current_column) = (298)*(-1.380649*(10^-23))*log((N(current_row,current_column)/sum(N,"all"))/(max_occupancy/sum(N,"all")));
%             end
%         end
% 
%         Delta_G_Matrix(isinf(Delta_G_Matrix)) = 0;
%         figure('Theme','Light');
%         colormap(batlow)
%         h = histogram2('XBinEdges',Xedges,'YBinEdges',Yedges,'BinCounts',Delta_G_Matrix,'DisplayStyle','tile','ShowEmptyBins','off');
%         hold on;
%         scatter(eigenvector_1_our_sampling,eigenvector_2_our_sampling,"red",'.','SizeData',100)
% 
%         title(Title);
%         xlabel("Projection on Eigenvector 1 (u^{1/2}nm)");
%         ylabel("Projection on Eigenvector 2 (u^{1/2}nm)");
%         colorbar
% 
% 
%     end
% end
% 
% 
% proj2d = load("2dproj.txt");
% deltaGify("Most favorable triple mutant peptide",proj2d);
% 
% full_proj2d = load("full_2dproj.txt");
% deltaGify("Most favorable triple mutant peptide - Full length",full_proj2d);
% 
% proj2d_2 = load("../h_t1r_a6r_l8r_sim1_analysis/2dproj.txt");
% deltaGify("Least favorable triple mutant peptide",proj2d_2);
% 
% 
% proj2d_3 = load("../wt_sim4_analysis/2dproj.txt");
% deltaGify("Random wildtype peptide",proj2d_3);
% 
% proj2d_4 = load("../hl18r_sim2_analysis/2dproj.txt");
% deltaGify("Translocating peptide during analysis window",proj2d_4);
% 
% full_proj2d_4 = load("../hl18r_sim2_analysis/full_2dproj.txt");
% deltaGify("Translocating peptide during analysis window - Full length",full_proj2d_4);
% 
% % hold off;
% % figure;
% % proj_1 = load("./proj.txt");
% % time = proj_1(:,1);
% % PC1 = proj_1(:,2);
% % scatter(time,PC1);