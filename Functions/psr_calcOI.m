function OI = psr_calcOI(xc,lagsec,lagwin)
%% psr_calcOI Computes the oscillatory index (OI) for a normalized-correlogram input
%
% INPUTS:
%   xc: normalized correlogram values (bounded between 0 and 1)
%   lagsec: corresponding time vector (in seconds)
%   lagwin: window to find peaks within (in seconds)
%
% OUTPUTS:
%   OI - oscillatory index (OI); 0 is no oscillation (i.e. completely
%        flat). 1 is perfect oscillation (i.e. trough is 0, oscillatory
%        peak is equal to identity peak at t=0)
%
% Written by Scott Kilianski
% Updated on 2024-12-19
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
posInds = lagsec>lagwin(1) & lagsec<lagwin(2);  % get the indices within the lag window
posxc = xc(posInds);                            % get the values
posTime = lagsec(posInds);                      % get the actual times (in seconds)
endF = 0; % end flag

% -- Find largest peak -- %
[op,opIDX] = findpeaks(posxc);
if isempty(op)
    endF = 1;
else
    [op, cIDX] = max(op);
    opTime = posTime(opIDX(cIDX));

    % -- Find largest trough BEFORE the peak -- %
    newInds = lagsec>lagwin(1) & lagsec<opTime;    % get the indices within the lag window
    posxc = xc(newInds);                    % get the values
end

% ------------------------------------------------------------------- % 
% Inserting try/catch below because findpeaks throws
% error if there are two few elements in 'posxc' 
% ------------------------------------------------------------------- % 
try
    [ot,otIDX] = findpeaks(-posxc);                 % find all troughs and corresponding indices
catch
    ot = [];
    otIDX = []; 
end

if isempty(ot)
    endF = 1;
else
    [ot, cIDX] = max(ot);                           % find the largest trough and index
    ot = -ot;                                       % re-convert the sign
    otTime = posTime(otIDX(cIDX));                  % get the proper sign
end

OI = op-ot; % peak minus trough

if endF % if there are no peaks or troughs
    OI = 0;
    opTime =[];
    otTime = [];
    op = [];
    ot = [];
end

% -- Optional plotting -- %%
figure; plot(lagsec,xc,'k');
hold on
scatter(opTime,op,'bo');
scatter(otTime,ot,'ro');

end % function end
