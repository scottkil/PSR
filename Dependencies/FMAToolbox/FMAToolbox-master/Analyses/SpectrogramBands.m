function bands = SpectrogramBands(spectrogram,frequencies,varargin)

%SpectrogramBands - Determine running power in physiological bands.
%
%  USAGE
%
%    bands = SpectrogramBands(spectrogram,frequencies,<options>)
%
%    spectrogram    spectrogram obtained using <a href="matlab:help MTSpectrogram">MTSpectrogram</a>
%    frequencies    frequency bins for spectrogram
%    <options>      optional list of property-value pairs (see table below)
%
%    =========================================================================
%     Properties    Values
%    -------------------------------------------------------------------------
%     'smooth'      smoothing for ratio (0 = no smoothing) (default = 2)
%     'delta'       set delta band (default = [0 4])
%     'theta'       set theta band (default = [7 10])
%     'spindles'    set spindle band (default = [10 20])
%     'lowGamma'    set low gamma band (default = [30 80])
%     'highGamma'   set high gamma band (default = [80 120])
%     'ripples'     set ripple band (default = [100 250])
%     'broadLow'    set broad low frequency band (default = [1 12])
%     'amyGamma'    set amygdala gamma band (default = [45 65])
%    =========================================================================
%
%  OUTPUT
%
%    bands.delta      delta power
%    bands.theta      theta power
%    bands.spindles   spindle power
%    bands.lowGamma   low gamma power
%    bands.highGamma  high gamma power
%    bands.ripples    ripple power
%    bands.broadLow   broad low frequency power
%    bands.amyGamma   amygdala gamma power
%
%    bands.ratios.hippocampus      theta/delta ratio
%    bands.ratios.cortex           [0.5 4.5]/[0.5 9] and [0.5 20]/[0.5 55]
%    bands.ratios.amygdala         gamma/broad low ratio
%
%    Heuristic ratios for cortex are from Gervasoni et al. (2004).
%
%  SEE
%
%    See also MTSpectrogram.

% Copyright (C) 2004-2014 by Michaël Zugaro, Gabrielle Girardeau
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.

% Defaults
smooth = 2;
delta = [0 4];
theta = [7 10];
spindles = [10 20];
lowGamma = [30 80];
highGamma = [80 120];
ripples = [100 250];
broadLow = [1 12];
amyGamma = [45 65];

% Check number of parameters
if nargin < 2,
  error('Incorrect number of parameters (type ''help <a href="matlab:help SpectrogramBands">SpectrogramBands</a>'' for details).');
end

% Check parameter sizes
if ~isdmatrix(spectrogram),
	error('Parameter ''spectrogram'' is not a matrix (type ''help <a href="matlab:help SpectrogramBands">SpectrogramBands</a>'' for details).');
end
if ~isdvector(frequencies) | length(frequencies) ~= size(spectrogram,1),
	error('Parameter ''frequencies'' is not a vector or does not match spectrogram size (type ''help <a href="matlab:help SpectrogramBands">SpectrogramBands</a>'' for details).');
end

% Parse options
for i = 1:2:length(varargin),
	if ~ischar(varargin{i}),
		error(['Parameter ' num2str(i) ' is not a property (type ''help <a href="matlab:help SpectrogramBands">SpectrogramBands</a>'' for details).']);
	end
	switch(lower(varargin{i})),
		case 'smooth',
			smooth = varargin{i+1};
			if ~isdscalar(smooth,'>=0'),
				error('Incorrect value for property ''smooth'' (type ''help <a href="matlab:help SpectrogramBands">SpectrogramBands</a>'' for details).');
			end
		case 'delta',
			delta = varargin{i+1};
			if ~isdvector(delta,'>=0','<','#2'),
				error('Incorrect value for property ''delta'' (type ''help <a href="matlab:help SpectrogramBands">SpectrogramBands</a>'' for details).');
			end
		case 'theta',
			theta = varargin{i+1};
			if ~isdvector(theta,'>=0','<','#2'),
				error('Incorrect value for property ''theta'' (type ''help <a href="matlab:help SpectrogramBands">SpectrogramBands</a>'' for details).');
			end
		case 'spindles',
			spindles = varargin{i+1};
			if ~isdvector(spindles,'>=0','<','#2'),
				error('Incorrect value for property ''spindles'' (type ''help <a href="matlab:help SpectrogramBands">SpectrogramBands</a>'' for details).');
			end
		case 'lowgamma',
			lowGamma = varargin{i+1};
			if ~isdvector(lowGamma,'>=0','<','#2'),
				error('Incorrect value for property ''lowGamma'' (type ''help <a href="matlab:help SpectrogramBands">SpectrogramBands</a>'' for details).');
			end
		case 'highgamma',
			highGamma = varargin{i+1};
			if ~isdvector(highGamma,'>=0','<','#2'),
				error('Incorrect value for property ''highGamma'' (type ''help <a href="matlab:help SpectrogramBands">SpectrogramBands</a>'' for details).');
			end
		case 'ripples',
			ripples = varargin{i+1};
			if ~isdvector(ripples,'>=0','<','#2'),
				error('Incorrect value for property ''ripples'' (type ''help <a href="matlab:help SpectrogramBands">SpectrogramBands</a>'' for details).');
			end
		case 'broadlow',
			broadLow = varargin{i+1};
			if ~isdvector(broadLow,'>=0','<','#2'),
				error('Incorrect value for property ''broadLow'' (type ''help <a href="matlab:help SpectrogramBands">SpectrogramBands</a>'' for details).');
			end
		case 'amygamma',
			amyGamma = varargin{i+1};
			if ~isdvector(amyGamma,'>=0','<','#2'),
				error('Incorrect value for property ''amyGamma'' (type ''help <a href="matlab:help SpectrogramBands">SpectrogramBands</a>'' for details).');
			end
		otherwise,
			error(['Unknown property ''' num2str(varargin{i}) ''' (type ''help <a href="matlab:help SpectrogramBands">SpectrogramBands</a>'' for details).']);
	end
end

n = size(spectrogram,1);

% Select relevant frequency bins
thetaBins = frequencies >= theta(1) & frequencies <= theta(2);
deltaBins = frequencies >= delta(1) & frequencies <= delta(2);
spindleBins = frequencies >= spindles(1) & frequencies <= spindles(2);
lowGammaBins = frequencies >= lowGamma(1) & frequencies <= lowGamma(2);
highGammaBins = frequencies >= highGamma(1) & frequencies <= highGamma(2);
rippleBins = frequencies >= ripples(1) & frequencies <= ripples(2);
broadLowBins = frequencies >= broadLow(1) & frequencies <= broadLow(2);
amyGammaBins = frequencies >= amyGamma(1) & frequencies <= amyGamma(2);

% Compute physiological bands
bands.theta = mean(spectrogram(thetaBins,:),1)';
bands.delta = mean(spectrogram(deltaBins,:))';
bands.spindles = mean(spectrogram(spindleBins,:))';
bands.lowGamma = mean(spectrogram(lowGammaBins,:))';
bands.highGamma = mean(spectrogram(highGammaBins,:))';
bands.ripples = mean(spectrogram(rippleBins,:))';
bands.broadLow = mean(spectrogram(broadLowBins,:))';
bands.amyGamma = mean(spectrogram(amyGammaBins,:))';

% Theta/delta ratio
bands.ratios.hippocampus = Smooth(bands.theta./(bands.delta+eps),smooth);
bands.ratio = bands.ratios.hippocampus;

% Heuristic ratios from Gervasoni et al. (2004)
range1 = [0.5 4.5];
bins1 = frequencies >= range1(1) & frequencies <= range1(2);
band1 =  mean(spectrogram(bins1,:))';
range2 = [0.5 9];
bins2 = frequencies >= range2(1) & frequencies <= range2(2);
band2 =  mean(spectrogram(bins2,:))';
bands.ratios.cortex(:,1) = Smooth(band1./(band2+eps),smooth);
bands.ratio1 = bands.ratios.cortex;

range1 = [0.5 20];
bins1 = frequencies >= range1(1) & frequencies <= range1(2);
band1 =  mean(spectrogram(bins1,:))';
range2 = [0.5 55];
bins2 = frequencies >= range2(1) & frequencies <= range2(2);
band2 =  mean(spectrogram(bins2,:))';
bands.ratios.cortex(:,2) = Smooth(band1./(band2+eps),smooth);
bands.ratio2 = bands.ratios.cortex(:,2);

% Amygdala ratio
bands.ratios.amygdala = Smooth(bands.amyGamma./(bands.broadLow+eps),smooth);
bands.ratio3 = bands.ratios.amygdala;
