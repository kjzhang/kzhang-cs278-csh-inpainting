function A_output = CSH_inpaint(A, B, mask, CSH_w, CSH_i, CSH_k)

A_org = A;
B_org = B;
M_org = mask;

sig = 0.25;
error_power = 4;

max_iterations = 50;
min_iterations = 25;
threshold = 0.01;

delta = CSH_w - 1;

[hB wB dB] = size(B);

starting_scale = -ceil(log2(min(hB, wB))) + 5;
scale = 2^starting_scale;

A = imresize(A, scale);

[ht wt dt] = size(A);
A = imresize(A_org, [ht wt]);
B = imresize(B_org, [ht wt]);
mask = imresize(M_org, [ht, wt]);

% B = imresize(B, scale);
% mask = imresize(mask, scale);

% M3 = repmat(mask, [1 1 3]) == 1;
% [wt ht dt] = size(A);
% Rnd = uint8(255 * rand(wt, ht, dt));
% A(M3) = Rnd(M3);

for current_scale = starting_scale:0    
    scale = 2^current_scale;

    [hB wB dB] = size(B);

    hMin = hB + 1;
    hMax = 0;
    wMin = wB + 1;
    wMax = 0;

    fprintf('Calculating bounding box...\n');

    for i = 1:hB,
        for j = 1:wB,
            if mask(i, j) == 1,
               if i < hMin,
                   hMin = i;
               end
               if i > hMax,
                   hMax = i;
               end
               if j < wMin,
                   wMin = j;
               end
               if j > wMax,
                   wMax = j;
               end
            end
        end
    end

    for current = 1:max_iterations,

        fprintf('  Iteration %2d/%2d\n', current, max_iterations);
        imshow(A)
        pause(0.01)

        M3 = (repmat(mask, [1 1 3]) == 1);

        CSH_ann = CSH_nn(A, B, CSH_w, CSH_i, CSH_k, 0, mask);

        A = im2double(A);

        R_sum = zeros(size(A));
        R_num = zeros([hB wB]);

        for i = hMin - delta : hMax,
            for j = wMin - delta : wMax,
                if i >= 1 && i + delta <= hB && j >= 1 && j + delta <= wB,

                    % Patch A
                    PAi = i : i + delta;
                    PAj = j : j + delta;
                    patchA = A(PAi, PAj, :);
                    
                    % Patch B
                    iB = CSH_ann(i, j, 2);
                    jB = CSH_ann(i, j, 1);
                    
                    PBi = iB : iB + delta;
                    PBj = jB : jB + delta;
                    patchB = A(PBi, PBj, :);

                    % patch voting
                    d = sum( (patchA(:) - patchB(:)).^ error_power);
                    
                    patchM = mask(PAi, PAj);
                    ratio = 1 - (sum(sum(patchM)) / (CSH_w * CSH_w));
                    ratio = 1 / 10 + 9 / 10 * ratio;
                    
                    progress = current / max_iterations;
                    
                    sim = ratio * exp( -d / (2 * sig ^ 2));

                    R_sum(PAi, PAj, :) = R_sum(PAi, PAj, :) + sim * patchB;
                    R_num(PAi, PAj) = R_num(PAi, PAj) + sim;
                
                end
            end
        end

        R_num = repmat(R_num, [1 1 3]);
        R_sum(R_num > 0) = R_sum(R_num > 0) ./ R_num(R_num > 0);
        
%         imshow(R_sum);
        
        R_sum(~M3) = A(~M3);
        

        
        A_prev = A;
        
%         A(M3) = R_sum(M3);
%         A = im2uint8(A);
        
        A = im2uint8(R_sum);
        
        if current > 1,
        
            A_prev_temp = im2double(A_prev);
            A_temp = im2double(A);
            
            diff_sum = sum( (A_prev_temp(:) - A_temp(:)).^2 );
            diff_num = sum( mask(:) > 0 );
            
            fprintf('%f %f\n', diff_sum, diff_num);
            
            diff = diff_sum / diff_num * 100;
            
            fprintf('        diff = %f\n', diff);
            
            if diff < threshold / (2^current_scale) && current > min_iterations,
                break;
            end
        end
        
    end
    
    if current_scale < 0,
        A_data = imresize(A_org, 2 * scale);
        [hB wB dB] = size(A_data);
        
        A_data = imresize(A_org, [hB wB]);
        A = imresize(A, [hB wB]);
        B = imresize(B_org, [hB wB]);
        
        mask = imresize(M_org, [hB wB]);
        mask(mask > 0) = 1;
        M3 = repmat(mask, [1 1 3]) == 1;
        
        A(~M3) = A_data(~M3);
    end
end

A_output = A;