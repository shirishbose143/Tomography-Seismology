function [ G ] = inter_dist_mat( n2,n1,latmin,latmax,longmin,longmax,file )
%RAY_PATH_MAT Generates data kernel
%   Creates a data kernel for the problem based on the grid size selected
    
    load(file); 
    dt=total;
    x = [dt(:,1),dt(:,3)];
    y = [dt(:,2),dt(:,4)];

    % Defining grid lines
    x1 = linspace(longmin,longmax,n1+1);
    y1 = linspace(latmin,latmax,n2+1);

    % Call ray_path function to determine each row and then joining it to G
    for j = 1:length(x)
        a = inter_dist(x(j,1),y(j,1),x(j,2),y(j,2),x1,y1);
        G(j,:) = reshape(a,n1*n2,1);
    end
    
end

