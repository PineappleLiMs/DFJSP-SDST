function [sequence,best_position,value] = insert_best_position(sequence_partial, data, inserting_job)
%INSERT_BEST_POSITION Find the best position for the inserting job to be
%placed in given sequence
% Parameters:
%   sequence_partial: current partial sequence.
%   data: the struct of instance
%   inserting_job: job to be inserted
% returns:
%       sequence: new sequence after inserting the job into its best position
%       i: location to insert the new job
%       value: objective value of the new sequence

current_length = length(sequence_partial);
new_length = current_length + 1;
value = inf;
sequence = sequence_partial;
old_sequence = [];
old_value = inf;
for insert_position = 1:new_length
    % insert inserting_job into all possible positions
    if insert_position == new_length
        sequence_tem = [sequence_partial, inserting_job];
    else
        sequence_tem = [sequence_partial(1:insert_position-1), inserting_job,...
            sequence_partial(insert_position:end)];
    end
    % evaluate obtained sequence
    if ~(isempty(old_sequence)) && isequal(old_sequence, sequence_tem)
        % if same sequence is obtained, we dont need to evaluate again
        value_tem = old_value;
    else
        value_tem = dfjsp_setup(sequence_tem, data);
        if value_tem < value
            value = value_tem;
            sequence = sequence_tem;
            best_position = insert_position;
        end
    end
    % update old_sequence and old_value
    old_sequence = sequence_tem;
    old_value = value_tem;
end
end

