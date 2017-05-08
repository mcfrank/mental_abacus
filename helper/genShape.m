% Generates and returns mxn matrix corresponding to the final shape: 0 means not filled, 1 means filled.
% Total number of filled squares for easy = 4, for hard = 8

function s = genShape(settings, num_squares)

s = zeros(settings.grid_dims);

% while validate(settings,s) == false
  s = zeros(settings.grid_dims);

  while sum(sum(s)) < num_squares
    m = ceil(settings.grid_dims(1)*rand);
    n = ceil(settings.grid_dims(2)*rand);
    s(m,n) = 1;
  end
% end
