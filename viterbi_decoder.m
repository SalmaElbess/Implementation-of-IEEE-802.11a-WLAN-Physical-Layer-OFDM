function out_decoded = viterbi_decoder(encoded,CR)
% ARGUMENTS
    % encoded: convolutionally encoded data
    % CR: code rate
% OUTPUTS
    % out_decoded: decoded stream

trellis = poly2trellis(7,[133 171]);
tbdepth = round(2*(log2(trellis.numStates)/(1-CR))); % Traceback depth for Viterbi decoder
out_decoded = vitdec(encoded,trellis,tbdepth,'trunc','hard');
end

