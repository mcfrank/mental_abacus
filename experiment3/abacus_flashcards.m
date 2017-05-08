% abacusMagnitudeTest
% mcf and db 7/1/08 
% compares magnitude estimation with abacus reading in terms of speed and
% accuracy
%
% note: to test, put subject number as -1.
% 
% see creative commons license BY 3.0

function abacus_flashcards(subnum)

ListenChar(2); % disable write to matlab
addpath('../helper');
start_time = GetSecs;

if ~isnumeric(subnum)
  error('Subject code must be a number!  Try again using the syntax "abacusMagnitudeTest(1)"\n')
elseif ~isempty(dir(['data/' num2str(subnum) '.mat'])) && subnum~=-1 
  ListenChar(0); % enable write to matlab
  error('datafile already exists!')
end

%% settings
  
settings.viewing_interval = .4; % in seconds, so .4 = 400ms
settings.isi = 1; % inter stimulus interval
settings.abacus.lines = 8;

settings.abacus.line_width = 10;
settings.abacus.bead_diam = 64;
settings.textsize = 70;
settings.space_dim = [450 650];
settings.response_size = 70;
settings.max_digits = 12;

% set up the quantities so that there are different quantities for each of
% abacus and numbers but twice as many trials for dots
settings.before_trial_interval = .5;
settings.experiment_time_limit = 480; % revised to 8 min from 5 min -mcf 10/15

%% init
ws = doScreen;
mask = prepMask(ws,settings);

Screen('TextSize',ws.ptr,40);
drawText('PRESS ANY KEY TO START EXPERIMENT.',ws,1);
Screen('TextSize',ws.ptr,settings.textsize);

settings.num_digits(1) = 1;
settings.num_digits(2) = 1;

i = 1;
while GetSecs - start_time < settings.experiment_time_limit;
  
  % adapt the number of digits
  if i > 2 && correct(i-1) && correct(i-2) && ...
    settings.num_digits(i-1)==settings.num_digits(i-2)
  
    settings.num_digits(i) = min([settings.num_digits(i-1)+1 settings.max_digits]);
  elseif i > 2 && ~correct(i-1)
    settings.num_digits(i) = max([settings.num_digits(i-1)-1 1]);
  elseif i > 2
    settings.num_digits(i) = settings.num_digits(i-1);
  end
    
  % now get the actual numbers and make sure they have the right number of
  % digits
  [settings.q(i) a] = getDigits(settings.num_digits(i));
  settings.resp_len = settings.num_digits(i);
  
  % show numbers and get response
  drawAbacusArray(ws,settings,settings.q(i)); 
  WaitSecs(settings.viewing_interval);
  showMask(ws,mask);
  [resp(i) rt1(i) rt2(i)] = readInResponse(ws,mask,settings,1);
  
  % check if we're right
  if resp(i) == settings.q(i)
    correct(i) = 1; 
    drawText('CORRECT',ws,0,1,[0 200 0]);
  else
    correct(i) = 0;
    drawText('ERROR',ws,0,1,[200 0 0]);
  end;
  
  % save the data after every trial
  save(['data/' num2str(subnum) '-FC.mat'],'settings','resp','rt1','rt2');

  % now clear and wait
  Screen('Flip',ws.ptr);
  WaitSecs(settings.isi);
  i = i + 1;
end

%% clean up
clear screen
ListenChar(0); % enable write to matlab
ShowCursor
fprintf('*** total duration: %d ***\n',GetSecs - start_time);