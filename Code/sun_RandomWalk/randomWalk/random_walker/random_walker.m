function probabilities = random_walker(pairPotentials, seeds, labels, vNumbers)
%Function [mask, probabilities] = random_walker(img, seeds, labels, beta) uses the 
%random walker segmentation algorithm to produce a segmentation given a 2D 
%image, input seeds and seed labels.
%
%Inputs: img - The image to be segmented
%        seeds - The input seed locations (given as image indices, i.e., 
%           as produced by sub2ind)
%        labels - Integer object labels for each seed.  The labels 
%           vector should be the same size as the seeds vector.
%        beta - Optional weighting parameter (Default beta = 90)
%
%Output: mask - A labeling of each pixel with values 1-K, indicating the
%           object membership of each pixel
%        probabilities - Pixel (i,j) belongs to label 'k' with probability
%           equal to probabilities(i,j,k)
%
%
%10/31/05 - Leo Grady
%Based on the paper:
%Leo Grady, "Random Walks for Image Segmentation", IEEE Trans. on Pattern 
%Analysis and Machine Intelligence, Vol. 28, No. 11, pp. 1768-1783, 
%Nov., 2006.
%
%Available at: http://www.cns.bu.edu/~lgrady/grady2006random.pdf
%
%Note: Requires installation of the Graph Analysis Toolbox available at:
%http://eslab.bu.edu/software/graphanalysis/


% Error catches
exitFlag = 0;


% Check seed locations argument
if(sum(seeds < 1) || sum(seeds > size(pairPotentials.source,1)) || (sum(isnan(seeds)))) 
    disp('ERROR: All seed locations must be in the range of nunmbers of superpixels.')
    exitFlag = 1;
end

if(sum(diff(sort(seeds))==0)) % Check for duplicate seeds
    disp('ERROR: Duplicate seeds detected.')
    disp('Include only one entry per seed in the "seeds" and "labels" inputs.')
    exitFlag = 1;
end


if(exitFlag)
    disp('Exiting...')
    probabilities = [];
    return
end

% Build graph
edges = [pairPotentials.source , pairPotentials.destination] + 1; % c语言下标从0开始
 
% [anyvalues, edges] = lattice(X, Y); 
% anyvalues：行，列下标从0开始, 格子阵
% edges: 每次只算 下和右 两个方向

% Generate weights and Laplacian matrix
% if (Z > 1)   % Color images
%     tmp = img(:,:,1);
%     imgVals = tmp(:);
%     tmp = img(:,:,2);
%     imgVals(:,2) = tmp(:);
%     tmp = img(:,:,3);
%     imgVals(:,3) = tmp(:);
% else
%     imgVals=img(:);
% end
% weights = makeweights(edges, imgVals, beta);

weights  = pairPotentials.value ;
weights(1:vNumbers)  = weights(1:vNumbers)*(0.1);

weights = 1 - exp(-4*weights);

% weights = weights./(max(weights));

L = laplacian(edges, weights);
%L=laplacian(edges,weights,length(points),1);



% Determine which label values have been used
label_adjust = min(labels); labels = labels-label_adjust + 1;  % Adjust labels to be > 0
labels_record(labels) = 1;
labels_present = find(labels_record);
number_labels = length(labels_present);

% Set up Dirichlet problem
boundary = zeros(length(seeds), number_labels);
for k = 1:number_labels
    boundary(:,k) = (labels(:) == labels_present(k));
end

% Solve for random walker probabilities by solving combinatorial Dirichlet problem
probabilities = dirichletboundary(L, seeds(:), boundary);

