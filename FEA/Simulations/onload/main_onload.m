close all
clear all
clc

%% Define the motor under test
run('TeslaModel3_MODEL_DATA.m')

MD.ModelPath = fullfile(projectRoot,'DriveData','Motor','IPM_TeslaModel3','FEA');

%% Set simulation parameters

RatedCurrent    = 802.1408;
ExtendedRange   = RatedCurrent*1.2;
NumPoints       = 10; % Number of points for each quadrant. 
% The axes points are not included in this number. That is, the final
% number of points for each axis will be (2*NumPoints+1)

%% Set plot and save functionality

SD.flagSaveResults = 1; % 1=save results, 0 = no plot

SD.PlotResults = 1; % 1=plot figures, 0 = no plot
SD.flagSaveFigures = 1; % 1=save figures, 0 = no save fig

SD.CurrentFolder    = fileparts(mfilename("fullpath"));
SD.ResultsFolder    = fullfile(SD.CurrentFolder,'results');
SD.FiguresFolder    = fullfile(SD.ResultsFolder,'figures');

%% Get current vectors for accurate map

% The minimum value of variable "NumPoints" must be at least 2
if NumPoints<2
    NumPoints = 2;
end

SD.Id_vec    = linspace(0.1,1,NumPoints)*ExtendedRange;
SD.Id_vec     = [-fliplr(SD.Id_vec) 0 SD.Id_vec];

SD.Iq_vec    = linspace(0.1,1,NumPoints)*ExtendedRange;
SD.Iq_vec     = [-fliplr(SD.Iq_vec) 0 SD.Iq_vec];

%% Create Flux Maps with FERAL functions
Map             = sim_mapping(MD, SD);

% Flip up to down map of FluxQ
%Map.FluxQ       = flipud(Map.FluxQ);

%% Maps inversion
Map     = mapsInversion_DEPT(Map);


% Save the results
save("MapsInversion", 'Map');

%% Plot results

% if SD.PlotResults
% 
%   plot_sim_mapping_results(Map);
% 
% end % if SD.PlotResults

%% Inductances

% Apparent
fluxPM          = interp2(Map.Id_vec,Map.Iq_vec,Map.FluxD,0,Map.Iq_vec);

Map.indApp_D    = (Map.FluxD-fluxPM)./Map.Id;
Map.indApp_Q    = Map.FluxQ./Map.Iq;

% get the d-axis indexes where the inductance is not defined
index_d     = isnan(Map.indApp_D);
[row_d,col_d] = ind2sub(size(Map.indApp_D),find(index_d));

% interpolate the inductance values for the d-axis at zero current
Map.indApp_D(isnan(Map.indApp_D)) = 0.5*(Map.indApp_D(:,col_d(1)-1)+Map.indApp_D(:,col_d(1)+1));

% find where the inductance q is -Inf
index_q     = isinf(Map.indApp_Q);
[row_q,col_q] = ind2sub(size(Map.indApp_Q),find(index_q));
% interpolate the inductance values for the q-axis at zero current
Map.indApp_Q(isinf(Map.indApp_Q)) = 0.5*(Map.indApp_Q(row_q(1)-1,:)+Map.indApp_Q(row_q(1)+1,:));


surf(Map.indApp_D)
hold on
surf(Map.indApp_Q)

% Differential

Map.indDiff_D   = gradient(Map.FluxD,Map.Id_vec(2)-Map.Id_vec(1));
Map.indDiff_Q   = gradient(Map.FluxQ',Map.Iq_vec(2)-Map.Iq_vec(1));

figure
surf(Map.indDiff_D)
hold on
surf(Map.indDiff_Q)

% Cross-differential
Map.indDiff_QD  = gradient(Map.FluxD',Map.Iq_vec(2)-Map.Iq_vec(1));
Map.indDiff_DQ  = gradient(Map.FluxQ,Map.Id_vec(2)-Map.Id_vec(1));

figure
surf(Map.indDiff_QD)
hold on 
surf(Map.indDiff_DQ')


%% MTPA curve: constant parameters

% Calculate the MTPA curve using the unsaturated inductances
Ld = interp2(Map.Id_vec,Map.Iq_vec,Map.indApp_D,0,0);
Lq = interp2(Map.Id_vec,Map.Iq_vec,Map.indApp_Q,0,0);
fluxPM  = interp2(Map.Id_vec,Map.Iq_vec,Map.FluxD,0,0);
p = 3;

% Range di correnti
I_range = linspace(0,max(Map.Iq_vec)); % [A]

% Inizializzazione vettori risultato
currAngle = zeros(1, length(I_range));

% Calcolo della curva MTPA
for ii = 1:length(I_range)
    I = I_range(ii);
    
    % Funzione obiettivo da massimizzare (coppia)
    torque_func = @(beta) 1/(1.5 * p * (fluxPM * I * sin(beta) + (Ld - Lq) * I^2 * sin(beta)*cos(beta)));
    
    % Trova l'angolo beta ottimale che massimizza la coppia
    currAngle(ii) = fminbnd(torque_func, 0, pi);

end

% get the MTPA curve in the dq plane
MTPA.linear.curr_D = I_range.*cos(currAngle);
MTPA.linear.curr_Q = I_range.*sin(currAngle);

% Visualizzazione risultati
figure;
plot(MTPA.linear.curr_D, MTPA.linear.curr_Q, 'b-', 'LineWidth', 2);
xlabel('id [A]');
ylabel('iq [A]');
title('Curva MTPA');
grid on;
axis equal;

% Calculate the torque map
torqMap = 1.5 * p * (fluxPM * Map.Iq + (Ld - Lq) .* Map.Id .* Map.Iq);

% plot the isotorque curves over the dq plane
hold on
contour(Map.Id_vec, Map.Iq_vec, torqMap, 'ShowText', 'on', 'LineWidth', 1.5);
%clabel(C, h, 'LabelSpacing', 200, 'FontSize', 8, 'Color', 'k');


% Calcolo e visualizzazione della coppia lungo la curva MTPA
torque = 1.5 * p * (fluxPM * MTPA.linear.curr_Q + (Ld - Lq) .* MTPA.linear.curr_D .* MTPA.linear.curr_Q);

figure;
plot(I_range, torque, 'r-', 'LineWidth', 2);
xlabel('Corrente [A]');
ylabel('Coppia [Nm]');
title('Coppia lungo la curva MTPA');
grid on;

%% MTPA with non linear 
MTPA.nonlinear.currAngle = zeros(1,length(I_range));

for ii = 1:length(I_range)
    I = I_range(ii);
    torq_fun_nonlinear = @(beta) - (1.5*p*...
            (interp2(Map.Id_vec,Map.Iq_vec,Map.FluxD,I*cos(beta),I*sin(beta)*I*sin(beta))) -... % Flux_D * curr_Q
            interp2(Map.Id_vec,Map.Iq_vec,Map.FluxQ,I*cos(beta),I*sin(beta)*I*cos(beta))...    %Flux_Q*curr_D
                );

    MTPA.nonlinear.currAngle = fminbnd(torq_fun_nonlinear,0,pi);



end

MTPA.nonlinear.curr_D = I_range.*cos(MTPA.nonlinear.currAngle);
MTPA.nonlinear.curr_D = I_range.*sin(MTPA.nonlinear.currAngle);

figure 
plot(MTPA.linear.curr_D,MTPA.linear.curr_Q)
hold on 
plot(MTPA.nonlinear.curr_D,MTPA.nonlinear.curr_Q)