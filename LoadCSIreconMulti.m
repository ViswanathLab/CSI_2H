%% Load multiple CSI files for Bruker format
% require the LoadCSIreconFun function
% input: folder number for CSIs and ParaVision version
% output: MetImageC file - complex reconstructed data & idxarry_ppm - ppm
% scale of spectra

% GB20230831

PreInj = 8;             % 1st 2H-CSI
PostInj = [9:12];       % rest 2H-CSIs
PVversion = 0;          % if use PV6.0.1 the '0', if use PV360 then '1'

for rep = [PreInj PostInj]
    for Recon = 1:2
        switch PVversion
            case 0
                [im_tmp, idxarry_ppm] = LoadCSIreconFun(rep, Recon);
            otherwise
                [im_tmp, idxarry_ppm] = LoadCSIreconFun_pv360(rep, Recon);
        end
        if Recon == 1
            MetImage(:,:,:,(rep-PreInj+1)) = im_tmp;
        else
            MetImageP(:,:,:,(rep-PreInj+1)) = im_tmp; 
        end
    end
end

MetImageC = MetImage.*exp(1i*MetImageP);