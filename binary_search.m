runOpt_params;
baseFile='file.fsp';
baseFileSave0='file_found_length';

resonantWavelength=1550e-9;
%radius=25e-9;

lengths=600e-9+(0:20)*10e-9;
gaps=1e-9*[5 10 15 20];
%angles=[0 90]; % not all angles will be simulated, will change with gap spacing

Prads=zeros(length(lengths),length(gaps));
%Ptots=zeros(length(lengths),length(gaps));
%Purcells=zeros(length(lengths),length(gaps));

Prads_max=zeros(length(gaps));
%Ptots_max=zeros(length(gaps));
%Purcells_max=zeros(length(gaps));

resonantLengths=zeros(length(gaps));

for j=1:length(gaps);
    
    resonantLength=false;
    searchIndices=1:length(lengths); % changes within length loop

    while ~resonantLength
        i=floor((searchIndices(end)+searchIndices(1))/2);

        save('setup_resonant_length_search.mat','baseFile','lengths','gaps','i','j')
        runLumericalScript(lumerical,'setup_resonant_length_search.mat','setup_resonant_length_search.lsf');

        baseFileSave=[baseFileSave0,'_',num2str(j),'.fsp'];

        save('get_fields_dipole.mat','baseFile','baseFileSave');
        runLumericalScript(lumerical,'get_fields_dipole.mat','get_fields_dipole.lsf');

        load('get_fields_dipole.mat','Prad','lambda');
        %load('get_fields_dipole.mat','Prad','lambda','Ptot','Purcell');
        
        [~,index]=min(abs(lambda-resonantWavelength));

        Prads(i,j)=Prad(index);
        %Ptots(i,j)=Ptot(index);
        %Purcells(i,j)=Purcell;

        [~,maxIndex]=max(Prad);

        searchIndex=find(searchIndices==i);

        if maxIndex<length(lambda) && maxIndex>1
            if all(lambda(maxIndex-1:maxIndex+1)>lambda(index))
                if length(searchIndices)==1
                    resonantLengths(j,k)=lengths(i);
                    resonantLength=true;
                    Prads_max(j)=Prad(index);
                    %Ptots_max(j)=Ptot(index);
                    %Purcells_max(j)=Purcell;
                    disp('Resonant length not exact (failsafe) \n ')
                    disp(j);
                else
                    searchIndices=searchIndices(1:searchIndex);
                end
            elseif all(lambda(maxIndex-1:maxIndex+1)<lambda(index))
                if length(searchIndices)==1
                    resonantLengths(j)=lengths(i);
                    resonantLength=true;
                    Prads_max(j)=Prad(index);
                    %Ptots_max(j)=Ptot(index);
                    %Purcells_max(j)=Purcell;
                    disp('Resonant length not exact (failsafe) \n ')
                    disp(j);
                else
                    searchIndices=searchIndices(searchIndex:end);
                end
            else
                resonantLengths(j)=lengths(i);
                resonantLength=true;
                Prads_max(j)=Prad(index);
                %Ptots_max(j)=Ptot(index);
                %Purcells_max(j)=Purcell;
            end
        elseif maxIndex==length(lambda)
            searchIndices=searchIndices(searchIndex:end);
        elseif maxIndex==1
            searchIndices=searchIndices(1:searchIndex);
        end
    end

    save('completed_resonant_length_search.mat','Prads_max','Prads','resonantLengths','gaps','lengths')
    %save('completed_resonant_length_search.mat','Prads_max','Prads','Ptots_max','Ptots','Purcells_max','Purcells','resonantLengths','gaps','angles','lengths','index')
    
end