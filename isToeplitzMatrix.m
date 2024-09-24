function is_toeplitz = isToeplitzMatrix(A)

    % isToeplitzMatrix checks if a square matrix A is a Toeplitz matrix.
    %
    % Usage:
    %   is_toeplitz = isToeplitzMatrix(A)
    %
    % Input:
    %   A - square matrix to be tested
    %
    % Output:
    %   is_toeplitz - logical value, true if A is Toeplitz, false otherwise

    % Check if A is a square matrix
    
    [n, m] = size(A);
    if n ~= m
        error('Input must be a square matrix.');
    end

    % Compare each element with its down-right neighbor
    is_toeplitz = all(all(A(1:end-1, 1:end-1) == A(2:end, 2:end)));
end
