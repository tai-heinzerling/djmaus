function [ fname ] = getSCTfile( datadir )
%reads settings.xml in datadir to figure out which node the soundcardtrig
%was recorded on, and hence what the filename is
cd(datadir)
settings=xml2struct('settings.xml');

if (0)
%this helpfully prints out all the nodes and their names
signalchain=settings.SETTINGS.SIGNALCHAIN;
for i=1:length(signalchain)
    processors=signalchain{i}.PROCESSOR;
    for j=1:length(processors)
        if iscell(processors)
            fprintf('\n%s: %s',    processors{j}.Attributes.NodeId, processors{j}.Attributes.name)
        else
            if length(processors)==1
                fprintf('\n%s: %s',    processors.Attributes.NodeId, processors.Attributes.name)
            else
                error('wtf')
            end
        end
    end
end
end

NodeId=[];

%this searches all the nodes to see which has "record" turned on
%we are looking for the node that has ch35 turned on, which is ADC1 which
%should be recording the soundcardtriggers

signalchain=settings.SETTINGS.SIGNALCHAIN;
for i=1:length(signalchain)
    processors=signalchain{i}.PROCESSOR;
    for j=1:length(processors)
        if iscell(processors)
            if isfield(processors{j}, 'CHANNEL')
                channels=processors{j}.CHANNEL;
                for ch=1:length(channels)
                    if    str2num(channels{ch}.SELECTIONSTATE.Attributes.record)
                        %fprintf('\n%s: %s ch %s is being recorded',    processors{j}.Attributes.NodeId, processors{j}.Attributes.name, channels{ch}.Attributes.number)
                        if  strcmp(channels{ch}.Attributes.number, '35') 
                                             NodeId=processors{j}.Attributes.NodeId;
                        end
                    end
                end
            end
        else
            if length(processors)==1
                if isfield(processors, 'CHANNEL')
                    
                    channels=processors.CHANNEL;
                    for ch=1:length(channels)
                        if    channels{ch}.SELECTIONSTATE.Attributes.record
                            %fprintf('\n%s: %s ch %d is being recorded',    processors.Attributes.NodeId, processors.Attributes.name, channels{ch}.Attributes.number)
                            %  don't bother, this is the network events
                        end
                    end
                end
            else
                error('wtf')
            end
        end
    end
end

filename=sprintf('%s_ADC1.continuous', NodeId);
absfilename=fullfile(datadir, filename);
if exist(absfilename,'file')
fname=filename;
else
    fname=[];
end