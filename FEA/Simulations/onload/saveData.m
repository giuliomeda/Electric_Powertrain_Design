mot.maps.fluxVec_D = Map.fluxVec_D;
mot.maps.fluxVec_Q = Map.fluxVec_Q;

mot.maps.currMap_D = Map.currMap_D;
mot.maps.currMap_Q = Map.currMap_Q;

mot.maps.MTPA.torqVec = MTPA.nonlinear.torqVec;
mot.maps.MTPA.currVec_D = MTPA.nonlinear.curr_D;
mot.maps.MTPA.currVec_Q = MTPA.nonlinear.curr_Q;

mot.maps.indApp_D = Map.indApp_D;
mot.maps.indApp_Q = Map.indApp_Q;

mot.maps.indDiff_D = Map.indDiff_D;
mot.maps.indDiff_Q = Map.indDiff_Q;

mot.maps.indDiff_DQ = Map.indDiff_DQ;

mot.maps.fluxMap_D = Map.FluxD;
mot.maps.fluxMap_Q = Map.FluxQ;

mot.maps.currVec_D = Map.Id_vec;
mot.maps.currVec_Q = Map.Iq_vec;

save ("nonlinearMaps_TeslaM3.mat","mot")