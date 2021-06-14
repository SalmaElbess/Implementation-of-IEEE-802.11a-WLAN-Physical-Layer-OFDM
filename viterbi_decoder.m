function out_decoded = viterbi_decoder(encoded,CR)
% ARGUMENTS
    % encoded: convolutionally encoded data
    % CR: code rate
% OUTPUTS
    % out_decoded: decoded stream

trellis = poly2trellis(7,[133 171]);
tbdepth = round(2*(log2(trellis.numStates)/(1-CR))); % Traceback depth for Viterbi decoder
switch CR
    case 1/2
        out_decoded = vitdec(encoded,trellis,tbdepth,'trunc','hard');
    case 3/4
        punctpat = [1 1 1 0 0 1];
        if rem(length(encoded), sum(punctpat))
            padding = sum(punctpat) - rem(length(encoded), sum(punctpat));
            encoded = [encoded zeros(1,padding)];
        end
        out_decoded = vitdec(encoded,trellis,2*tbdepth,'trunc','hard',punctpat);
    case 2/3
        punctpat = [1 1 1 0];
        if rem(length(encoded), sum(punctpat))
            padding = sum(punctpat) - rem(length(encoded), sum(punctpat));
            encoded = [encoded zeros(1,padding)];
        end
        out_decoded = vitdec(encoded,trellis,2*tbdepth,'trunc','hard',punctpat);
end

