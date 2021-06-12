function [with_cyclic_guards, temp_data] = WiFi_transmitter(bin_data, mod_type, rate, Nc, guard_len)
%% WiFi_transmitter: This function performs all required steps to transmit binary data using WiFi
% Parameters: 
    % bin_data: a row vector of the binary input data
    % mod_type: the needed modulation schemce (N-QAM, PSK, QPSK)
    % rate: 
    % Nc: Number of subcarriers
    % guard_len: Cyclic prefix length
% Returns:
    % with_cyclic_guards: the output OFDM complex symbols to be sent

%% --(1) Standards Specifications 
zero_indecies = cat(2, 1, (28:38));   %indecies of zeroes
pilots_indecies = [44, 57, 8, 22];
data_indecies = setdiff(setdiff((1:Nc), pilots_indecies), zero_indecies);

%% --(2) Construct the frame
%input_length = length(bin_data);
[temp_preamble, temp_signal, temp_data] = construct_frame(bin_data, mod_type, rate);

    
%% --(3) Preamble & Signal post-processing
temp_preamble = reshape(temp_preamble,[],4).';

% ---add_noise
% preamble_powers = sum(abs(temp_preamble).^2,2)/52;
% No_preamble = preamble_powers./(log2(2)*snr);
% noiseq = (randn(size(temp_preamble)) + 1j*randn(size(temp_preamble))) .* sqrt(No_preamble/2);
%noise_power = sum(abs(noiseq).^2)/length(noiseq);
%temp_preamble = temp_preamble + noiseq;

preamble = zeros(4,64); signal = zeros(1,64);

rest_indecies = setdiff((1:64), zero_indecies);
for i=1:4
    preamble(i,rest_indecies) = temp_preamble(i,:);
end
preamble = reshape(preamble.',1,[]);
signal(rest_indecies) = temp_signal;
%% --(4) Data post-processing
n_data = length(data_indecies);
% -- padding

data = padarray(temp_data, [0, n_data-ceil(rem(length(temp_data),n_data))], 0, 'post');
temp_data = data;

% -- add_noise
% data_power = sum(abs(temp_data).^2)/length(temp_data);
% No_data = data_power/(log2(64)*snr);
% noiseq = (randn(1,length(temp_data)) + 1j*randn(1,length(temp_data))) * sqrt(No_data/2);
% noise_power = sum(abs(noiseq).^2)/length(noiseq);
% %temp_data = temp_data + noiseq;

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
 frame = [preamble, signal, final_data];  % READY for transmission
 
%% --(5) OFDM  
%serial to parallel conversion
parallel_frame = reshape(frame,Nc,[]);
%IFFT module
after_ifft = ifft(parallel_frame,[],1);
%Add cyclic prefix
with_cyclic_guards = [after_ifft(Nc-guard_len+1:end,:);after_ifft];
%parallel to serial conversion  
with_cyclic_guards = reshape(with_cyclic_guards,1,[]);
end