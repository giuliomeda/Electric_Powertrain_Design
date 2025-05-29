function Map_OUT = mapsInversion_DEPT(Map_IN)
%MAPSINVERSION_DEPT Invert flux maps to generate current maps.
%   Detailed explanation goes here

Map_OUT         = Map_IN;

% Get temp variables
fluxMap_D       = Map_IN.FluxD;
fluxMap_Q       = Map_IN.FluxQ;

currVec_D       = Map_IN.Id_vec;
currVec_Q       = Map_IN.Iq_vec;


% Validate input dimensions
assert(size(fluxMap_D, 1) == length(currVec_D), 'Mismatch in rows of FluxD_map and currVec_D');
assert(size(fluxMap_Q, 2) == length(currVec_Q), 'Mismatch in columns of FluxD_map and currVec_Q');

% Create grids for original flux and current
[currGrid_D, currGrid_Q]    = meshgrid(currVec_D, currVec_Q);
currFlat_D                  = currGrid_D(:);
currFlat_Q                  = currGrid_Q(:);
FluxD_flat                  = fluxMap_D(:);
FluxQ_flat                  = fluxMap_Q(:);

% Define resolution of the inverted maps
fluxVecNew_D   = linspace(min(FluxD_flat), max(FluxD_flat), length(currVec_D));
fluxVecNew_Q   = linspace(min(FluxQ_flat), max(FluxQ_flat), length(currVec_Q));
[fluxGridNew_D, fluxGridNew_Q] = meshgrid(fluxVecNew_D, fluxVecNew_Q);

% Extrapolation warning
if any(fluxVecNew_D < min(FluxD_flat) | fluxVecNew_D > max(FluxD_flat)) || ...
   any(fluxVecNew_Q < min(FluxQ_flat) | fluxVecNew_Q > max(FluxQ_flat))
    warning('Extrapolated flux values may be inaccurate. Verify simulation range.');
end

% Interpolation for Id and Iq
currInterpolant_D = scatteredInterpolant(FluxD_flat, FluxQ_flat, currFlat_D, 'natural', 'nearest');
currInterpolant_Q = scatteredInterpolant(FluxD_flat, FluxQ_flat, currFlat_Q, 'natural', 'nearest');

% Set output Map structure for results
Map_OUT.currMap_D = currInterpolant_D(fluxGridNew_D, fluxGridNew_Q);
Map_OUT.currMap_Q = currInterpolant_Q(fluxGridNew_D, fluxGridNew_Q);
Map_OUT.fluxVec_D = fluxVecNew_D;
Map_OUT.fluxVec_Q = fluxVecNew_Q;

end

