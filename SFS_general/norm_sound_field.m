function P = norm_sound_field(P)
%NORM_SOUND_FIELD normalizes the sound field
%
%   Usage: P = norm_sound_field(P)
%
%   Input options:
%       P       - sound field
%
%   Output options:
%       P       - normalized sound field
%
%   NORM_SOUND_FIELD(P) normalizes the given sound field P to 1 at its center
%   position, or if the given value at the center is < 0.3 to 1 as its maximum
%   value.
%
%   See also: plot_sound_field

%*****************************************************************************
% Copyright (c) 2010-2015 Quality & Usability Lab, together with             *
%                         Assessment of IP-based Applications                *
%                         Telekom Innovation Laboratories, TU Berlin         *
%                         Ernst-Reuter-Platz 7, 10587 Berlin, Germany        *
%                                                                            *
% Copyright (c) 2013-2015 Institut fuer Nachrichtentechnik                   *
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


%% ===== Checking of input parameters ====================================
nargmin = 1;
nargmax = 1;
narginchk(nargmin,nargmax);
isargnumeric(P);


%% ===== Computation =====================================================
% If abs(P)>0.3 at center of sound field use that value for normalization,
% otherwise look for the maximum value in the sound field. The first case is the
% better normalization for monochromaticsound field, the second one for
% time-domain sound fields
if abs(P(round(end/2),round(end/2)))>0.3
    P = P/max(abs(P(round(end/2),round(end/2))));
else
    P = P/max(abs(P(:)));
end
