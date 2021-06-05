out=[];
step = 1032*8
for i=1:step:length(data)
    frame = data(i:min(length(data),i+step-1)); 
    coded_data = conv_encoder(frame,3/4);
    decoded_data = viterbi_decoder(coded_data,3/4);
    recovered = decoded_data(1:length(frame));
    if sum(recovered~=frame)
        flag=1;
    end
    out=[out recovered];
end
find((out~=data)==1)