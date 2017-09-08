function output = sun_updatePairwisePotentials (params, pairPotentials, consInSegments, consExSegments)


edgeSegments = [consInSegments; consExSegments];

for i = 1:size(edgeSegments, 1)
   temp = (pairPotentials.source(:) == edgeSegments(i, 1)) .* (pairPotentials.destination (:) == edgeSegments(i, 2));
   index = find( temp == 1 );
   
   if isempty(index)
       pairPotentials.source =[pairPotentials.source(:); uint32(edgeSegments(i, 1))];
       pairPotentials.destination =[pairPotentials.destination(:); uint32(edgeSegments(i, 2))];
      pairPotentials.value =[pairPotentials.value(:); params.edgeWeight * single(edgeSegments(i, 3))];
   else
       pairPotentials.value(index) = pairPotentials.value(index) + params.edgeWeight * single(edgeSegments(i, 3));
   end
end
output = pairPotentials;
       