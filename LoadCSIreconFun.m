%% Script for opening Bruker CSI data
% Input: CSI acquisition scan number (data_path) and subfolder (path_img)
% for Magnitude data (1) or Phase (2) & order of repetition (TR)
% Output: MetImage - CSI data as 4D matrix
% for use for data acquire in PV6.0.1
% GB - 20230124

function [im_rot idxarry_ppm] = LoadCSIreconFun(data_folder,ReIm);

data_path = ['./' num2str(data_folder)];
path_img   = [data_path '/pdata/' num2str(ReIm) '/'];

path_method  = [data_path '/method'];
path_recon = [path_img 'reco']; 
%% read recon header
recon_header = readBrukerHeader(path_recon);   
%% read method header
method_header = readBrukerHeader(path_method);
n_rep = method_header.PVM_NRepetitions; 
dimension = [recon_header.RECO_size; n_rep]';       % [x spec y N_d] the dimension of the 2dseq file
%% read 2dseq file
f1 = fopen([path_img '2dseq'],'r');
im_all=fread(f1,'int16');
im_epsi=reshape(im_all,dimension(1),dimension(2),dimension(3),dimension(4));
%% rotate epsi image
% resize_fac = 1;         %resize factor
im_rot = permute(im_epsi(:,:,:,:),[3 2 1 4]);
im_rot = flip(im_rot,1);
% inim = imresize(sum(sum(im_rot,3),4),[dimension(1) dimension(3)]*resize_fac);
% figure, imshow(inim,[]), title('image summed over all dynamics and spectral points')
%% compute the ppm range for spectra
cent_ppm = 4.75;
rang_ppm = method_header.PVM_SpecSW;
npts     = dimension(1);
start_ppm = cent_ppm + rang_ppm/2;
stop_ppm  = cent_ppm - rang_ppm/2;
step_ppm  = rang_ppm/(npts-1);

idxarry_ppm = -start_ppm:step_ppm:-stop_ppm;
idxarry_ppm = -idxarry_ppm;
end