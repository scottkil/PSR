function [CSDmat, zs] = psr_calcCSD(traces,chDepths)
%% psr_calcCSD Calculates CSD across provided channels
%
% INPUTS:
%   traces - NxT matrix with voltages (in VOLTS). N is # electrodes. T is # samples
%   chDepths - depths of electrodes, in microns in descending order. chDepth(1) should be >0
%
% OUTPUTS:
%   CSD - CSD matrix in uA/mm^3 units
%   zs - depths of all the rows in the CSD matrix
%
% Written by Scott Kilianski
% Updated on 2024-05-21
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
% -- Adjustable parameters for estimating CSD -- %
gauss_sigma = 0.15*1e-3; % mm -> m. For CSD smoothing
gfilter_range = 5*gauss_sigma; % numeric filter must be finite in extent. For CSD smoothing
diam = .5*1e-3; %diameter of disks in [m]. 0.5mm default
cond_top = 0.3; %S/m, conductivity of brain surface 
cond = 0.3; %S/m, conductivity of extracellular fluid

% -- Calculating CSD using cubic spline method -- %
el_pos = chDepths'.*1e-6; % convert microns to meters
% -- compute spline iCSD: -- %
Fcs = F_cubic_spline(el_pos,diam,cond,cond_top);  % make splines
[zs,CSD_cs] = make_cubic_splines(el_pos,traces,Fcs); % Creates the F matrix of the cubic spline method
[zs,CSD_cs]=gaussian_filtering(zs,CSD_cs,gauss_sigma,gfilter_range); % gaussian filter the output
unit_scale = 1e-3; % A/m^3 -> muA/mm^3
CSDmat = CSD_cs*unit_scale;

end % function end