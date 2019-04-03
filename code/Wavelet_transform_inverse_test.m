% Test for Matlab Wavelet transform
hold off;
clear all;

% Part I: Load data
travel_time = csvread("travel_time_data_link_1.csv",1,1);

%% Part II: Transform and plot transform
tt_mean = mean(travel_time);
tt_minus_mean = travel_time - tt_mean;
tt_wt = cwt(tt_minus_mean,'amor',1);
cwt(tt_minus_mean,'amor',1)

%%
[cfs,s] = cwt(tt_minus_mean,'amor',1);
helperCWTTimeFreqPlot(cfs,s,f,'surf','CWT of Travel Times','Minutes','Hz')

%% Part IIb: Inverse transform check
hold off;
plot((icwt(tt_wt))+tt_mean)
hold on;
plot(travel_time)

%CORRECT!
%%
hold off;
plot(travel_time)
hold on;
plot(icwt(cwt(travel_time))+tt_mean)



%% Part IIc: Additivity Check
hold off;
tt_dec1 = 0.3 .* tt_wt;
tt_dec2 = 0.7 .* tt_wt;
inv_dec1 = icwt(tt_dec1) ;
inv_dec2 = icwt(tt_dec2) ;
hold on;
plot(inv_dec1 + inv_dec2 + tt_mean)
plot(travel_time)

% CORRECT!

%% Part III: Compute modulus, power, phase and check against output from R
mod_wt = abs(tt_wt);
pow_wt = mod_wt.^2;
phase_wt = angle(tt_wt);
%h = heatmap(pow_wt(1:140, 1:10080))

%% Part IV: Decomposition in Background and Spikes
depth = size(pow_wt,1);
length = size(pow_wt,2);
spikes_complex = zeros(depth, length);
background_complex = zeros(depth, length);
for i = 1:depth
    if i == 1
        f = waitbar(i/depth, 'Progress...')
    else
        waitbar(i/depth, f, 'Progress...')
    end
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
   background_mod(over_limit) = sqrt(upper_lim);
   spikes_mod(over_limit) = mod_data(over_limit) - sqrt(upper_lim);
   
   background_complex(i,:) = complex(background_mod .* cos(arg_data), background_mod .* sin(arg_data));
   spikes_complex(i,:) = complex(spikes_mod .* cos(arg_data), spikes_mod .* sin(arg_data));   
end
 close(f)
%% Part V: Inverse Transform
background = icwt(background_complex);
spikes = icwt(spikes_complex);

%% Part VI: Reconstruction
background = background + tt_mean;
reconstructed = background + spikes;
%% Part VII: Plotting
hold off;


plot(travel_time)
hold on;
grid on;
plot(background)
plot(spikes)
%plot(reconstructed)
legend("Original Travel Time", "WT Background", "WT Spikes")
xlabel("Time")

%% Part VIII: Plot explorer
hold off;
hold on;
week_start = 0;
week_end = 4;

plot(travel_time(1+week_start*10080:week_end*10080),'LineWidth',2)
plot(background(1+week_start*10080:week_end*10080),'LineWidth',2)
plot(spikes(1+week_start*10080:week_end*10080),'LineWidth',2)
set(gca,'FontSize',20)
xticks([0 2*1440 4*1440 6*1440 8*1440 10*1440 12*1440 14*1440 16*1440 18*1440 20*1440 22*1440 24*1440 26*1440 28*1440])
xticklabels({'0','2','4','6','8','10','12','14','16','18','20','22','24','26','28'})
ylim([-25 220])
xlabel("Time [days]")
ylabel("Travel Time [seconds]")
[a,b,c,d]=legend("Original Travel Time", "WT Background", "WT Spikes")
hl = findobj(b,'type','line')
set(hl,'LineWidth',2)


%%
hold off;
hold on;
remainder = travel_time - reconstructed';
plot(remainder)
%%
hold off
histogram(remainder)

%%
h = gcf;
set(h,'PaperOrientation','Landscape')