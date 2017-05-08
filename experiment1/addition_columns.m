% additionTest
% mcf and db 10/10/08
% see creative commons license BY 3.0

function addition_columns

home
fprintf('Addition with variable place value.\n\n');
subnum = input('Subject name/number: ','s'); 

PsychJavaTrouble
ListenChar(2); % disable write to matlab
addpath('../helper');

%% settings
  
settings.viewing_interval = 2; % in seconds, so .4 = 400ms
settings.isi = 1; % inter stimulus interval
settings.textsize = 30;

settings.max_digits = 14;
settings.before_trial_interval = .5;
settings.before_prompt_interval = 0;

settings.trial_time_limit = 10;
settings.experiment_time_limit = 300;

ws = doScreen;

%% basic loop for the experiment
Screen('TextSize',ws.ptr,40);
Screen('TextFont',ws.ptr,'Courier');
drawText('PRESS ANY KEY TO START.',ws,1);
start_time = GetSecs;
settings.num_digits(1) = 2;

i = 1;
while GetSecs - start_time < settings.experiment_time_limit;

  % adapt the number of digits
  if i > 1 && correct(i-1) && settings.num_digits(i-1) < settings.max_digits;
    settings.num_digits(i) = settings.num_digits(i-1)+1;
  elseif i > 1 && ~correct(i-1)
    settings.num_digits(i) = max([settings.num_digits(i-1)-1 2]);
  elseif i > 1
    settings.num_digits(i) = settings.num_digits(i-1);
  end

  % now get the actual numbers and make sure they have the right number of
  % digits
  settings.qs{i} = getDigits3(settings.num_digits(i));

  % show numbers and get response
  [resp(i) rt1(i) rt2(i)] =  drawManyNumbers(ws,settings,settings.qs{i});

  % check if we're right
  if resp(i) == sum(settings.qs{i})
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
  save(['data/' subnum '-ADD-COLUMNS.mat'],'correct','settings','resp','rt1','rt2');

  % now clear and wait
  Screen('Flip',ws.ptr);
  WaitSecs(settings.isi);
  i = i + 1;
  
  if i > 7 && all(settings.num_digits(end-6:end) == settings.max_digits), break; end;
end

%% clean up
clear screen
ListenChar(0); % enable write to matlab
ShowCursor
fprintf('*** total duration: %2.2f ***\n',round(GetSecs - start_time));