function [P,x,y,z] = wave_field_mono_line_source(X,Y,Z,xs,varargin)
%WAVE_FIELD_MONO_LINE_SOURCE simulates a wave field for a line source
%
%   Usage: [P,x,y,z] = wave_field_mono_line_source(X,Y,Z,xs,f,[conf])
%
%   Input parameters:
%       X           - [xmin,xmax]
%       Y           - [ymin,ymax]
%       Z           - [zmin,zmax]
%       xs          - position of line source (m)
%       f           - monochromatic frequency (Hz)
%       conf        - optional configuration struct (see SFS_config)
%
%   Output parameters:
%       P           - Simulated wave field
%       x           - corresponding x axis
%       y           - corresponding y axis
%       z           - corresponding z axis
%
%   WAVE_FIELD_MONO_LINE_SOURCE(X,Y,Z,xs,f,conf) simulates a wave
%   field of a line source positioned at xs.
%   To plot the result use plot_wavefield(P,x,y,z).
%
%   References:
%       Williams1999 - Fourier Acoustics (Academic Press)
%
%   see also: wave_field_mono, plot_wavefield, wave_field_imp_point_source

%*****************************************************************************
% Copyright (c) 2010-2013 Quality & Usability Lab, together with             *
%                         Assessment of IP-based Applications                *
%                         Deutsche Telekom Laboratories, TU Berlin           *
%                         Ernst-Reuter-Platz 7, 10587 Berlin, Germany        *
%                                                                            *
% Copyright (c) 2013      Institut fuer Nachrichtentechnik                   *
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
% http://dev.qu.tu-berlin.de/projects/sfs-toolbox       sfstoolbox@gmail.com *
%*****************************************************************************


%% ===== Checking of input  parameters ==================================
nargmin = 5;
nargmax = 6;
narginchk(nargmin,nargmax);
isargxs(xs);


%% ===== Computation ====================================================
[P,x,y,z] = wave_field_mono(X,Y,Z,[xs 0 -1 0],'ls',1,varargin{:});
