clc
clear
addpath(genpath('srv1_9'));
load('mnist_insitu_0-3_0-4.mat')
%%
% Save the dictionary
Dict = dictSetSmall;

% FIXME - X should be N by M where N is number of atoms and M is number of
% testing samples. Happens that M == N
X = zeros(size(Dict, 2), size(trainSetSmall, 2));
%% Generate kernel fncs
kfncs  = { ...
    @(x,y) x'*y; ...            % Linear
    @(x,y) (x'*y + 1); ...
    @(x,y) (x'*y + 0.5).^2; ...  % Polynomial
    @(x,y) (x'*y + 0.5).^3; ...
    @(x,y) (x'*y + 0.5).^4; ...
    @(x,y) (x'*y + 1.0).^2; ...
    @(x,y) (x'*y + 1.0).^3; ...
    @(x,y) (x'*y + 1.0).^4; ...
    @(x,y) (x'*y + 1.5).^2; ...
    @(x,y) (x'*y + 1.5).^3; ...
    @(x,y) (x'*y + 1.5).^4; ...
    @(x,y) (x'*y + 2.0).^2; ...
    @(x,y) (x'*y + 2.0).^3; ...
    @(x,y) (x'*y + 2.0).^4; ...
    @(x,y) (x'*y + 2.5).^2; ...
    @(x,y) (x'*y + 2.5).^3; ...
    @(x,y) (x'*y + 2.5).^4; ...
    @(x,y) tanh(0.1 + 1.0*(x'*y)); ...  % Hyperbolic Tangent
    @(x,y) tanh(0.2 + 1.0*(x'*y)); ...
    @(x,y) tanh(0.3 + 1.0*(x'*y)); ...
    @(x,y) tanh(0.4 + 1.0*(x'*y)); ...
    @(x,y) tanh(0.5 + 1.0*(x'*y)); ...
    @(x,y) tanh(0.5 + 0.2*(x'*y)); ...
    @(x,y) tanh(0.5 + 0.4*(x'*y)); ...
    @(x,y) tanh(0.5 + 0.6*(x'*y)); ...
    @(x,y) tanh(0.5 + 0.8*(x'*y)); ...
    @(x,y) exp((-(repmat(sum(x.^2,1)',1,size(y,2))-2*(x'*y)+repmat(sum(y.^2,1),size(x,2),1))/0.1)); ...  % Gaussian
    @(x,y) exp((-(repmat(sum(x.^2,1)',1,size(y,2))-2*(x'*y)+repmat(sum(y.^2,1),size(x,2),1))/0.2)); ...
    @(x,y) exp((-(repmat(sum(x.^2,1)',1,size(y,2))-2*(x'*y)+repmat(sum(y.^2,1),size(x,2),1))/0.3)); ...
    @(x,y) exp((-(repmat(sum(x.^2,1)',1,size(y,2))-2*(x'*y)+repmat(sum(y.^2,1),size(x,2),1))/0.4)); ...
    @(x,y) exp((-(repmat(sum(x.^2,1)',1,size(y,2))-2*(x'*y)+repmat(sum(y.^2,1),size(x,2),1))/0.5)); ...
    @(x,y) exp((-(repmat(sum(x.^2,1)',1,size(y,2))-2*(x'*y)+repmat(sum(y.^2,1),size(x,2),1))/0.6)); ...
    @(x,y) exp((-(repmat(sum(x.^2,1)',1,size(y,2))-2*(x'*y)+repmat(sum(y.^2,1),size(x,2),1))/0.7)); ...
    @(x,y) exp((-(repmat(sum(x.^2,1)',1,size(y,2))-2*(x'*y)+repmat(sum(y.^2,1),size(x,2),1))/0.8)); ...
    @(x,y) exp((-(repmat(sum(x.^2,1)',1,size(y,2))-2*(x'*y)+repmat(sum(y.^2,1),size(x,2),1))/0.9)); ...
    @(x,y) exp((-(repmat(sum(x.^2,1)',1,size(y,2))-2*(x'*y)+repmat(sum(y.^2,1),size(x,2),1))/1.0)); ...
    @(x,y) exp((-(repmat(sum(x.^2,1)',1,size(y,2))-2*(x'*y)+repmat(sum(y.^2,1),size(x,2),1))/1.1)); ...
    @(x,y) exp((-(repmat(sum(x.^2,1)',1,size(y,2))-2*(x'*y)+repmat(sum(y.^2,1),size(x,2),1))/1.2)); ...
    @(x,y) exp((-(repmat(sum(x.^2,1)',1,size(y,2))-2*(x'*y)+repmat(sum(y.^2,1),size(x,2),1))/1.3)); ...
    @(x,y) exp((-(repmat(sum(x.^2,1)',1,size(y,2))-2*(x'*y)+repmat(sum(y.^2,1),size(x,2),1))/1.4)); ...
    @(x,y) exp((-(repmat(sum(x.^2,1)',1,size(y,2))-2*(x'*y)+repmat(sum(y.^2,1),size(x,2),1))/1.5)); ...
    @(x,y) exp((-(repmat(sum(x.^2,1)',1,size(y,2))-2*(x'*y)+repmat(sum(y.^2,1),size(x,2),1))/1.6)); ...
    @(x,y) exp((-(repmat(sum(x.^2,1)',1,size(y,2))-2*(x'*y)+repmat(sum(y.^2,1),size(x,2),1))/1.7)); ...
    @(x,y) exp((-(repmat(sum(x.^2,1)',1,size(y,2))-2*(x'*y)+repmat(sum(y.^2,1),size(x,2),1))/1.8)); ...
    };
%% Compute the M kernel matrices
textprogressbar('Generating first set of matrices: ')
% Find K_m(Y, Y) for all M kernel functions
kernel_mats = cell(length(kfncs), 1);
for m=1:length(kfncs)
    option.kernel = 'cust'; option.kernelfnc=kfncs{m};
    kernel_mats{m} = computeKernelMatrix(Dict,Dict,option);
    textprogressbar(m*100/length(kfncs));
end

% Make the ideal matrix - FIXME - assumes blocks of samples (probably fine)
K_ideal = eye(size(Dict,2));
% Find the number of samples in each class
classes = unique(dictClassSmall);
num_classes = numel(classes);
masks = zeros(size(Dict,2),numel(classes));
for i=1:num_classes
    num_samples_per_class(i) = sum(dictClassSmall == classes(i));
    masks(:,i) = dictClassSmall == classes(i);
    locs = find(dictClassSmall == classes(i));
    K_ideal(min(locs):max(locs),min(locs):max(locs)) = 1;
end
textprogressbar(' Done.');
%% Get ranked ordering of kfncs based on similarity to ideal kernel
textprogressbar('Generating ranks of matrices: ')
for i=1:length(kfncs)
    alignment_scores(i) = kernelAlignment(kernel_mats{i}, K_ideal);
    textprogressbar(i*100/length(kfncs));
end
[sorted, idx] = sort(alignment_scores,'descend');
kernel_mats = kernel_mats(idx);
kfncs = kfncs(idx);
textprogressbar(' Done.');
%% Compute more kernel matrices
% if iscell(Hfull) == 0
    textprogressbar('Generating second set of matrices: ');
    for kidx=1:length(kfncs)
        eta_temp = [];
        eta_temp(kidx) = 1; % place a 1 in the current kernel
        
        Hfull{kidx,1}=computeMultiKernelMatrix(Dict,Dict,eta_temp,kfncs);
        for sidx=1:length(trainClassSmall)
            Gfull{kidx,sidx}=computeMultiKernelMatrix(Dict,trainSetSmall(:,sidx),eta_temp,kfncs);
            Bfull{kidx,sidx}=computeMultiKernelMatrix(trainSetSmall(:,sidx),trainSetSmall(:,sidx),eta_temp,kfncs);
        end
        
        textprogressbar(kidx*100/length(kfncs));
    end
    textprogressbar(' Done.');
% end
%% Generate eta
eta = zeros(length(kfncs),1);
eta(1)=1;
%% Parameters
mu = .02;
% sparsity_reg \lambda
lambda = .1;
% max iterations
T = 20;
% error thresh for convergence
err_thresh = .01;
err = err_thresh + 1;
%% Loop to get all sparse coeffs
% Find the number of samples in each class
classes = unique(dictClassSmall);
num_classes = numel(classes);
for i=1:num_classes
    num_per_class(i) = sum(dictClassSmall == classes(i));
end

t = 0;
while(t <= T && err>= err_thresh)
    t = t + 1;
    
    [X, h, g, z, zm, c] = mklsrcUpdate(Hfull, Gfull, Bfull, eta, trainClassSmall, num_classes, num_per_class);
    
    if sum(z)/length(z) == 1 | sum(c)==0
        err = 0;
    else    
        [eta, err] = updateEta(eta, c, mu, z, zm);
    end
    
    display(['Iteration: ' num2str(t) '/' num2str(T) ' Accuracy: ' num2str(sum(z)/numel(z)) ' Error: ' num2str(err)])
end
%% Look at the recon errors
errors = trainSetSmall - Dict*X;
errornorms = vecnorm(errors);
%% Test the test set
textprogressbar('Generating testing matrices: ')
for kidx=1:length(kfncs)
    eta_temp = [];
    eta_temp(kidx) = 1; % place a 1 in the current kernel
    
    Hfulltest{kidx,1}=computeMultiKernelMatrix(Dict,Dict,eta_temp,kfncs);
    for sidx=1:length(testClassSmall)
        Gfulltest{kidx,sidx}=computeMultiKernelMatrix(Dict,testSetSmall(:,sidx),eta_temp,kfncs);
        Bfulltest{kidx,sidx}=computeMultiKernelMatrix(testSetSmall(:,sidx),testSetSmall(:,sidx),eta_temp,kfncs);
    end
    textprogressbar(kidx*100/length(kfncs));
end
textprogressbar(' Done.');

[Xtest, htest, ~, ztest, ~, ~] = mklsrcUpdate(Hfulltest, Gfulltest, Bfulltest, eta, testClassSmall, num_classes, num_per_class);
   
display(['Testing Accuracy: ' num2str(sum(ztest)/numel(ztest))])

%% Get just the top K largest coeffs in the Xtest for analysis
Xtestsparse = Xtest;
% K=3;
% totalnums = 1:length(Xtestsparse(:,1));
% for i=1:size(Xtestsparse,2)
%     [~, maxes]=maxk(Xtestsparse(:,i), K);
%     Xtestsparse(setdiff(totalnums, maxes),i) = 0;
% end
recons = Dict*Xtestsparse;
recon_errors = testSetSmall - recons;
errors = vecnorm(recon_errors);
