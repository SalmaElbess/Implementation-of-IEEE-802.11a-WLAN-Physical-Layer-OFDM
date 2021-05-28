function out_decoded = WiFi_receiver(input_stream, Nc, guard_len)
%% WiFi_receiver: This function performs all required steps to receive complex symbols and convert them to binary data using WiFi
% Parameters: 
    % input_stream: the input OFDM complex symbols to received
    % Nc: Number of subcarriers
    % guard_len: Cyclic prefix length
% Returns:
    % out_decoded: the output binary data received
    
 %% --(1) Standards Specifications 
zero_indecies = cat(2, 1, (28:38));   %indecies of zeroes
pilots_indecies = [44, 57, 8, 22];
data_indecies = setdiff(setdiff((1:Nc), pilots_indecies), zero_indecies);

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
  channel_gains = estimate_channel(rec_preamble,'ZF');
%% TODO#3: --(4) Channel Equalization
  % ---
  rx_data_equalized = equalize_channel(rx_data,channel_gains,'ZF');
 %% TODO#4: --(5) Extract data_length , rate from signal & use them to eliminate the padding
rx_length = 1000;          %TODO: must be extracted from signal 
rx_rate = 1/2;             %TODO: must be extracted from signal
mod_type = '16qam';        %TODO: must be extracted from signal

%% --(6) Data symbols demapping and Padding removal
out_coded = demodulate(rx_data_equalized, mod_type, 'binary');
out_coded = out_coded(1:rx_length/rx_rate); % Padding removal

 %% --(7) Viterbi Decoding  
trellis = poly2trellis(7,[133 171]);
tbdepth = round(2*(log2(trellis.numStates)/(1-rx_rate))); % Traceback depth for Viterbi decoder
out_decoded = vitdec(out_coded,trellis,tbdepth,'trunc','hard');

end