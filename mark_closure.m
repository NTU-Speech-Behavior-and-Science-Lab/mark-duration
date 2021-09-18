function mark_closure(inputVideo, inputcsv, delay, start, release)
% e.g., mark_closure('Teddy_test_t.mp4', 'Teddy_test_t_aligned.csv', 0.5)

arguments
    inputVideo char 
    inputcsv char
    delay double
    start double = 1
    release logical = false
end

% Load the video and textgrid information
ultrasoundvid=VideoReader(char(inputVideo));
textgrid=readtable(char(inputcsv),'Delimiter',',');
filename = regexp(inputcsv, '\.', 'split');

% Parameter setting
rect = [79.5, 267.5, 553, 200]; % for m mode image
sweep_rate = 4; % 4 seconds
delay_pixel = delay/sweep_rate*rect(3);

if release
    t = cell2table(cell(0,3),'VariableNames', {'Token', 'ClosureTime', 'ReleaseTime'});
else
    t = cell2table(cell(0,3),'VariableNames', {'Token', 'ClosureTime', 'DurationOfLine'});
end

%t = table;
%t.Properties.VariableNames = {'Token', 'ClosureTime', 'ClosureDuration'};
for i=start:length(textgrid.Label)
    tokenname = char(textgrid{i,'Label'});
    currentTime = textgrid{i,'Time'};
    currentTime = currentTime + delay;
    I = GetMovieFrameMod(ultrasoundvid, currentTime);
    I = imresize(I,[534 NaN]);
    I = imcrop(I, rect);
    I = imcomplement(I);
    %figure('Name', tokenname,'NumberTitle','off'), 
    imshow(I, 'InitialMagnification', 1200);
    title(tokenname);
    impixelinfo
    roi = drawline('Position', [50 50; 50+delay_pixel 50],'Color', 'r', 'Linewidth', 1.5, 'MarkerSize', 4);
    wait(roi)
    roiLine = abs(roi.Position(1)-roi.Position(2));
    if roiLine > rect(3)/2
        roiLine = rect(3) - roiLine;
    end
    closure = currentTime - roiLine*sweep_rate/rect(3);
    
    if release
        roi2 = drawline('Position', [roi.Position(1) roi.Position(3)+10; roi.Position(2) roi.Position(4)+10],'Color', 'b', 'Linewidth', 1, 'MarkerSize', 4);
        wait(roi2)
        roi2Line = abs(roi2.Position(1)-roi2.Position(2));
        if roi2Line > rect(3)/2
            roi2Line = rect(3) - roi2Line;
        end
        release = currentTime - roi2Line*sweep_rate/rect(3);
        t = [t;{tokenname, closure, release}];
    else
        t = [t;{tokenname, closure, roiLine*sweep_rate/rect(3)}];
    end
    %string = regexp(tokenname, '\.', 'split'); % uncomment this line if you used Sam's script
    %tg_to_csv.R
    %t = [t;{string(1), closure, duration}];
    % t = [t;{tokenname, closure, duration}];
    %close(tokenname)
    if mod(i, 10) == 0
        choise = menu('Do you want to continue?', 'Yes', 'No');
        if choise == 2 | choise == 0
            fprintf('Tokens from %d to %d were annotated.\n', start, i)
            % disp(sprintf("First %d tokens were marked.", i))
            break;
        end
        writetable(t, char(strcat(filename(1), '_clo_', num2str(start), '.csv')),'Delimiter',',','WriteRowNames',true);
    end
end
%t.Properties.VariableNames = {'Token', 'ClosureTime', 'ClosureDuration'};
close()
writetable(t, char(strcat(filename(1), '_clo_', num2str(start), '-', num2str(i), '.csv')),'Delimiter',',','WriteRowNames',true);
end