function out_decoded = WiFi_receiver(input_stream, Nc, guard_len, estimation_method)
%% WiFi_receiver: This function performs all required steps to receive complex symbols and convert them to binary data using WiFi
% Parameters: 
    % input_stream: the input OFDM complex symbols to received
    % Nc: Number of subcarriers
    % guard_len: Cyclic prefix length
% Returns:
    % out_decoded: the output binary data received
if nargin < 4
   estimation_method = 'ZF'; 
end
 %% --(1) Standards Specifications 
zero_indecies = cat(2, 1, (28:38));   %indecies of zeroes
pilots_indecies = [44, 57, 8, 22];
data_indecies = setdiff(setdiff((1:Nc), pilots_indecies), zero_indecies);
gray_scheme_64QAM = [4 5 7 6 2 3 1 0 
                       12 13 15 14 10 11 9 8
                       28 29 31 30 26 27 25 24
                       20 21 23 22 18 19 17 16
                       52 53 55 54 50 51 49 48
                       60 61 63 62 58 59 57 56
                       44 45 47 46 42 43 41 40
                       36 37 39 38 34 35 33 32]; 
 %% --(2) OFDM Demodulation and Frame Split 
recv_with_prefix = reshape(input_stream,Nc + guard_len,[]);
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
rec_data = conj(reshape(rec_data, 64, [])');
% For each data symbol, extract (pilots, real_data)
 rx_data = [];
 rx_pilots = [];
for i=1:size(rec_data,1)
   rx_pilots = cat(1,rx_pilots,rec_data(i, pilots_indecies)); 
   rx_data =  cat(2,rx_data, rec_data(i, data_indecies));  % multiple of 48 now
end

%% TODO#2: --(3) Channel Estimation
  % --- using rec_preamble
  channel_gains = estimate_channel(rec_preamble,estimation_method);
%% TODO#3: --(4) Channel Equalization
  % ---
  rx_data_equalized = equalize_channel(rx_data,channel_gains,estimation_method);
 %% TODO#4: --(5) Extract data_length , rate from signal & use them to eliminate the padding
useful_ind = setdiff([1:64],zero_indecies);
rec_signal= rec_signal(useful_ind);
rec_signal = demodulate(rec_signal, 'bpsk', 'binary');
rec_signal_decoded = viterbi_decoder(rec_signal,1/2);
R=num2str(rec_signal_decoded(1:4)')';
rx_length = bin2dec(num2str(rec_signal_decoded(5:16)));
switch R
    case '1101'
        mod_type = 'BPSK';
        rx_rate = 1/2;
        gray_scheme = -1;
    case '1111'
        mod_type = 'BPSK';
        rx_rate = 3/4;
        gray_scheme = -1;
    case '0101'
        mod_type = 'QPSK';
        rx_rate = 1/2;
        gray_scheme = [1 0 3 2];
    case '0111'
        mod_type = 'QPSK';
        rx_rate = 3/4;
        gray_scheme = [1 0 3 2];
    case '1001'
        mod_type = '16QAM';
        rx_rate = 1/2;
        gray_scheme = [2 3 1 0 6 7 5 4 14 15 13 12 10 11 9 8];
    case '1011'
        mod_type = '16QAM';
        rx_rate = 3/4;
        gray_scheme = [2 3 1 0 6 7 5 4 14 15 13 12 10 11 9 8];
    case '0001'
        mod_type = '64QAM';
        rx_rate = 2/3;
        gray_scheme = gray_scheme_64QAM;
    case '0011'
        mod_type = '64QAM';
        rx_rate = 3/4;
        gray_scheme = gray_scheme_64QAM;
end
%% --(6) Data symbols demapping and Padding removal

out_coded = demodulate(rx_data_equalized, mod_type, 'binary', gray_scheme);
out_coded = out_coded(1:8*rx_length/rx_rate); % Padding removal

 %% --(7) Viterbi Decoding  
out_decoded = viterbi_decoder(out_coded,rx_rate);
end