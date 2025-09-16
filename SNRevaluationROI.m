%% Code to evaluate SNR in ROI from CSI 2H data from Bruker
% data should have been processed through AnalyzeImage_2DCSI_2Hglc before using this code
% required data are:
% RefImage - anatomical image for reference and localization of region of interest
% inim_lac - matrix with the values of lactate in a 8x8
% FOV over all the acquired time frames
% 
% G.Batsios - v20221006

%% Define voxel to calculate lactate SNR levels
figure, imagesc(RefImage)
colormap('gray')
set(gcf,'position',[10,10,500,500])
message = sprintf('Move the voxel at the area of interest (tumor/control)');
uiwait(msgbox(message));
hFH = imrect(gca,[10 10 10 10]);  % pos x, pos y, size x, size y
position = wait(hFH);
RefMask = hFH.createMask();

%% Calculate SNR of lactate

inim_Prod = inim_lac;

for frame = 1:size(inim_Prod,3)
    inim_SNR_Lac(:,:,frame) = imresize(inim_Prod(:,:,frame),[256 256],'lanczos2')./inim_noise(frame);
    SNR_Lac(:,frame) = mean(mean(inim_SNR_Lac(:,:,frame).*RefMask))*256^2/nnz(RefMask);
end
