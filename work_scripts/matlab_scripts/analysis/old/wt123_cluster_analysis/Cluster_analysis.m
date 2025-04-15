%% general settings %%

clear;

blue = [57 106 177]./255;
red = [204 37 41]./255;
black = [83 81 84]./255;
green = [62 150 81]./255;
brown = [146 36 40]./255;
purple = [107 76 154]./255;


%% Backbone mindist and binding free energy


%need to set up the y-axis to be binding free energy

%need to match the snapshot to the minimum distance snapshot and
%make that the x axis

%plot them against eachother


%do a backbone and a side chain plot

%set(0, 'DefaultFigureVisible', 'off')
run("../1wt_analysis/analysis.m")
run("../wt123_bindingfreeenergy/binding_free_engergy.m");
%set(0, 'DefaultFigureVisible', 'on')



