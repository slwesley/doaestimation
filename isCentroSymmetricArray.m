function isSymmetric = isCentroSymmetricArray(x)
    % isMirrorSymmetric checks if a vector x is symmetric about its middle.
    %
    % Usage:
    %   is_symmetric = isMirrorSymmetric(x)
    %
    % Input:
    %   x - input vector (row or column vector)
    %
    % Output:
    %   is_symmetric - logical value, true if x is symmetric about its middle, false otherwise

    % Ensure x is a vector
    if ~isvector(x)
        error('Input must be a vector.');
    end

    % Get the length of the vector
    n = length(x);

    % Check symmetry by comparing elements
    isSymmetric = true;  % Initialize as true
    c = (x(1)+x(end))/2;
    x = abs(x-c);

    for i = 1:floor(n/2)
        if x(i) ~= x(n - i + 1)
            isSymmetric = false;
            break;
        end
    end
end


