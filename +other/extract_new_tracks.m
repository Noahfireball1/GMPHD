

function [extract_variables,updated_state_variable_table]=extract_new_tracks(extraction_inputs,state_variable_table,updated_state_variable_table) %Case A

%Parsing variables (only for ease of access)
label_row_numbers=extraction_inputs.max_weight_info.label_row;
filter_parameters=extraction_inputs.filter_parameters;
label_values=extraction_inputs.label_values;

%% Finding column numbers of the new confirmed targets
%Finding indices where max weight is larger than threshold
[weight_row_numbers,weight_col_numbers]=find(state_variable_table.weight>=filter_parameters.weight_large);

%Finding common rows numbers with labels and weight above threshold
row_number_idx=ismember(weight_row_numbers,label_row_numbers);

%Selecting columns only if row has a label that matches weight and label
col_number_index=weight_col_numbers(row_number_idx);

%Making sure not choosing measurement with no detection (first column)
no_detection_col_num_index=ismember(col_number_index,1);
if any(no_detection_col_num_index) %true if cn_first_col_idx contains non-zero
    col_number_index(no_detection_col_num_index)=[];
end

%Selecting only unique values
column_number_confirmed=unique(col_number_index);

%Adding to master column numbers of interest
measurement_col_number=column_number_confirmed';

%% Extract and update state variable table for new confirmed tracks
%Preallocate extraction of confirmed targets
extraction_row=zeros(length(column_number_confirmed),1);
extraction_column=zeros(length(column_number_confirmed),1);
extraction_label=zeros(length(column_number_confirmed),1);

%For each column of confirmed targets
for ii=1:length(column_number_confirmed)
    %Find max weight of the confirmed track across multiple measurements
    [~,row_number_index]=max(state_variable_table.weight(label_row_numbers,column_number_confirmed(ii)));
    row_number_confirmed=label_row_numbers(row_number_index);

    %Set extraction variables
    label_values.r_max_confirmed=label_values.r_max_confirmed+1;
    extraction_row(ii)=row_number_confirmed;
    extraction_column(ii)=column_number_confirmed(ii);
    extraction_label(ii)=label_values.r_max_confirmed;

    %Modify updated state variable tables to establish new confirmed tracks
    if ii==1 %First new confirmed track
        %Zero out weights of confirmed track
        updated_state_variable_table.weight(label_row_numbers,:)=0;

        %Set the weight of the new confirmed target
        %%%% IS THIS REALLY NEEDED??? I feel like it is already set to that value %%%%
        updated_state_variable_table.weight(row_number_confirmed,column_number_confirmed(ii))=state_variable_table.weight(row_number_confirmed,column_number_confirmed(ii));

        %Set the label of the new confirmed target
        updated_state_variable_table.label(label_row_numbers,:)=label_values.r_max_confirmed;
    else %Second or greater new confirmed track
        %Zero out weights of confirmed track
        updated_state_variable_table.weight(end+1,:)=0;

        %Set the weight of the new confirmed target
        updated_state_variable_table.weight(end,column_number_confirmed(ii))=state_variable_table.weight(row_number_confirmed,column_number_confirmed(ii));

        %Set the state variables of the new confirmed target - add extra row with same state
        updated_state_variable_table.label(end+1,:)=label_values.r_max_confirmed;
        updated_state_variable_table.state(end+1,:)=state_variable_table.state(row_number_confirmed,:);
        updated_state_variable_table.covariance(end+1,:)=state_variable_table.covariance(row_number_confirmed,:);
    end
end

%% Finding column numbers of the new unconfirmed targets
%Finding indicies where weight is in between small and large thresholds
[weight_row_numbers,weight_col_numbers]=find(state_variable_table.weight<filter_parameters.weight_large & state_variable_table.weight>=filter_parameters.weight_small);

%Finding common rows numbers with labels and weight inbetween thresholds
row_number_idx=ismember(weight_row_numbers,label_row_numbers);

%Selecting columns only if row has a label that matches weight and label
col_number_index=weight_col_numbers(row_number_idx);

%Making sure not choosing measurement with no detection (first column)
no_detection_col_num_index=ismember(col_number_index,1);
if any(no_detection_col_num_index) %true if cn_first_col_idx contains non-zero
    col_number_index(no_detection_col_num_index)=[];
end

%Selecting only unique values
col_number_unique_between=unique(col_number_index);

%Index of columns already confirmed
column_number_index=ismember(col_number_unique_between,column_number_confirmed);

%Keeping only columns not confirmed
column_number_unconfirmed=col_number_unique_between(~column_number_index);

%Adding to master column numbers of interest
measurement_col_number=[measurement_col_number,column_number_unconfirmed'];

%% New unconfirmed tracks
%For each column of unconfirmed targets
for ii=1:length(column_number_unconfirmed)
    %Find max weight of the unconfirmed track across multiple measurements
    [~,rn_between_idx]=max(state_variable_table.weight(label_row_numbers,column_number_unconfirmed(ii)));
    row_number_unconfirmed=label_row_numbers(rn_between_idx);

    %Increase counter of unconfirmed tracks
    label_values.r_max_unconfirmed=label_values.r_max_unconfirmed+1;

    %Modify updated state variable tables to establish new unconfirmed tracks
    if ii==1 && isempty(column_number_confirmed) %First new unconfirmed track AND no new confirmed tracks
        %Zero out weights of unconfirmed track
        updated_state_variable_table.weight(label_row_numbers,:)=0;

        %Set the weight of the new unconfirmed target
        updated_state_variable_table.weight(row_number_unconfirmed,column_number_unconfirmed(ii))=state_variable_table.weight(row_number_unconfirmed,column_number_unconfirmed(ii));

        %Set the label of the new unconfirmed target
        updated_state_variable_table.label(label_row_numbers,:)=label_values.r_max_unconfirmed;
    else %Second or greater new unconfirmed track or confirmed tracks already added
        %Zero out weights of unconfirmed track
        updated_state_variable_table.weight(end+1,:)=0;

        %Set the weight of the new unconfirmed target
        updated_state_variable_table.weight(end,column_number_unconfirmed(ii))=state_variable_table.weight(row_number_unconfirmed,column_number_unconfirmed(ii));

        %Set the state variables of the new unconfirmed target - add extra row with same state
        updated_state_variable_table.label(end+1,:)=label_values.r_max_unconfirmed;
        updated_state_variable_table.state(end+1,:)=state_variable_table.state(row_number_unconfirmed,:);
        updated_state_variable_table.covariance(end+1,:)=state_variable_table.covariance(row_number_unconfirmed,:);
    end
end

%% Output
%Set extraction output
extract_variables.extraction_flag=true;
extract_variables.row_number=extraction_row;
extract_variables.col_number=extraction_column;
extract_variables.label=extraction_label;
extract_variables.label_values=label_values;
extract_variables.zero_col_num=measurement_col_number;

end