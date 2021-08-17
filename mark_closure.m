function mark_closure(inputVideo, inputcsv, delay, start)
% e.g., mark_closure('Teddy_test_t.mp4', 'Teddy_test_t_aligned.csv', 0.5)

arguments
    inputVideo char 
    inputcsv char
    delay double
    start double = 1
end

% Load the video and textgrid information
ultrasoundvid=VideoReader(char(inputVideo));
textgrid=readtable(char(inputcsv),'Delimiter',',');

% Parameter setting
rect = [79.5, 267.5, 553, 200]; % for m mode image
sweep_rate = 4; % 4 seconds
delay_pixel = delay/sweep_rate*rect(3);

t = table;
for i=start:length(textgrid.Label)
    filename=char(textgrid{i,'Label'});
    currentTime = textgrid{i,'Time'};
    currentTime = currentTime + delay;
    I = GetMovieFrameMod(ultrasoundvid, currentTime);
    I = imresize(I,[534 NaN]);
    I = imcrop(I, rect);
    I = imcomplement(I);
    imshow(I, 'InitialMagnification', 1200);
    impixelinfo
    roi = drawline('Position', [50 50; 50+delay_pixel 50],'Color', 'r', 'Linewidth', 1.5, 'MarkerSize', 4);
    wait(roi)
    duration = abs(roi.Position(1)-roi.Position(2));
    if duration > rect(3)/2
        duration = rect(3) - duration;
    end
    duration = currentTime - duration*sweep_rate/rect(3);
    string = regexp(filename, '\.', 'split');
    t = [t;{string(1), duration}];
    if mod(i, 10) == 0
        choise = menu('Do you want to continue?', 'Yes', 'No');
        if choise == 2 | choise == 0
            fprintf('First %d tokens were marked.', i)
            % disp(sprintf("First %d tokens were marked.", i))
            break;
        end
    end
end
t.Properties.VariableNames = {'Token', 'ClosureTime'};
string = regexp(inputcsv, '\.', 'split');
writetable(t, char(strcat(string(1), '_clo_', num2str(start), '-', num2str(i), '.csv')),'Delimiter',',','WriteRowNames',true);
end