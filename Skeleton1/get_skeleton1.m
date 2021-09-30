%% trace extraction
%
% @author Haitian Zheng, Xiaoyun Yuan
% @date May, 31, 2014
%
% @param file 
%           string : file name of the kernel image
% @param textfile
%           string : the *.txt file to write the trace nodes
% @param tracefile
%           tracefile : the image file to save the one pixel trace file
% An implement of Gray-Scale Skeletonization of Small Vessels in Magnetic Resonance Angiography
% IEEE TRANSACTIONS ON MEDICAL IMAGING, VOL. 19, NO. 6, JUNE 2000
%
function  [Path, pixels]  = get_skeleton1(file, textfile, tracefile)

% Initiate
gaussian_kernel_size = 3;
gaussian_kernel_std = 0.1;
energy_percent = 0.98;
% energy_percent = 0.98;

I = file;

[sx sy m]=size(I);
% display([sx,sy]);
% disp( ['Kernel size: ' sx '   ' sy]);
if(m==3)
    J=rgb2gray(I);
else
    J=I;
end
J=double(J)/255;

 % Gaussian filter on kernel;
 kernel=J;
 wmask=fspecial('gaussian', gaussian_kernel_size, gaussian_kernel_std);
 J=conv2(kernel,wmask,'same');
 J=J/max(max(J));
energy=sum(sum(J));

maxx = max(J(:));
[mx, my] = find(J == maxx);
mx = mx(1);
my = my(1);

R=zeros(sx,sy);
B=zeros(sx,sy);
length1=zeros(sx,sy);
length2=zeros(sx,sy);
connect=zeros(sx,sy,8);
CCC=0;
neigh8X=[1,-1,0,0 ,1, 1,-1,-1];
neigh8Y=[0, 0,1,-1,1,-1, 1,-1];
InverseMap=[2,1,4,3,8,7,6,5];

neigh4X=[1,-1,0,0];
neigh4Y=[0,0,1,-1];

R(mx,my)=1;

     
  energy_m=double(J(mx,my));
  boundry=ones(sx,sy)-bwmorph(ones(sx,sy),'erode',1);  % 四周为1，内部全0
  
while energy_m/energy < energy_percent
    B=R-bwmorph(R,'erode',1)-(R.*boundry);
   
    [sPx,sPy,v]=find(B);
    maxx=-1;
    for j=1:size(sPx,1)
       if (J( sPx(j),sPy(j) )>maxx)
           maxx=J( sPx(j),sPy(j) );
           maxPx=sPx(j);
           maxPy=sPy(j);
       end
    end
    
    maxx=-1;
     for j=1:8
         xx=maxPx+neigh8X(1,j);
         yy=maxPy+neigh8Y(1,j);
         if(1<=xx && sx>=xx && 1<=yy && sy>= yy )
             if( R(xx,yy)~=1)
             	energy_m=energy_m+double(J(xx,yy));
                % 最大强度点（M）和j点建立连接关系，这种关系是双向的
                connect(maxPx+neigh8X(j),maxPy+neigh8Y(j),InverseMap(j) )=1;  % j-->M
                connect(maxPx,maxPy,j )=1;   % M-->j
                %length1(xx,yy)=length1(maxPx,maxPy)+ sqrt(neigh8Y(j)^2 + neigh8X(j)^2) ;
                
                length1(xx,yy)=length1(maxPx,maxPy)+ J(xx,yy)+J(maxPx,maxPy) ;
                R(xx,yy)=1;
             end
         end
     end
end     
mask=R;

% calculate the mean value of the kernel 
total = 0;
count = 0;
for i = 1:sx
    for j = 1:sy
        if(mask(i, j) == 1)
            total = total + J(i, j);
            count = count + 1;
        end
    end
end

mean =total / count;
mask_J = zeros(sx, sy);
% mask_J(J >= mean) = 1;
mask_J(J >= mean) = 1;
% find the start point of the longest trace
length_tmp = length1 .* mask_J;
[x, y] = find(length_tmp == max(length_tmp(:)));
x = x(1);
y = y(1);
R=zeros(sx,sy);
B=zeros(sx,sy);
R(x,y)=1;
start_node_row = x;
start_node_col = y;

root_x=zeros(sx,sy);
root_y=zeros(sx,sy);
CCC=0;

while 1==1
    [sPx,sPy,v]=find(R);
    RR=R;
    for j=1:size(sPx,1)
        for k=1:8
            xx=sPx(j)+neigh8X(k);
            yy=sPy(j)+neigh8Y(k);
            if(1<=xx && sx>=xx && 1<=yy && sy>= yy )
                if (R(xx,yy)==0 && connect(sPx(j),sPy(j),k)==1 )
                    RR(xx,yy)=1;
                    %length2(xx,yy)=length2(sPx(j),sPy(j))+sqrt(neigh8Y(k)^2 + neigh8X(k)^2);
                     length2(xx,yy)=length2(sPx(j),sPy(j))+ J(xx,yy)+J(sPx(j),sPy(j) );
                    root_x(xx,yy)=sPx(j);root_y(xx,yy)=sPy(j);
                    CCC=CCC+1;
                end
            end
        end
    end
    if(R==RR) 
        break;
    end
    R=RR;
end
% find the start point of the longest trace
mx=max(max(length2));
[Px2,Py2]=find(length2==mx);
x=Px2(1);y=Py2(1);
num=0;
xxx = zeros(sx, sy);
while root_x(x,y)~=0 ||root_y(x,y)~=0
    xx=root_x(x,y);
    yy=root_y(x,y);
    num=num+1;
    Pat(1:2,num)=[xx,yy];
    xxx(xx,yy) = 1;
    x=xx;
    y=yy;
end
  Pat=Pat';
  Pat = flipud(Pat);
%%VIPNODE
vipnode=zeros(1,num);
vipnode(1)=1;
vipnode(num)=1;
maxd=-1;
for i=1:num
    d = abs(det([Pat(1,:)-Pat(num,:) ; Pat(i,:)-Pat(num,:)]))/norm(Pat(1,:)-Pat(num,:));
    if(maxd<d)
        maxd=d;
        v=i;
    end
end
vipnode(v)=1;
 pixels = Pat;
 Path=zeros(sx,sy);
 for i=1:num
     Path(Pat(i,1),Pat(i,2))=0.5+vipnode(i)/2;
 end
      Path(Path>0) = 255;
end

