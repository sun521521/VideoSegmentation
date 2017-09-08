function grad = sun_gradient(flow)

grad.G0 = zeros(size(flow),'single'); grad.G1 = grad.G0 ; grad.G2 = grad.G0 ; grad.G3 = grad.G0 ; grad.G4 = grad.G0 ; 
grad.G5 = grad.G0 ; grad.G6 = grad.G0 ; grad.G7 = grad.G0 ; 

grad.G0(2:end, :, :) = flow(1:end-1, :, :) - flow(2:end, :, :);
grad.G0(1, :, :) = -grad.G0(2, :, :);

grad.G4(1:end-1, :, :) = flow(2:end, :, :) - flow(1:end-1, :, :);
grad.G4(end, :, :) = -grad.G4(end-1, :, :);

grad.G2(:, 2:end, :) = flow(:, 1:end-1, :) - flow(:, 2:end, :);
grad.G2(:, 1, :) = -grad.G2(:, 2, :);

grad.G6(:, 1:end-1, :) = flow(:, 2:end, :) - flow(:, 1:end-1, :);
grad.G6(:, end, :) = -grad.G6(:, end-1, :);

grad.G1(2:end, 2:end, :) = flow(1:end-1, 1:end-1, :) - flow(2:end, 2:end, :);
grad.G1(1, :, :) = -grad.G1(2, :, :);
grad.G1(:, 1, :) = -grad.G1(:, 2, :);

grad.G7(2:end, 1:end-1, :) = flow(1:end-1, 2:end, :) - flow(2:end, 1:end-1, :);
grad.G7(1, :, :) = -grad.G7(2, :, :);
grad.G7(:, 1, :) = -grad.G7(:, 2, :);

grad.G3(1:end-1, 2:end, :) = flow( 2:end,1:end-1, :) - flow(1:end-1, 2:end, :);
grad.G3(end, :, :) = -grad.G3(end-1, :, :);
grad.G3(:, 1, :) = -grad.G3(:, 2, :);

grad.G5(1:end-1, 1:end-1, :) = flow(2:end, 2:end, :) - flow(1:end-1, 1:end-1, :);
grad.G5(end, :, :) = -grad.G5(end-1, :, :);
grad.G5(:, end, :) = -grad.G5(:, end-1, :);







