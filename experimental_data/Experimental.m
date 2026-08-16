close all;
clear;

% need to fit spetra to log normal equation, eaiser to see blue shift and
% then "confirmational heterogeneity" easier to analyze width of peak as
% well

% After doing the log fitting graph, make a position width plot to see if
% there is any naturally occuring structural heterogeneity... Probably not
% useful due to a lack of other solvent analysis. BUT replicating figure 8
% may be useful for peptide mutations. can potentially use a corrected
% version of the papers baseline as a starter and then create my own later

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
        NameValueArgs.fontname = 'Helvetica' % really does nothing if using the latex interpreter. If font is an issue, change to a different interpreter or add the words in post.
        NameValueArgs.exp_name = 0
    end

    % Variables and general graph settings
    fontsize_of_your_paper = 18; %roughly equal to 12 point font in times new roman.
    xticklabel_fontsize = fontsize_of_your_paper - 0; % Can put this to -2, may not be good in all scenarios though
    legend_font_size = fontsize_of_your_paper - 3; % Can drop this to -5, also may not be good
    picturewidth = 20; % In Centimeters. Roughly 8 inches which is good for paper figures that span the width of the page
    hw_ratio = 0.65;

    set(findall(NameValueArgs.figure_name, '-property', 'Fontsize'),'Fontsize',fontsize_of_your_paper);
    set(findall(NameValueArgs.figure_name, '-property', 'Box'),'Box','off');
    set(findall(NameValueArgs.figure_name, '-property', 'Interpreter'),'Interpreter','tex'); %change to LaTeX if you're using that %%% can't change font if you do though
    set(findall(NameValueArgs.figure_name, '-property', 'TicklabelInterpreter'),'TicklabelInterpreter','tex');
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
    if NameValueArgs.exp_name ~= 0
        print(NameValueArgs.figure_name,"pictures_of_data/"+NameValueArgs.exp_name+"/"+NameValueArgs.PDF_PNG_name,'-dpdf','-vector','-fillpage')
        print(NameValueArgs.figure_name,"pictures_of_data/"+NameValueArgs.exp_name+"/"+NameValueArgs.PDF_PNG_name,'-dpng','-vector', '-r600')
    end
    print(NameValueArgs.figure_name,"pictures_of_data/"+NameValueArgs.PDF_PNG_name,'-dpdf','-vector','-fillpage')
    print(NameValueArgs.figure_name,"pictures_of_data/"+NameValueArgs.PDF_PNG_name,'-dpng','-vector', '-r600')
    


end




function [directories,files_in_first] = get_directories(current_experiments)
     
    file_contents = dir("~/wellesley/experimental_data/"+current_experiments);
    isDir = [file_contents.isdir];
    directories = file_contents(isDir);
    dirNames = {directories.name};
    directories = dirNames(~strcmp(dirNames, '.') & ~strcmp(dirNames, '..') & ~strcmp(dirNames, 'summary'));
    everything_in_first = dir("~/wellesley/experimental_data/"+current_experiments+"/"+directories(1,1));
    files_in_first = sum([everything_in_first.isdir] == 0);
end






% Constants
molar_concentration_of_water = 55.3; % M
mkdir("~/wellesley/experimental_data/pictures_of_data");
graphs = 1;
verbose = 0; 
wellesley_purple = [16 6 159]./255;
wellesley_blue = [6 92 158]./255;
nsf_gold = [200 165 45]./255;
nih_grey = [101 102 106]./255;
firebrick_red = [0.698 0.13 0.13];

black = [0 0 0]./255;

% Changing

%pre-reps testing
% experiments = {'test1','test2','test_parameter_titration','test3_BFII','test4_BFII','test5_BFII','test6_BFII','test7_BFII','test8_BFII'};
% experimental_lipid_molar = {0.002870664,0.002870664,0.002870664,0.002870664,0.004058812,0.004058812,0.00394825,0.00394825,0.00394825,0.004552613}; % M
% lipid_aliquots = {0.000010,0.000010,0.000010,0.000010,0.000010,0.000010,0.000005,0.000005,0.000005};

%t1r testing
% experiments = {'t1r_rep1_2','t1r_rep1_3','t1r_testing','t1r_testing_2','t1r_testing_3'};
% experimental_lipid_molar = {0.004552613,0.004552613,(0.004552613/5),0.007754819,0.007754819};
% lipid_aliquots = {0.000005,0.000004,0.000005,0.00000293,0.00000293};

%rep 0
rep_0 = {
'test8_BFII'; 
0.004552613;
0.000005;
};

%rep 2
rep_blah = {
'l8r_rep1'; 
0.004552613;
0.000005;
};

%rep post
rep_post = {
'test8_BFII','wt_rep1','a6r_rep1','l8r_rep1','triple_rep1','t1r_rep2','a6r_rep2','l8r_rep2','triple_rep2','wt_rep3','t1r_rep3','a6r_rep3','l8r_rep3','triple_rep3','t1r_rep4','a6r_rep4','l8r_rep4','triple_rep4'; 
0.004552613,0.004552613,0.004552613,0.004552613,0.004552613,0.015509637,0.015509637,0.015509637,0.015509637,0.004135147,0.004135147,0.004135147,0.004135147,0.004135147,0.00410125,0.00410125,0.00410125,0.00410125;
0.000005,0.000005,0.000005,0.000005,0.000005,0.00000293,0.00000293,0.00000293,0.00000293,0.00000550,0.00000550,0.00000550,0.00000550,0.00000550,0.00000555,0.00000555,0.00000555,0.00000555;
};

%replicates 1
rep_1 = {
'wt_rep1','t1r_rep1','a6r_rep1','l8r_rep1','triple_rep1'; %last triple tit was no second mix
0.004552613,0.004552613,0.004552613,0.004552613,0.004552613;
0.000005,0.000005,0.000005,0.000005,0.000005;
};

%replicates 2 - 02-02/03-2026 - Messed up and added double the conc
rep_2 = {
'wt_rep2','t1r_rep2','a6r_rep2','l8r_rep2','triple_rep2';
0.015509637,0.015509637,0.015509637,0.015509637,0.015509637;
0.00000293,0.00000293,0.00000293,0.00000293,0.00000293;
};

%replicates 3 - 02-09/10-2026
rep_3 = {
'wt_rep3','t1r_rep3','a6r_rep3','l8r_rep3','triple_rep3';
0.004135147,0.004135147,0.004135147,0.004135147,0.004135147;
0.00000550,0.00000550,0.00000550,0.00000550,0.00000550;
};

% replicates 4 - 02-18/19-2026
rep_4 = {
'wt_rep4','t1r_rep4','a6r_rep4','l8r_rep4','triple_rep4';
0.00410125,0.00410125,0.00410125,0.00410125,0.00410125;
0.00000555,0.00000555,0.00000555,0.00000555,0.00000555;
};

% t1r_4 = {'t1r_rep4';0.00410125;0.00000555};


% replicates = [rep_post];
replicates = [rep_blah];
experiments = replicates(1,:);
experimental_lipid_molar = replicates(2,:);
lipid_aliquots = replicates(3,:);

wavlength_of_interest = 350;
all_ahats = {};
all_blueshift_ranges = {};
summary_table = table();


% choosing_mutants = contains(replicates(1,:),'wt');
% data = replicates(:,choosing_mutants);



for exp = 1:length(experiments)
    current_exp = experiments{exp};
    [titrations,num_of_files] = get_directories(current_exp);
    experimental_data = struct();
    mkdir("~/wellesley/experimental_data/pictures_of_data/"+current_exp);

    %reading in the data
    for titr = 1:length(titrations)
        current_titr = titrations{titr};
        titr_name = "L_"+string(current_titr);

        clear sample;
        sample(:,["WAVELENGTH" "FLUORESCENCE_BFII_titr"]) = readtable("~/wellesley/experimental_data/"+current_exp+"/"+current_titr+"/sample_1.txt");
        sample(:,["WAVELENGTH_2" "FLUORESCENCE_TRP"]) = readtable("~/wellesley/experimental_data/"+current_exp+"/"+current_titr+"/sample_2.txt");
        sample(:,["WAVELENGTH_3" "FLUORESCENCE_BFII_no_titr"]) = readtable("~/wellesley/experimental_data/"+current_exp+"/"+current_titr+"/sample_3.txt");
        
        if num_of_files == 8
            sample(:,["WAVELENGTH_4" "FLUORESCENCE_TRP_nolipid"]) = readtable("~/wellesley/experimental_data/"+current_exp+"/"+current_titr+"/sample_4.txt");
            sample = removevars(sample, {'WAVELENGTH_4'});
        end 

        sample = removevars(sample, {'WAVELENGTH_2', 'WAVELENGTH_3'});
        
        experimental_data.(titr_name) = sample;
    end

    %setting up figures
    if graphs == 1
        BFII_lipid_no_correction = figure('Theme','Light','WindowStyle', 'normal');
        if num_of_files == 8
            TRP_nolipid_correction = figure('Theme','Light','WindowStyle', 'normal');
        end
        TRP_lipid = figure('Theme','Light','WindowStyle', 'normal');
        BFII_no_lipid = figure('Theme','Light','WindowStyle', 'normal');
        BFII_lipid_with_correction = figure('Theme','Light','WindowStyle', 'normal');
    end

    % % %
    regression_and_confInf = figure('Theme','Light','WindowStyle', 'normal');
    % % %

    %Setting up calculation variables
    intensity = [];
    lmax = [];
    wavelength_intensity_concentration = [];
    concentrations = [];
    cuvette_total = 0.003; %L
 
    for titr = 1:length(titrations)
        current_titr = titrations{titr};
        titr_name = "L_"+string(current_titr);
        initial_titr = 'L_'+string(titrations{1});
        

        %plotting of non corrected spectra
        
        if graphs == 1    
            figure(BFII_lipid_no_correction);
            hold on;
            plot(experimental_data.(titr_name).WAVELENGTH,experimental_data.(titr_name).FLUORESCENCE_BFII_titr);
            non_corrected_legend = legend(strrep(titrations,'_',' '),'AutoUpdate','off','Orientation','vertical');
            if titr == length(titrations)
                Title = 'BFII titration - no corrections';
                title(Title);
                xlabel('Wavelength (nm)');
                ylabel('Intensity');
                fitting_data(tight_fitting=true, data_spacing_y=0.05);
                consistent_figures(figure_name=BFII_lipid_no_correction, PDF_PNG_name=Title, legend_name=non_corrected_legend, exp_name=current_exp);
                if verbose == 0
                    close(BFII_lipid_no_correction)
                end
            end
        end
        
        if graphs == 1
            figure(TRP_lipid);
            hold on;
            plot(experimental_data.(titr_name).WAVELENGTH,experimental_data.(titr_name).FLUORESCENCE_TRP);
            TRP_titration_legend = legend(strrep(titrations,'_',' '),'AutoUpdate','off','Orientation','vertical');
            if titr == length(titrations)
                Title = 'TRP titration';
                title(Title);
                xlabel('Wavelength (nm)');
                ylabel('Intensity');
                fitting_data(tight_fitting=true);
                consistent_figures(figure_name=TRP_lipid, PDF_PNG_name=Title, legend_name=TRP_titration_legend, exp_name=current_exp);
                if verbose == 0
                    close(TRP_lipid);
                end
            end
        end

        if graphs == 1
            figure(BFII_no_lipid);
            hold on;
            plot(experimental_data.(titr_name).WAVELENGTH,experimental_data.(titr_name).FLUORESCENCE_BFII_no_titr);
            BFII_correction_legend = legend(strrep(titrations,'_',' '),'AutoUpdate','off','Orientation','vertical');
            if titr == length(titrations)
                Title = 'BFII correction';
                title(Title);
                xlabel('Wavelength (nm)');
                ylabel('Intensity');
                fitting_data(tight_fitting=true);
                consistent_figures(figure_name=BFII_no_lipid, PDF_PNG_name=Title, legend_name=BFII_correction_legend, exp_name=current_exp);
                if verbose == 0
                    close(BFII_no_lipid);
                end
            end
        end

        if graphs == 1
            if num_of_files == 8
                figure(TRP_nolipid_correction);
                hold on;
                plot(experimental_data.(titr_name).WAVELENGTH,experimental_data.(titr_name).FLUORESCENCE_TRP_nolipid);
                TRP_nolipid_correction_legend = legend(strrep(titrations,'_',' '),'AutoUpdate','off','Orientation','vertical');
                if titr == length(titrations)
                    Title = 'TRP no lipid correction';
                    title(Title);
                    xlabel('Wavelength (nm)');
                    ylabel('Intensity');
                    fitting_data(tight_fitting=true);
                    consistent_figures(figure_name=TRP_nolipid_correction, PDF_PNG_name=Title, legend_name=TRP_nolipid_correction_legend, exp_name=current_exp);
                    if verbose == 0
                        close(TRP_nolipid_correction);
                    end
                end
            end
        end
        

        %TRP and no_lipid corrections to spectra, also concentration
        %calculation
        % if num_of_files == 8 %experimental_data.(titr_name).FLUORESCENCE_TRP_nolipid
        %     % experimental_data.(titr_name).FLUORESCENCE_BFII_titr = experimental_data.(titr_name).FLUORESCENCE_BFII_titr.*(experimental_data.(initial_titr).FLUORESCENCE_TRP_nolipid./experimental_data.(titr_name).FLUORESCENCE_TRP_nolipid);
        %     % experimental_data.(titr_name).FLUORESCENCE_TRP = (experimental_data.(initial_titr).FLUORESCENCE_TRP./experimental_data.(titr_name).FLUORESCENCE_TRP)./((experimental_data.(initial_titr).FLUORESCENCE_TRP_nolipid./experimental_data.(titr_name).FLUORESCENCE_TRP_nolipid));
        %     experimental_data.(titr_name).FLUORESCENCE_BFII_no_titr_no_machinedrift = experimental_data.(titr_name).FLUORESCENCE_BFII_no_titr;
        %     dawg = ((experimental_data.(initial_titr).FLUORESCENCE_TRP_nolipid./experimental_data.(titr_name).FLUORESCENCE_TRP_nolipid)-1);
        %     dawggie = (experimental_data.(initial_titr).FLUORESCENCE_BFII_no_titr./experimental_data.(titr_name).FLUORESCENCE_BFII_no_titr);
        %     doggsiees = (experimental_data.(initial_titr).FLUORESCENCE_TRP./experimental_data.(titr_name).FLUORESCENCE_TRP);
        %     experimental_data.(titr_name).FLUORESCENCE_BFII_no_titr_no_machinedrift = dawggie-dawg;
        %     experimental_data.(titr_name).FLUORESCENCE_trp_no_machinedrift = doggsiees-dawg;
        % end
        experimental_data.(titr_name).FLUORESCENCE_BFII_titr = experimental_data.(titr_name).FLUORESCENCE_BFII_titr.*(experimental_data.(initial_titr).FLUORESCENCE_TRP./experimental_data.(titr_name).FLUORESCENCE_TRP);
        % experimental_data.(titr_name).FLUORESCENCE_BFII_titr = experimental_data.(titr_name).FLUORESCENCE_BFII_titr.*experimental_data.(initial_titr).FLUORESCENCE_BFII_no_titr_no_machinedrift;
        % experimental_data.(titr_name).FLUORESCENCE_BFII_titr = experimental_data.(titr_name).FLUORESCENCE_BFII_titr.*experimental_data.(titr_name).FLUORESCENCE_trp_no_machinedrift;
        experimental_data.(titr_name).FLUORESCENCE_BFII_titr = experimental_data.(titr_name).FLUORESCENCE_BFII_titr.*(experimental_data.(initial_titr).FLUORESCENCE_BFII_no_titr./experimental_data.(titr_name).FLUORESCENCE_BFII_no_titr);        
        % experimental_data.(titr_name).FLUORESCENCE_BFII_titr = experimental_data.(titr_name).FLUORESCENCE_BFII_titr.*(experimental_data.(initial_titr).FLUORESCENCE_TRP_nolipid./experimental_data.(titr_name).FLUORESCENCE_TRP_nolipid);        


        wavelength_dict = dictionary(experimental_data.(titr_name).WAVELENGTH,experimental_data.(titr_name).FLUORESCENCE_BFII_titr);
        intensity = [intensity,wavelength_dict(wavlength_of_interest)];
        [max_intensity,wavelength_index] = max(experimental_data.(titr_name).FLUORESCENCE_BFII_titr);
        lmax = [lmax,experimental_data.(titr_name).WAVELENGTH(wavelength_index)];
        

        %concentrations
        if titr == 1            
            concentrations = [concentrations, 0.0]; %M
        else
            past_concentration = (concentrations(end));
            next_concentration = ((experimental_lipid_molar{exp}*(lipid_aliquots{exp}))/cuvette_total(end))+past_concentration;
            concentrations = [concentrations,next_concentration];
        end
        cuvette_total = cuvette_total+lipid_aliquots{exp};


        %for big all spectra graph
        concentration_array = createArray(length(experimental_data.(titr_name).WAVELENGTH), 1, FillValue=concentrations(end));
        wavelength_intensity_concentration(:,:,titr) = [experimental_data.(titr_name).WAVELENGTH,experimental_data.(titr_name).FLUORESCENCE_BFII_titr,concentration_array];


        % plotting of corrected spectra

        if graphs == 1
            color1 = firebrick_red;
            color2 = wellesley_blue;

            n = 11;
            r = interp1([1 n],[color1(1) color2(1)],1:n);
            g = interp1([1 n],[color1(2) color2(2)],1:n);
            b = interp1([1 n],[color1(3) color2(3)],1:n);
            color_map = [r;g;b]';

            figure(BFII_lipid_with_correction);
            hold on;
            plot(experimental_data.(titr_name).WAVELENGTH,experimental_data.(titr_name).FLUORESCENCE_BFII_titr,'Color',color_map(titr,:),'LineWidth',0.7);
            hold on
            BFII_corrected_legend = legend(strrep(titrations,'_','µL '),'AutoUpdate','off','Orientation','vertical');
            if titr == length(titrations)
                Title = 'BFII titration - with corrections';
                xline(350,'--','Color',black);
                title(Title);
                xlabel('Wavelength (nm)');
                ylabel('Intensity');
                fitting_data(tight_fitting=true);
                consistent_figures(figure_name=BFII_lipid_with_correction, PDF_PNG_name=Title, legend_name=BFII_corrected_legend, exp_name=current_exp);
            end
        end

        
    end

    %misc    
    relative_intensity = 1./(intensity(1)./intensity);
    current_exp_2 = strrep(current_exp,'_',' ');


    % % optimization fitting algorithm
    a0 = [1.1,1000]; %initial guess
    options = optimoptions('lsqnonlin','Algorithm','trust-region-reflective');
    predicted = @(a)((1+((a(1)-1)*((a(2)*concentrations)./((molar_concentration_of_water*(ones(size(concentrations))))+(a(2).*concentrations))))) - relative_intensity);
    [ahat,resnorm,residual,exitflag,output,lambda,jacobian] = lsqnonlin(predicted,a0,[1.0,10000],[2,100000000],[],[],[],[],[],options); %fitting
    disp(ahat);
    predicted_2 = @(a,x)(1+((a(1)-1)*((a(2)*x)./((molar_concentration_of_water*(ones(size(x))))+(a(2).*x)))));
    concentrations_inferred = linspace(concentrations(1),concentrations(end));

    %intensity at 350 against concentration (origionally in molar)
    % figure('Theme','Light','WindowStyle', 'normal');
    % hold on;
    % scatter(concentrations*1000000,relative_intensity);
    % title("Relative intensity as a function of concentration of lipids (µM) for "+current_exp_2+" - Optimization fitting algorithm");
    % xlabel('Concentration (µM)');
    % ylabel('Relative Intensity');
    % % %Adding nonlinear regression curve to graph
    % plot(concentrations_inferred*1000000,predicted_2(ahat,concentrations_inferred))
    % hold off;

    % large all wavelength relative intensity graph
    % figure('Theme','Light','WindowStyle', 'normal');
    % for conc = 1:length(concentrations)
    %     plot3(wavelength_intensity_concentration(:,1,conc),wavelength_intensity_concentration(:,3,conc),wavelength_intensity_concentration(:,2,conc))
    %     hold on;
    % end
    % constantplane('x',350)
    % hold off

    % % fraction patitioned graph
    % figure('Theme','Light','WindowStyle', 'normal')
    % binding_coefficient = ahat(2);
    % y = (binding_coefficient.*concentrations_inferred)./(molar_concentration_of_water+(binding_coefficient.*concentrations_inferred));
    % plot(concentrations_inferred,y)
    
    % residual plot
    % % figure('Theme','Light','WindowStyle', 'normal')
    % % plot(concentrations,(-1).*residual)

    % runs test - how many runs of points should we see if residuals are
    % normally distributed?
    % traditional_reses = (-1).*residual;
    % neg_reses = length(find(traditional_reses<0));
    % pos_reses = length(find(traditional_reses>0));
    % runs = ((2*pos_reses*neg_reses)/(pos_reses+neg_reses))+1;

    % normailty - are the residuals following a normal distribution?
    % figure('Theme','Light','WindowStyle', 'normal')
    % normplot(residual)

    % % SOME nice equations
    % sqrt(resnorm/(length(concentrations)-2)) SD sorta
    % % resnorm/(length(concentrations)-2) Variance sorta

    % confidence intervals - different algorithm
    predicted_diff = @(a,x)((1+((a(1)-1)*((a(2)*x)./((molar_concentration_of_water*(ones(size(x))))+(a(2).*x))))));
    [beta,R,J,CovB,MSE,ErrorModelInfo] = nlinfit(concentrations,relative_intensity,predicted_diff,a0);
    ci = nlparci(beta,R,"Covar",CovB);
    coefficient_standard_error = sqrt(diag(CovB));
    beta_lower = beta' - ci(:,1);
    beta_higher = ci(:,2) - beta';
    range_betas = beta_higher-beta_lower;
    [Ypredci,deltaci] = nlpredci(predicted_diff,concentrations,beta,R,"Covar",CovB);
    [Ypredpi,deltapi] = nlpredci(predicted_diff,concentrations,beta,R,"Covar",CovB,'PredOpt','observation');
    lowerci = Ypredci - deltaci;
    upperci = Ypredci + deltaci;
    lowerpi = Ypredpi - deltapi;
    upperpi = Ypredpi + deltapi;
    
    molar_conc = concentrations.'*1000000;
    xconf = [molar_conc;molar_conc(end:-1:1)];
    yconfci = [Ypredci+(deltaci);Ypredci(end:-1:1)-(deltaci(end:-1:1))];
    yconfpi = [Ypredpi+(deltapi);Ypredpi(end:-1:1)-(deltapi(end:-1:1))];

    % % % plotting of the confidence intervals
    figure(regression_and_confInf);      
    hold on;
    scatter(concentrations*1000000,relative_intensity,40,'filled');
    Title = "Relative intensity as a function of concentration of lipids (µM) for "+current_exp_2+" - Statistics fitting algorithm";
    title(Title);
    xlabel('Concentration (µM)');
    ylabel('Relative Intensity');
    plot(concentrations_inferred*1000000,predicted_diff(beta,concentrations_inferred),"Color",[0 0 0]);
    fill(xconf,yconfci,wellesley_blue, "FaceAlpha",0.3);
    fill(xconf,yconfpi,firebrick_red, "FaceAlpha",0.1);
    yline(beta(1),'--');
    regression_and_confInf_legend = legend({'Raw','Regression line','Confidence interval (95%)','Prediction interval (95%)','I_\infty ('+string(beta(1))+')'} ,'Location','southeast');
    fitting_data(tight_fitting=true,data_spacing_y=0.1);
    consistent_figures(figure_name=regression_and_confInf, PDF_PNG_name=Title, legend_name=regression_and_confInf_legend, exp_name=current_exp);
    hold off;
    % % %

    % for summary graphs

    % choosing_mutants = contains(replicates(1,:),'wt');
    % data = replicates(:,choosing_mutants);
   


    % For display table
    row_line = cell2table({cellstr(current_exp),experimental_lipid_molar{exp}*1000,lipid_aliquots{exp}*1000000,ahat(1),ahat(2),resnorm,beta(1),beta(2),(ci(1,1)+" -- "+ci(1,2)),(ci(2,1)+" -- "+ci(2,2)),(ci(2,2)-ci(2,1)),range(lmax)}); %for the SSE, I assume 2 is the degrees of freedom because we're estimating two variables
    summary_table = vertcat(summary_table,row_line);



end

 summary_table.Properties.VariableNames = ["Exp. name",'Lipid (mM)','aliquot (µL)','Iinf - opt alg','pc - opt alg','SSE - opt alg','Iinf - stat alg','pc - stat alg','Iinf conf. int.','Part coe conf. int.','part_co_range','Blue shift range'];
 disp(summary_table);



%% load data

pco_struct = load("/Users/zak/wellesley/work_scripts/matlab_scripts/old_or_random/pco_and_binding/wt123_combined_∆∆G/pco_fornorm.mat",'for_normalization_figure');
bfe_struct = load("/Users/zak/wellesley/work_scripts/matlab_scripts/bfe/bfe_fornorm.mat",'for_normalization_figure');
pco_struct_all = load("/Users/zak/wellesley/work_scripts/matlab_scripts/old_or_random/pco_and_binding/wt123_combined_∆∆G/pco_fornorm_all.mat",'for_normalization_figure_all');
bfe_struct_all = load("/Users/zak/wellesley/work_scripts/matlab_scripts/bfe/bfe_fornorm_all.mat",'for_normalization_figure_all');


pco_data = pco_struct.for_normalization_figure;
bfe_data = bfe_struct.for_normalization_figure;
pco_data_all = pco_struct_all.for_normalization_figure_all;
bfe_data_all = bfe_struct_all.for_normalization_figure_all;

%%

wt = summary_table([1,2,10],:);
t1r = summary_table([6,11,15],:);
a6r = summary_table([3,7,12,16],:);
l8r = summary_table([4,8,13,17],:);
triple = summary_table([5,9,14,18],:);
blue_shifting = summary_table(:,12);

all_sim_cats = [];


Title = "Experimental Summary";
% Summary_exp_figure = figure('Name',Title,'NumberTitle','off');
exp_names = {'WT','T1R','A6R','L8R','Triple'};
exp_names_full = {'hWT','T1R','A6R','L8R','Q9R','V12R','L18R','Triple'};
analysis = "pc - stat alg";
exp_data = {wt.(analysis),t1r.(analysis),a6r.(analysis),l8r.(analysis),triple.(analysis)};

data_and_name = vertcat(exp_data,exp_names)';
all_data = cell2mat(data_and_name(:,1));
all_data_pfe = log(all_data).*(298.15*8.31446262*(-1)*0.000239006);

for sim = 1:5

    this_sim_cat = (ones(1, length(cell2mat(exp_data(1,sim)))).*sim)';
    all_sim_cats = [all_sim_cats;this_sim_cat];

    data = log(cell2mat(exp_data(sim))).*(298.15*8.31446262*(-1)*0.000239006);

%     scatter(sim,data,90,wellesley_blue,'.')
%     hold on;
%     scatter(sim, mean(data),300,black,'.')
%     hold on;
%     errorbar(sim, mean(data) ,std(data)/sqrt(length(data)),  '.','LineWidth',1.3,'MarkerSize',10, 'Color',black)
%     hold on;
end
% 
% hold off;
% 
% ylabel('Partitioning Free Energy ({\itkcal/mol})');
% xticks(1:length(exp_names));
% xticklabels(exp_names);
% 
% fitting_data(tight_fitting=true, data_spacing_x=0.025);
% consistent_figures(figure_name=Summary_exp_figure, rotate_x_labels_by_angle=20, PDF_PNG_name=Title);
% 
% 


function h = plotEllipses(cnt,rads,axh)
    % cnt is the [x,y] coordinate of the center (row or column index).
    % rads is the [horizontal, vertical] "radius" of the ellipses (row or column index).
    % axh is the axis handle (if missing or empty, gca will be used)
    % h is the object handle to the plotted rectangle.
    % The easiest approach IMO is to plot a rectangle with rounded edges. 
    % EXAMPLE
    %    center = [1, 2];         %[x,y] center (mean)
    %    stdev = [1.2, 0.5];      %[x,y] standard dev.
    %    h = plotEllipses(center, stdev)
    %    axis equal
    % get axis handle if needed
    if nargin < 3 || isempty(axh)
        axh = gca();  
    end
    % Compute the lower, left corner of the rectangle.
    llc = cnt(:)-rads(:);
    % Compute the width and height
    wh = rads(:)*2; 
    % Draw rectangle 
    h = rectangle(axh,'Position',[llc(:).',wh(:).'],'Curvature',[1,1]); 
end



% wellesley_blue to nsf_gold
% 10 steps
color1 = wellesley_blue;
color2 = nsf_gold;

n = 5;
r = interp1([1 n],[color1(1) color2(1)],1:n);
g = interp1([1 n],[color1(2) color2(2)],1:n);
b = interp1([1 n],[color1(3) color2(3)],1:n);
color_map = [r;g;b]';

Title = "BFE_EXP_Comparision";
Summary_exp_figure = figure('Name',Title,'NumberTitle','off');
% axis equal
ecorr_mean_ste = [];
ccorr_mean_ste = [];
for sub = 1:5

    c_corr_mean = mean(bfe_data(bfe_data(:,2) == sub));
    if sub == 1 %wt
        % c_corr_ste = std(bfe_data(bfe_data(:,2) == sub))/sqrt(6);
        % std(bfe_data(bfe_data(:,2) == sub))

        % n=101;
        % a = (bfe_data(bfe_data(:,2) == sub));
        % b = arrayfun(@(i) mean(a(i:i+n-1)),1:n:length(a)-n+1)'; % the averaged vector
        % c_corr_ste = std(b)/sqrt(24);

        n=404;
        a = (bfe_data(bfe_data(:,2) == sub));
        b = arrayfun(@(i) mean(a(i:i+n-1)),1:n:length(a)-n+1)'; % the averaged vector
        c_corr_ste = std(b)/sqrt(6);

    else
        % c_corr_ste = std(bfe_data(bfe_data(:,2) == sub))/sqrt(3);
        % std(bfe_data(bfe_data(:,2) == sub))

        % n=101;
        % a = (bfe_data(bfe_data(:,2) == sub));
        % b = arrayfun(@(i) mean(a(i:i+n-1)),1:n:length(a)-n+1)'; % the averaged vector
        % c_corr_ste = std(b)/sqrt(12);

        n=404;
        a = (bfe_data(bfe_data(:,2) == sub));
        b = arrayfun(@(i) mean(a(i:i+n-1)),1:n:length(a)-n+1)'; % the averaged vector
        c_corr_ste = std(b)/sqrt(3);
    end
    
    ccorr_mean_ste = [ccorr_mean_ste;c_corr_mean,c_corr_ste];


    e_corr_mean = mean(all_data_pfe(all_sim_cats == sub));
    e_corr_ste = std(all_data_pfe(all_sim_cats == sub))/sqrt(length(all_data_pfe(all_sim_cats == sub)));
    ecorr_mean_ste = [ecorr_mean_ste;e_corr_mean,e_corr_ste];



    h = plotEllipses([c_corr_mean,e_corr_mean],[c_corr_ste,e_corr_ste]);
    [color_map(sub,:),.9]
    h.FaceColor = [color_map(sub,:)]; %4th value is undocumented: transparency
    h.FaceAlpha = 0.2;
    h.EdgeColor = [color_map(sub,:)]; 
    h.LineWidth = 2;
    hold on;
    fill(nan,nan,color_map(sub,:),'FaceAlpha',0.3)
    hold on;
end


blegend3 = legend('WT','T1R','A6R','L8R','Triple','AutoUpdate','off');
scatter(ccorr_mean_ste(:,1),ecorr_mean_ste(:,1),35,color_map,"filled")
% plotregression(ccorr_mean_ste(:,1),ecorr_mean_ste(:,1))
% errorbar(ccorr_mean_ste(:,1),ecorr_mean_ste(:,1),-ecorr_mean_ste(:,2),ecorr_mean_ste(:,2),-ccorr_mean_ste(:,2),ccorr_mean_ste(:,2),'.')


h = lsline();
h.LineWidth = 2;
h.Color = [firebrick_red 0.3];
cc = corr(ccorr_mean_ste(:,1),ecorr_mean_ste(:,1))


ylabel('Experimental PFE (kcal/mol)');
xlabel('Computational BFE (kcal/mol)');

fitting_data(tight_fitting=true, data_spacing=true);
consistent_figures(figure_name=Summary_exp_figure, PDF_PNG_name=Title, legend_name=blegend3);




% Title = "Normalized summary";
% normalized_figure = figure('Name',Title,'NumberTitle','off');
% 
%
wt_logical = (all_sim_cats == 1);
other_logical = (all_sim_cats ~= 1);
wt_shifted_normalization = all_data_pfe(wt_logical);

%for mean shifting
mean_wt_pfe = mean(wt_shifted_normalization);
wt_mean_shifted_pfe_data = all_data_pfe -mean_wt_pfe;


% [N,C,S] = normalize(wt_shifted_normalization);
% [N2] = normalize(all_data_pfe(other_logical),"center",C,"scale",S);
% [Nall,Call,Sall] = normalize(all_data_pfe);
% all_normalized = [N;N2];
% %

boxchart_1 = ones(length(all_sim_cats),1)*2;
% b = boxchart(all_sim_cats,all_normalized,'MarkerStyle','none',GroupByColor=boxchart_1)
% hold on;
% all_normalized_exp = [];
% all_normalized_exp = [all_normalized,all_sim_cats,boxchart_1];
% pfe_mean_data_total = [];
% pfe_mean_data_total = [wt_mean_shifted_pfe_data,all_sim_cats,boxchart_1];
% 
% pfe_normalized_data_total = [];
% pfe_normalized_data_total = [Nall,all_sim_cats,boxchart_1];


%
wt_logical = (bfe_data(:,2) == 1);
other_logical = (bfe_data(:,2) ~= 1);

t1r_logical = (bfe_data_all(:,2) == 2);
hwt_logical = (bfe_data_all(:,2) == 1);
a6r_logical = (bfe_data_all(:,2) == 3);
l8r_logical = (bfe_data_all(:,2) == 4);
q9r_logical = (bfe_data_all(:,2) == 5);
v12r_logical = (bfe_data_all(:,2) == 6);
l18r_logical = (bfe_data_all(:,2) == 7);
triple_logical = (bfe_data_all(:,2) == 8);



wt_shifted_normalization = bfe_data(wt_logical,1);

% mean_wt_bfe = mean(wt_shifted_normalization);
% wt_mean_shifted_bfe_data = bfe_data(:,1)-mean_wt_bfe;

% [N,C,S] = normalize(wt_shifted_normalization);
% [N2] = normalize(bfe_data(other_logical,1),"center",C,"scale",S);
% [Nall2] = normalize(bfe_data(:,1));
% 
% all_normalized = [N;N2];
% 
% bfe_normalized_data_total = [];
% bfe_normalized_data_total = [Nall2,bfe_data(:,2),boxchart_2];

% wt = Nall2(wt_logical,1);
% wt_mean = mean(wt);
% wt_ste = std(wt)/sqrt(3);
% t1r_data = Nall2(t1r_logical,1);
% t1r_mean = mean(t1r_data);
% t1r_ste = std(t1r_data)/sqrt(3);
% a6r_data = Nall2(a6r_logical,1);
% a6r_mean = mean(a6r_data);
% a6r_ste = std(a6r_data)/sqrt(3);
% l8r_data = Nall2(l8r_logical,1);
% l8r_mean = mean(l8r_data);
% l8r_ste = std(l8r_data)/sqrt(3);
% triple_data = Nall2(triple_logical,1);
% triple_mean = mean(triple_data);
% triple_ste = std(triple_data)/sqrt(3);
% mean_ste = [wt_mean,1,wt_ste;t1r_mean,2,t1r_ste;a6r_mean,3,a6r_ste;l8r_mean,4,l8r_ste;triple_mean,5,triple_ste];


% 
% boxchart_2 = ones(length(bfe_data(:,2)),1)*1;
% bfe_data_total = [];
% bfe_data_total = [all_normalized,bfe_data(:,2),boxchart_2];
% 
% bfe_mean_data_total = [];
% bfe_mean_data_total = [wt_mean_shifted_bfe_data,bfe_data(:,2),boxchart_2];
% 
% bfe_normalized_data_total = [];
% bfe_normalized_data_total = [Nall2,bfe_data(:,2),boxchart_2];
% 
% mean_total = [bfe_mean_data_total;pfe_mean_data_total];
% normal_total = [bfe_normalized_data_total;pfe_normalized_data_total];
% flipped_total = [pfe_normalized_data_total;bfe_normalized_data_total];
% 
% total = [bfe_data_total;all_normalized_exp];

% b = boxchart(total(:,2),total(:,1),'MarkerStyle','none',GroupByColor=total(:,3));
% b = boxchart(mean_total(:,2),mean_total(:,1),'MarkerStyle','none',GroupByColor=mean_total(:,3));
% b = boxchart(normal_total(:,2),normal_total(:,1),'MarkerStyle','none',GroupByColor=normal_total(:,3));
% violinplot(bfe_normalized_data_total(:,2)-0.4,bfe_normalized_data_total(:,1),'FaceColor',wellesley_blue,GroupByColor=bfe_normalized_data_total(:,3));
% hold on;

% v = violinplot(bfe_normalized_data_total(:,2),bfe_normalized_data_total(:,1),GroupByColor=bfe_normalized_data_total(:,3));
% v(1).FaceColor = nsf_gold; 
% v(2).FaceColor = wellesley_blue;
% errorbar(mean_total(:,2),mean_total(:,1))

% % blegend = legend('BFE','Experimental','AutoUpdate','off');


% b.ColorGroupWidth = 0.5;
hold on;

% hund_diffs=[];
t1r_data = bfe_data_all(t1r_logical,1);
hwt_data = bfe_data_all(hwt_logical,1);
a6r_data = bfe_data_all(a6r_logical,1);
l8r_data = bfe_data_all(l8r_logical,1);
q9r_data = bfe_data_all(q9r_logical,1);
v12r_data = bfe_data_all(v12r_logical,1);
l18r_data = bfe_data_all(l18r_logical,1);
triple_data = bfe_data_all(triple_logical,1);

% for x = 1:100
%     dawg = randsample(wt_shifted_normalization,48);
%     dawg2 = randsample(t1r_shifted_normalization,48);
%     meany = mean(dawg);
%     mean2 = mean(dawg2);
%     diff = meany-mean2;
%     hund_diffs = [hund_diffs;diff];
% end

% mean(hund_diffs)
% t1r_ddg = -(mean(wt_shifted_normalization)-mean(t1r_data));
% hwt_ddg = -(mean(wt_shifted_normalization)-mean(hwt_data));
% a6r_ddg = -(mean(wt_shifted_normalization)-mean(a6r_data));
% l8r_ddg = -(mean(wt_shifted_normalization)-mean(l8r_data));
% q9r_ddg = -(mean(wt_shifted_normalization)-mean(q9r_data));
% v12r_ddg = -(mean(wt_shifted_normalization)-mean(v12r_data));
% l18r_ddg = -(mean(wt_shifted_normalization)-mean(l18r_data));
% triple_ddg = -(mean(wt_shifted_normalization)-mean(triple_data));



n=404;
a = wt_shifted_normalization;
b = arrayfun(@(i) mean(a(i:i+n-1)),1:n:length(a)-n+1)'; % the averaged vector
ste = std(b)/sqrt(6);
wt_mean = mean(b);
wt_ste = ste;

sim_data_names = {'hwt_data','t1r_data','a6r_data','l8r_data','q9r_data','v12r_data','l18r_data','triple_data'};
bfe_ddg_mean_ste = [];

for ddg_name = 1:8

    n=404;
    a = eval(sim_data_names{ddg_name});
    b = arrayfun(@(i) mean(a(i:i+n-1)),1:n:length(a)-n+1)'; % the averaged vector
    sub_ste = std(b)/sqrt(3);
    meany = mean(b);

    sim_ddg_mean = -(mean(wt_mean)-meany);
    sim_ddg_error = sqrt((wt_ste^2)+(sub_ste^2));
    bfe_ddg_mean_ste = [bfe_ddg_mean_ste;sim_ddg_mean,sim_ddg_error];
end

% t1r_ddg_median = -(median(wt_shifted_normalization)-median(t1r_data));
% hwt_ddg_median = -(median(wt_shifted_normalization)-median(hwt_data));
% a6r_ddg_median = -(median(wt_shifted_normalization)-median(a6r_data));
% l8r_ddg_median = -(median(wt_shifted_normalization)-median(l8r_data));
% q9r_ddg_median = -(median(wt_shifted_normalization)-median(q9r_data));
% v12r_ddg_median = -(median(wt_shifted_normalization)-median(v12r_data));
% l18r_ddg_median = -(median(wt_shifted_normalization)-median(l18r_data));
% triple_ddg_median = -(median(wt_shifted_normalization)-median(triple_data));
% seperate_triple_mean = t1r_ddg+a6r_ddg+l8r_ddg;
% seperate_triple_median = t1r_ddg_median+a6r_ddg_median+l8r_ddg_median;


% mean_median_group = [hwt_ddg,hwt_ddg_median,1;t1r_ddg,t1r_ddg_median,2;a6r_ddg,a6r_ddg_median,3;l8r_ddg,l8r_ddg_median,4;q9r_ddg,q9r_ddg_median,5;v12r_ddg,v12r_ddg_median,6;l18r_ddg,l18r_ddg_median,7;triple_ddg,triple_ddg_median,8];


% y = 0;
% x = 0:0.1:6;
% plot(x,y,'LineStyle','--','LineWidth', 2)

% yline(0,'--');


% ylabel('Standard Deviation (Z-score)');
% xticks(1:length(exp_names));
% xticklabels(exp_names);
% 
% fitting_data(tight_fitting=true, data_spacing_x=0.025);
% consistent_figures(figure_name=normalized_figure, rotate_x_labels_by_angle=20, PDF_PNG_name=Title, legend_name=blegend);
% ylim([-4,4]);

% 
% % Title = "PCO_BFE";
% % bfe_pco_figure = figure('Name',Title,'NumberTitle','off');
% % 
% % % Need BFE prop error and mean

pco_data_all_sorted = sortrows(pco_data_all,2);
pco_means = [unique(pco_data_all_sorted(:,3),"stable")];
pco_ste = [unique(pco_data_all_sorted(:,4),"stable")];
pco_triple_mean = pco_means(2)+pco_means(3)+pco_means(4);
pco_triple_ste = sqrt((pco_ste(2)^2)+(pco_ste(3)^2)+(pco_ste(4)^2));
pco_ddg_mean_ste = [[pco_means;pco_triple_mean],[pco_ste;pco_triple_ste]]
% % 
% % 
color1 = wellesley_blue;
firebrick_red = [0.698 0.13 0.13];
color2 = nsf_gold;
% % 
% % n = 8;
% % r = interp1([1 n],[color1(1) color2(1)],1:n);
% % g = interp1([1 n],[color1(2) color2(2)],1:n);
% % b = interp1([1 n],[color1(3) color2(3)],1:n);
% % color_map = [r;g;b]';
% % 
% % for plot = 1:length(bfe_ddg_mean_ste)
% % 
% %     h = plotEllipses([bfe_ddg_mean_ste(plot,1),pco_ddg_mean_ste(plot,1)],[bfe_ddg_mean_ste(plot,2),pco_ddg_mean_ste(plot,2)]);
% %     h.FaceColor = [color_map(plot,:)]; %4th value is undocumented: transparency
% %     h.FaceAlpha = 0.1;
% %     h.EdgeColor = [color_map(plot,:)]; 
% %     h.LineWidth = 2;
% %     hold on;
% %     fill(nan,nan,color_map(plot,:),'FaceAlpha',0.3)
% %     hold on;
% % end
% % 
% % blegend4 = legend('hWT','T1R','A6R','L8R','Q9R','V12R','L18R','Triple','AutoUpdate','off');
% % scatter(bfe_ddg_mean_ste(:,1),pco_ddg_mean_ste(:,1),35,color_map,"filled")



% [blegend2,blog] = legend('PCO','BFE Mean');
% blog1 = blog(1,1);
% blog2 = blog(2,1);
% blog3 = blog(3,1);
% blegend2.Box = 'on';
% blog1.FontName = 'Helvetica';
% blog1.FontSize = 18;
% blog1.Color = black;
% blog2.FontName = 'Helvetica';
% blog2.FontSize = 18;
% blog2.Color = black;
% blog3.Children.MarkerSize = 15;

%%
column = '12';
exps = {"wt(:,"+column+")","t1r(:,"+column+")","a6r(:,"+column+")","l8r(:,"+column+")","triple(:,"+column+")"};
allblueshift = [];
scabber = [];
color_map_lengthend = [];
for exp = 1:5
    exp_blueshift = table2array(eval(exps{exp}));
    blueshift_mean = mean(exp_blueshift);
    blueshift_error = std(exp_blueshift)/sqrt(length(exp_blueshift));
    allblueshift = [allblueshift;blueshift_mean,blueshift_error];
    scabber = [scabber;exp_blueshift,exp*(ones(length(exp_blueshift),1)) ];
    color_map_lengthend = [color_map_lengthend;repmat(color_map(exp,:),length(exp_blueshift),1)];
end


Title = "Blue_shift";
dawg_figure = figure('Name',Title,'NumberTitle','off');
errorbar([1 2 3 4 5],allblueshift(:,1),allblueshift(:,2),'.','LineWidth',1.9,'MarkerSize',23, 'Color',black)
hold on;
scatter(scabber(:,2),scabber(:,1),35,color_map_lengthend,'filled',SizeDataMode='manual')
xticks([1 2 3 4 5])
xticklabels(exp_names)
ylabel('Magnitude in Blue Shift (nm)');
fitting_data(tight_fitting=true, data_spacing=true);
consistent_figures(figure_name=dawg_figure, PDF_PNG_name=Title);

% (bfe_ddg_mean_ste(:,1),pco_ddg_mean_ste(:,1)
% scatter( ccorr_mean_ste(:,1),allblueshift(:,1) );
% figure()
% scatter( exp_data(:,1), ecorr_mean_ste(:,1) );



%%
Title = "PCO_BFE";
bfe_pco_figure = figure('Name',Title,'NumberTitle','off');
violinplot(pco_data_all(:,2)-0.14,pco_data_all(:,1),'FaceColor',wellesley_purple);
hold on;
e = errorbar([1 2 3 4 5 6 7 8]+0.14,bfe_ddg_mean_ste(:,1),bfe_ddg_mean_ste(:,2), '.','LineWidth',1.3,'MarkerSize',15, 'Color',black);
e.Color = nsf_gold;
e.MarkerEdgeColor = black;
hold on;

errorbar([1 2 3 4 5 6 7 8]-0.14,pco_ddg_mean_ste(:,1),pco_ddg_mean_ste(:,2), '.','LineWidth',1.3,'MarkerSize',15, 'Color',wellesley_purple);
ylabel('\Delta\DeltaG_{PCO}, (kcal/mol)');
ylim([-10,4])
xticks(1:length(exp_names_full));
xticklabels(exp_names_full);

blegend4 = legend('\Delta\DeltaG_{PCO}','\Delta\DeltaG_{BFE}','AutoUpdate','off');
fitting_data(tight_fitting=true, data_spacing=true);
consistent_figures(figure_name=bfe_pco_figure, PDF_PNG_name=Title,legend_name=blegend4);
ylim([-11,4])