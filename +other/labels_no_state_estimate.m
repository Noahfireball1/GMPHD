


function label_no_state=labels_no_state_estimate(extracted_label_set,state_labels,birth_labels)

%Select only unique labels of the current state estimate
uni_state_lables=unique(state_labels); 

%Find difference between current state labels and new birth labels
unconfirmed_labels=setdiff(uni_state_lables,birth_labels);

%Difference between unconfirmed labels and the extracted labels
label_no_state=setdiff(unconfirmed_labels,extracted_label_set);

end