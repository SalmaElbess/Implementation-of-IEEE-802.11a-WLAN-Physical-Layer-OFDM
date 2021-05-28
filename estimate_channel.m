function channel_gains = estimate_channel(rec_preamble,estimation_method)
    if estimation_method == 'ZF'
    %Constructing ture preamble values
    L = [1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 1 -1 -1 1 1 -1 1 -1 1 -1 -1 -1 -1 -1 1 1 -1 -1 1 -1 1 -1 1 1 1 1];
    zero_indecies = cat(2, 1, (28:38));   %indecies of zeroes
    pilots_indecies = [44, 57, 8, 22];
    rest_indecies = setdiff((1:64), zero_indecies);
    %get the long recieved preamble symbols
    long_rec_preamble_1 = rec_preamble(rest_indecies + 64*2);
    long_rec_preamble_2 = rec_preamble(rest_indecies + 64*3);
    h1 = long_rec_preamble_1./L;
    h2 = long_rec_preamble_2./L;
    channel_gains = (h1+h2)./2;
    end
end