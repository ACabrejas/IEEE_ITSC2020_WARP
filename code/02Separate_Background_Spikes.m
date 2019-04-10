% Test for Matlab Wavelet transform
%clear all;

motorway = 'm6';

normalisation = true;

if motorway == 'm6'
    length_links = 14;
elseif motorway == 'm11'
    length_links = 25;
elseif motorway == 'm25'
    length_links = 61;
end

wavelet = 'morse';

if wavelet == 'morse'
    wavename = 'morse';
elseif wavelet == 'morlet'
    wavename = 'amor';
elseif wavelet == 'bump'
    wavename = 'bump';
end

f = waitbar(0, 'Progress...')

for j=1:length_links

    waitbar(j/length_links, f)
    
    % Load data
    travel_time = csvread(strcat('./02_extracted_link_data/',motorway,'_link_',string(j),'.csv'));
    
    % Normalisation Step
    if normalisation
        norm_factor = max(travel_time);
        travel_time = travel_time/norm_factor;
    end
    
    % Statistics
    tt_mean = mean(travel_time);
    tt_minus_mean = travel_time - tt_mean;
    tt_wt = cwt(tt_minus_mean,wavename,1);
    
    % Manually calculate modulus, power, phase
    mod_wt = abs(tt_wt);
    pow_wt = mod_wt.^2;
    phase_wt = angle(tt_wt);
    
    %Choose depth of CWT
    depth = size(pow_wt,1);
    length = size(pow_wt,2);
    spikes_complex = zeros(depth, length);
    background_complex = zeros(depth, length);
    
    % CWT
    for i = 1:depth
        % Create containers
        background_mod = zeros(1, length);
        spikes_mod = zeros(1, length);
        % Fetch data for this timescale
        scale_data = pow_wt(i,:); 
        mod_data = mod_wt(i,:);
        arg_data = phase_wt(i,:);
   
        % Statistical analysis of data
        median_power = median(scale_data);
        iqr_power = iqr(scale_data);
        upper_lim = median_power + 1*iqr_power;
   
        % Logical vectors for positions within and over limits.
        over_limit = scale_data>upper_lim;
        within_limit = ~over_limit;
   
        % Background: Copy data if within limits, it over limits, use limit.
        background_mod(within_limit) = mod_data(within_limit);
        %background_mod(over_limit) = upper_lim;
        background_mod(over_limit) = sqrt(upper_lim);
        %spikes_mod(over_limit) = mod_data(over_limit) - upper_lim;
        spikes_mod(over_limit) = mod_data(over_limit) - sqrt(upper_lim);

        background_complex(i,:) = complex(background_mod .* cos(arg_data), background_mod .* sin(arg_data));
        spikes_complex(i,:) = complex(spikes_mod .* cos(arg_data), spikes_mod .* sin(arg_data));   
    end
    % Inverse Transform
    background = icwt(background_complex);
    spikes = icwt(spikes_complex);
    
    % Reconstruction
    background = background + tt_mean;
    
    % De-normalization
    if normalisation
        background = background * norm_factor;
        spikes = spikes * norm_factor;
        travel_time = travel_time * norm_factor;
    end
    
    reconstructed = background + spikes;
    
    % Filenames out
    fileout_background = strcat('./03_background_spikes_matlab_to_r/',wavelet,'/',motorway,'_link_',string(j),'_background.csv');
    fileout_spikes     = strcat('./03_background_spikes_matlab_to_r/',wavelet,'/',motorway,'_link_',string(j),'_spikes.csv');
    
    % Write files out
    %writematrix(background, fileout_background)
    csvwrite(fileout_background, background')
    disp(strcat('Link ', string(j) ,': successfully written Background to file.'))
    %writematrix(spikes, fileout_spikes)
    csvwrite(fileout_spikes, spikes')
    disp(strcat('Link ', string(j) ,': successfully written Spikes to file.'))
    
    hold off;
    plot(travel_time);
    hold on;
    plot(reconstructed);
    legend('Travel Time', 'Reconstructed Series');
    saveas(gcf, strcat('./03_background_spikes_matlab_to_r/',wavelet,'/',motorway,'_link_',string(j),'.png'));
    hold off;
    plot(reconstructed-travel_time');
    legend('Reconstructed - Travel Time');
    saveas(gcf, strcat('./03_background_spikes_matlab_to_r/',wavelet,'/',motorway,'_link_',string(j),'_difference_tt_reconstruction.png'));

    
end
close(f)

%% Reconstruction plot:
% Plots the Original series, reconstructed background and spikes.
% Spike series is modified by setting all spikes under a threshold to zero.
%

motorway = 'm6';
wavelet = 'morse';
link = 3;
normalisation = true;
if wavelet == 'morse'
    wavename = 'morse';
elseif wavelet == 'morlet'
    wavename = 'amor';
elseif wavelet == 'bump'
    wavename = 'bump';
end
travel_time = csvread(strcat('./02_extracted_link_data/',motorway,'_link_',string(link),'.csv'));



% Normalization step
if normalisation
    norm_factor = max(travel_time);
    travel_time = travel_time/norm_factor;
end

% Statistics
tt_mean = mean(travel_time);
tt_minus_mean = travel_time - tt_mean;
tt_wt = cwt(tt_minus_mean,wavename,1);

% Manually calculate modulus, power, phase
mod_wt = abs(tt_wt);
pow_wt = mod_wt.^2;
phase_wt = angle(tt_wt);

%Choose depth of CWT
depth = size(pow_wt,1);
length = size(pow_wt,2);
spikes_complex = zeros(depth, length);
background_complex = zeros(depth, length);

% CWT
for i = 1:depth
    % Create containers
    background_mod = zeros(1, length);
    spikes_mod = zeros(1, length);
    % Fetch data for this timescale
    scale_data = pow_wt(i,:); 
    mod_data = mod_wt(i,:);
    arg_data = phase_wt(i,:);

    % Statistical analysis of data
    median_power = median(scale_data);
    iqr_power = iqr(scale_data);
    upper_lim = median_power + 1*iqr_power;

    % Logical vectors for positions within and over limits.
    over_limit = scale_data>upper_lim;
    within_limit = ~over_limit;

    % Background: Copy data if within limits, it over limits, use limit.
    background_mod(within_limit) = mod_data(within_limit);
    %background_mod(over_limit) = upper_lim;
    background_mod(over_limit) = sqrt(upper_lim);
    %spikes_mod(over_limit) = mod_data(over_limit) - upper_lim;
    spikes_mod(over_limit) = mod_data(over_limit) - sqrt(upper_lim);

    background_complex(i,:) = complex(background_mod .* cos(arg_data), background_mod .* sin(arg_data));
    spikes_complex(i,:) = complex(spikes_mod .* cos(arg_data), spikes_mod .* sin(arg_data));   
end
% Inverse Transform
background = icwt(background_complex);
spikes = icwt(spikes_complex);


% Reconstruction
background = background + tt_mean;

if normalisation
    background = background * norm_factor;
    spikes = spikes * norm_factor;
    travel_time = travel_time * norm_factor;
end

reconstructed = background + spikes;


spike_min = 5;
hold off;
plot(travel_time)
hold on;
plot(background)
spikesnew = spikes;
spikesnew(spikes<spike_min) = 0;
plot(spikesnew)
legend('Travel Time', 'WT Background', 'WT Spikes')
