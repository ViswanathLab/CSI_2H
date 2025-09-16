%% code to import HR image data for Bruker PV6.0.1
% to input the High Resolution (HR) data folder and after running once to
% update the HR slice of choice based on tumor location on image stuck

% inputs: data_path (l:12) and slice (l:36)

% GB - 20230109

clear all
close all

data_path =  './3';         % enter HR folder

path_img   = [data_path '/pdata/1/']; 
path_method  = [data_path '/method'];
path_recon = [path_img 'reco'];               
%%
recon_header = readBrukerHeader(path_recon);   
dimension = [recon_header.RECO_size; recon_header.RecoObjectsPerRepetition]';
%% read method header
method_header = readBrukerHeader(path_method);
n_rep = method_header.PVM_NRepetitions;                
%% read 2dseq file
f1 = fopen([path_img '2dseq'],'r');
im_all=fread(f1,'int16');
%%
image = reshape(im_all, [dimension, n_rep]);
%%
for i = 1:size(image,3)
    im_rot = flip(permute(sum(squeeze(image(:,:,i)),3),[2 1]),1);
    figure(i), imshow(im_rot,[])
end

%% save image to RefImage parameter
% update with required slice below and run code again
slice = 13;

RefImage = flip(permute(squeeze(image(:,:,slice)),[2 1]),1);