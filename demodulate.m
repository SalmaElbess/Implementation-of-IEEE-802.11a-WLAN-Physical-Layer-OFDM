function output_stream = demodulate(input_stream, mod_type, additional, output_type)
%% demodulate: This function perform demodulation for input complex symbols with multiple modulation schemes
% Parameters: 
    % input_stream: modulated complex symbols
    % mod_type: the needed modulation schemce (N-QAM, PSK, QPSK)
    % additional: additional information depending on mod_type. In case of
    % QAM, it's the needed reference vector for demodulation
    % output_type: the type of the output stream (symbols, binary)
    
% Returns:
    % output_stream: the output stream (binary or symbols).
%% ---------------------------------------------------------------- %%
if strcmpi(mod_type, '16qam') || strcmpi(mod_type, '64qam') ||  strcmpi(mod_type, 'qpsk')
  % In case of QAM , the additional is the ref_demodualtor
  [~,I] = min(conj(input_stream') - additional,[], 2);
  demod_samples = (I-1)';
elseif strcmpi(mod_type, 'bpsk')
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
