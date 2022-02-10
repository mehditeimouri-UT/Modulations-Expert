function ydata = tsne_ME(X, labels, no_dims, initial_dims, perplexity, max_iter)

% This Performs symmetric t-SNE on dataset X.
%
% Copyright (C) Laurens van der Maaten, 2010, University of California, San Diego
% Copyright (C) 2020 Mehdi Teimouri <mehditeimouri [at] ut.ac.ir>
%
% This file is a part of Modulations-Expert software, a software package for
% feature extraction from modulated signals and classification among various modulations.
% 
% Modulations-Expert software is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License 
% as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
%
% Modulations-Expert software is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along with this program.
% If not, see <http://www.gnu.org/licenses/>.
%
% Usauges:
%
%   mappedX = tsne(X, labels, no_dims, initial_dims, perplexity, max_iter)
%
% The function performs symmetric t-SNE on the NxD dataset X to reduce its
% dimensionality to no_dims dimensions (default = 2). The data is
% preprocessed using PCA, reducing the dimensionality to initial_dims
% dimensions (default = 30).
% The perplexity of the Gaussian kernel that is employed can be specified
% through perplexity (default = 30). The labels of the data are not used
% by t-SNE itself, however, they are used to color intermediate plots.
% max_iter is the maximum number of iterations in tsne_p function.
%
% Revisions:
% 2020-Oct-28   function was created

% Normalize input data
X = X - min(X(:));
X = X / max(X(:));
X = bsxfun(@minus, X, mean(X, 1));

% Perform preprocessing using PCA
GUI_MainEditBox_Update_ME(false,'Preprocessing data using PCA...');
pause(0.01);
if size(X, 2) < size(X, 1)
    C = X' * X;
else
    C = (1 / size(X, 1)) * (X * X');
end
[M, lambda] = eig(C);
[lambda, ind] = sort(diag(lambda), 'descend');
M = M(:,ind(1:initial_dims));
lambda = lambda(1:initial_dims);
if ~(size(X, 2) < size(X, 1))
    M = bsxfun(@times, X' * M, (1 ./ sqrt(size(X, 1) .* lambda))');
end
X = bsxfun(@minus, X, mean(X, 1)) * M;
clear M lambda ind

% Compute pairwise distance matrix
sum_X = sum(X .^ 2, 2);
D = bsxfun(@plus, sum_X, bsxfun(@plus, sum_X', -2 * (X * X')));

% Compute joint probabilities
P = d2p(D, perplexity, 1e-5); % compute affinities using fixed perplexity
if isequal(P,-1)
    ydata = -1;
    return;
end
clear D

% Run t-SNE
ydata = tsne_p(P, labels, no_dims, max_iter);

end

%% d2p Function
function [P, beta] = d2p(D, u, tol)
% D2P Identifies appropriate sigma's to get kk NNs up to some tolerance
%
%   [P, beta] = d2p(D, kk, tol)
%
% Identifies the required precision (= 1 / variance^2) to obtain a Gaussian
% kernel with a certain uncertainty for every datapoint. The desired
% uncertainty can be specified through the perplexity u (default = 15). The
% desired perplexity is obtained up to some tolerance that can be specified
% by tol (default = 1e-4).
% The function returns the final Gaussian kernel in P, as well as the
% employed precisions per instance in beta.
%
%
% (C) Laurens van der Maaten, 2008
% Maastricht University


if ~exist('u', 'var') || isempty(u)
    u = 15;
end
if ~exist('tol', 'var') || isempty(tol)
    tol = 1e-4;
end

% Initialize some variables
n = size(D, 1);                     % number of instances
P = zeros(n, n);                    % empty probability matrix
beta = ones(n, 1);                  % empty precision vector
logU = log(u);                      % log of perplexity (= entropy)

% Run over all datapoints
progressbar_ME('Computing P-values ...');
for i=1:n
    
    if ~rem(i, 500)
        GUI_MainEditBox_Update_ME(false,['Computed P-values ' num2str(i) ' of ' num2str(n) ' datapoints...']);
        pause(0.01);
    end
    
    % Set minimum and maximum values for precision
    betamin = -Inf;
    betamax = Inf;
    
    % Compute the Gaussian kernel and entropy for the current precision
    [H, thisP] = Hbeta(D(i, [1:i - 1, i + 1:end]), beta(i));
    
    % Evaluate whether the perplexity is within tolerance
    Hdiff = H - logU;
    tries = 0;
    while abs(Hdiff) > tol && tries < 50
        
        % If not, increase or decrease precision
        if Hdiff > 0
            betamin = beta(i);
            if isinf(betamax)
                beta(i) = beta(i) * 2;
            else
                beta(i) = (beta(i) + betamax) / 2;
            end
        else
            betamax = beta(i);
            if isinf(betamin)
                beta(i) = beta(i) / 2;
            else
                beta(i) = (beta(i) + betamin) / 2;
            end
        end
        
        % Recompute the values
        [H, thisP] = Hbeta(D(i, [1:i - 1, i + 1:end]), beta(i));
        Hdiff = H - logU;
        tries = tries + 1;
    end
    
    % Set the final row of P
    P(i, [1:i - 1, i + 1:end]) = thisP;
    
    stopbar = progressbar_ME(1,i/n);
    if stopbar
        P = -1;
        beta = -1;
        return;
    end

end
%disp(['Mean value of sigma: ' num2str(mean(sqrt(1 ./ beta)))]);
%disp(['Minimum value of sigma: ' num2str(min(sqrt(1 ./ beta)))]);
%disp(['Maximum value of sigma: ' num2str(max(sqrt(1 ./ beta)))]);
end

%% Hbeta Function
% Function that computes the Gaussian kernel values given a vector of
% squared Euclidean distances, and the precision of the Gaussian kernel.
% The function also computes the perplexity of the distribution.
function [H, P] = Hbeta(D, beta)
P = exp(-D * beta);
sumP = sum(P);
H = log(sumP) + beta * sum(D .* P) / sumP;
% why not: H = exp(-sum(P(P > 1e-5) .* log(P(P > 1e-5)))); ???
P = P / sumP;
end

%% tsne_p Function
function ydata = tsne_p(P, labels, no_dims, max_iter)
%TSNE_P Performs symmetric t-SNE on affinity matrix P
%
%   mappedX = tsne_p(P, labels, no_dims, max_iter)
%
% The function performs symmetric t-SNE on pairwise similarity matrix P
% to create a low-dimensional map of no_dims dimensions (default = 2).
% The matrix P is assumed to be symmetric, sum up to 1, and have zeros
% on the diagonal.
% The labels of the data are not used by t-SNE itself, however, they
% are used to color intermediate plots. Please provide an empty labels
% matrix [] if you don't want to plot results during the optimization.
% The low-dimensional data representation is returned in mappedX.
% max_iter is the maximum number of iterations in tsne_p function.
%
% (C) Laurens van der Maaten, 2010
% University of California, San Diego

if ~exist('labels', 'var')
    labels = [];
end
if ~exist('no_dims', 'var') || isempty(no_dims)
    no_dims = 2;
end

% First check whether we already have an initial solution
if numel(no_dims) > 1
    initial_solution = true;
    ydata = no_dims;
    no_dims = size(ydata, 2);
else
    initial_solution = false;
end

% Initialize some variables
n = size(P, 1);                                     % number of instances
momentum = 0.5;                                     % initial momentum
final_momentum = 0.8;                               % value to which momentum is changed
mom_switch_iter = 250;                              % iteration at which momentum is changed
stop_lying_iter = 100;                              % iteration at which lying about P-values is stopped
epsilon = 500;                                      % initial learning rate
min_gain = .01;                                     % minimum gain for delta-bar-delta

% Make sure P-vals are set properly
P(1:n + 1:end) = 0;                                 % set diagonal to zero
P = 0.5 * (P + P');                                 % symmetrize P-values
P = max(P ./ sum(P(:)), realmin);                   % make sure P-values sum to one
const = sum(P(:) .* log(P(:)));                     % constant in KL divergence
if ~initial_solution
    P = P * 4;                                      % lie about the P-vals to find better local minima
end

% Initialize the solution
if ~initial_solution
    ydata = .0001 * randn(n, no_dims);
end
y_incs  = zeros(size(ydata));
gains = ones(size(ydata));

% Run the iterations
h = [];
progressbar_ME('Please wait ...');
for iter=1:max_iter
    
    % Compute joint probability that point i and j are neighbors
    sum_ydata = sum(ydata .^ 2, 2);
    num = 1 ./ (1 + bsxfun(@plus, sum_ydata, bsxfun(@plus, sum_ydata', -2 * (ydata * ydata')))); % Student-t distribution
    num(1:n+1:end) = 0;                                                 % set diagonal to zero
    Q = max(num ./ sum(num(:)), realmin);                               % normalize to get probabilities
    
    % Compute the gradients (faster implementation)
    L = (P - Q) .* num;
    y_grads = 4 * (diag(sum(L, 1)) - L) * ydata;
    
    % Update the solution
    gains = (gains + .2) .* (sign(y_grads) ~= sign(y_incs)) ...         % note that the y_grads are actually -y_grads
        + (gains * .8) .* (sign(y_grads) == sign(y_incs));
    gains(gains < min_gain) = min_gain;
    y_incs = momentum * y_incs - epsilon * (gains .* y_grads);
    ydata = ydata + y_incs;
    ydata = bsxfun(@minus, ydata, mean(ydata, 1));
    
    % Update the momentum if necessary
    if iter == mom_switch_iter
        momentum = final_momentum;
    end
    if iter == stop_lying_iter && ~initial_solution
        P = P ./ 4;
    end
    
    % Print out progress
    %if ~rem(iter, 10)
        %cost = const - sum(P(:) .* log(Q(:)));
        %disp(['Iteration ' num2str(iter) ': error is ' num2str(cost)]);
    %end
    
    % Display scatter plot (maximally first three dimensions)
    if ~rem(iter, 10) && ~isempty(labels)
        if isempty(h)
            h = figure('Name','t-SNE Visualization','NumberTitle','off');
        else
            figure(h);
        end
        if no_dims == 2
            gscatter(ydata(:,1), ydata(:,2), labels);
            set(gca,'xtick',[])
            set(gca,'xticklabel',[])
            set(gca,'ytick',[])
            set(gca,'yticklabel',[])
        else
            gsh = gscatter(ydata(:,1), ydata(:,2), labels);
            labels_unique = unique(labels);
            for k = 1:numel(labels_unique)
                set(gsh(k), 'ZData', ydata(cellfun(@isequal,labels,repmat(labels_unique(k),size(labels,1),1)),3));
            end
            view(3);
            set(gca,'xtick',[])
            set(gca,'xticklabel',[])
            set(gca,'ytick',[])
            set(gca,'yticklabel',[])
            set(gca,'ztick',[])
            set(gca,'zticklabel',[])
        end
        axis tight
        drawnow
    end
    
    stopbar = progressbar_ME(1,iter/max_iter);
    if stopbar
        if isempty(h)
            figure('Name','t-SNE Visualization','NumberTitle','off');
        else
            figure(h);
        end
        if no_dims == 2
            gscatter(ydata(:,1), ydata(:,2), labels);
            set(gca,'xtick',[])
            set(gca,'xticklabel',[])
            set(gca,'ytick',[])
            set(gca,'yticklabel',[])
        else
            gsh = gscatter(ydata(:,1), ydata(:,2), labels);
            labels_unique = unique(labels);
            for k = 1:numel(labels_unique)
                set(gsh(k), 'ZData', ydata(cellfun(@isequal,labels,repmat(labels_unique(k),size(labels,1),1)),3));
            end
            view(3);
            set(gca,'xtick',[])
            set(gca,'xticklabel',[])
            set(gca,'ytick',[])
            set(gca,'yticklabel',[])
            set(gca,'ztick',[])
            set(gca,'zticklabel',[])
        end
        axis tight
        drawnow
        
        return
    end
    
    if ~rem(iter, 10) && ~isempty(labels) && iter<max_iter
        progressbar_ME();
    end
end

end