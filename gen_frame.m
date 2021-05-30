clear; clc; close all;
N = 64; guard_len = 16; % OFDM parameters
rate= 1/2; mod_type = '16qam';

zero_indecies = cat(2, 1, (28:38));   %indecies of zeroes
pilots_indecies = [44, 57, 8, 22];
data_indecies = setdiff(setdiff((1:64), pilots_indecies), zero_indecies);

input_length = 10000;
bin_data = randi([0,1], [1,input_length]);
[temp_preamble, temp_signal, temp_data] = construct_frame(bin_data, mod_type, rate);

%% Preamble & Signal post-processing
temp_preamble = reshape(temp_preamble,[],4).'; 
preamble = zeros(4,64); signal = zeros(1,64);

rest_indecies = setdiff((1:64), zero_indecies);
for i=1:4
    preamble(i,rest_indecies) = temp_preamble(i,:);
end
preamble = reshape(preamble.',1,[]);
signal(rest_indecies) = temp_signal;

%% Data post-processing
n_data = length(data_indecies);
% -- padding
data = padarray(temp_data, [0, n_data-ceil(rem(length(temp_data),n_data))], 0, 'post');
tx_pilots = temp_data(randperm(20, length(pilots_indecies))); % 20 is totally a random number
% -- add pilots
data = reshape(data,n_data,[]).';
final_data = zeros(size(data,1), 64);
for r=1:size(data,1)
    final_data(r,pilots_indecies) = tx_pilots;
    final_data(r,data_indecies) = data(r,:);
end
 final_data = reshape(final_data.', 1, []);
 % Constellation
 %scatterplot(final_data);
 % FINALLY, concatenate with the preamble and signal
 frame = [preamble, signal, final_data];  % READY for transmission
%% OFDM  
%serial to parallel conversion
parallel_frame = reshape(frame,N,[]);
%IFFT module
after_ifft = ifft(parallel_frame,[],1);
%Add cyclic prefix
with_cyclic_guards = [after_ifft(N-guard_len+1:end,:);after_ifft];
%parallel to serial conversion  
with_cyclic_guards = reshape(with_cyclic_guards,1,[]);

%% TODO#1: Channel  
h = [0.8208 + 0.2052*1i, 0.4104 + 0.1026*1i, 0.2052 + 0.2052*1i, 0.1026 + 0.1026*1i];
%with_cyclic_guards = conv(with_cyclic_guards,h);
%with_cyclic_guards = with_cyclic_guards(1:end-length(h)+1);
 
%% Rx Side
  % Given we have (with_cyclic_guards) as the input after channel equalization
%serial to parallel conversion
recv_with_prefix = reshape(with_cyclic_guards,N+guard_len,[]);
%Remove cyclic prefix
recv = recv_with_prefix(guard_len+1:end,:);
%FFT module
after_fft = fft(recv,[],1);
%parallel to serial
rec_frame = reshape(after_fft,1,[]);  %it should be the same as (frame)
% Separate preamble, signal, data
rec_preamble = rec_frame(1:64*4);
rec_signal = rec_frame(64*4+1:64*5);
rec_data = rec_frame(64*5+1:end);     %it should be the same as (final_data)
rec_data = reshape(rec_data, 64, []).';
% For each data symbol, extract (pilots, real_data)
 rx_data = [];
 rx_pilots = [];
for i=1:size(rec_data,1)
   rx_pilots = cat(1, rx_pilots, rec_data(i, pilots_indecies)); %% SHOULD BE CONCATENATED ...
   rx_data =  cat(2,rx_data, rec_data(i, data_indecies));  % multiple of 48 now
end
%% TODO#2: Channel Estimation
  % ---
  %channel_gains = estimate_channel(rec_preamble,'ZF');
  %Constructing ture preamble values
   L = [1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 1 -1 -1 1 1 -1 1 -1 1 -1 -1 -1 -1 -1 1 1 -1 -1 1 -1 1 -1 1 1 1 1];
   %zero_indecies = cat(2, 1, (28:38));   %indecies of zeroes
   %rest_indecies = setdiff((1:64), zero_indecies);
   %get the long recieved preamble symbols
   long_rec_preamble_1 = rec_preamble(rest_indecies + 64*2);
   long_rec_preamble_2 = rec_preamble(rest_indecies + 64*3);
   h1 = long_rec_preamble_1./L;
   h2 = long_rec_preamble_2./L;
   channel_gains = (h1+h2)./2;
%% TODO#3: Channel Equalization
  % ---
    rx_pilots_indecies = [44-12, 57-12, 8-1, 22-1];
    rx_data_indecies = setdiff((1:52), rx_pilots_indecies);
    data_channel_gains = channel_gains(rx_data_indecies);
    equalized_data = zeros(size(rx_data));
    for i = 1:48:length(rx_data)
        equalized_data(i:i+47) = rx_data(i:i+47)./data_channel_gains;
    end
 
% Costellation
 scatterplot(equalized_data);
% Symbol Demapping
 out_coded = demodulate(equalized_data, mod_type, 'binary');
 %% TODO#4: Extract data_length , rate from signal
% given that I know the rate and data length 
 rx_length = input_length; rx_rate = rate;%must be extracted from signal
 out_coded = out_coded(1:rx_length/rate);
% Viterbi decoder
trellis = poly2trellis(7,[133 171]);
tbdepth = round(2*(log2(trellis.numStates)/(1-rx_rate))); % Traceback depth for Viterbi decoder
out_decoded = vitdec(out_coded,trellis,tbdepth,'trunc','hard');
%% Check
BER = sum(out_decoded ~= bin_data)/length(out_decoded)  