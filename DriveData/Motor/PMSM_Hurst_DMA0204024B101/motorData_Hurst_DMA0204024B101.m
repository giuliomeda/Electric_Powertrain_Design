%% Motor data
%File of the motor parameters

%% Electric parameters
mot.param.resistance    = 0.342;        %(Ohm)
mot.param.indApp_D      = 0.32e-3;      %(H) 
mot.param.indApp_Q      = 0.32e-3;      %(H)
mot.param.fluxPM        = 8.2e-3;       %(Vs)

mot.param.pp            = 5;            %Pole pairs

%% Mechanical parameters 
mot.param.inertiaM      = 1.81e-5;      %(Kgm^2)
mot.param.frictionM     = 2.79e-5;      %(Nms/rad)
%% Rated parameters
mot.rated.curr          = 4.53;         %(A)
mot.rated.volt          = 20;           %(V)
mot.rated.speed_rpm     = 2800;         %(rpm)
mot.rated.speed_rads    = mot.rated.speed_rpm/60*2*pi; %(rads) 
mot.rated.torq          = 0.22;         %(Nm)
%% Maps 
% Linear relationship of the magnetic flux linkages and currents
mot.maps.currVec_D      = (-1:0.1:1)*mot.rated.curr; %creo un vettore di punti che utilizzerò per la relazione corr - flusso
mot.maps.currVec_Q      = (-1:0.1:1)*mot.rated.curr; %creo vettore identico anche per asse Q

mot.maps.fluxVec_D      = mot.param.fluxPM + mot.maps.currVec_D * mot.param.indApp_D;   %vettore di flussi asse d (caso lineare)
mot.maps.fluxVec_Q      = mot.maps.currVec_Q * mot.param.indApp_Q;

%creazione delle matrici di corrente asse D e Q con meshgrid (servono per plottare le superfici di flusso)
[mot.maps.currMap_D,...
    mot.maps.currMap_Q] = meshgrid(mot.maps.currVec_D,mot.maps.currVec_Q);

%return
%% Useful stuff
% maps plot 
surf(mot.maps.fluxVec_D,mot.maps.fluxVec_Q,mot.maps.currMap_D);
xlabel('flux D');
ylabel('flux Q');
zlabel('curr d');

figure;

surf(mot.maps.fluxVec_D,mot.maps.fluxVec_Q,mot.maps.currMap_Q);
xlabel('flux D');
ylabel('flux Q');
zlabel('curr q');
