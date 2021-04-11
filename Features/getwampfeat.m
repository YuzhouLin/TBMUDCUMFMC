%
% GETWAMPFEAT Gets the Willison Amplitude feature.
%
% feat = getwampfeat(x,winsize,wininc,threshold)
%
% This function computes the Willison amplitude feature of the signals in x,
% which are stored in columns.
%
% The signals in x are divided into multiple windows of size
% winsize and the windows are space wininc apart.
%
% Inputs
%    x: 		columns of signals
%    threshold: avoiding background noise in the signals
%    winsize:	window size
%    wininc:	spacing of the windows (winsize)
%    datawin:   window for data (e.g. Hamming, default rectangular)
%               must have dimensions of (winsize,1)
%
% Outputs
%    feat:     Willison amplitude value in a 2 dimensional matrix
%              dim1 window
%              dim2 feature (col i is the features for the signal in column i of x)

function feat = getwampfeat(x,winsize,wininc,option)

if nargin < 4
   if nargin < 3
      if nargin < 2
         winsize = size(x,1);
      end
      wininc = winsize;
   end
   option(1) = 1; % The threshold value should be defined.
end

threshold = option(1);

datawin = ones(winsize,1);
datasize = size(x,1);
Nsignals = size(x,2);
numwin = floor((datasize - winsize)/wininc)+1;

feat = zeros(numwin,Nsignals);

st = 1;
en = winsize;

for i = 1:numwin
   curwin = x(st:en,:).*repmat(datawin,1,Nsignals);
   
   % WAMP
   curwin2 = curwin(2:end,:);
   curwin1 = curwin(1:end-1,:);
   clear curwin
   con = (abs(curwin1-curwin2)>=threshold);
   feat(i,:) = sum(con==1);
   clear curwin1 curwin2 con
   
   st = st + wininc;
   en = en + wininc;
end
