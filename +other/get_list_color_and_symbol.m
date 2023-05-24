

function [label_color,label_symbol]=get_list_color_and_symbol

%Define symbol order
symbols=['o','s','d','<','>','^','v','o','s','d','<','>','^','v'];

%Define colors (MATLAB default)
colors_values=[...
    0 0.4470 0.7410
    0.8500 0.3250 0.0980
    0.9290 0.6940 0.1250
    0.4940 0.1840 0.5560
    0.4660 0.6740 0.1880
    0.3010 0.7450 0.9330
    0.6350 0.0780 0.1840
    ];
num_colors=size(colors_values,1);

%Figure out maximum number of labels
max_label_value=num_colors*length(symbols);

%Preallocation
label_color=zeros(max_label_value,3);
label_symbol=char(zeros(max_label_value,1));
% label_symbol=[];

%Setting counter variables
color_counter=1; %Current position (or row) within color matrix
symbol_counter=0; %Current position within symbol matrix - set to one at first label

%Looping through each combination of color and symbol
for ii=1:max_label_value
    if mod(ii-1,num_colors)==0
        color_counter=1; %Reset color
        symbol_counter=symbol_counter+1; %Increment symbol counter
    else
                color_counter=color_counter+1;
    end

    %Keeping values
    label_color(ii,:)=colors_values(color_counter,:);
    label_symbol(ii)=char(symbols(symbol_counter));

end

end