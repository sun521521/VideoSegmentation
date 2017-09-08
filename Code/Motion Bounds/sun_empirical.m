function  output = sun_empirical( input )

[height width] = size(input);

if min(height, width) ~= 1
    input = reshape(input, numel(input), 1);
end

[anyvalues anyvalues index] = unique(input);

empDistribution = ecdf(input);
% empDistribution = empDistribution( 2:end );

output = empDistribution(index);
output = reshape(output, height, width);