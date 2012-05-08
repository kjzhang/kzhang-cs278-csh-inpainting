function A_output = CSH_level(level, A, B, mask, CSH_w, CSH_i, CSH_k)
[hB wB dB] = size(B);

if level > 0,   
    % resize A, B, and mask to 50%
    next_A = impyramid(A, 'reduce');
    next_B = impyramid(B, 'reduce');
    [next_hB next_wB next_dB] = size(next_B);
    next_mask = imresize(mask, [next_hB next_wB]);
    
    disp('Resizing images');
    disp(size(A));
    disp(size(next_A));
    disp(size(next_B));
    disp(size(next_mask));
    
    disp('Getting lower level');
    % CSH_fill the next lowest level
    A_temp = CSH_level(level - 1, next_A, next_B, next_mask, CSH_w, CSH_i, CSH_k);

    % rescale and fill in current level
    A_scale = impyramid(A_temp, 'expand');
    
    disp('processing lower level');
    disp(size(A_temp));
    disp(size(A_scale));
    
    for i = 1:hB,
        for j = 1:wB,
            if mask(i, j) == 1,
                A(i, j, :) = A_scale(i, j, :);
            end
        end
    end
end

A_output = CSH_fill(A, B, mask, CSH_w, CSH_i, CSH_k);


function A_output = CSH_fill(A, B, mask, CSH_w, CSH_i, CSH_k)

% width = CSH_w;
% iterations = CSH_i;
% k = CSH_k;

disp('Beginning CSH Fill');
disp(size(A));
disp(size(B));
disp(size(mask));

[hB wB dB] = size(B);
d = CSH_w - 1;

xmin = 1048576;
xmax = -1;
ymin = 1048576;
ymax = -1;

for i = 1:hB,
    for j = 1:wB,
        if mask(i, j),
            if xmin > j,
                xmin = j;
            end
            if xmax < j,
                xmax = j;
            end
            if ymin > i,
                ymin = i;
            end
            if ymax < i,
                ymax = i;
            end
        end
    end
end

disp('xmin:');
disp(xmin);
disp('xmax:');
disp(xmax);
disp('ymin:');
disp(ymin);
disp('ymax:');
disp(ymax);
% iterative fill with CSH

for nub = 1:1,
    % CSH Patch Match
    
    disp(class(A));
    disp(class(B));
    disp(class(mask));
    disp(size(A));
    disp(size(B));
    disp(size(mask));
    
    A_next = A;
    
    CSH_ann = CSH_nn(A, B, CSH_w, CSH_i, CSH_k, 0, mask);    
    current_mask = mask;
    s = sum(sum(current_mask));
    while s > 64,
        current_border = getborder(current_mask, 'inside');
        next_mask = logical(current_mask - current_border);
        for row = ymin:ymax,
            for col = xmin:xmax,
                if current_border(row, col) == 1,           
                    n = 0;          
                    s1 = double(0);
                    s2 = double(0);
                    s3 = double(0);

                    for i = (row - d):row,
                        for j = (col - d):col,
                            y = CSH_ann(i, j, 2);
                            x = CSH_ann(i, j, 1);

                            B_row = y + (row - i);
                            B_col = x + (col - j);

                            if B_row > 0 && B_row < (hB + 1) && B_col > 0 && B_col < (wB + 1),
                                % original
                                p1 = B(B_row, B_col, 1);
                                p2 = B(B_row, B_col, 2);
                                p3 = B(B_row, B_col, 3);
                                s1 = s1 + double(p1);
                                s2 = s2 + double(p2);
                                s3 = s3 + double(p3);
                                n = n + 1;
                            end
                        end
                    end

                    n = double(n);
                    s1 = s1 / n;
                    s2 = s2 / n;
                    s3 = s3 / n;
                    A_next(row, col, 1) = round(s1);
                    A_next(row, col, 2) = round(s2);
                    A_next(row, col, 3) = round(s3);
                end
            end
        end
        current_mask = next_mask;
        s = sum(sum(current_mask));
    end

    for row = ymin:ymax,
        for col = xmin:xmax,
            if current_mask(row, col) == 1,           
                n = 0;          
                s1 = double(0);
                s2 = double(0);
                s3 = double(0);

                for i = (row - d):row,
                    for j = (col - d):col,
                        y = CSH_ann(i, j, 2);
                        x = CSH_ann(i, j, 1);

                        B_row = y + (row - i);
                        B_col = x + (col - j);

                        if B_row > 0 && B_row < (hB + 1) && B_col > 0 && B_col < (wB + 1),
                            % original
                            p1 = B(B_row, B_col, 1);
                            p2 = B(B_row, B_col, 2);
                            p3 = B(B_row, B_col, 3);
                            s1 = s1 + double(p1);
                            s2 = s2 + double(p2);
                            s3 = s3 + double(p3);
                            n = n + 1;
                        end
                    end
                end

                n = double(n);
                s1 = s1 / n;
                s2 = s2 / n;
                s3 = s3 / n;
                A_next(row, col, 1) = round(s1);
                A_next(row, col, 2) = round(s2);
                A_next(row, col, 3) = round(s3);
            end
        end
    end

    A = A_next;
    disp(nub);
end

A_output = A;