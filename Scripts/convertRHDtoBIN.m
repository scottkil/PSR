function convertRHDtoBIN(dirPath)
%% convertRHDtoBIN Converts all RHD files in a directory to a combined BIN file
%
% INPUTS:
%   dirPath - path to directory containing RHD files
%
% OUTPUTS:
%   NO OUTPUTS, but creates the following binary files in directory specificed by dirPath:
%   'combined.bin'   - stores the probe-channel data as int16 (e.g.256xnumberOfTotalSamples values)
%   'timestamps.bin' - stores timestamps values as int32
%   'analogData.bin' - stores data from analog input channels as int16 (e.g. 8xnumberOfTotalSamples values)
%
% Written by Scott Kilianski
% Updated on 2023-11-01
%------------------------------------------------------------   %
%% ---- Function Body Here ---- %%%
funClock = tic;                             % start the function clock
dirFiles = dir(dirPath);                    % list all files in directory
rhdLog = contains({dirFiles.name},'.rhd');  % filter for only RHD files
filenames = {dirFiles(rhdLog).name};        % grab the RHD files only

combined_fid = fopen(fullfile(dirPath,'combined.bin'),'w');         % create 'combined.bin' file to store probe-channel data
ts_fid = fopen(fullfile(dirPath,'timestamps.bin'),'w');             % create 'timestamps.bin' to store timestamp vector
analog_fid = fopen(fullfile(dirPath,'analogData.bin'),'w');         % create 'analogData.bin' to store analog input channel data
rwbar = waitbar(0,'Converting RHD files to .bin and combining');    % make status bar
for fi = 1:length(filenames)
    fileClock = tic;                                    % start the file clock
    cf = fullfile(dirPath, filenames{fi});              % get next RHD files
    ID = sk_readRHD(cf);                                % read in Intan Data (ID)
    fwrite(combined_fid,ID.amplifier_data,'int16');     % write channel data to .bin file
    fwrite(ts_fid,ID.t_amplifier,'int32');              % write timestamps to .bin file
    fwrite(analog_fid,ID.board_adc_data,'int16');       % write analog data to .bin file
    waitbar(fi/length(filenames),rwbar);                % update the waitbar
    fprintf('RHD file %d took %.2f seconds\n',...
        fi,toc(fileClock));                             % print the time it took to read/write each RHD file
end
fclose('all'); % close all files                     
waitbar(1,rwbar,'Converting and combing RHD files complete!'); % update waitbar to finished
fprintf('Converting and combining all RHD files took %.2f minutes\n',... 
    toc(funClock)/60); % print the total time it took to run function
close(rwbar) % close waitbar

end % function end