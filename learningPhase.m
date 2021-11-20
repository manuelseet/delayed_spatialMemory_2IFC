 
% Clear the workspace and the screen
sca;
close all;
clearvars;

Screen('Preference', 'SkipSyncTests', 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% PARTICIPANT DETAILS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prompt = {'Participant ID:','Age:'};
title = 'Participant Information';
dims = [1 35];
answer = inputdlg(prompt,title,dims);
particID = answer{1};
particAge = answer{2};
today = datestr(now,'ddmmmyy_HHMM');

particID = answer{1};
particAge = answer{2};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
%%PSYCHTOOLBOX, GENERAL SETTINGS and PARAMTERS%
% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
% Get the screen numbers
screens = Screen('Screens');
% Draw to the external screen if avaliable
screenNumber = max(screens);
% Define black, white and grey


white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;
inc = white - grey;
%}
% black and white colors
black = 0;
white = 255;
grey = (white/2);

% find screen size [x y]
whichScreen = 0;
monitor = Screen('Rect',0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% PREPARE STIM AND RESPONSE PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Response Parameters%
allowedSet = 'bnQ'; % b for Yes, n for No, Q for quit
no_key = 'n';
yes_key = 'b';

%Stimulus parameters
mem_img_dur = 3;
fixation = ['+'];
fixation_dur = 2;
ISI = 3;
qn_dur = 6; %question duration


%define tone
Fs = 10000;                                     % Sampling Frequency
dur = 0.2;                                      %duration
t  = linspace(0, dur-1/Fs, dur*Fs);             % One Second Time Vector
w = 2*pi*1000;                                  % Radian Value To Create 1kHz Tone
s = sin(w*t);                                   % Create Tone

%%%%%%%%%%%%%%%%%%% Reading Stimuli List from Excel %%%%%%%%%%%%%%%%%%%%%%%
DocName = ['Test1_list_random.xlsx'];
%Setting up data file reading parameters
worksheet_no = 1;
first_column = 'B';
last_column = 'J';
start_row = '2';
end_row = '20';
%number of practice trials
prac_trial_no = 3;
%number of test trials
start_test_no = (prac_trial_no + 1);
num_test = (str2num(end_row) - str2num(start_row) + 1);
%define the stimuli list range for excel sheet reading
stim_range = [first_column,start_row,':',last_column,end_row];
%read stimuli excel file
[~,text]  = xlsread(DocName,stim_range);
stim_list = text;
%shuffle the stimuli rows
%shufflerow(stim_list)

%%%%%%%%%%%%%%PREPARE DATA SAVING%%%%%%%%%%%%%%%%%%%%%%%%%%%

filename = [answer{1},'_','TestA','_',today,'.xlsx'];
excel_data = {'Trial No.','SubjectID','Age','Test Time','Mem_image1','Mem_image2','Mem_name1','Mem_name2','Test_image','Question','testID','Type','Resp_key','Accuracy','RT'};

%save the file first
%xlswrite(filename,excel_data,1);

%save
filenameMAT = [particID,'_','TestA','_',today,'.mat'];
eval(['save ' filenameMAT]);


%#######################################################################%
%####################% START STIM PRESENTATION ##########################%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try

%##################### OPEN SCREEN & GET SCREEN INFO%%############%
window = Screen('OpenWindow',whichScreen,white);
%Hide the cursor
HideCursor();
%{
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);
% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
% Query the frame duration
ifi = Screen('GetFlipInterval', window);
% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);
% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
%Hide the cursor
HideCursor()
%}


%[0] Start with blank screen
Screen('FillRect', window, white);
Screen('Flip', window);
WaitSecs(0.2);

%[1] Show Welcome Screen
Screen('TextSize', window, 40);
DrawFormattedText(window, 'Welcome to Test A. \n\nPress the Spacebar to continue.', 'center','center', [0 0 0]);
Screen('Flip', window);
WaitSecs(0.5);
% after holding fixation, hit space bar to start a block
FlushEvents('keyDown');	% discard previous key presses in the event queue.
character = GetChar;
while (character ~= ' ')
    character = GetChar;
end

%[2] Show Instructions Screen
Screen('TextSize', window, 40);
DrawFormattedText(window, 'In this test, you will see 2 images in sequence, \nthen you will be asked to identify one of them\nas accurately and quickly as you can.\n\nPress "b" for Yes and "n" for No. \n\nIf you have questions, please ask the experiment now.\nOtherwise, when you are ready, press the Spacebar to start your practice.', 'center','center', [0 0 0]);
Screen('Flip', window);
WaitSecs(0.5);
% after holding fixation, hit space bar to start a block
FlushEvents('keyDown');	% discard previous key presses in the event queue.
character = GetChar;
while (character ~= ' ')
    character = GetChar;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%Practice TRIALS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%[2] Show Instructions Screen
Screen('TextSize', window, 40);
DrawFormattedText(window, 'You will now have some practice trials. \n\nWhen you are ready, press the Spacebar to start.', 'center','center', [0 0 0]);
Screen('Flip', window);
WaitSecs(0.5);
% after holding fixation, hit space bar to start a block
FlushEvents('keyDown');	% discard previous key presses in the event queue.
character = GetChar;
while (character ~= ' ')
    character = GetChar;
end

%[3] Blank Screen before the trial starts
Screen('FillRect', window, white);
Screen('Flip', window);
WaitSecs(0.2);

for i = [1:prac_trial_no]
    
    %%%%%%%%%%%Prepare Stimuli and text for the Trial%%%%%%%%%%%%%%%%
    %binary column decide
    A = randi([1 2]);
    B = 3-A;
    %read stimuli
    memory_1 = imread([stim_list{i,A},'.jpg']);
    memory_2 = imread([stim_list{i,B},'.jpg']);
    mem1_name = stim_list{i,(A+2)};
    mem2_name = stim_list{i,(B+2)};
    test_0 = imread([stim_list{i,5},'.jpg']);
    qn = ['Is this ',(stim_list{i,6}),'?'];    %prepare question
    test_id = stim_list{i,7};
    img_type = stim_list{i,8};
    correct = stim_list{i,9};
    

    % Make the images into a texture
    mem1 = Screen('MakeTexture', window, memory_1);
    mem2 = Screen('MakeTexture', window, memory_2);
    test = Screen('MakeTexture', window, test_0);
    %%%%%%%%%%%End Preparation for the Trial%%%%%%%%%%%%%%%%
    
    if i > 1
        %Ready to proceed to trial; wait for self-paced keypress
        Screen('TextSize', window, 60);
        DrawFormattedText(window, 'Press the spacebar to continue', 'center','center', [0.5 0 0]);
        Screen('Flip', window);

        FlushEvents('keyDown');	% discard previous key presses in the event queue.
        character = GetChar;
        while (character ~= ' ')
            character = GetChar;
        end
    elseif i == 1
        WaitSecs(0.01);
    end
    
    %#############################################################
    %%%%%%%%%%%%%START TRIAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %#############################################################
        
    % Now blank screen for 2 seconds
    Screen('FillRect', window, white);
    Screen('Flip', window);
    WaitSecs(2);
    
    % draw pre-trial fixation cross
    Screen('TextSize', window, 70);
    DrawFormattedText(window, '+', 'center','center', [0 0 0]);
    Screen('Flip', window);
    WaitSecs(fixation_dur);
    
    % Draw mem1 name 
    Screen('TextSize', window, 70);
    DrawFormattedText(window, mem1_name, 'center','center', [0 0 0]);
    Screen('Flip', window);
    WaitSecs(mem_img_dur);
    
    % Draw stimuli mem1 
    Screen('DrawTexture', window, mem1, [], [], 0);
    Screen('Flip', window);
    WaitSecs(mem_img_dur);

    % Now inter-mem_img ISI with fixation cross
    Screen('TextSize', window, 70);
    DrawFormattedText(window, '+', 'center','center', [0 0 0]);
    Screen('Flip', window);
    WaitSecs(ISI);

    % Draw mem2 name 
    Screen('TextSize', window, 70);
    DrawFormattedText(window, mem2_name, 'center','center', [0 0 0]);
    Screen('Flip', window);
    WaitSecs(mem_img_dur);
    
    %Draw stimuli mem2
    Screen('DrawTexture', window, mem2, [], [], 0);
    Screen('Flip', window);
    WaitSecs(mem_img_dur);
       
    % Now pre-test fixation cross
    Screen('TextSize', window, 70);
    DrawFormattedText(window, '+', 'center','center', [1 0 0]);
    Screen('Flip', window);
    WaitSecs(fixation_dur);
    
    % Draw question 
    Screen('TextSize', window, 70);
    DrawFormattedText(window, qn, 'center','center', [0 0 0]);
    Screen('Flip', window);
    WaitSecs(qn_dur);
    
    %Draw  test image & wait till response; record RT
    Screen('DrawTexture', window, test, [], [], 0);
    Screen('Flip', window);
    sound(s, Fs); % Produce alert Tone
    
    Rtime0 = GetSecs;

    FlushEvents('keyDown'); % flush out any previous key presses
    while (1)
        character = GetChar;
        Rtime1 = GetSecs;
        if any(character == allowedSet)
            break;
        end
    end
    
    if character == allowedSet(3) % quit
        bFlag = 1;
        break;
    end
    
    % Now blank screen to mark end of trial
    Screen('FillRect', window, white);
    Screen('Flip', window);
    %###############################################################    
    resp_key = character; %define response key
    %{
    if resp_key == no_key %pressed no
        resp = 'no'
    elseif resp_key == yes_key
        resp = 'yes'
    end
    
    if resp == correct
        accuracy = 'correct'
    elseif resp ~= correct
        accuracy = 'incorrect' 
    end
    %}
    rt = Rtime1 - Rtime0; %define reaction time
    
    %APPEND EXCEL DATA in cell array using {}, write it into excelfile
    %###############################################################
    
    clear Rtime1 Rtime0  
    WaitSecs(0.5);    
    
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%TEST TRIALS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%[2] Show Instructions Screen
Screen('TextSize', window, 40);
DrawFormattedText(window, 'That is the end of your practice. \n\nWhen you are ready, press the Spacebar to begin the actual test.', 'center','center', [0 0 0]);
Screen('Flip', window);
WaitSecs(0.5);
% after holding fixation, hit space bar to start a block
FlushEvents('keyDown');	% discard previous key presses in the event queue.
character = GetChar;
while (character ~= ' ')
    character = GetChar;
end

%[3] Blank Screen before the trial starts
Screen('FillRect', window, white);
Screen('Flip', window);
WaitSecs(0.2);



for i = [4:num_test]
    
    %%%%%%%%%%%Prepare Stimuli and text for the Trial%%%%%%%%%%%%%%%%
    %binary column decide
    A = randi([1 2]);
    B = 3-A;
    %read stimuli
    memory_1 = imread([stim_list{i,A},'.jpg']);
    memory_2 = imread([stim_list{i,B},'.jpg']);
    mem1_name = stim_list{i,(A+2)};
    mem2_name = stim_list{i,(B+2)};
    test_0 = imread([stim_list{i,5},'.jpg']);
    qn = ['Is this ',(stim_list{i,6}),'?'];    %prepare question
    test_id = stim_list{i,7};
    img_type = stim_list{i,8};
    correct = stim_list{i,9};
    

    % Make the images into a texture
    mem1 = Screen('MakeTexture', window, memory_1);
    mem2 = Screen('MakeTexture', window, memory_2);
    test = Screen('MakeTexture', window, test_0);
    %%%%%%%%%%%End Preparation for the Trial%%%%%%%%%%%%%%%%
    
    if i > 1
        %Ready to proceed to trial; wait for self-paced keypress
        Screen('TextSize', window, 60);
        DrawFormattedText(window, 'Press the spacebar to continue', 'center','center', [0.5 0 0]);
        Screen('Flip', window);

        FlushEvents('keyDown');	% discard previous key presses in the event queue.
        character = GetChar;
        while (character ~= ' ')
            character = GetChar;
        end
    elseif i == 1
        WaitSecs(0.01);
    end
    
    %#############################################################
    %%%%%%%%%%%%%START TRIAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %#############################################################
        
    % Now blank screen for 2 seconds
    Screen('FillRect', window, white);
    Screen('Flip', window);
    WaitSecs(2);
    
    % draw pre-trial fixation cross
    Screen('TextSize', window, 70);
    DrawFormattedText(window, '+', 'center','center', [0 0 0]);
    Screen('Flip', window);
    WaitSecs(fixation_dur);
    
    % Draw mem1 name 
    Screen('TextSize', window, 70);
    DrawFormattedText(window, mem1_name, 'center','center', [0 0 0]);
    Screen('Flip', window);
    WaitSecs(mem_img_dur);
    
    % Draw stimuli mem1 
    Screen('DrawTexture', window, mem1, [], [], 0);
    Screen('Flip', window);
    WaitSecs(mem_img_dur);

    % Now inter-mem_img ISI with fixation cross
    Screen('TextSize', window, 70);
    DrawFormattedText(window, '+', 'center','center', [0 0 0]);
    Screen('Flip', window);
    WaitSecs(ISI);

    % Draw mem2 name 
    Screen('TextSize', window, 70);
    DrawFormattedText(window, mem2_name, 'center','center', [0 0 0]);
    Screen('Flip', window);
    WaitSecs(mem_img_dur);
    
    %Draw stimuli mem2
    Screen('DrawTexture', window, mem2, [], [], 0);
    Screen('Flip', window);
    WaitSecs(mem_img_dur);
       
    % Now pre-test fixation cross
    Screen('TextSize', window, 70);
    DrawFormattedText(window, '+', 'center','center', [1 0 0]);
    Screen('Flip', window);
    WaitSecs(fixation_dur);
    
    % Draw question 
    Screen('TextSize', window, 70);
    DrawFormattedText(window, qn, 'center','center', [0 0 0]);
    Screen('Flip', window);
    WaitSecs(qn_dur);
    
    %Draw  test image & wait till response; record RT
    Screen('DrawTexture', window, test, [], [], 0);
    Screen('Flip', window);
    sound(s, Fs); % Produce alert Tone
    
    Rtime0 = GetSecs;

    FlushEvents('keyDown'); % flush out any previous key presses
    while (1)
        character = GetChar;
        Rtime1 = GetSecs;
        if any(character == allowedSet)
            break;
        end
    end
    
    if character == allowedSet(3) % quit
        bFlag = 1;
        break;
    end
    
    % Now blank screen to mark end of trial
    Screen('FillRect', window, white);
    Screen('Flip', window);
    %###############################################################    
    resp_key = character; %define response key
    %{
    if resp_key == no_key %pressed no
        resp = 'no'
    elseif resp_key == yes_key
        resp = 'yes'
    end
    
    if resp == correct
        accuracy = 'correct'
    elseif resp ~= correct
        accuracy = 'incorrect' 
    end
    %}
    rt = Rtime1 - Rtime0; %define reaction time
    
    
    %APPEND EXCEL DATA in cell array using {}, write it into excelfile
    results = {i,particID,particAge,today,stim_list{i,A},stim_list{i,B},mem1_name,mem2_name,stim_list{i,5},qn,test_id,img_type,resp_key,'accuracy',rt};
    excel_data = [excel_data; results]; %append new results in new row,in list function i.e. []
    
    %xlswrite(filename,excel_data);
    %save
    eval(['save ' filenameMAT]);

    
    %###############################################################
    
    clear Rtime1 Rtime0  
    WaitSecs(0.5);    
    
end 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Clear the screen%%%%%%%%%%%%%%%%%%%%%%%%%

sca;

%#####################################################################

%Save to EXCEL file
%xlswrite(filename,excel_data)
%save
%save to matfile
eval(['save ' filenameMAT]);

end