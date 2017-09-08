function laUnary = sun_getUnaryLA(LocationUnaries, appearanceUnary)


LocationUnaries(:, 1) = LocationUnaries(:, 1)/2/max(LocationUnaries(:, 1));  % 归一到[0, 0.5]
% LocationUnaries(:, 2) = LocationUnaries(:, 2)/2/max(LocationUnaries(:, 2));
LocationUnaries(:, 2) = 0.5 - LocationUnaries(:, 1);

appearanceUnary(:, 1) = appearanceUnary(:, 1)/2/max(appearanceUnary(:, 1));
appearanceUnary(:, 2) = appearanceUnary(:, 2)/2/max(appearanceUnary(:, 2));

LA(:, 1) = sun_entropy(LocationUnaries(:, 1) +eps^2 ,appearanceUnary(:, 1) +eps^2 );
LA(:, 2) = sun_entropy(LocationUnaries(:, 2) +eps^2 ,appearanceUnary(:, 2) +eps^2 );

laUnary = 0.1 * LA;   % 尺度因子，保证在0 - 1之间