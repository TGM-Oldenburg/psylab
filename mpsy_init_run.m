% Usage: mpsy_init_run
%
%  To be called at the beginning of a new measurement run.
%  A typical call would be be M = mpsy_init_run(M);
%
%  Clears history of past run (i.e. set M.REVERSAL, M.VARS, M.STEPS,
%  M.ANSWERS, M.REV_IDX
%  to zero or to empty vectors).
%  Sets some variables to default values.
% 
%   input:   (none), works on global variables
%  output:   (none) 
%
% Copyright (C) 2003, 2004   Martin Hansen, FH OOW  
% Author :  Martin Hansen,  <psylab AT jade-hs.de>
% Date   :  23 May 2003
% Updated:  < 8 Apr 2013 08:42, martin>
% Updated:  < 7 Mai 2010 22:45, hansen>
% Updated:  <25 Okt 2006 21:28, hansen>
% Updated:  <14 Jan 2004 11:30, hansen>

%% This file is part of PSYLAB, a collection of scripts for
%% designing and controlling interactive psychoacoustical listening
%% experiments.  
%% This file is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published
%% by the Free Software Foundation; either version 2 of the License, 
%% or (at your option) any later version.  See the GNU General
%% Public License for more details:  http://www.gnu.org/licenses/gpl
%% This file is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.


% clear reference and test signal, as a security means
clear m_test m_ref* 

% clear history of past run 
M.REVERSAL  = 0;
M.VARS      = [];
M.STEPS     = [];
M.ANSWERS   = [];
%M.REV_IDX   = [];
M.LOWER_REV_IDX   = [];
M.UPPER_REV_IDX   = [];
M.DIRECTION = [];
%

% generate silence signals, in case only their duration is specified.
% NOTE: this works only in case of mono signals
if isscalar(m_quiet),
  m_quiet = zeros(round(m_quiet*M.FS), 1);
  disp('hu')
end
if isscalar(m_postsig),
  m_postsig = zeros(round(m_postsig*M.FS), 1);
  disp('ha')
end
if isscalar(m_presig),
  m_presig = zeros(round(m_presig*M.FS), 1);
  disp('he')
end


% reset some internal variables 
% NOTE:  mpsy_proto and mpsy_plot_feedback depend on THIS:
M.med_thres = [];

% set some variables to default-values, if not yet present
if ~isfield(M, 'TASK')
  M.TASK = '';
end
if ~isfield(M, 'EARSIDE'),
  M.EARSIDE = M_BINAURAL;
  % fprintf('*** Info: (%s)  M.EARSIDE has been set to M_BINAURAL\n', mfilename);
end
if ~isfield(M, 'RESULTSTYLE'),
  M.RESULTSTYLE = 1;   % all plots into one 
end
if ~isfield(M, 'USE_GUI'),
  M.USE_GUI = 0;
end
if ~isfield(M, 'VISUAL_INDICATOR'),
  M.VISUAL_INDICATOR = 0;
end
if ~isfield(M, 'INFO'),
  M.INFO = 1;
end
if ~isfield(M, 'FEEDBACK'),
  M.FEEDBACK = 1;
end
if ~isfield(M, 'DEBUG'),
  M.DEBUG = 0;
end
if ~isfield(M, 'USE_MSOUND')
  M.USE_MSOUND = 0;
end


if ~ispc & M.VISUAL_INDICATOR & ~M.USE_MSOUND,
  M.VISUAL_INDICATOR = 0;
  disp('*** info:  The VISUAL_INDICATOR feature is not yet supported on non-pcwin computers');
end


if M.USE_MSOUND
  msound_state = msound('verbose', 0);
  if ~msound_state.IsOpenForWriting,
    msound('openWrite', M.MSOUND_DEVID, M.FS, M.MSOUND_FRAMELEN, M.MSOUND_NCHAN);
  else
    % do nothing, continue to use the already opened msound
  end
end

% from version 2.6 and up, reversals are counted both at upper
% reversals (change from going up to down) and lower reversals
% (change from going down to up).  However, in version 2.5. and
% below, only upper reversal were counted.  So check for meaningful
% number of reversals:  
% Every maximal reversal count <= 4 is suspicious for belonging
% to an older psylab experiment designed before version 2.6:
if M.MAXREVERSAL <= 4,
  % upon fresh delivery, the psylab distribution contains the two
  % files 'mpsy_maxreversal_check' and 'mpsy_maxreversal_askagain'
  % which are identical upon delivery
  flag_reversal_ok = mpsy_maxreversal_check(M.MAXREVERSAL);
  
  tmp_pathname = fileparts( which ('mpsy_maxreversal_check'));
  if flag_reversal_ok == 1,
    % do nothing, or equivalently:
    copyfile( fullfile(tmp_pathname, 'mpsy_maxreversal_askagain.m'), ...
              fullfile(tmp_pathname, 'mpsy_maxreversal_check.m'));
  else
    % (re-)create the file 'mpsy_maxreversal_check.m'
    new_filename = 'mpsy_maxreversal_dontask.m'
    if exist(new_filename) ~= 2,
      % create the file, if it doesn't exist yet
      [fid, msg] = fopen( fullfile( tmp_pathname, new_filename), 'w');
      if fid == -1,
        error('fopen on file %s exited with message %s', new_filename, msg);
      end
      fprintf(fid, 'function y =  mpsy_maxreversal_dontask(n_maxreversal)\n\n'); 
      fprintf(fid, '%% this function was auto-generated by mpsy_init_run.m on %s\n', datestr(now)); 
      fprintf(fid, '%% its existence indicates that the user selected, not to check the value   \n'); 
      fprintf(fid, '%% of variable M.MAXREVERSAL for a meaningful value in the future.  \n'); 
      fprintf(fid, '\n\n'); 
      fprintf(fid, 'y = 0; \n\n'); 
      fclose(fid);
    end
    % and overwrite the file  'mpsy_maxreversal_check.m'
    copyfile( fullfile(tmp_pathname, 'mpsy_maxreversal_dontask.m'), ...
              fullfile(tmp_pathname, 'mpsy_maxreversal_check.m'));
            
  end
  
    
end

% End of file:  mpsy_init_run.m

% Local Variables:
% time-stamp-pattern: "40/Updated:  <%2d %3b %:y %02H:%02M, %u>"
% End:
