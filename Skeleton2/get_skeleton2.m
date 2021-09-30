% read in a sample image -- also see letters.png, bagel.png
function [skel,exy,jxy]=get_skeleton2(im)
% img = imread(im);
% figure;imshow(img);
% 
% %   OPERATION is a string that can have one of these values:
% %      'bothat'       Subtract the input image from its closing
% %      'branchpoints' Find branch points of skeleton
% %      'bridge'       Bridge previously unconnected pixels
% %      'clean'        Remove isolated pixels (1's surrounded by 0's)
% %      'close'        Perform binary closure (dilation followed by
% %                       erosion)
% %      'diag'         Diagonal fill to eliminate 8-connectivity of
% %                       background
% %      'endpoints'    Find end points of skeleton
% %      'fill'         Fill isolated interior pixels (0's surrounded by
% %                       1's)
% %      'hbreak'       Remove H-connected pixels
% %      'majority'     Set a pixel to 1 if five or more pixels in its
% %                       3-by-3 neighborhood are 1's
% %      'open'         Perform binary opening (erosion followed by
% %                       dilation)
% %      'remove'       Set a pixel to 0 if its 4-connected neighbors
% %                       are all 1's, thus leaving only boundary
% %                       pixels
% %      'shrink'       With N = Inf, shrink objects to points; shrink
% %                       objects with holes to connected rings
% %      'skel'         With N = Inf, remove pixels on the boundaries
% %                       of objects without allowing objects to break
% %                       apart
% %      'spur'         Remove end points of lines without removing
% %                       small objects completely
% %      'thicken'      With N = Inf, thicken objects by adding pixels
% %                       to the exterior of objects without connected
% %                       previously unconnected objects
% %      'thin'         With N = Inf, remove pixels so that an object
% %                       without holes shrinks to a minimally
% %                       connected stroke, and an object with holes
% %                       shrinks to a ring halfway between the hole
% %                       and outer boundary
% %      'tophat'       Subtract the opening from the input image
% 
% % the standard skeletonization:
% % imshow(bwmorph(img,'skel',inf));
% 
% % [bwout,lut]=bwmorph(img,'remove',inf);
% 
% figure; 
% imshow(bwmorph(img,'thin',inf));
%  
%  
%  
% % the new method:
% % imshow(bwmorph(skeleton(img)>35,'skel',Inf));
% figure;imshow(bwmorph(skeleton(img)>2,'thin',Inf));
% in more detail:
im1 = im2uint8(im);
[skr,rad] = skeleton(im1);

% the intensity at each point is proportional to the degree of evidence
% that this should be a point on the skeleton:

% 
% imagesc(skr);
% colormap jet
% axis image off

% skeleton can also return a map of the radius of the largest circle that
% fits within the foreground at each point:


% imagesc(rad)
% colormap jet
% axis image off

% thresholding the skeleton can return skeletons of thickness 2,
% so the call to bwmorph completes the thinning to single-pixel width.
skel = bwmorph(skr > 1,'thin',inf);
% figure;imshow(skel)
% try different thresholds besides 35 to see the effects

% anaskel returns the locations of endpoints and junction points
[dmap,exy,jxy] = anaskel(skel);
skel=skel;
exy=exy;
jxy=jxy;
% hold on
% plot(exy(1,:),exy(2,:),'go')
% plot(jxy(1,:),jxy(2,:),'ro')
end
