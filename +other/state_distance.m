

function distance=state_distance(state1,state2,model_H)
%States to measurement
measurement1=model_H*state1;
measurement2=model_H*state2;

%Find distance
distance=norm(measurement1-measurement2); %Order doesn't matter inside norm

end