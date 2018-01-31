path(path,'/Users/josefin/Downloads/1.1-master/miditoolbox')
%Create RMAT
midi_data = 'shepertbluesdrums';
[RMAT,midifile] = CreateRmat(midi_data); 
agentcell_init = initializationPhase(RMAT); %initialization phase
agentcell = beatTracking(agentcell_init, RMAT); %beat tracking


%%
winning_agent = sort(cat(2,agentcell{3,1}, agentcell{5,1}), 'ascend');
hold on
plot(RMAT(:,3),ones(length(RMAT(:,3))),'k.');
for i=1:length(winning_agent') %the winning agent is plotted in red
   plot([winning_agent(i) winning_agent(i)],[0.9 1],'r');
end

ylim([0,2]);

hold off
clicks = transpose(winning_agent);


%%
 
tic 
%in this section,  we create the cell array  B , the first column has the beats,
%the second to fourth  columns stores all the corresponding RMAT data in the half-open intervall [beat(i),
%beat(i+1)). 
%second column: instrument
%third column: velocity
%fourth column: onsettime
B = cell(length(clicks), 4);
B(1:end,1) =num2cell(clicks);
 
for i =1:length(clicks)-1
    B{i,2}= RMAT(and(clicks(i) <= RMAT(:,3) ,RMAT(:,3)  < clicks(i+1)),1); % instrument
    B{i,3}= RMAT(and(clicks(i) <= RMAT(:,3) ,RMAT(:,3)  < clicks(i+1)),2);%velocity
    B{i,4}= RMAT(and(clicks(i) <= RMAT(:,3) ,RMAT(:,3)  < clicks(i+1)),3); %onset time
end
 
 
B{length(clicks), 2} = RMAT((RMAT(:,3) >= B{end,1}(end)),1); %just last entry in the lower left corner of the B cell
B{length(clicks), 3} = RMAT((RMAT(:,3) >= B{end,1}(end)),2); 
B{length(clicks), 4} = RMAT((RMAT(:,3) >= B{end,1}(end)),3); 

%%
 
%Now we give each instrument that has been played an own column, so that we can check the autocorrelattion individually
instrumentlist = unique(RMAT(:,1)); %list of all instruments that have been played
 
C = cell(length(clicks), length(instrumentlist)); % each instrument gets its column

for i=1:length(instrumentlist)
  
   for j=1:length(clicks)-1 %loop over all clicks from beat tracking
       
           if ismember(B{j,2},instrumentlist(i)) %if the instrument is played between to clicks or on click
           [tf,loc]=ismember(B{j,2},instrumentlist(i)); % store its position
           idx=[1:length(B{j,2})]; % creates an index vector over the number of onsets
           idx=idx(tf); % gives the position where the instrument is played
        
           onsetvec = cell2mat(B(j,4));
           onsetvec = onsetvec(idx)
           quantvec=quantize_microbeats1(clicks(j), clicks(j+1),onsetvec);
           C{j,i}=quantvec;
           
       
           else % if the instrument is not on the click or within then just put all zeros
                C{j,i}=[0 0 0 0 0 0 0 0 0 0 0 0];
         
            end
   end
end


[a,b]= hist(RMAT(:,1), instrumentlist);

 
 [Y,I]= sort(a, 'descend'); % here we sort the columns of C according to how often the corresponding instrument is played. 
 
 
 
 
 %%
A1 = cell2mat(C(:,I(1))); %This instrument is played the most 
A1 = A1';
Avec1 = A1(:);

A2 = cell2mat(C(:,I(2))); %this instrument is played the second most
A2 = A2';
Avec2 = A2(:);


A3 = cell2mat(C(:,I(3))); %this instrument is played the third most
A3 = A3';
Avec3 = A3(:);

A4 = cell2mat(C(:,I(4)));%this instrument is played the fourth most
A4 = A4';
Avec4 = A4(:);

A5 = cell2mat(C(:,I(5))); %this instrument is played the fifth most
A5 = A5';
Avec5 = A5(:);

%A6 = cell2mat(C(:,I(6))); %this instrument is played the sixth most
%A6 = A6';
%Avec6 = A6(:);

%%
%in this part, we will take care of finding the instruments name
%corresponding to the pitch number 

pitchlist=[35:1:59];
pitch2name={' Acoustic Bass Drum ', ' Bass Drum 1 ', ' Side Stick ', ' Acoustic Snare ',' Hand Clap ', ' Electric Snare ', ' Low Floor Tom ', ' Closed High-Hat ',' High Floor Tom ', ' Pedal High-Hat ', ' Low Tom ', ' Open High-Hat ' ,' Low Mid-Tom ',' High Mid-Tom ', ' Crash Cymbal1 ', ' High Tom ', ' Ride Cymbal 1 ', ' Chinese Cymbal ',' Ride Bell ', ' Tamburine ', ' Splash Cymbal ', ' Cowbell ', ' Crash Cymbal 2 ', ' Vibraslap ', ' Ride Cymbal 2 '};
%%
acf1=autocorr(Avec1,480);
ACF1 =acf1(1:12:end); %only every twelfth sample of acf1 , corresponding to shifting by one click
index=(pitchlist==instrumentlist(I(1)));
instrumentname= pitch2name{index};
figure(1)
scatter( [0:length(acf1(1:12:end))-1],ACF1) %this is the acf when shifting by twelve
title( [' ACF of  instrument:', instrumentname ])
ax = gca;
ax.XGrid =  'on';
ax.YGrid = 'off';

%%

acf2=autocorr(Avec2,480);
ACF2 =acf1(1:12:end); %only every twelfth sample of acf2 , corresponding to shifting by one click
index=(pitchlist==instrumentlist(I(2)));
instrumentname= pitch2name{index} ;
figure(2)
scatter( [0:length(acf1(1:12:end))-1],ACF2) %this is the acf when shifting by twelve
title( [' ACF of  instrument:', instrumentname ])
ax = gca;
ax.XGrid =  'on';
ax.YGrid = 'off';


acf3=autocorr(Avec3,480);
ACF3 =acf3(1:12:end); %only every twelfth sample of acf3 , corresponding to shifting by one click
index=(pitchlist==instrumentlist(I(3))); 
instrumentname= pitch2name{index};
figure(3)
scatter( [0:length(acf1(1:12:end))-1],ACF3) %this is the acf when shifting by twelve
title( [' ACF of  instrument:', instrumentname ])
ax = gca;
ax.XGrid =  'on';
ax.YGrid = 'off';


acf4=autocorr(Avec4,480);
ACF4 =acf4(1:12:end); %only every twelfth sample of acf4 , corresponding to shifting by one click
index=(pitchlist==instrumentlist(I(4)));
instrumentname= pitch2name{index};
figure(4)
scatter( [0:length(acf1(1:12:end))-1],ACF4) %this is the acf when shifting by twelve
title( [' ACF of  instrument:', instrumentname ])
ax = gca;
ax.XGrid =  'on';
ax.YGrid = 'off';


acf5=autocorr(Avec5,480);
ACF5 =acf5(1:12:end); %only every twelfth sample of acf5 , corresponding to shifting by one click
index=(pitchlist==instrumentlist(I(5)));
instrumentname= pitch2name{index};
figure(5)
scatter( [0:length(acf1(1:12:end))-1],ACF5) %this is the acf when shifting by twelve
title( [' ACF of  instrument:', instrumentname ])
ax = gca;
ax.XGrid =  'on';
ax.YGrid = 'off';


%acf6=autocorr(Avec6,480);
%ACF6 =acf3(1:12:end) ;%only every twelfth sample of acf6 , corresponding to shifting by one click
%index=(pitchlist==instrumentlist(I(6)));
%instrumentname= pitch2name{index};
%figure(6)
%scatter( [0:length(acf1(1:12:end))-1],ACF6) %this is the acf when shifting by twelve
%title( [' ACF of  instrument:', instrumentname ])
%ax = gca;
%ax.XGrid =  'on';
%ax.YGrid = 'off';


%%

%in this part, we look at the peaks of the ACF of all instrument to
%determine the time signature

[Y,acf_peak1]=max(ACF1(2:end));
[Y,acf_peak2]=max(ACF2(2:end));
[Y,acf_peak3]=max(ACF3(2:end));
[Y,acf_peak4]=max(ACF4(2:end));
[Y,acf_peak5]=max(ACF5(2:end));
%[Y,acf_peak6]=max(ACF6(2:end));

acf_peak_vec=[acf_peak1, acf_peak2, acf_peak3, acf_peak4, acf_peak5]


%%

%     