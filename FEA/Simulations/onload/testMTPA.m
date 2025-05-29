close all; clear all; clc;
load('MapsInversion.mat');

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

%% MTPA with nonlinear 

MTPA.nonlinear.currAngle = zeros(1,length(I_range));

tic
for ii = 1:length(I_range)
    I = I_range(ii);
    torq_fun_nonlinear = @(beta) - (...
        1.5*p*( ...  % @(beta) è al variare di beta
        interp2(Map.Id_vec,Map.Iq_vec,Map.FluxD,I*cos(beta),I*sin(beta),"spline")*I*sin(beta) - ...% flux_D*curr_Q
        interp2(Map.Id_vec,Map.Iq_vec,Map.FluxQ,I*cos(beta),I*sin(beta),"spline")*I*cos(beta)... % flux_Q*curr_D
            )...
        );  

    MTPA.nonlinear.currAngle(ii) = fminbnd(torq_fun_nonlinear,0,pi);

end
toc
MTPA.nonlinear.curr_D = I_range.*cos(MTPA.nonlinear.currAngle);
MTPA.nonlinear.curr_Q = I_range.*sin(MTPA.nonlinear.currAngle);

MTPA.nonlinear.torqVec = 1.5*p*(...
    interp2(Map.Id_vec,Map.Iq_vec,Map.FluxD,MTPA.nonlinear.curr_D,MTPA.nonlinear.curr_Q).*...
    MTPA.nonlinear.curr_Q - ...
    interp2(Map.Id_vec,Map.Iq_vec,Map.FluxQ,MTPA.nonlinear.curr_D,MTPA.nonlinear.curr_Q).* ...
    MTPA.nonlinear.curr_D);


figure
plot(MTPA.linear.curr_D,MTPA.linear.curr_Q,'LineWidth', 1.5)
hold on
plot(MTPA.nonlinear.curr_D,MTPA.nonlinear.curr_Q,'LineWidth', 1.5)

torqMapNolinear = 1.5*p*(Map.FluxD.*Map.Iq_vec-Map.FluxQ.*Map.Id_vec);
% plot the isotorque curves over the dq plane
hold on
contour(Map.Id_vec, Map.Iq_vec, torqMapNolinear, 'ShowText', 'on', 'LineWidth', 1.5);

% le mappe sono mappe discontinue perchè ho dati tabellati, la interpolazione fa un interpolazione
% lineare, non deve andare contro la logica del sistema, meglio avere una
% curva senza discontinuità, vado a pulire la curva. 
% spline garantisce la continuità che ci siano interpolazioni derivabili,
% curva con molto meno rumore di interpolazione