clear; clc;
N = 64; N_FFT = N; guard_len = 16; % OFDM parameters
rate= 1/2; mod_type = '16qam';

zero_indecies = cat(2, 1, (28:38));   %indecies of zeroes
pilots_indecies = [44, 57, 8, 22];
data_indecies = setdiff(setdiff((1:64), pilots_indecies), zero_indecies);

bin_data = randi([0,1], [1,1000]);
[temp_preamble, temp_signal, temp_data] = construct_frame(bin_data, mod_type, rate);

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
 final_data = reshape(conj(final_data'), 1, []); % READY for transmission

%% OFDM
stream = final_data; %transition
%serial to parallel conversion
parallel_stream = reshape(stream,N,[]);
%IFFT module
after_ifft = ifft(parallel_stream,N_FFT,1);
%Add cyclic prefix
with_cyclic_guards = [after_ifft(N-guard_len+1:end,:);after_ifft];
%parallel to serial conversion  
with_cyclic_guards = reshape(with_cyclic_guards,1,[]);
