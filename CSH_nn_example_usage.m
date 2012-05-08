% example usage for CSH_nn function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all
clear all
clc

fprintf('CSH algorithm example script!!!\r\n');
fprintf('*******************************\r\n');

img1 = 'Saba1.bmp';
img2 = 'Saba2.bmp';

% First example: use internal defaults to show mapping
A = imread(img1);
B = imread(img2);

fprintf('Dummy run to warmup...');
CSH_ann = CSH_nn(A,B);
fprintf('Done!!\r\n');

[hA wA dA] = size(A);
[hB wB dB] = size(B);

% mpa = floor(hB*wB/1000) / 1000;
% mpb = floor(hB*wB/1000) / 1000;
% 
% MP_A_Str = [num2str(mpa) ' MP'];
% MP_B_Str = [num2str(mpb) ' MP'];
% 
% fprintf('Image A: %s, size = %s\r\n' , img1 , MP_A_Str);
% fprintf('Image B: %s, size = %s\r\n',img2 , MP_B_Str);
% 
% %%% Initialize random seed
% s = RandStream('swb2712','Seed',123456789);
% RandStream.setDefaultStream(s)
% 
% fprintf('1. Runing CSH_nn example with default parameter values\r\n');
% CSH_TIC = tic;
% %%%%%% CSH RUN %%%%%%%
% CSH_ann = CSH_nn(A,B);
% %%%%%%%%%%%%%%%%%%%%%%
% CSH_TOC = toc(CSH_TIC);
% fprintf('   CSH_nn elapsed time: %.3f[s]\r\n' , CSH_TOC);
% width = 8; % Default patch width value
% PlotExampleResults(A,B,CSH_ann,width,1);
%     
% % Second example: run CSH with user defined parameters settings
% width = 4;
% iterations = 4;
% k = 1;
% fprintf('2. Runing CSH_nn example: width = %d, iterations = %d, k = %d\r\n',width,iterations,k);
% CSH_TIC = tic;
% %%%%%% CSH RUN %%%%%%%
% CSH_ann = CSH_nn(A,B,width,iterations,k,0);
% %%%%%%%%%%%%%%%%%%%%%%
% CSH_TOC = toc(CSH_TIC);
% fprintf('   CSH_nn elapsed time: %.3f[s]\r\n' , CSH_TOC);
% PlotExampleResults(A,B,CSH_ann,width,k);
% 
% % Third example: run CSH for KNN mapping
% width = 8;
% iterations = 3;
% k = 8;
% fprintf('3. Runing CSH_nn example for KNN (K = %d) demonstration\r\n',k);
% CSH_TIC = tic;
% %%%%%% CSH RUN %%%%%%%
% CSH_knn = CSH_nn(A,B,width,iterations,k,0);
% %%%%%%%%%%%%%%%%%%%%%%
% CSH_TOC = toc(CSH_TIC);
% fprintf('   CSH_nn elapsed time: %.3f[s]\r\n' , CSH_TOC);
% PlotExampleResults(A,B,CSH_knn,width,k);

% Fourth example: run CSH ANN with mask
width = 8;
iterations = 3;
k = 1;
fprintf('4. Runing CSH_nn example with mask\r\n');

mask = zeros(hB,wB);
mask(round(hB/7):round(hB*6/7),round(wB/7):round(wB*6/7)) = 1; % Mark the patches that are NOT used for mapping
CSH_TIC = tic;
%%%%%% CSH RUN %%%%%%%
CSH_ann = CSH_nn(A,B,width,iterations,k,0,mask);
%%%%%%%%%%%%%%%%%%%%%%
CSH_TOC = toc(CSH_TIC);
fprintf('   CSH_nn elapsed time: %.3f[s]\r\n' , CSH_TOC);
PlotExampleResults(A,B,CSH_ann,width,k,mask);

