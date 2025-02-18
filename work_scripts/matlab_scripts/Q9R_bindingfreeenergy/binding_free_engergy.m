%% general settings %%


blue = [57 106 177]./255;
red = [204 37 41]./255;
black = [83 81 84]./255;
green = [62 150 81]./255;
brown = [146 36 40]./255;
purple = [107 76 154]./255;

peptides_per_sim = 4;
num_of_sims = 3;
normally_dist = [];

%% binding free energy WT1 :)

all_Q9R_data_points = [];
all_Q9R_means = [];

for sim = num_of_sims:-1:1.0

    for pep = peptides_per_sim:-1:1.0

        Q9R_bfe_data = load(pep+"p_Q9R_sim"+sim+".txt");
        all_Q9R_data_points = [all_Q9R_data_points Q9R_bfe_data];
        Q9R_bfe_mean = mean(Q9R_bfe_data);
        all_Q9R_means(end+1) = Q9R_bfe_mean;

    end
end

all_Q9R_means = all_Q9R_means.';
Q9R_mean = mean(all_Q9R_means);




%{
wt1_means = [];

wt1_1p = load("1wt_1p_bfe.txt");
normally_dist(end+1) = chi2gof(wt1_1p);
wt1_means(end+1) = mean(wt1_1p);

wt1_2p = load("1wt_2p_bfe.txt");
normally_dist(end+1) = chi2gof(wt1_2p);
wt1_means(end+1) = mean(wt1_2p);

wt1_3p = load("1wt_3p_bfe.txt");
normally_dist(end+1) = chi2gof(wt1_3p);
wt1_means(end+1) = mean(wt1_3p);

wt1_4p = load("1wt_4p_bfe.txt");
normally_dist(end+1) = chi2gof(wt1_4p);
wt1_means(end+1) = mean(wt1_4p);



%[table,chi2,p] = crosstab(wt1_1p,wt1_2p,wt1_3p,wt1_4p)

%combind_array_wt1 = cat(1,wt1_1p,wt1_2p,wt1_3p,wt1_4p); % old way with no
%account for the change in population sizes.
combind_array_wt1 = (wt1_means.');
data_mean_wt1 = mean(combind_array_wt1,1);
data_std_wt1 = std(combind_array_wt1,1);
data_ste_wt1 = data_std_wt1/sqrt(peps_per_sim);

fprintf(data_mean_wt1+" ± "+data_std_wt1+"\n")



%% binding free energy WT2 :)

wt2_means = [];

wt2_1p = load("2wt_1p_bfe.txt");
normally_dist(end+1) = chi2gof(wt2_1p);
wt2_means(end+1) = mean(wt2_1p);

wt2_2p = load("2wt_2p_bfe.txt");
normally_dist(end+1) = chi2gof(wt2_2p);
wt2_means(end+1) = mean(wt2_2p);

wt2_3p = load("2wt_3p_bfe.txt");
normally_dist(end+1) = chi2gof(wt2_3p);
wt2_means(end+1) = mean(wt2_3p);

wt2_4p = load("2wt_4p_bfe.txt");
normally_dist(end+1) = chi2gof(wt2_4p);
wt2_means(end+1) = mean(wt2_4p);



%[table,chi2,p] = crosstab(wt2_1p,wt2_2p,wt2_3p,wt2_4p) 

%combind_array_wt2 = cat(1,wt2_1p,wt2_2p,wt2_3p,wt2_4p); % old way with no
%account for the change in population sizes.
combind_array_wt2 = (wt2_means.');
data_mean_wt2 = mean(combind_array_wt2,1);
data_std_wt2 = std(combind_array_wt2,1);
data_ste_wt2 = data_std_wt2/sqrt(peps_per_sim);

fprintf(data_mean_wt2+" ± "+data_std_wt2+"\n")

%% binding free energy WT3 :)


wt3_means = [];

wt3_1p = load("3wt_1p_bfe.txt");
normally_dist(end+1) = chi2gof(wt3_1p);
wt3_means(end+1) = mean(wt3_1p);

wt3_2p = load("3wt_2p_bfe.txt");
normally_dist(end+1) = chi2gof(wt3_2p);
wt3_means(end+1) = mean(wt3_2p);

wt3_3p = load("3wt_3p_bfe.txt");
normally_dist(end+1) = chi2gof(wt3_3p);
wt3_means(end+1) = mean(wt3_3p);

wt3_4p = load("3wt_4p_bfe.txt");
normally_dist(end+1) = chi2gof(wt3_4p);
wt3_means(end+1) = mean(wt3_4p);



%[table,chi2,p] = crosstab(wt1_1p,wt1_2p,wt1_3p,wt1_4p)

%combind_array_wt1 = cat(1,wt1_1p,wt1_2p,wt1_3p,wt1_4p); % old way with no
%account for the change in population sizes.
combind_array_wt3 = (wt3_means.');
data_mean_wt3 = mean(combind_array_wt3,1);
data_std_wt3 = std(combind_array_wt3,1);
data_ste_wt3 = data_std_wt3/sqrt(peps_per_sim);

fprintf(data_mean_wt3+" ± "+data_std_wt3+"\n")

%% Three simulation combined data

Total_peptides = num_of_sims * peps_per_sim;

combind_array_tot = cat(2,wt1_means,wt2_means,wt3_means).';
data_mean = mean(combind_array_tot,1);
data_std = std(combind_array_tot,1);
data_ste = data_std/sqrt(Total_peptides);

fprintf(data_mean+" ± "+data_ste+"\n")


%% testing normal distribution

%to look and make sure the observations are normally distributed, the
%normally distributed file should contain a 0 meaning the data set was
%normally distributed. If it's a one it means it wasn't normally
%distributed according to a p-value of 0.05

%}
