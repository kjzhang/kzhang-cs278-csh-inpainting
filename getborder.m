function Ib = getborder(I,method);

% create border inside or outside a mask of logical arrays
%
% Ib = getborder(Ib,method)
% _________________________________________________________________________
%
% getborder returns the outline around logical values in A (mask) using a 8-
% connected neighborhood. 
% A must be a logical n*m matrix. method 'inside' returns the inner border 
% around "islands" of logical values. 'outside' returns the border outside 
% the islands.
% 
% Example:
%
% I = peaks(8)<0
% 
% I =
% 
%      0     0     1     1     1     1     1     1
%      0     0     1     1     1     1     1     0
%      1     0     0     1     1     1     0     0
%      1     1     1     0     0     0     0     0
%      1     1     1     0     0     0     0     0
%      1     1     0     0     0     0     0     0
%      0     0     0     0     0     0     0     0
%      0     0     0     0     0     0     0     0
% 
% Ib = getborder(I,'inside')
% 
% Ib =
% 
%      0     0     1     1     1     1     1     1
%      0     0     1     1     0     1     1     0
%      1     0     0     1     1     1     0     0
%      1     1     1     0     0     0     0     0
%      1     1     1     0     0     0     0     0
%      1     1     0     0     0     0     0     0
%      0     0     0     0     0     0     0     0
%      0     0     0     0     0     0     0     0
%      
% Ib = getborder(I,'outside')
% 
% Ib =
% 
%      0     1     0     0     0     0     0     0
%      1     1     0     0     0     0     0     1
%      0     1     1     0     0     0     1     1
%      0     0     0     1     1     1     1     0
%      0     0     0     1     0     0     0     0
%      0     0     1     1     0     0     0     0
%      1     1     1     0     0     0     0     0
%      0     0     0     0     0     0     0     0

% _________________________________________________________________________
% Wolfgang Schwanghart
%

% check input
if nargin~=2;
    error('wrong number of input arguments')
end

if ~islogical(I);
    error('I must be a logical matrix');
end

if strncmpi(method, 'inside', 1);
    method = 'inside';
elseif strncmpi(method, 'outside', 1);
    method = 'outside';
else
    error('unknown method');
end
    
% Kernel
B   = ones(3,3);
% convolution
C   = conv2(double(I),B,'same');

% create border
switch lower(method);
    case {'inside'};
        Ib = C<9 & I;
    case {'outside'};
        Ib = C>0 & ~I;
end
