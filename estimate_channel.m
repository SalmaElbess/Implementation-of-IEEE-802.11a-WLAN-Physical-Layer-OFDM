function channel_gains = estimate_channel(rec_preamble,estimation_method)
%The function estimated the channel effects using recieved preamble long
%symbols and the ture long preamble values and returns the estimated gains
%
%inputs:
%       rec_preamble: array of shape 1*256 containing the received preamble
%       symbols 
%       estimation_method:
%output:
%       channel_gains: array of shape 1*52 of the channel gains(data gains 
%       and pilots gains).


%Constructing ture preamble values
L = [1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 1 -1 -1 1 1 -1 1 -1 1 -1 -1 -1 -1 -1 1 1 -1 -1 1 -1 1 -1 1 1 1 1];
zero_indecies = cat(2, 1, (28:38));   %indecies of zeroes
rest_indecies = setdiff((1:64), zero_indecies);
%get the long recieved preamble symbols
long_rec_preamble_1 = rec_preamble(rest_indecies + 64*2);
long_rec_preamble_2 = rec_preamble(rest_indecies + 64*3);

if strcmpi(estimation_method,'ZF')
%estimate from the first long recieved preamble symbol
h1 = long_rec_preamble_1./L; 
%estimate from the second long recieved preamble symbol
h2 = long_rec_preamble_2./L;
%average estimate of the channel gains
channel_gains = (h1+h2)./2;

else
    M = 4;
    channel_gains=zeros(M,1);
    preamble=[long_rec_preamble_1;long_rec_preamble_2];
    for k=1:2
        desired = L;
        M = 4;
        mu=0.01;
        w = zeros(M,1);
        u=[0 0 0 preamble(k,:)];
        for i=1:length(u)-3
            d_hat = w'*[u(i+3);u(i+2);u(i+1);u(i)];
            e = desired(i) - d_hat;
            w = w + mu*[u(i+3);u(i+2);u(i+1);u(i)]*conj(e);
        end
    channel_gains=(channel_gains+w);
    end
    channel_gains=channel_gains./2;
end
end