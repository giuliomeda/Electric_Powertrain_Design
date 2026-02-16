%% Motor data
%File of the motor parameters

%% Maps 
load("nonlinearMaps_TeslaM3.mat");

%% Electric parameters
mot.param.resistance    = 0.00475;          %(Ohm)
mot.param.indApp_D      = interp2(mot.maps.currVec_D,mot.maps.currVec_Q,mot.maps.indApp_D,0,0);               %(H) 
mot.param.indApp_Q      = interp2(mot.maps.currVec_D,mot.maps.currVec_Q,mot.maps.indApp_Q,0,0);               %(H)
mot.param.fluxPM        = interp2(mot.maps.currVec_D,mot.maps.currVec_Q,mot.maps.fluxMap_D,0,0);              %(Vs)

mot.param.pp            = 3;                %Pole pairs

%% Mechanical parameters 
mot.param.inertiaM      = 0.001;      %(Kgm^2)
mot.param.frictionM     = 0.002;      %(Nms/rad)
%% Rated parameters
mot.rated.curr          = 800;         %(A)
mot.rated.volt          = 0;           %(V)
mot.rated.speed_rpm     = 2646/3*30/pi;         %(rpm)
mot.rated.speed_rads    = mot.rated.speed_rpm/60*2*pi; %(rads) 
mot.rated.torq          = 1.5*mot.param.pp*(...
    interp2(mot.maps.currVec_D,mot.maps.currVec_Q,mot.maps.fluxMap_D,-582,548)*548 - ...
    interp2(mot.maps.currVec_D,mot.maps.currVec_Q,mot.maps.fluxMap_Q,-582,548)*-(582));         %(Nm)
