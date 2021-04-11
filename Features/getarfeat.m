%
% getARfeat: gets the Auto-Regressive Coefficients feature.
%
% feat = getarfeat(x,winsize,wininc,order)
%
% This function computes the auto-regressive coefficients feature of the signals in x,
% which are stored in columns.
%
% The signals in x are divided into multiple windows of size
% winsize and the windows are space wininc apart.
%
% AR model determined using the Levinson-Durbin algorithm.
%
% Inputs
%    x: 		columns of signals
%    winsize:	window size (length of x)
%    wininc:	spacing of the windows (winsize)
%    order:     order of AR model
%    datawin:   window for data (e.g. Hamming, default rectangular)
%               must have dimensions of (winsize,1)
%
% Outputs
%    feat:     auto-regressive coefficient values in a 2 dimensional matrix
%              dim1 window
%              dim2 feature
%                   (AR coefficients from the next signal is to the right of the previous signal)

function feat = getarfeat(x,winsize,wininc,option)

if nargin < 4
   if nargin < 3
      if nargin < 2
         winsize = size(x,1);
      end
      wininc = winsize;
   end
   option(1) = 4; % Should be defined 1->
end
    
order = option(1);
datawin = ones(winsize,1);

datasize = size(x,1);
Nsignals = size(x,2);
numwin = floor((datasize - winsize)/wininc)+1;

feat = zeros(numwin,Nsignals*order);

st = 1;
en = winsize;

for i = 1:numwin
   curwin = x(st:en,:).*repmat(datawin,1,Nsignals);

   cur_xlpc = real(lpc(curwin,order)');
   cur_xlpc = cur_xlpc(2:(order+1),:);
   feat(i,:) = reshape(cur_xlpc,1,Nsignals*order);
   
   st = st + wininc;
   en = en + wininc;
end
