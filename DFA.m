function [timescale,f,windownum,alpha]=DFA(data,dfaorder,segments,outfilename,figurenum)
%The program performed the detrended fluctuation analysis (DFA) on the provided
%signal.
%Inputs:
%       data (signal data points)
%       segments (segments of data to be analyzed)
%       dfaorder (order of the DFA for the polynomial fit)
%       outfilename (output file name in which results will be written) 
%Output:
%       timescale (time scales)
%       f (detrended fluctuation amplitudes at different time scales)
% disp('Usage:');
% disp('[timescale,f,windownum,alpha]=DFA(data,dfaorder,segments,outfilename,figurenum)');
timescale=[];f=[];windownum=0;alpha=nan;
if nargin<1
    disp('Provide data.');
    return;
end
if nargin<2
    dfaorder=2;
elseif dfaorder <0
    dfaorder=2;
end

if nargin<3
    segments=[1,length(data)];
end
[segnum,i]=size(segments);
if i~=2
    segments
    errordlg(['The column number for segments should be two: the first one for start index and the second for end index']);
    return;
end

if nargin<4
    outfilename = ['results.dfa',num2str(dfaorder)];
end

if nargin< 5
    figurenum=1;
end

%remove segments shorter than 5 points
seglen=segments(:,2)-segments(:,1)+1;
ii=find(seglen<5);
segments(ii,:)=[];seglen(ii)=[];
[segnum,i]=size(segments);

pointsused=[];
for i=1:segnum
    pointsused=[pointsused,segments(i,1):segments(i,2)];
end
pointsused=pointsused';
% len=max(pointsused);
len=length(data);

x=[1:len];y(1:len)=nan;iy(1:len)=nan;
y(pointsused)= data(pointsused);
if nargin == 5
    figure(figurenum);subplot(3,1,1);plot(x,y,'r');xlabel('Index');ylabel('Raw data');
end
%DFA:
%step 1. remove mean and do the integration (in each segment)
iy(1:len)=nan;
for i=1:segnum
    segy=[];
    segy=y(segments(i,1):segments(i,2));
    a=mean(segy);segy=segy-a;b=cumsum(segy);
    iy(segments(i,1):segments(i,2))=b;
end
if nargin == 5
figure(figurenum);subplot(3,1,2);plot(x,iy,'b');xlabel('Index');ylabel('Integrated data');
end
%step 2. choose the time scales
minscale=dfaorder+3;
maxscale=max(seglen);
minlogscale=log(minscale);
maxlogscale=log(maxscale);
step=log(2)/10;%step=(maxlogscale-minlogscale)/200;
logscale=[minlogscale:step:maxlogscale];
dscale=exp(logscale);
timescale=floor(dscale);
num=length(timescale);
i=2;

while i<=num
    if timescale(i)==timescale(i-1)
        timescale(i)=[];
        num=num-1;
    else
        i=i+1;
    end
end

% 

%step 3. do the fit for each time scale
f(1:num)=nan;windownum(1:num)=nan;
for ii=1:num
    s=timescale(ii);
    [f(ii),dfatrend,dfafluctuation,windownum(ii)]=dfaeachscale(iy,s,segments,dfaorder);
end
ii=find(isnan(f));
f(ii)=[];timescale(ii)=[];windownum(ii)=[];
num=length(f);
%figure(figurenum);subplot(3,1,3); loglog(timescale,f,'ro');


%Step 4. Save the dfa results
if nargin >= 4
    fiddfa=fopen(outfilename,'w');
    for i=1:num
        fprintf(fiddfa,'%d\t%f\t%d\n',timescale(i),f(i),windownum(i));
    end
    fclose(fiddfa);
end
% %step 5. obtain the scaling exponent alpha

ii=find(timescale>=6 & windownum>=4);
logf=log(f(ii));
logtimescale=log(timescale(ii));
[coefficient,cerror]=polyfit(logtimescale,logf,1);
alpha=coefficient(1);
% disp(['alpha= ', num2str(alpha)]);

logfit=coefficient(1)*logtimescale+coefficient(2);
fit=exp(logfit);
if nargin == 5
    figure(figurenum);subplot(3,1,3);loglog(timescale,f,'ro',timescale(ii),fit,'k');
    xlabel('Time scale n'); ylabel('Detrended fluctuation function');
end
[i,j]=size(timescale);
if i==1
    timescale=timescale';
end
[i,j]=size(f);
if i==1
    f=f';
end
[i,j]=size(windownum);
if i==1
    windownum=windownum';
end
return;

function [fn,dfatrend,dfafluctuation,totalwindownum]=dfaeachscale(yi,s,segments,DFAorder);
minwindownum=4;
fn=nan;
[segnum,i]=size(segments);
len=length(yi);
dfatrend=[];dfatrend(1:len)=nan;%polynomial trend 
dfafluctuation=[];dfafluctuation(1:len)=nan;%DFA fluctuation

totalwindownum=0;
for j=1:segnum%in each segment, do polynomial fitting
    N=segments(j,2)-segments(j,1)+1;
    numofwindows=floor(N/s);
    startindices=[segments(j,1):s:segments(j,2)];
    endindices=startindices+s-1;
    if length(startindices)>numofwindows
        startindices(numofwindows+1:end)=[];
        endindices(numofwindows+1:end)=[];
    end
    y=[];
    for i=1:numofwindows
        data=[];
        data=yi(startindices(i):endindices(i));
        x0=startindices(i):endindices(i);
        x=(x0-mean(x0))/std(x0);
        p=polyfit(x,data,DFAorder);
%         yfit=ones(1,s)*p(DFAorder+1);
%         for jj=1:DFAorder
%             yfit=yfit+p(DFAorder-jj+1)*(x.^jj);
%         end
        yfit=polyval(p,x);
        dfatrend(startindices(i):endindices(i))=yfit;
        dfafluctuation(startindices(i):endindices(i))=yi(startindices(i):endindices(i))-yfit;
    end
    totalwindownum=totalwindownum+numofwindows;
end
if totalwindownum>=minwindownum
    fn=sqrt(nanmean(dfafluctuation.*dfafluctuation));
end

return;
