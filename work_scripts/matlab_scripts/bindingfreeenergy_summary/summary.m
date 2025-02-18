%% general settings %%

blue = [57 106 177]./255;
red = [204 37 41]./255;
black = [83 81 84]./255;
green = [62 150 81]./255;
brown = [146 36 40]./255;
purple = [107 76 154]./255;

%% data handeling %%

summary_array = [];
summary_mean = [];

run("../wt123_bindingfreeenergy/binding_free_engergy.m");
summary_array = combind_array_tot;
summary_mean = data_mean;

run("../prot_his_bindingfreeenergy/binding_free_engergy.m");
summary_array = cat(2,summary_array,combind_array_tot);
summary_mean = cat(2,summary_mean,data_mean);

run("../Q9R_bindingfreeenergy/binding_free_engergy.m")
summary_array = cat(2,summary_array,all_Q9R_means);
summary_mean = cat(2,summary_mean,Q9R_mean);





%figure settings
figure('Name','Binding Free energy summary','NumberTitle','off');
myfontsize = 15;

colors = blue;

scatter([1,2,3], summary_array, 25, colors,"filled");
ylabel('\DeltaG_{opt,elec}, kcal/mol','fontsize',myfontsize);
xlabel('Simulation','fontsize',myfontsize);
hold on
plot(summary_mean, '.r','MarkerSize',30);
hold off
ax1 = gca;

%restricts the axises to be directly up on the data and then gives them
%some centering space
axis(ax1, 'tight');
xlim(ax1, xlim(ax1) + [-1,1]*range(xlim(ax1)).* 0.5)
ylim(ax1, ylim(ax1) + [-1,1]*range(ylim(ax1)).* 0.05)
%
ax1.FontSize = myfontsize;
xticks(0:length(summary_array));
xticklabels({'','WT','HISH','Q9R',''});