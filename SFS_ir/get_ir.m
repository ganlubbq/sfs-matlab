function ir = get_ir(sofa,xs,coordinate_system,conf)
%GET_IR returns a IR for the given apparent angle
%
%   Usage: ir = get_ir(sofa,xs,[coordinate_system],[conf])
%
%   Input parameters:
%       sofa    - IR data set (sofa struct)
%       xs      - position of the desired source / m
%                 this is always assumed to be from the position of the listener
%                 which is et to [0 0 0] implicitly
%       coordinate_system - coordinate system xs is specified in, avialable
%                           systems are:
%                             'spherical' - spherical system with phi / rad,
%                                           delta / rad, r / m  (default)
%                             'cartesian' - cartesian system with x,y,z / m
%       conf        - optional configuration struct (see SFS_config)
%
%   Output parameters:
%       ir      - IR for the given position (length of IR x 2)
%
%   GET_IR(sofa,phi,delta,r,X0) returns a single IR set for the given angles 
%   phi and delta. If the desired angles are not present in the IR data set 
%   an interpolation is applied to create the desired angles.
%   The desired radius is achieved by delaying and weighting the impulse
%   response.
%
%   see also: read_irs, slice_irs, intpol_ir 

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
nargmin = 2;
nargmax = 4;
narginchk(nargmin,nargmax)
if nargin==nargmax-1
    if isstruct(coordinate_system)
        conf = coordinate_system;
        coordinate_system = 'spherical';
    else
        conf = SFS_config;
    end
elseif nargin==nargmax-2
    coordinate_system = 'spherical';
    conf = SFS_config;
end


%% ===== Configuration ==================================================
useinterpolation = conf.ir.useinterpolation;
% Precission of the wanted angle. If a IR within the given precission could be
% found no interpolation is applied.
prec = 0.001; % ~ 0.05 deg


%% ===== Computation ====================================================

% === SOFA loading ===
if ~isstruct(sofa) && exist(sofa,'file')
    % get metadata
    header = SOFAload(sofa,'nodata');
elseif isfield(sofa.Data,'IR')
    header = sofa;
    header.Data = rmfield(sofa.Data,'IR');
else
    error('%s: sofa has to be a file or a SOFA struct.',upper(mfilename));
end

% === SOFA checking ===
% Conventions handled so far
SOFA_conventions = { ...
    'SimpleFreeFieldHRIR', ...
    'SingleRoomDRIR', ...
    };
if ~any(strcmp(header.GLOBAL_SOFAConventions,SOFA_conventions))
    error('%s: wrong SOFA Convention.');
end

% === Internal variables ===
% Calculate the apparent azimuth, elevation and distance
x0 = SOFAcalculateAPV(header); % / [deg deg m]
% convert angles to radian
x0(:,1:2) = rad(x0(:,1:2));


% === Coordinate system conversion ===
if strcmp('spherical',coordinate_system)
    % store desired radius
    r = xs(3);
    xs = [correct_azimuth(xs(1)) correct_elevation(xs(2))]';
elseif strcmp('cartesian',coordinate_system)
    % store desired radius
    [phi,delta,r] = cart2sph(xs(1),xs(2),xs(3));
    xs = [phi delta]';
else
    error('%s: unknown coordinate system type.',upper(mfilename));
end

% find the three nearest positions to the desired one (incorporating only angle
% values and disregarding the radius)
[neighbours,idx] = findnearestneighbour(x0(:,1:2)',xs,3);

% check if we have found directly the desired point or have to interpolate
% bewteen different impulse responses
if norm(neighbours(:,1)-xs)<prec || ~useinterpolation
    % return the first nearest neighbour
    ir = get_sofa_data(sofa,idx(1));
    ir = correct_radius(ir,x0(idx(1),3),r,conf);
else
    % === IR interpolation ===
    % check if we have to interpolate in one or two dimensions
    if norm(neighbours(1,1)-neighbours(1,2))<prec || ...
        norm(neighbours(2,1)-neighbours(2,2))<prec
        % --- 1D interpolation ---
        warning('SFS:irs_intpol',...
            ['doing 1D IR interpolation between (%.1f,%.1f) deg ', ...
             'and (%.1f,%.1f) deg.'], ...
            deg(x0(idx(1),1)), deg(x0(idx(1),2)), ...
            deg(x0(idx(2),1)), deg(x0(idx(2),2)));
        ir1 = get_sofa_data(sofa,idx(1));
        ir2 = get_sofa_data(sofa,idx(2));
        ir3 = get_sofa_data(sofa,idx(3));
        ir1 = correct_radius(ir1,x0(idx(1),3),r,conf);
        ir2 = correct_radius(ir2,x0(idx(2),3),r,conf);
        ir = intpol_ir(ir1,ir2,neighbours(:,1:2),xs);
    else
        % --- 2D interpolation ---
        warning('SFS:irs_intpol3D',...
            ['doing 2D IR interpolation between (%.1f,%.1f) deg, ', ...
             '(%.1f,%.1f) deg and (%.1f,%.1f) deg.'], ...
            deg(x0(idx(1),1)), deg(x0(idx(1),2)), ...
            deg(x0(idx(2),1)), deg(x0(idx(2),2)), ...
            deg(x0(idx(3),1)), deg(x0(idx(3),2)));
        ir1 = get_sofa_data(sofa,idx(1));
        ir2 = get_sofa_data(sofa,idx(2));
        ir3 = get_sofa_data(sofa,idx(3));
        ir1 = correct_radius(ir1,x0(idx(1),3),r,conf);
        ir2 = correct_radius(ir2,x0(idx(2),3),r,conf);
        ir3 = correct_radius(ir3,x0(idx(3),3),r,conf);
        ir = intpot_ir(ir1,ir2,ir3,[neighbours; 1 1 1],[xs;1]);
    end
end
end

function ir = correct_radius(ir,ir_distance,r,conf)
    % Fix large distances
    if ir_distance>10, ir_distance = 10; end
    % delay only if we have an delay other than 0
    if abs(r-ir_distance)>0.0001 % ~0.01 samples
        % Time delay of the source (at the listener position)
        delay = (r-ir_distance)/conf.c*conf.fs; % / samples
        % Amplitude weighting (point source model)
        % This gives weight=1 for r==ir_distance
        weight = 1/(r-ir_distance+20) * 20;
        if abs(delay)>size(ir,1)
            error(['%s: your impulse response is to short for a desired ', ...
                'delay of %i samples.'],upper(mfilename),delay);
        end
        % Apply delay and weighting
        ir = delayline(ir,[delay; delay],[weight; weight],conf);
    end
end

function ir = get_sofa_data(sofa,idx)
    % Check if we have a file or struct
    if isstruct(sofa)
        ir = sofa.Data.IR(idx,:,:);
        ir = squeeze(ir)';
    else
        file = sofa;
        % FIXME: this is currently not working under Octave, because it will
        % always return [1 idx] data
        sofa = SOFAload(file,[idx idx]);
        ir = squeeze(sofa.Data.IR)';
    end
end
