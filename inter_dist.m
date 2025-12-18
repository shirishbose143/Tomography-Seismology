function [ len ] = inter_dist( X1,Y1,X2,Y2,gridx,gridy )
%ray_path Function to generate length of ray traverse in each cell of grid

n1 = length(gridx)-1;
n2 = length(gridy)-1;
len = zeros(n2,n1);   %initialized as null matrix
p=1;



if X1>X2             %function works for ascending longitude values
    temp = X2;
    X2 = X1;
    X1 = temp;
    temp = Y2;
    Y2 = Y1;
    Y1 = temp;
end

%determine points of intersection
int1 = Y1 + (gridx-X1)*(Y2-Y1)/(X2-X1);   
int2 = X1 + (gridy-Y1)*(X2-X1)/(Y2-Y1);   
intp = [X1 Y1
gridx' int1'
int2' gridy'
X2 Y2];

%intp is an array of points on the line containing all the points of
%intersection and the event and station coordinates

intp = sortrows(intp,1);         %sorted in ascending longitude order


% Distance from one point to the next in intp evaluated, and the cell to
% which it belongs to is determined by finding the mid point of the two
% points between which the distance was calculated and then finding which
% grid cell it lies in.

while X1 ~= X2
    if intp(p,1) <= X1
        p=p+1;
        continue
    else
      %  dist2 = ((intp(p,1)-X1)*96)^2 + ((intp(p,2)-Y1)*111)^2;
        dist2 = ((intp(p,1)-X1))^2 + ((intp(p,2)-Y1))^2;
        dist = sqrt(dist2);
        intp(p,1);
        intp(p,2);
        XY = [(intp(p,1)+X1)/2 (intp(p,2)+Y1)/2];
        for j = 1:n1
            if gridx(j+1)>XY(1) && gridx(j)<XY(1)
                for k = 1:n2
                    if gridy(k+1)>XY(2) && gridy(k)<XY(2)
                        len(k,j)=dist;
                    end
                end
            end
        end
        X1 = intp(p,1);
        Y1 = intp(p,2);
        p = p+1;
    end
end


end

