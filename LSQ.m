% Q-tomography estimation by using LSQR method
close all;
clear;
clc;
load total.dat     % output Results from TSM/ loading file with station pair (long and lat for 1st & 2nd station) and corresponding Q values
%V=DATAQ;
dt=total;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% G matrix calculation
yy=26.5;
yyy=28.25;
xx=88.5;
xxx=92.25;
 % G matrix calculation
    n1 = 4 * (xxx - xx);
    n2 = 4 * (yyy - yy);
    [G] = inter_dist_mat(n2, n1, yy, yyy, xx, xxx, 'total.dat');

%  dlmwrite('Lg_0.25.dat',g1,'precision','%3.4f')
% % dlmwrite('Lg.dat',g1);
%-----------------------------------------------
x_1=dt(:,1);  %longitude of station 1
y_1=dt(:,2);  % latitude of station 1
x_2=dt(:,3);  %longitude of station 2
y_2=dt(:,4);  % latitude of station 2
QM=dt(:,5);  % Q values 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Calculate the span of lat and long of the study area
    x = xx:0.25:xxx;
    y = yy:0.25:yyy;
% x=83:0.5:90;  % Dividing the whole area into small grid with grid size 0.5 degree 
% y=26:0.5:30;
% x = linspace(xx,xxx,15);
% y = linspace(yy,yyy,15);
%Give the size of the grids
x_x=max(size(x));
y_y=max(size(y));

 
%  load AMAT.DAT  % loading file with length segment with their corresponding grid
%  G=AMAT;
%total no. of stations or events or total no. of data points
n=length(x_1);

%for calculation of (delta)n/Qn values, (delta)n is the distance between
% 1st and 2nd station.
for i=1:n

        D(i)=sqrt((x_1(i)-x_2(i))^2+(y_1(i)-y_2(i))^2);
        b(i)=D(i)/QM(i);        

 end

d=b'; % matrix containing (delta)n/Qn values (i.e. data (d) matrix)

G;    % matrix containing length segment in their respective grid (i.e. G matrix)

% Inversion of Q by LSQR method-------------------------------
[n, m]=size(G);
 ss=m; %min(size(G));
 I=eye(ss,ss);    % Identity Matrix
 lamda=[0.05,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1,2,3];  % damping parameter
 lamda=1.6;
% lamda=linspace(0,2,100);
% lamd=(lamda)*(lamda); % square of lamda
%-----------------------------------

A=pinv(G);  % pseudo-inverse matrix of G (pre-conditioner matrix)
%----------------------------------------------------
% From d=Gm 
%Q=(inv(A*A'+(lamd*I)))*A*d;
for ij=1:length(lamda)
    lamd=(lamda(ij))*(lamda(ij));
Q=(inv(G'*A'*A*G+(lamd*I)))*G'*A'*A*d; % Calculation of Q by LSQR Method Gallegous 2014
phid=d-G*Q;
Dvar=var(G*Q);
dmisfit=norm(phid);
%phim=Mobs-Q;
Mvar=var(Q);
deltaM=norm(Q);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FINAL(ij,1)=deltaM;
FINAL(ij,2)=dmisfit;
FINAL(ij,3)=lamda(ij);
end
%----------------------------------------------------
g1=length(Q);

 for h1=1:g1
    
                  if (Q(h1,:))==0                   % constraining the range of the quality factor if in case any quality factor becomes out lier due to the inversion truncation
                       Q(h1,:)=10000;
                  end
                  if Q(h1,:)<0
                      Q(h1,:)=10000;
                  end
                  if Q(h1,:)<0.002
                      Q(h1,:)=10000;
                  end
         
    
 end

% Estimation of Q values---------------------------------

m=length(Q);
f=1; 
for g=1:x_x-1
    for h=1:y_y-1
       
        if f<m+1;
        Qmn(h,g)=1/Q(f);
         f=f+1;
%        if Qmn(h,g)>500
%            Qmn(h,g)=QM(n);
%        end
        end
    end    
end
%        [nn mm]=size(Qmn);
%        for aa=1:nn;
%            for bb=1:mm
%                if Qmn(aa,bb)>500
%                    Qmn(aa,bb)=max(QM);
%            end
%        end
%        end
 Qmn;  % inverted Q values by LSQR inversion method 
csvwrite('Qmn1.csv',Qmn);
%---------------------------------------------------------
 % Modify plotting to work for any latitude and longitude range
    x11 = linspace(xx + 0.25, xxx, x_x - 1);
    y11 = linspace(yy + 0.25, yyy, y_y - 1);

% x11 = linspace(xx+0.5,xxx,14);
% y11 = linspace(yy+0.5,yyy,14);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% obtain txt data for the GMT plot
[s1, s2]=size(Qmn);
fid = fopen('LgQgmt-0.5.txt','w');
for iii=1:s1
    for jjj=1:s2
        
        xx11(:,1)=x11(jjj);
        yy11(:,1)=y11(iii);
      
        fprintf(fid, '%g %g %g \n', x11(jjj), y11(iii), Qmn(iii, jjj));
     
       
    end
end
fclose(fid);
%end
 %csvwrite('SnQgmt.csv',SS);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %plotting of the final Q values after inversion
 figure(1)
 Z=linspace(min(x11),max(x11), 50);
 Z1=linspace(min(y11),max(y11),50);
 [Z2,Z3]=meshgrid(Z,Z1);                
GFFF=griddata(x11,y11,Qmn,Z2,Z3,'cubic');  %plotting the quality factor in the domain of definition 
imagesc(x11,y11,GFFF);

xlabel('Longitude');
ylabel('Latitude');
P=GFFF(:);
% Define the grid spacing
dx = x11(2) - x11(1);
dy = y11(2) - y11(1);

% Create a figure for the contour plot
figure(2);

% Define the contour levels you want to display
contourLevels = 0:0.1:max(GFFF(:)); % Adjust the range and step size as needed

% Generate the contour plot
contourf(Z2, Z3, GFFF, contourLevels, 'LineColor', 'none');

% Add a colorbar for reference
colorbar;

% Set labels and title
xlabel('Longitude');
ylabel('Latitude');
title('Contour Plot of Quality Factor');


% End of the program
% end of program------------------------------
data=FINAL;
 for c1=1:length(data)-1
      for c2=1:c1-1
     rho(:,c1)=log(data(c1,2));
     eta(:,c1)=log(data(c1,1));
     der_eta(:,c1)=(log(data(c1+1,1))-log(data(c1,1)))/0.01;
     der_rho(:,c1)=(log(data(c1+1,2))-log(data(c1,2)))/0.01;
    
     der2_eta(1,c2)=der_eta(1,c2+1)-der_eta(1,c2)/0.01^2;
     der2_rho(:,c2)=der_rho(1,c2+1)-der_rho(1,c2)/0.01^2;
      curvature(1,c2)=((der_rho(1,c2)*der2_eta(1,c2))-(der2_rho(1,c2)*der_eta(1,c2)))/((der_rho(1,c2))^2+(der_eta(1,c2))^2)^(3/2);
     end
 end
figure(2)
 for k=1:length(data)
         plot(data(k,2), data(k,1),'*')
         hold on
 end
 hold off
 title('L-Curve')
 xlabel('\Phi_d (data misfit)')
 ylabel('\Phi_m (model misfit)')
 print -djpeg lcurve.jpg