function Al = cylexpR_mono_pw(nk,f,x0,conf)
%Regular Cylindrical Expansion of Plane Wave
%
%   Usage: Al = cylexpR_mono_pw(nk,f,x0,conf)
%
%   Input parameters:
%       nk          - propagation direction of plane wave 
%       f           - frequency
%       x0          - optional expansion center
%       conf        - optional configuration struct (see SFS_config)
%
%   Output parameters:
%       Al          - regular cylindrical Expansion Coefficients
%
%   CYLEXPR_MONO_PW(nk,x0,f,conf) computes the regular cylindrical
%   expansion coefficients for a plane wave. The expansion will be done 
%   around the expansion center x0.  
%
%   References:
%       Gumerov,Duraiswami (2004) - "Fast Multipole Methods for the 
%                                    Helmholtz Equation in three 
%                                    Dimensions", ELSEVIER
%
%   see also:

%*****************************************************************************
% Copyright (c) 2010-2014 Quality & Usability Lab, together with             *
%                         Assessment of IP-based Applications                *
%                         Telekom Innovation Laboratories, TU Berlin         *
%                         Ernst-Reuter-Platz 7, 10587 Berlin, Germany        *
%                                                                            *
% Copyright (c) 2013-2014 Institut fuer Nachrichtentechnik                   *
%                         Universitaet Rostock                               *
%                         Richard-Wagner-Strasse 31, 18119 Rostock           *
%                                                                            *
% This file is part of the Sound Field Synthesis-Toolbox (SFS).              *
%                                                                            *
% The SFS is free software:  you can redistribute it and/or modify it  under *
% the terms of the  GNU  General  Public  License  as published by the  Free *
% Software Foundation, either version 3 of the License,  or (at your option) *
% any later version.                                                         *
%                                                                            *
% The SFS is distributed in the hope that it will be useful, but WITHOUT ANY *
% WARRANTY;  without even the implied warranty of MERCHANTABILITY or FITNESS *
% FOR A PARTICULAR PURPOSE.                                                  *
% See the GNU General Public License for more details.                       *
%                                                                            *
% You should  have received a copy  of the GNU General Public License  along *
% with this program.  If not, see <http://www.gnu.org/licenses/>.            *
%                                                                            *
% The SFS is a toolbox for Matlab/Octave to  simulate and  investigate sound *
% field  synthesis  methods  like  wave  field  synthesis  or  higher  order *
% ambisonics.                                                                *
%                                                                            *
% http://github.com/sfstoolbox/sfs                      sfstoolbox@gmail.com *
%*****************************************************************************

%% ===== Checking of input  parameters ==================================
nargmin = 1;
nargmax = 4;
narginchk(nargmin,nargmax);
isargvector(nk);
if nargin<nargmax
    conf = SFS_config;
else
    isargstruct(conf);
end

%% ===== Configuration ==================================================
showprogress = conf.showprogress;
Nce = conf.scattering.Nce;
timereverse = conf.scattering.timereverse;

%% ===== Computation ====================================================
if (timereverse)
  n_sign = 1;
else
  n_sign = -1;
end

% convert nk into cylindrical coordinates
phi = atan2(nk(2),nk(1));

L = 2*Nce+1;
Al = zeros(L,1);
l = 0;
for n=-Nce:Nce
  l = l+1;
  Al(l) = (1j)^(n_sign*n).*exp(-1j*n*phi);
  if showprogress, progress_bar(l,L); end % progress bar
end

end

