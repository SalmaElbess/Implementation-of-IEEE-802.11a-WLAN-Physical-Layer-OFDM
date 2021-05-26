function output_stream = demodulate(input_stream, mod_type, output_type, coding_scheme_vec)
%% demodulate: This function perform demodulation for input complex symbols with multiple modulation schemes
% Parameters: 
    % input_stream: modulated complex symbols
    % mod_type: the needed modulation schemce (N-QAM, PSK, QPSK)
    % output_type: the type of the output stream (symbols, binary)
     % coding_scheme_vec: -1 in case of no specific coding/decoding scheme
     %               Otherwise, the coded symbols should be written a
     %               columns by a column (such as reshape function
     %               behavior)
    
% Returns:
    % output_stream: the output stream (binary or symbols).
%% ---------------------------------------------------------------- %%
 %-- check if coding scheme is passed
if nargin < 4
   coding_scheme_vec = -1; %default value in case of no specific coding scheme 
end

if strcmpi(mod_type, '16QAM')
  K = 1/sqrt(10);
  ref_demod = QAM_mapping_reference(16,coding_scheme_vec,K);
  [~,I] = min(conj(input_stream') - ref_demod,[], 2);
  demod_samples = (I-1)';
elseif strcmpi(mod_type, '64QAM')
    K = 1/sqrt(10);
  ref_demod = QAM_mapping_reference(64,coding_scheme_vec,K);
  [~,I] = min(conj(input_stream') - ref_demod,[], 2);
  demod_samples = (I-1)';
elseif strcmpi(mod_type, 'QPSK')
  K = 1/sqrt(10);
  ref_demod = QAM_mapping_reference(4,coding_scheme_vec,K);
  [~,I] = min(conj(input_stream') - ref_demod,[], 2);
  demod_samples = (I-1)';
elseif strcmpi(mod_type, 'BPSK')
  demod_samples = zeros(size(input_stream));
  demod_samples(input_stream > 0 ) = 1;
end
  output_stream = demod_samples;
 
% If the needed output format is binary, convert to binary data.
 if strcmpi(output_type, 'binary')
   output_stream = de2bi(output_stream, 'left-msb');
   output_stream = reshape(output_stream', 1, []); 
 end
end
