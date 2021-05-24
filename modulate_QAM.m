function [mapped_stream, cmx_vec] = modulate_QAM(qam_n, input_stream, coding_scheme_vec)
% This function construct the modulated symbols for N-QAM modulation
% scheme
% Input: 
    % qma_n: QAM modulation order (4, 16, 64, ..)
    % input_stream: The stream of symbols [0 : 15]
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
% x-axis setup
   ak_mat = repmat((-sqrt(qam_n)+1:2:sqrt(qam_n)-1), sqrt(qam_n), 1);
% y-axis setup
    bk_mat = repmat(flip((-sqrt(qam_n)+1:2:sqrt(qam_n)-1))',1,sqrt(qam_n));
%the matrix of the whole QAM corrdinates reference          
    cmx_mat = ak_mat + 1j*bk_mat; 
    cmx_vec = reshape(cmx_mat,1,[]);  
% In case of specific encoding scheme
    if ~ any(coding_scheme_vec == -1)
        cmx_vec(coding_scheme_vec+1) = cmx_vec(1:qam_n);
    end
    %% Symbol mapping
    mapped_stream = cmx_vec(input_stream+1);
end
