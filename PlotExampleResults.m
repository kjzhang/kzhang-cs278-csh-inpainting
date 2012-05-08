% Plot error image of mapping
function PlotExampleResults(A,B,CSH_Mapping,width,K_of_KNN,bMask)
    % PlotExampleResults - Plot results from example run
    % A and B are the input images
    % CSH_Mapping is the nn mapping of the CSH run
    % Width is the used patch width
    
    [hA,wA,dA] = size(A);
    [hB,wB,dB] = size(B);
    
    CSH_MeansRMS = 0;
    errImg = zeros(hA,wA);
    
    for t = 1:K_of_KNN
        [errImg_tmp,CSH_MeansRMS_tmp] = GetErrorMeanAndImage(CSH_Mapping(:,:,:,t),hB,wB,hA,wA,width,A,B,width,0);% Mapping error calculation
        CSH_MeansRMS = CSH_MeansRMS + CSH_MeansRMS_tmp;
        errImg = errImg + errImg_tmp;
    end
    
    errImg = errImg./K_of_KNN;
    CSH_MeansRMS = CSH_MeansRMS / K_of_KNN;
    
    fprintf('    CSH_nn mapping RMS error: %.3f\r\n',CSH_MeansRMS);
    figure;
    br_boundary_to_ignore = width;
    Hash_error_img = errImg(1:end - br_boundary_to_ignore,1:end - br_boundary_to_ignore);
    pct98 = prctile(Hash_error_img(:),99);
    Hash_error_img = min(pct98,errImg(1:end - br_boundary_to_ignore,1:end - br_boundary_to_ignore));
    [I,J] = bounds(Hash_error_img(:),1);
    [clims(1),clims(2)] = bounds([I,J],1);
    clims(2) = max(clims(1) + 1, clims(2));
    subplot(221);imshow(A); title('image A');
    subplot(222);imshow(B); title('image B');
    subplot(223);imagesc(Hash_error_img,clims); title(['CSH error: ' num2str(CSH_MeansRMS)]);
    if (exist('bMask','var'))
        bMask(bMask>0)=512; % For representation only
        subplot(224);imagesc(bMask,clims); title('Binary mask (red = hole)');
    end
end