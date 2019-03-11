% Load the time series of the RH step response (for this code, it's best to have
% a low sampling rate (I go with 10 minutes) when calculating the impulse response)
clear all 

trend = load('init_data/ITMY_trend_10min_int_longer.dat'); 
normalize = 3.13;
start = 3;

RH_calibration = 18*10^(-6); %(18 \mu diopters per watt)

t = trend(start:end,1); %Choose spherical power times that will best reflect the response to the RH step
sph_pow = trend(start:end,2);
sph_pow = smooth(sph_pow); %Get rid of high frequency noise 
for i = 0:(length(t)-1)  %Data viewer didn't give me the nicest times
    t_new(i+1) = i*10*60; 
end
ir = (sph_pow(2:end)-sph_pow(1:end-1)); %Calculate the impulse response
ir_smooth = smooth(smooth(ir))/normalize; %Smooth out and normalize the impulse response by the RH step size (to get you the transfer function)
Fs=1/(t_new(2)-t_new(1)); %Calculate sampling frequency
%%
[H,F]=freqz(ir_smooth(1:end),1,3000,Fs);  %Starting the design of a digital filter for the plant
model =  zpk(-2*pi*5e-6, -2.*pi.*[1.3e-5; 9.5e-5; 5e-5],1); %Crude fit of the digital filter (by hand)
model = model*abs(H(1))/abs(squeeze(freqresp(model, 0))); %Get the gain correct for the filter
[zm, pm, km] = zpkdata(model); % Get the zpk parameters for plant filter
model = squeeze(freqresp(model, 2.*pi.*F)); % Get frequency response of time series

figure(3)
loglog(F,abs(H),F,abs(model)); %plot the measured plant filter and digital plant filter
ylabel('Magnitude')
xlabel('Frequency [Hz]')
title('RH filter')
legend('measured', 'fitted')

savefig('saved_figures/matlab/RH_filter.fig') 

t_step = 1:60:(3*86400); % Sets time array to be used to calculate step response to filter
step_size = normalize; %reproduce the step response by using the original step that was set in the original data
opt0 = stepDataOptions('StepAmplitude',step_size); % Set step size to 1
new_sph_pow = step(zpk(zm,pm,km), t_step, opt0); % Get get lens response from amplitude 1 step into digital filter

%%
figure(4) %Plot the measured response next to response from digital filter
plot(t_new/3600, sph_pow + (-min(sph_pow)), 'Marker', 'o')
hold on
plot(t_step/3600, new_sph_pow, 'LineWidth', .75)
title(['Ring Heater Step response using the fitted zpk filter', ' ( step size ', num2str(step_size), ' )'],'FontSize', 25)
ldg = legend('measured', 'fitted'); 
ldg.FontSize = 12; 
ylabel('Spherical power [\mu diopters]','FontSize', 20)
xlabel('Time (hr)','FontSize', 20)

savefig('saved_figures/matlab/ring_heater_step_response.fig')
%%
inv_model = zpk(pm{1}, zm{1}, 1/km); %Invert the plant filter


[zlp, plp, klp] = butter(2, 1*pi*2e-4,'s'); % Low pass it to avoid that linear rise at high frequencies


inv_model = inv_model*zpk(zlp, plp , klp); 

[zlm, plm, klm] = zpkdata(inv_model); 

pls=plm{:};

inv_model = zpk(zlm, [pls(1),-2*pi*.1113055e-3,-2*pi*.1113055e-3],1/(1.9e-5)); %Level out high frequencies with DC gain

[znnf, pnnf, knnf] = zpkdata(inv_model);

inv_model_nnf = zpk(znnf{:}/(-2*pi), pnnf{:}/(-2*pi), knnf); 



%To achieve the same lens from the above step response from the plant
%filter, we need to find what the spherical power converges to and use that
%convering value to define a final lens we want to send into our inverse
%filter. 
power_request = 1; 
lens_step = RH_calibration*power_request; 
lens_ww = lens_step; 
opt = stepDataOptions('StepAmplitude',lens_ww); 
figure(5)
lens_step_up = step(inv_model, t_step, opt);
plot(t_step/3600, lens_step_up)
title(['Ring Heater inverse step response (change in lensing by ', num2str(lens_ww), ' diopters)'])
ylabel('RH power [W]')
savefig('saved_figures/matlab/inverted_step_response.fig')
inv_model_zpk = squeeze(freqresp(inv_model, 2.*pi.*F));  

%% Write text file
fileID = fopen(['saved_data/matlab/RH_time_series', num2str(power_request), 'W.txt'],'w');
A = [t_step; lens_step_up'/2.0];
fprintf(fileID,'%6f %7f \n',A);
fclose(fileID); 

%%
figure(7)
loglog(F, abs(inv_model_zpk))
title('RH inverse filter')
ylabel('Magnitude')
xlabel('Frequency [Hz]')

savefig('saved_figures/matlab/RH_inverse_filter.fig')

% filter comparison
test_butter = squeeze(freqresp(zpk(zlp, plp, klp), 2.*pi.*F));

figure(8)
loglog(F, abs(inv_model_zpk))
hold on
loglog(F, abs(test_butter))
hold on
loglog( F,abs(model))
%hold on
loglog(F, abs(inv_model_zpk).*abs(model))
title('Filter comparison')

savefig('saved_figures/matlab/filter_comparison.fig')

%% Apply power time series to plant to see how fast the spherical power converges
figure(10)
power_instruct = zpk(-2*pi*5e-6, -2.*pi.*[1.3e-5; 9.5e-5; 5e-5],1); 
power_instruct = power_instruct*abs(H(1))/abs(squeeze(freqresp(power_instruct, 0)));
y = lsim(power_instruct, lens_step_up, t_step); 
plot(t_step/3600, -y, t_step/3600, -new_sph_pow)
ylabel('Spherical power [1/m]')
xlabel('Time [hrs]')
title('ITMY spherical power response')
legend('new response','old response')
savefig('saved_figures/matlab/step_lens.fig')


%% Make sure that we get to the same power
figure(11)
model_zpk = zpk(-2*pi*5e-6, -2.*pi.*[1.3e-5; 9.5e-5; 5e-5],1);
model_zpk = model_zpk*abs(H(1))/abs(squeeze(freqresp(model_zpk, 0)));

plot(t_step/3600, lens_step_up, t_step/3600, ones(1,length(t_step)))
ylabel('RH power [W]')
ylim([0,2])
xlabel('Time [hrs]')
title('ITMY ring heater inputs')
legend('new input', 'old input')
savefig('saved_figures/matlab/power_compare.fig')


%% Plotting the Ring heater time series
rh_upper = load('/Users/daniel_vander-hyde/Documents/MATLAB/RH_time_constant_decrease/fin_data_longer/ITMY_RH_upper_9_30_2018.dat'); 
rh_lower = load('/Users/daniel_vander-hyde/Documents/MATLAB/RH_time_constant_decrease/fin_data_longer/ITMY_RH_lower_9_30_2018.dat');
figure(12)
t = (1:1:length(rh_upper))*60; 
plot((t_step/3600), lens_step_up+1)
hold on 
plot((t(49:end)/3600)-.8, (rh_upper(49:end,2)+rh_lower(49:end,2))); 
title('Inverted ring heater step response test (ITMY ring heaters)')
xlabel('Time (hours)')
ylabel('Ring Heater power (W)')
legend('model', 'H1:TCS\_ITMY\_RH\_UPPERPOWER + H1:TCS\_ITMY\_RH\_LOWERPOWER (startgps 1222308260) ')

%% 
sim_surf = load('/Users/daniel_vander-hyde/Documents/MATLAB/RH_time_constant_decrease/fin_data_longer/ITMY_sim_surf_9_30_2018.dat');
sim_sub = load('/Users/daniel_vander-hyde/Documents/MATLAB/RH_time_constant_decrease/fin_data_longer/ITMY_sim_sub_single_pass_9_30_2018.dat');
real_sph_pow = load('/Users/daniel_vander-hyde/Documents/MATLAB/RH_time_constant_decrease/fin_data_longer/ITMY_spherical_power_9_30_2018_longer.dat'); 

figure(13)
plot(t_step/3600, -y)
hold on 

title('Inverted ring heater step response test (ITMY spherical power)')
xlabel('Time (hours)')
ylabel('Spherical power (diopters)')


legend('model', 'H1:TCS-ITMY\_HWS\_PROBE\_SPHERICAL\_POWER (start gps 1222308260)', 'TCS simulation (start gps 1222308260)')

%% Write text file (Ring heater power with estimated spherical power)
fileID = fopen(['RH_time_series_neg', num2str(lens_ww), 'lens.txt'],'w');
A = [t_step; lens_step_up'/2.0; y'];
fprintf(fileID,'%6f %7f %.9f\n',A);
fclose(fileID); 


