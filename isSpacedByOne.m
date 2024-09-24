function is_spaced_by_one = isSpacedByOne(vector)

    % isSpacedByOne checks if a vector's elements are spaced by one unit.
    %
    % Usage:
    %   is_spaced_by_one = isSpacedByOne(vector)
    %
    % Input:
    %   vector - input vector (row or column vector)
    %
    % Output:
    %   is_spaced_by_one - logical value, true if elements are spaced by one unit, false otherwise

    % Ensure vector is a column vector

    vector = vector(:);

    % Check if vector has less than 2 elements
    if length(vector) < 2
        is_spaced_by_one = true; % A single element is trivially spaced by one
        return;
    end

    % Sort the vector
    sorted_vector = sort(vector);

    % Compute differences between consecutive elements
    diffs = diff(sorted_vector);

    % Check if all differences are equal to 1 (within numerical tolerance)
    is_spaced_by_one = all(abs(diffs - 1) < eps);
end
