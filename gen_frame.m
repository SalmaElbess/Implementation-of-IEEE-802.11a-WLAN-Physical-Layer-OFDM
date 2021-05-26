clear; clc;
N = 64; N_FFT = N; guard_len = 16; % OFDM parameters
rate= 1/2; mod_type = '16qam';

zero_indecies = cat(2, 1, (28:38));   %indecies of zeroes
pilots_indecies = [44, 57, 8, 22];
data_indecies = setdiff(setdiff((1:64), pilots_indecies), zero_indecies);

bin_data = randi([0,1], [1,1000]);
[temp_preamble, temp_signal, temp_data, ref_demod] = construct_frame(bin_data, mod_type, rate);

%% Preamble & Signal post-processing
temp_preamble = reshape(temp_preamble,[],4)'; 
preamble = zeros(4,64); signal = zeros(1,64);

rest_indecies = setdiff((1:64), zero_indecies);
for i=1:4
    preamble(rest_indecies) = temp_preamble(i,:);
end
preamble = reshape(preamble',1,[]);
signal(rest_indecies) = temp_signal;

%% Data post-processing
n_data = length(data_indecies);
% -- padding
data = padarray(temp_data, [0, n_data-ceil(rem(length(temp_data),n_data))], 0, 'post');
tx_pilots = data(randperm(n_data, length(pilots_indecies)));
% -- add pilots
data = conj(reshape(data,n_data,[])');
final_data = zeros(size(data,1), 64);
for r=1:size(data,1)
    final_data(r,pilots_indecies) = tx_pilots;
    final_data(r,data_indecies) = data(r,:);
end
 final_data = reshape(conj(final_data'), 1, []);
 % FINALLY, concatenate with the preamble and signal
 stream = [preamble, signal, final_data];  % READY for transmission
%% OFDM  
%serial to parallel conversion
parallel_stream = reshape(stream,N,[]);
%IFFT module
after_ifft = ifft(parallel_stream,N_FFT,1);
%Add cyclic prefix
with_cyclic_guards = [after_ifft(N-guard_len+1:end,:);after_ifft];
%parallel to serial conversion  
with_cyclic_guards = reshape(with_cyclic_guards,1,[]);

%% Channel / Channel Estimation / Channel Equalization
  % ---
%% Rx Side
  % Given we have (with_cyclic_guards) as the input after channel equalization
%serial to parallel conversion
recv_with_prefix = reshape(with_cyclic_guards,N+guard_len,[]);
%Remove cyclic prefix
recv = recv_with_prefix(guard_len+1:end,:);
%FFT module
after_fft = fft(recv,N_FFT,1);
%parallel to serial
rec_symbols = reshape(after_fft,1,[]);  %it should be the same as (stream)
% Separate preamble, signal, data
rec_preamble = rec_symbols(1:64*4);
rec_signal = rec_symbols(64*4+1:64*5);
rec_data = rec_symbols(64*5+1:end);     %it should be the same as (final_data)
rec_data = conj(reshape(rec_data, 64, [])');
% For each data symbol, extract (pilots, real_data)
 rx_data = [];
for i=1:size(rec_data,1)
   rx_pilot = rec_data(i, pilots_indecies); %% SHOULD BE CONCATENATED ...
   rx_data =  cat(2,rx_data, rec_data(i, data_indecies));  % multiple of 48 now
end

% Symbol Demapping
out_coded = demodulate(rx_data, mod_type, ref_demod, 'binary');
 % given that I know the rate and data length (2000)
out_coded = out_coded(1:2000);
 % Viterbi decoder
trellis = poly2trellis(7,[133 171]);
tbdepth = 2*(log2(trellis.numStates)/(1-rate)); % Traceback depth for Viterbi decoder
out_decoded = vitdec(out_coded,trellis,tbdepth,'trunc','hard');
%% Check
BER = sum(out_decoded ~= bin_data)/length(out_decoded)  