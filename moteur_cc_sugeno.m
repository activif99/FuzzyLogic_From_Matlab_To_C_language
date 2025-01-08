clear all; close all; clf; clc;

% FIS Creation
FIS_Moteur_cc = sugfis('Name', 'FIS_Moteur_cc');

% System variables:
FIS_Moteur_cc = addInput(FIS_Moteur_cc, [-10 50], 'Name', 'Temperature');
FIS_Moteur_cc = addInput(FIS_Moteur_cc, [0 4], 'Name', 'Driving_Mode');
FIS_Moteur_cc = addInput(FIS_Moteur_cc, [1300 2000], 'Name', 'Weight');
FIS_Moteur_cc = addInput(FIS_Moteur_cc, [-1.1 1.1], 'Name', 'Slope');
FIS_Moteur_cc = addInput(FIS_Moteur_cc, [0 110], 'Name', 'SOC');
FIS_Moteur_cc = addInput(FIS_Moteur_cc, [-120 120], 'Name', 'Velocity_Change'); 
FIS_Moteur_cc = addInput(FIS_Moteur_cc, [0 160], 'Name', 'Current_Velocity');

% Membership functions for Temperature variable:
FIS_Moteur_cc = addMF(FIS_Moteur_cc, 'Temperature', 'trapmf', [-10 -5 15 25], 'Name', 'Cold');
FIS_Moteur_cc = addMF(FIS_Moteur_cc, 'Temperature', 'trapmf', [15 25 25 35], 'Name', 'Normal');
FIS_Moteur_cc = addMF(FIS_Moteur_cc, 'Temperature', 'trapmf', [25 35 45 50], 'Name', 'Hot');


% figure(1)
% plotmf(FIS_Moteur_cc,'input',1,1000)
% set(findall(gcf,'type','line'),'linewidth',2.5);

% Membership functions for the Driving_Mode variable:

FIS_Moteur_cc = addMF(FIS_Moteur_cc, 'Driving_Mode', 'pimf', [0 0 1 1], 'Name', 'Eco');
FIS_Moteur_cc = addMF(FIS_Moteur_cc, 'Driving_Mode', 'pimf', [1.1 1.1 2.1 2.1], 'Name', 'Sport');
FIS_Moteur_cc = addMF(FIS_Moteur_cc, 'Driving_Mode', 'pimf', [2.2 2.2 3.2 3.2], 'Name', 'Normal');
FIS_Moteur_cc = addMF(FIS_Moteur_cc, 'Driving_Mode', 'pimf', [3.3 3.3 4 4], 'Name', 'Comfort');


% figure(2)
% plotmf(FIS_Moteur_cc,'input',2,1000)
% xlabel('Driving Mode')
% set(findall(gcf,'type','line'),'linewidth',2.5);

% Membership functions definition for the 'Weight' variable

FIS_Moteur_cc = addMF(FIS_Moteur_cc, 'Weight', 'trapmf', [1300 1300 1467.5 1635], 'Name', 'Light');
FIS_Moteur_cc = addMF(FIS_Moteur_cc, 'Weight', 'trapmf', [1467.5 1635 1635 1802.5], 'Name', 'Normal');
FIS_Moteur_cc = addMF(FIS_Moteur_cc, 'Weight', 'trapmf', [1635 1802.5 2000 2000], 'Name', 'Heavy');

% figure(3)
% plotmf(FIS_Moteur_cc,'input',3,1000)
% set(findall(gcf,'type','line'),'linewidth',2.5);

% Membership functions for the Slope variable:
FIS_Moteur_cc = addMF(FIS_Moteur_cc, 'Slope', 'trapmf', [-1.1 -1 -0.5 0], 'Name', 'Descent');
FIS_Moteur_cc = addMF(FIS_Moteur_cc, 'Slope', 'trapmf', [-0.5 0 0 0.5], 'Name', 'Flat');
FIS_Moteur_cc = addMF(FIS_Moteur_cc, 'Slope', 'trapmf', [0 0.5 1 1.1], 'Name', 'Ascent');


% figure(4)
% plotmf(FIS_Moteur_cc,'input',4,1000)
% set(findall(gcf,'type','line'),'linewidth',2.5);
% % slope = [-1 0 1]; % descent, flat, ascent




% Membership functions for the SOC variable:
% Low State of Charge
FIS_Moteur_cc = addMF(FIS_Moteur_cc,'SOC','trapmf',[0 0 20 40],'Name','Low');
% Medium State of Charge
FIS_Moteur_cc = addMF(FIS_Moteur_cc,'SOC','trapmf',[20 40 60 80],'Name','Medium');
% High State of Charge
FIS_Moteur_cc = addMF(FIS_Moteur_cc,'SOC','trapmf',[60 80 100 110],'Name','High');

% Optional: Plotting the membership functions for SOC
% figure(5)
% plotmf(FIS_Moteur_cc,'input',5,1000)
% xlabel('SOC (%)')
% set(findall(gcf,'type','line'),'linewidth',2.5);

%velocity profile 

% Membership functions for the Slope variable:
FIS_Moteur_cc = addMF(FIS_Moteur_cc,'Velocity_Change','trapmf',[-100 -50 -50 -0.01],'Name','Decelerating');
FIS_Moteur_cc = addMF(FIS_Moteur_cc,'Velocity_Change','trapmf',[-0.01 0 0 0.01],'Name','Steady');
FIS_Moteur_cc = addMF(FIS_Moteur_cc,'Velocity_Change','trapmf',[0.01 50 50 100],'Name','Accelerating');

% Define membership functions for Current Velocity
FIS_Moteur_cc = addMF(FIS_Moteur_cc,'Current_Velocity','gaussmf',[0.01 0],'Name','Stopped'); % Sharp peak at 0
FIS_Moteur_cc = addMF(FIS_Moteur_cc,'Current_Velocity','gaussmf',[5 30],'Name','Slow'); % Normal distribution around 30
FIS_Moteur_cc = addMF(FIS_Moteur_cc,'Current_Velocity','gaussmf',[20 70],'Name','Medium'); % Normal distribution around 80
FIS_Moteur_cc = addMF(FIS_Moteur_cc,'Current_Velocity','gaussmf',[30 160],'Name','Fast'); % Normal distribution around 160
 figure(3)
plotmf(FIS_Moteur_cc,'input',7,1000)
xlabel('Velocity Profil')
set(findall(gcf,'type','line'),'linewidth',2.5);

% Optional: Plotting the membership functions for SOC
% figure(6)
% plotmf(FIS_Moteur_cc,'input',6,1000)
% xlabel('Velocity Profil')
% set(findall(gcf,'type','line'),'linewidth',2.5);
% Output variable for the Coefficient
FIS_Moteur_cc = addOutput(FIS_Moteur_cc, [0 1], 'Name', 'Coefficient');
% Define output membership functions with meaningful labels
outputMFs = {
    'Zero', 0.0;
    'V.V.Small', 0.3;
    'V.Small', 0.4;
    'Small', 0.5;
    'Normal', 0.6;
    'Large', 0.75;
    'V.Large', 0.85;
    'V.V.Large', 0.98;
};
% Add output membership functions
for i = 1:size(outputMFs, 1)
    FIS_Moteur_cc = addMF(FIS_Moteur_cc, 'Coefficient', 'constant', outputMFs{i, 2},'Name', outputMFs{i, 1});
end





% figure(7)
% plotmf(FIS_Moteur_cc,'output',1,1000)
% % set(findall(gcf,'type','line'),'linewidth',2.5);
% % Since it's a Sugeno FIS, the output membership functions will be singleton values
% FIS_Moteur_cc = addmf(FIS_Moteur_cc, 'output', 1, 'V.V.Small', 'constant', 0.3);
% FIS_Moteur_cc = addmf(FIS_Moteur_cc, 'output', 1, 'V.Small', 'constant', 0.4);
% FIS_Moteur_cc = addmf(FIS_Moteur_cc, 'output', 1, 'Small', 'constant', 0.5);
% FIS_Moteur_cc = addmf(FIS_Moteur_cc, 'output', 1, 'Normal', 'constant', 0.6);
% FIS_Moteur_cc = addmf(FIS_Moteur_cc, 'output', 1, 'Large', 'constant', 0.7);
% FIS_Moteur_cc = addmf(FIS_Moteur_cc, 'output', 1, 'V.Large', 'constant', 0.8);
% FIS_Moteur_cc = addmf(FIS_Moteur_cc, 'output', 1, 'V.V.Large', 'constant', 0.9);

% in one plot : 
 figure; % Create a new figure

% Subplot for the 'Velocity Profile' input
subplot(2, 3, 1); % This places the plot in the first position of a 2x3 grid
plotmf(FIS_Moteur_cc, 'input', 6, 1000);
xlabel('Velocity Profile (m/s)');
ylabel('Membership Grade');
title('Velocity Profile');
set(findall(gcf,'type','line'),'linewidth',2.5);

% Subplot for the 'SOC' input
subplot(2, 3, 2); % This places the plot in the second position of the same grid
plotmf(FIS_Moteur_cc, 'input', 5, 1000);
xlabel('SOC (%)');
ylabel('Membership Grade');
title('SOC');
set(findall(gcf,'type','line'),'linewidth',2.5);

% Subplot for the 'Weight' input
subplot(2, 3, 3); % This places the plot in the third position of the same grid
plotmf(FIS_Moteur_cc, 'input', 3, 1000);
xlabel('Weight (Kg)');
ylabel('Membership Grade');
title('Weight');
set(findall(gcf,'type','line'),'linewidth',2.5);

% Subplot for the 'Slope' input
subplot(2, 3, 4); % This places the plot in the first position of the second row
plotmf(FIS_Moteur_cc, 'input', 4, 1000);
xlabel('Slope');
ylabel('Membership Grade');
title('Slope');
set(findall(gcf,'type','line'),'linewidth',2.5);

% Subplot for the 'Driving Mode' input
subplot(2, 3, 5); % This places the plot in the second position of the second row
plotmf(FIS_Moteur_cc, 'input', 2, 1000);
xlabel('Driving Mode');
ylabel('Membership Grade');
title('Driving Mode');
set(findall(gcf,'type','line'),'linewidth',2.5);

% Subplot for the 'Temperature' input
subplot(2, 3, 6); % This places the plot in the third position of the second row
plotmf(FIS_Moteur_cc, 'input', 1, 1000);
xlabel('Temperature °');
ylabel('Membership Grade');
title('Temperature');
set(findall(gcf,'type','line'),'linewidth',2.5);

% Enhance overall appearance
sgtitle('Input Membership Functions'); % Super title for the whole figure

% Ensure defuzzification method is weighted average
FIS_Moteur_cc.defuzzMethod = 'wtaver';



% Fuzzy rules for the FIS_Moteur system

% Fuzzy rules for "Eco" Driving_Mode considering SOC, Temperature, and Weight

% When SOC is High
rule1a = "If (Driving_Mode is Eco) and (SOC is High) and (Temperature is Cold) and (Weight is Light) then (Coefficient is Normal)";
rule1b = "If (Driving_Mode is Eco) and (SOC is High) and (Temperature is Normal) and (Weight is Normal) then (Coefficient is Normal)";
rule1c = "If (Driving_Mode is Eco) and (SOC is High) and (Temperature is Hot) and (Weight is Heavy) then (Coefficient is Large)";
rule1d = "If (Driving_Mode is Eco) and (SOC is High) and (Slope is Ascent) and (Weight is Heavy) then (Coefficient is V.Large)";
rule1e = "If (Driving_Mode is Eco) and (SOC is High) and (Slope is Ascent) and (Weight is Normal) then (Coefficient is Large)";
rule1f = "If (Driving_Mode is Eco) and (SOC is High) and (Slope is Ascent) and (Weight is Light) then (Coefficient is Normal)";
rule11a = "If (Driving_Mode is Eco) and (SOC is High) and (Velocity_Change is Accelerating) then (Coefficient is Normal)";
rule11b = "If (Driving_Mode is Eco) and (SOC is High) and (Velocity_Change is Steady) and  (Weight is Heavy) then (Coefficient is Normal)";
rule11c = "If (Driving_Mode is Eco) and (SOC is High) and (Velocity_Change is Decelerating) then (Coefficient is V.V.Small)";
rule11d = "If (Driving_Mode is Eco) and (SOC is High) and (Velocity_Change is Steady) and (Slope is Ascent) and (Weight is Heavy) then (Coefficient is V.Large)"; 
% When SOC is Medium
rule2a = "If (Driving_Mode is Eco) and (SOC is Medium) and (Temperature is Cold) and (Weight is Light) then (Coefficient is Small)";
rule2b = "If (Driving_Mode is Eco) and (SOC is Medium) and (Temperature is Normal) and (Weight is Normal) then (Coefficient is Small)";
rule2c = "If (Driving_Mode is Eco) and (SOC is Medium) and (Temperature is Hot) and (Weight is Heavy) then (Coefficient is Normal)";
rule2d = "If (Driving_Mode is Eco) and (SOC is Medium) and (Slope is Ascent)  then (Coefficient is Large)";
rule22a = "If (Driving_Mode is Eco) and (SOC is Medium) and (Velocity_Change is Accelerating) and (Slope is Ascent) then (Coefficient is V.Large)";
rule22b = "If (Driving_Mode is Eco) and (SOC is Medium) and (Velocity_Change is Steady) and (Weight is Heavy) and (Slope is Ascent) then (Coefficient is Large)";
rule22c = "If (Driving_Mode is Eco) and (SOC is Medium) and (Velocity_Change is Steady) and (Weight is Light) and (Slope is Ascent) then (Coefficient is Normal)";
rule22d = "If (Driving_Mode is Eco) and (SOC is Medium) and (Velocity_Change is Decelerating)  then (Coefficient is V.V.Small)";
% When SOC is Low
rule3a = "If (Driving_Mode is Eco) and (SOC is Low) and (Velocity_Change is Steady) and (Slope is Ascent) then (Coefficient is Normal)";
rule33a = "If (Driving_Mode is Eco) and (SOC is Low) and (Velocity_Change is Accelerating)  then (Coefficient is Normal)";
rule333a = "If (Driving_Mode is Eco) and (SOC is Low) and (Velocity_Change is Accelerating) and (Slope is Ascent) then (Coefficient is Large)";
rule3b = "If (Driving_Mode is Eco) and (SOC is Low) and (Slope is Flat) then (Coefficient is Small)";
rule3c = "If (Driving_Mode is Eco) and (SOC is Low) and (Slope is Descent) then (Coefficient is V.V.Small)";
rule33b = "If (Driving_Mode is Eco) and (SOC is Low) and (Velocity_Change is Decelerating)  then (Coefficient is V.V.Small)";

% Fuzzy rules for "Comfort " Driving_Mode considering SOC, Temperature, and Weight

% When SOC is High
rule1g = "If (Driving_Mode is Comfort) and (SOC is High) and (Temperature is Cold) and (Velocity_Change is Steady) then (Coefficient is Large)"; % Assuming heating is prioritized
rule1h = "If (Driving_Mode is Comfort) and (SOC is High) and (Temperature is Hot) and (Velocity_Change is Steady) then (Coefficient is Large)"; % Assuming cooling is prioritized
rule11g = "If (Driving_Mode is Comfort) and (SOC is High) and (Temperature is Cold) and (Velocity_Change is Accelerating)and (Slope is Ascent) then (Coefficient is V.Large)"; 
rule11h = "If (Driving_Mode is Comfort) and (SOC is High) and (Temperature is Hot) and (Velocity_Change is Accelerating)and (Slope is Ascent) then (Coefficient is V.Large)";
rule111g = "If (Driving_Mode is Comfort) and (SOC is High) and (Temperature is Normal) then (Coefficient is Large)";
rule111h = "If (Driving_Mode is Comfort) and (SOC is High) and  (Velocity_Change is Decelerating) then (Coefficient is V.V.Small)";
% When SOC is Medium
rule2e = "If (Driving_Mode is Comfort) and (SOC is Medium) and (Temperature is Cold) and (Velocity_Change is Steady) then (Coefficient is Normal)"; % Slightly conserving energy but still heating
rule2f = "If (Driving_Mode is Comfort) and (SOC is Medium) and (Temperature is Hot) and (Velocity_Change is Steady) then (Coefficient is Normal)"; % Slightly conserving energy but still cooling
rule22e = "If (Driving_Mode is Comfort) and (SOC is Medium) and (Temperature is Cold) and (Velocity_Change is Accelerating) and (Slope is Ascent) then (Coefficient is Large)"; 
rule22f = "If (Driving_Mode is Comfort) and (SOC is Medium) and (Temperature is Hot) and (Velocity_Change is Accelerating) and (Slope is Ascent) then (Coefficient is Large)";
rule222e = "If (Driving_Mode is Comfort) and (SOC is Medium) and (Temperature is Normal) then (Coefficient is Normal)";
rule222f = "If (Driving_Mode is Comfort) and (SOC is Medium) and  (Velocity_Change is Decelerating) then (Coefficient is V.V.Small)";
% When SOC is Low
rule3d = "If (Driving_Mode is Comfort) and (SOC is Low) and (Temperature is Cold) and (Velocity_Change is Steady) then (Coefficient is Small)"; % Minimal energy use for heating
rule3e = "If (Driving_Mode is Comfort) and (SOC is Low) and (Temperature is Hot) and (Velocity_Change is Steady) then (Coefficient is Small)"; % Minimal energy use for cooling
rule33d = "If (Driving_Mode is Comfort) and (SOC is Low) and (Velocity_Change is Accelerating)  then (Coefficient is Normal)";
rule33e = "If (Driving_Mode is Comfort) and (SOC is Low) and (Velocity_Change is Decelerating)  then (Coefficient is V.V.Small)";
% Considering Weight as a factor for adjusting the Coefficient
 %rule7 = "If (Driving_Mode is Comfort) and (Weight is Light) then (Coefficient is Small)"; 
 %rule8 = "If (Driving_Mode is Comfort) and (Weight is Heavy) and (Velocity_Change is Accelerating) then (Coefficient is Large)";
 %rule9 = "If (Driving_Mode is Comfort) and (Slope is Ascent) and (Weight is Heavy) and (Velocity_Change is Accelerating) then (Coefficient is V.Large)";
 %rule10 = "If (Driving_Mode is Comfort) and (Temperature is Normal) and (Weight is Normal) then (Coefficient is Normal)";
 %rule10a = "If (Driving_Mode is Comfort) and (Temperature is Normal)  then (Coefficient is Large)";


% Fuzzy rules for "Sports" Driving_Mode considering SOC, Weight, and Slope

% High SOC - prioritizing performance
rule1i = "If (Driving_Mode is Sport) and (SOC is High) and (Slope is Flat) then (Coefficient is V.Large)";
rule1j = "If (Driving_Mode is Sport) and (SOC is High) and (Weight is Heavy) and (Slope is Ascent) then (Coefficient is V.V.Large)";
rule1k = "If (Driving_Mode is Sport) and (SOC is High) and (Slope is Ascent) then (Coefficient is V.Large)";
rule11i = "If (Driving_Mode is Sport) and (SOC is High)  and (Velocity_Change is Accelerating) then (Coefficient is V.V.Large)";
rule11j = "If (Driving_Mode is Sport) and (SOC is High)  and (Velocity_Change is Steady) then (Coefficient is V.Large)";

% Medium SOC - balancing performance and energy conservation
rule2g = "If (Driving_Mode is Sport) and (SOC is Medium)  and (Slope is Flat) then (Coefficient is Large)";
rule2h = "If (Driving_Mode is Sport) and (SOC is Medium) and (Weight is Heavy) and (Slope is Ascent) then (Coefficient is V.V.Large)";
rule2i = "If (Driving_Mode is Sport) and (SOC is Medium) and (Slope is Ascent) then (Coefficient is V.Large)";
rule22i = "If (Driving_Mode is Sport) and (SOC is Medium)  and (Velocity_Change is Accelerating) then (Coefficient is V.Large)";
rule222i = "If (Driving_Mode is Sport) and (SOC is Medium)  and (Velocity_Change is Steady) then (Coefficient is Large)";

% Low SOC - conserving energy while providing necessary performance
rule3f = "If (Driving_Mode is Sport) and (SOC is Low) then (Coefficient is Normal)";
rule33f = "If (Driving_Mode is Sport) and (SOC is Low)  and (Velocity_Change is Accelerating) and (Weight is Heavy) then (Coefficient is Large)";
% rule for decceleration profiles in sport driving mode
rule11k = "If (Driving_Mode is Sport) and (Velocity_Change is Decelerating) then (Coefficient is V.V.Small)";

% Fuzzy rules for "Normal" Driving_Mode focusing on SOC levels

% High SOC - Optimal energy availability for a balanced approach
rule1l = "If (Driving_Mode is Normal) and (SOC is High)  and (Velocity_Change is Accelerating) then (Coefficient is V.Large)";
rule11l = "If (Driving_Mode is Normal) and (SOC is High) and (Weight is Heavy) and (Velocity_Change is Accelerating) then (Coefficient is V.V.Large)";
rule111l = "If (Driving_Mode is Normal) and (SOC is High) and (Weight is Heavy) and (Velocity_Change is Steady) then (Coefficient is V.Large)";
rule1m = "If (Driving_Mode is Normal) and (SOC is High) and  (Weight is Heavy) and (Slope is Ascent) then (Coefficient is V.V.Large)";
rule1n = "If (Driving_Mode is Normal) and (SOC is High) and  (Velocity_Change is Steady)  then (Coefficient is Large)";
rule1o = "If (Driving_Mode is Normal) and (SOC is High) and   (Velocity_Change is Decelerating) then (Coefficient is V.V.Small)";
% Medium SOC - Balancing performance with energy conservation
rule2j = "If (Driving_Mode is Normal) and (SOC is Medium) and (Slope is Ascent)  and (Weight is Heavy) then (Coefficient is V.Large)";
rule22j = "If (Driving_Mode is Normal) and (SOC is Medium) and (Velocity_Change is Accelerating) and (Weight is Heavy) then (Coefficient is V.Large)";
rule222j = "If (Driving_Mode is Normal) and (SOC is Medium) and (Velocity_Change is Accelerating) then (Coefficient is Large)";
rule2k =  "If (Driving_Mode is Normal) and (SOC is Medium) and (Velocity_Change is Steady) then (Coefficient is Normal)";
rule22k =  "If (Driving_Mode is Normal) and (SOC is Medium) and (Weight is Heavy) and (Velocity_Change is Steady) then (Coefficient is Large)";
rule222k = "If (Driving_Mode is Normal) and (SOC is Medium) and (Velocity_Change is Decelerating) then (Coefficient is V.V.Small)";

% Low SOC - Energy conservation is prioritized
rule3g = "If (Driving_Mode is Normal) and (SOC is Low) and  (Weight is Heavy) and (Slope is Ascent) then (Coefficient is Large)";
rule33g = "If (Driving_Mode is Normal) and (SOC is Low) and  (Weight is Heavy) and (Velocity_Change is Accelerating) then (Coefficient is Large)";
rule3h = "If (Driving_Mode is Normal) and (SOC is Low) and (Velocity_Change is Decelerating) then (Coefficient is V.V.Small)";
rule33h = "If (Driving_Mode is Normal) and (SOC is Low) and (Velocity_Change is Steady) then (Coefficient is Small)";
rule3i = "If (Driving_Mode is Normal) and (SOC is Low) and (Velocity_Change is Accelerating) then (Coefficient is Normal)";

rule_gen1 = "If (Slope is Descent) then (Coefficient is V.V.Small)";
rule_gen2 = "If (Slope is Descent) and (SOC is Medium )then (Coefficient is V.Small)";
rule_gen3 = "If (Velocity_Change is Decelerating) then (Coefficient is V.V.Small)";
rule_stop = "If (Current_Velocity is Stopped) then (Coefficient is Zero)";
rule_high_speed1 = "If (Current_Velocity is Fast)and (SOC is Medium ) then (Coefficient is V.Large)";
rule_high_speed2 = "If (Current_Velocity is Fast)and (SOC is High ) then (Coefficient is V.V.Large)";

%all fuzzy rules combined
rules_soc_high = [rule1a rule1b rule1c rule1d rule1e rule1f rule1g rule1h rule1i rule1j rule1k rule1l rule1m rule11l rule11d rule11c rule11b rule11a rule11j rule11i rule11h rule11g rule22e rule22f rule222e rule222f rule111h rule111g rule111l rule1n rule1o];
rules_soc_medium = [rule2a rule2b rule2c rule2d rule2e rule2f rule2g rule2h rule2i rule2j rule2k rule22k rule22e rule22d rule22c rule22a rule222k rule222j rule22j];
rules_soc_low = [rule3a rule3b rule3c rule3d rule3e rule3f rule3g rule3h rule33b rule33a rule33e rule33d rule33g rule3i rule33h rule333a];
fuzzy_rules = [rules_soc_high rules_soc_medium rules_soc_low rule11k rule_gen1 rule_gen2 rule_gen3 rule_stop rule_high_speed1 rule_high_speed2];
% FIS_Moteur_cc = parsrule(FIS_Moteur_cc,fuzzy_rules);
% Add rules to the FIS
FIS_Moteur_cc = addRule(FIS_Moteur_cc, fuzzy_rules);
%for i = 1:length(fuzzy_rules)
 %   rule_str = fuzzy_rules(i);
  %  FIS_Moteur_cc = addRule(FIS_Moteur_cc, rule_str);
%end



save FIS_Moteur_cc.mat
opt = gensurfOptions
opt.InputIndex = [5 2];

figure(8)
gensurf(FIS_Moteur_cc,opt)
zlabel('Motor Coefficient')
ylabel('Driving Mode')
set(findall(gcf,'type','line'),'linewidth',2.5);
view([-53.5 26.0])
annotation('textarrow',[0.5001 0.5001],[0.0775 0.1251],'String','Eco')
annotation('textarrow',[0.3911 0.3911],[0.1251 0.1585],'String','Sport')
annotation('textarrow',[0.2733 0.2733],[0.1561 0.2041],'String','Normal')
annotation('textarrow',[0.159 0.1572],[0.1731 0.237],'String','Comfort')

%annotation('textarrow',[0.56 0.4],[0.1 0.2],'String','Low')
%annotation('textarrow',[0.3911 0.3911],[0.1251 0.1585],'String','Medium')
%annotation('textarrow',[0.2733 0.2733],[0.1561 0.2041],'String','High')

opt = gensurfOptions
opt.InputIndex = [5 4]; 
figure(9)
gensurf(FIS_Moteur_cc,opt)
zlabel('Motor Coefficient')
ylabel('Road Slope  ')
set(findall(gcf,'type','line'),'linewidth',2.5);


opt = gensurfOptions
opt.InputIndex = [5 6];
figure(10)
gensurf(FIS_Moteur_cc,opt)
zlabel('Motor Coefficient')
ylabel('velocity change (m/s) ')
set(findall(gcf,'type','line'),'linewidth',2.5);


opt = gensurfOptions
opt.InputIndex = [5 7];
figure(11)
gensurf(FIS_Moteur_cc,opt)
zlabel('Motor Coefficient')
ylabel('velocity profile (m/s) ')
set(findall(gcf,'type','line'),'linewidth',2.5);