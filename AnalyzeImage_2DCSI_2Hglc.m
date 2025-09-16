%% code to process 2Hglucose CSI data
% - ability to zero fill & apodize spectra
% - create metabolic maps by integrating peaks and overlay them on
% anatomical image
% - evaluate SNR of defined ROI and ratio of metabolites

% before running run code and to create the required parameters: RefImage 
% (anatomical image) & MetImageC (complex CSI data)
% GB - 20241205

%% place points on HR image for voxel reference (grid on anatomical)
figure
imshow(RefImage,[])
hold on
plot(ones(8,1)*[1:8]*32,[1:8]'*ones(1,8)*32,'.r')

%% zero fill + apodization
% fill the number of points for zero filling and apodization width
ZeroFillPoints = 0;     % values: 0 or 512 or 1024
Apod = 5;               % values 0 to 15
MatrixDim = 8;          % Input CSI matrix size

yiC_FID = fft(MetImageC(:,:,:,:),size(MetImageC,3),3);
yiC_FID_z = zeros(MatrixDim,MatrixDim,ZeroFillPoints+size(MetImageC,3),size(MetImageC,4));
yiC_FID_z(1:MatrixDim,1:MatrixDim,1:size(MetImageC,3),1:size(MetImageC,4)) = yiC_FID;

time_z = [0:(size(yiC_FID_z,3)-1)]/(19.47*32);

smoothFilt = exp(-time_z*Apod*pi)*10;      % apodization
smoothFilt4D = repmat(smoothFilt',[1 MatrixDim MatrixDim size(MetImageC,4)]);
smoothFilt4D = permute(smoothFilt4D,[2,3,1,4]);

yiC_FID_zf = yiC_FID_z.*smoothFilt4D;
yiC_zf = fft(yiC_FID_zf,ZeroFillPoints+size(MetImageC,3),3);

idxarry_ppm_zf = linspace(min(idxarry_ppm),max(idxarry_ppm),size(yiC_zf,3));

%% Calculate metabolic maps by integrating spectral region
%% HDO : 4.1 - 6.2
for i = 1:size(MetImageC,4)
ppm_a = 4.1;    % ppm start point for integration
ppm_b = 6.2;    % ppm stop point for integration 
spectra_range_HDO = find((idxarry_ppm_zf>ppm_a)&(idxarry_ppm_zf < ppm_b));

inim_HDO(:,:,i) = sum(sum(abs(yiC_zf(:,:,spectra_range_HDO,i)),3),4);
end

%% Lactate : 1.2 - 1.6
for i = 1:size(MetImageC,4)
ppm_a = 1.2;    % ppm start point for integration
ppm_b = 1.6;    % ppm stop point for integration
spectra_range_lac = find((idxarry_ppm_zf>ppm_a)&(idxarry_ppm_zf < ppm_b));

inim_lac(:,:,i) = sum(sum(abs(yiC_zf(:,:,spectra_range_lac,i)),3),4);
end

%% Create mask for brain-region of interest
figure
imshow(RefImage,[])
set(gcf,'position',[10,10,1000,1000])
message = sprintf('Left click and hold to begin drawing.\nSimply lift the mouse button to finish');
uiwait(msgbox(message));
hFH = imfreehand(); % Actual line of code to do the drawing.
% Create a binary image ("mask") from the ROI object.
RefMask = hFH.createMask();

%% Maps of metabolite to STD of noise
% Evaluate noise (as the STD of the real part of spectra of voxel (1,1))
for i = 1:size(MetImageC,4)
    inim_noise(:,:,i) = std(real(yiC_zf(:,:,:,i)),0,3);
end

%% overlay metabolic image on anatomical for 6 frames (Ratio to STD value of noise)
figure
I = repmat(mat2gray(double(RefImage)),[1,1,3]);

% metabolite to be plot (change inim_? to metabolite)
MetPlot = inim_lac;
Fnoise = squeeze(inim_noise(1,1,:));

for i=1:size(MetPlot,3)      % number of time frames - do not forget to change dimension in subplot below

subplot(2,3,i)

F = imresize(MetPlot(:,:,i),[256 256],'lanczos2')./Fnoise(i);
F_Mask = F.*RefMask;

% Display the back image
hB = imagesc(I);axis image off;

% Add the front image on top of the back image
hold on;
F_MinMax = [min(min(F_Mask)) max(max(F_Mask))];
hF = imagesc(F_Mask,F_MinMax);

% Make the foreground image transparent
alphadata = 0.6.*(F_Mask >= F_MinMax(1));
set(hF,'AlphaData',alphadata);
colorbar
end

%% overlay SUM of metabolic images as ratio of metabolite to std of noise on anatomical
% input : frames to be summed and metabolite to be imaged
frames = [1:6];
inim_met = inim_lac;

figure
B = repmat(mat2gray(double(RefImage)),[1,1,3]);

% Display the back image
hB = imagesc(B);axis image off;

% Add the front image on top of the back image
hold on;

MetPlot = sum(inim_met(:,:,frames),3);
Fnoise = std(real(sum(yiC_zf(1,1,:,frames),4)),0,3);
F = imresize(MetPlot,[256 256],'lanczos2')./Fnoise;

F_Mask = F.*RefMask;
hF = imagesc(F_Mask,[min(F_Mask(:)) max(F_Mask(:))]);

% Make the foreground image transparent
alphadata = 0.5.*(F >= min(F(:)));
set(hF,'AlphaData',alphadata);
colorbar
