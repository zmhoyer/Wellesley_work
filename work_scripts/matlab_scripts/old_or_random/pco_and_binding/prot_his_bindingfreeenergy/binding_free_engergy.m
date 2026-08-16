%% general settings %%

blue = [57 106 177]./255;
red = [204 37 41]./255;
black = [83 81 84]./255;
green = [62 150 81]./255;
brown = [146 36 40]./255;
purple = [107 76 154]./255;

peps_per_sim = 4;
num_of_sims = 3;
normally_dist = [];

%% binding free energy WT1 :)

sim1_means = [];

sim1_1p = load("sim1_p1.txt");
normally_dist(end+1) = chi2gof(sim1_1p);
sim1_means(end+1) = mean(sim1_1p);

sim1_2p = load("sim1_p2.txt");
normally_dist(end+1) = chi2gof(sim1_2p);
sim1_means(end+1) = mean(sim1_2p);

sim1_3p = load("sim1_p3.txt");
normally_dist(end+1) = chi2gof(sim1_3p);
sim1_means(end+1) = mean(sim1_3p);

sim1_4p = load("sim1_p4.txt");
normally_dist(end+1) = chi2gof(sim1_4p);
sim1_means(end+1) = mean(sim1_4p);



%[table,chi2,p] = crosstab(wt1_1p,wt1_2p,wt1_3p,wt1_4p)

%combind_array_wt1 = cat(1,wt1_1p,wt1_2p,wt1_3p,wt1_4p); % old way with no
%account for the change in population sizes.
combind_array_sim1 = (sim1_means.');
data_mean_sim1 = mean(combind_array_sim1,1);
data_std_sim1 = std(combind_array_sim1,1);
data_ste_sim1 = data_std_sim1/sqrt(peps_per_sim);

fprintf(data_mean_sim1+" ± "+data_std_sim1+"\n")



%% binding free energy WT2 :)

sim2_means = [];

sim2_1p = load("sim2_p1.txt");
normally_dist(end+1) = chi2gof(sim2_1p);
sim2_means(end+1) = mean(sim2_1p);

sim2_2p = load("sim2_p2.txt");
normally_dist(end+1) = chi2gof(sim2_2p);
sim2_means(end+1) = mean(sim2_2p);

sim2_3p = load("sim2_p3.txt");
normally_dist(end+1) = chi2gof(sim2_3p);
sim2_means(end+1) = mean(sim2_3p);

sim2_4p = load("sim2_p4.txt");
normally_dist(end+1) = chi2gof(sim2_4p);
sim2_means(end+1) = mean(sim2_4p);



%[table,chi2,p] = crosstab(wt2_1p,wt2_2p,wt2_3p,wt2_4p) 

%combind_array_wt2 = cat(1,wt2_1p,wt2_2p,wt2_3p,wt2_4p); % old way with no
%account for the change in population sizes.
combind_array_sim2 = (sim2_means.');
data_mean_sim2 = mean(combind_array_sim2,1);
data_std_sim2 = std(combind_array_sim2,1);
data_ste_sim2 = data_std_sim2/sqrt(peps_per_sim);

fprintf(data_mean_sim2+" ± "+data_std_sim2+"\n")

%% binding free energy WT3 :)


sim3_means = [];

sim3_1p = load("sim3_p1.txt");
normally_dist(end+1) = chi2gof(sim3_1p);
sim3_means(end+1) = mean(sim3_1p);

sim3_2p = load("sim3_p2.txt");
normally_dist(end+1) = chi2gof(sim3_2p);
sim3_means(end+1) = mean(sim3_2p);

sim3_3p = load("sim3_p3.txt");
normally_dist(end+1) = chi2gof(sim3_3p);
sim3_means(end+1) = mean(sim3_3p);

sim3_4p = load("sim3_p4.txt");
normally_dist(end+1) = chi2gof(sim3_4p);
sim3_means(end+1) = mean(sim3_4p);



%[table,chi2,p] = crosstab(wt1_1p,wt1_2p,wt1_3p,wt1_4p)

%combind_array_wt1 = cat(1,wt1_1p,wt1_2p,wt1_3p,wt1_4p); % old way with no
%account for the change in population sizes.
combind_array_sim3 = (sim3_means.');
data_mean_sim3 = mean(combind_array_sim3,1);
data_std_sim3 = std(combind_array_sim3,1);
data_ste_sim3 = data_std_sim3/sqrt(peps_per_sim);

fprintf(data_mean_sim3+" ± "+data_std_sim3+"\n")

%% Three simulation combined data

Total_peptides = num_of_sims * peps_per_sim;

combind_array_tot = cat(2,sim1_means,sim2_means,sim3_means).';
data_mean = mean(combind_array_tot,1);
data_std = std(combind_array_tot,1);
data_ste = data_std/sqrt(Total_peptides);

fprintf(data_mean+" ± "+data_ste+"\n")


%% testing normal distribution

%to look and make sure the observations are normally distributed, the
%normally distributed file should contain a 0 meaning the data set was
%normally distributed. If it's a one it means it wasn't normally
%distributed according to a p-value of 0.05