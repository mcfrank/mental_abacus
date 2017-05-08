% additionTest2
% mcf and db 10/14/08
% see creative commons license BY 3.0
% must be run with a subject code (scalar) and an interference condition (string)

function interference_addition(subnum,icond)

ListenChar(2); % disable write to matlab
addpath('../helper');
start_time = GetSecs;

if ~isnumeric(subnum)
  error('Subject code must be a number!  Try again using the syntax "additionTest(1)"\n')
elseif ~isempty(dir(['data/' num2str(subnum) '.mat'])) && subnum~=-1 
  ListenChar(0); % enable write to matlab
  error('datafile already exists!')
end

%% settings
  
settings.viewing_interval = 2; % in seconds, so .4 = 400ms
settings.isi = 1; % inter stimulus interval
settings.textsize = 70;

settings.before_trial_interval = .5;
settings.before_prompt_interval = 0;

% settings.num_trials = 30;
settings.trial_time_limit = 10; % no trial time limit here
settings.experiment_time_limit = 300;
settings.num_digits = 2;
settings.max_addends = 8;

ws = doScreen;

%% instructions
if subnum~=-1 % if we're not testing
  Screen('TextSize',ws.ptr,40);
  drawText('PRESS ANY KEY TO START EXPERIMENT.',ws,1);
end

%% basic loop for the experiment
Screen('TextSize',ws.ptr,settings.textsize);
Screen('TextFont',ws.ptr,'Courier');

settings.num_addends(1) = 1;
settings.num_addends(2) = 1;

start_time = GetSecs;

i = 1;
while GetSecs - start_time < settings.experiment_time_limit;
  
  % adapt the number of digits 
  if i > 2 && correct(i-1) && correct(i-2) && ...
    settings.num_addends(i-1)==settings.num_addends(i-2) && ...
    settings.num_addends(i-1) < settings.max_addends;
  
    settings.num_addends(i) = settings.num_addends(i-1)+1;
  elseif i > 2 && ~correct(i-1)
    settings.num_addends(i) = max([settings.num_addends(i-1)-1 1]);
  elseif i > 2
    settings.num_addends(i) = settings.num_addends(i-1);
  end
    
  % now get the actual numbers and make sure they have the right number of
  % digits
  settings.qs = getManyDigits(settings.num_addends(i),settings.num_digits);

  % show numbers and get response
  [resp(i) rt1(i) rt2(i)] = drawManyNumbers(ws,settings,settings.qs);
  quants{i} = settings.qs;
  
  % check if we're right
  if resp(i) == sum(settings.qs), 
    correct(i) = 1; 
    drawText('CORRECT',ws,0,1,[0 200 0]);
  elseif rt1(i) > settings.trial_time_limit - .1;
    correct(i) = 0;
    drawText('OUT OF TIME',ws,0,1,[200 0 0]);
  else
    correct(i) = 0;
    drawText('ERROR',ws,0,1,[200 0 0]);
  end;
  
  % save the data after every trial
  save(['data/' num2str(subnum) '-ADINT-' icond '.mat'],'settings','resp','rt1','rt2','quants');

  % now clear and wait
  Screen('Flip',ws.ptr);
  WaitSecs(settings.isi);
  i = i + 1;
end

%% clean up
clear screen
ListenChar(0); % enable write to matlab
ShowCursor
fprintf('*** total duration: %2.2f ***\n',round(GetSecs - start_time));

