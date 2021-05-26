function cmx_vec = QAM_mapping_reference(qam_n, coding_scheme_vec, K)
%% QAM_mapping_reference: This function computes the reference complex symbols used for QAM modulation and demodulation
% Paramteres:
     % qam_n: QAM modulation order (4, 16, 64, ..)
     % coding_scheme_vec: -1 in case of no specific coding scheme
     %               Otherwise, the coded symbols should be written a
     %               columns by a column (such as reshape function
     %               behavior)
     % K: a factor multiplied by the complex reference symbols
     
% Returns:
    % cmx_vec : The reference complex symbols used for QAM modulation and demodulation
 
if nargin < 3
   K = 1; %default value
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
    cmx_vec = cmx_vec*K;
end