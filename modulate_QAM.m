function [mapped_stream, cmx_vec] = modulate_QAM(qam_n, input_stream, K, coding_scheme_vec)
% This function construct the modulated symbols for N-QAM modulation
% scheme
% Input: 
    % qam_n: QAM modulation order (4, 16, 64, ..)
    % input_stream: The stream of symbols [0 : 15]
    % K: a factor multiplied by the complex reference symbols
    % coding_scheme_vec: -1 in case of no specific coding scheme
    %               Otherwise, the coded symbols should be written a
    %               columns by a column (such as reshape function
    %               behavior)
% Output:
    % mapped_stream: The modulated symbols (complex)
    % cmx_vec : The reference complex symbols used for demodulation

% Check if the input QAM order is available
if rem(log(qam_n)/log(4), 1) ~= 0 || qam_n < 4
    disp('incorrent order for QAM modulation');
    return;
end
 %-- check if coding scheme is passed
if nargin < 3
   K=1;
   coding_scheme_vec = -1; %default value in case of no specific coding scheme 
elseif nargin < 4
    coding_scheme_vec = -1;
end
   cmx_vec = QAM_mapping_reference(qam_n, coding_scheme_vec, K);
    %% Symbol mapping
    mapped_stream = cmx_vec(input_stream+1);
end
