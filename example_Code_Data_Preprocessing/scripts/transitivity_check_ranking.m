   %% Function for checking for transitivity and producing rank order of preferences
   %% This function is copied from http://ryanomurphy.com/resources/SVO_Slider.m
        
        function [transitivity, ranking_out] = transitivity_check_ranking(primary_data)
            
            % EXAMPLE
            % one DM's selected alocations from the 6 sliders, version 1
            % input_matrix =[85    85; 100    50; 85    85; 50   100; 75    75; 85    85];
            
            item_endpoints =[85 85   85 15
                             85 15   100 50
                             50 100  85 85
                             50 100  85 15
                             100 50  50 100
                             100 50  85 85];
            catagories = [2 4; 
                          4 3; 
                          1 2; 
                          1 4; 
                          3 1; 
                          3 2]; % 1=altruistic, 2=prosocial, 3=individualistic, 4=competitive
            
            distance_matrix = zeros(6,2);
            endpoint_distance = zeros(6,1);
            for count = 1 : 6;
                distance_matrix(count,1) = pdist([primary_data(count,:); item_endpoints(count,[1 2])]);
                distance_matrix(count,2) = pdist([primary_data(count,:); item_endpoints(count,[3 4])]);
                endpoint_distance(count,1) = pdist([item_endpoints(count,[1 2]); item_endpoints(count,[3 4])]);
            end
            
            ranking = zeros(1,4);
            compare1 = zeros(1,6);
            compare2 = zeros(1,6);
     
%             % Uncomment the following lines and comment the ones below for applying 1/3 margin transitivity rule 
            
            endpoint_thresholds = endpoint_distance./3;
            
            for count = 1 : 6
                if (distance_matrix(count,1) < distance_matrix(count,2)) 
                    if distance_matrix(count,1) < endpoint_thresholds(count,1);
                    compare1(count) = catagories(count,1);
                    compare2(count) = catagories(count,2);
                    ranking(catagories(count,1)) = ranking(catagories(count,1)) + 1;
                    ranking(catagories(count,2)) = ranking(catagories(count,2)) + 0;
                    else
                    ranking(catagories(count,1)) = ranking(catagories(count,1)) + .5;
                    ranking(catagories(count,2)) = ranking(catagories(count,2)) + .5;
                    end
                elseif distance_matrix(count,1) > distance_matrix(count,2);
                    if distance_matrix(count,2) < endpoint_thresholds(count,1);
                    compare2(count) = catagories(count,1);
                    compare1(count) = catagories(count,2);
                    ranking(catagories(count,1)) = ranking(catagories(count,1)) + 0;
                    ranking(catagories(count,2)) = ranking(catagories(count,2)) + 1;
                    else
                    ranking(catagories(count,1)) = ranking(catagories(count,1)) + .5;
                    ranking(catagories(count,2)) = ranking(catagories(count,2)) + .5;
                    end
                elseif distance_matrix(count,1) == distance_matrix(count,2);
                    ranking(catagories(count,1)) = ranking(catagories(count,1)) + .5;
                    ranking(catagories(count,2)) = ranking(catagories(count,2)) + .5;
                end
            end
            
%             Uncomment the above lines and comment the following in order
%             to apply 1/3 transitivity rule:
%
%             for count = 1 : 6
%                 if distance_matrix(count,1) < distance_matrix(count,2);
%                     compare1(count) = catagories(count,1);
%                     compare2(count) = catagories(count,2);
%                     ranking(catagories(count,1)) = ranking(catagories(count,1)) + 1;
%                     ranking(catagories(count,2)) = ranking(catagories(count,2)) + 0;
%                 elseif distance_matrix(count,1) > distance_matrix(count,2);
%                     compare2(count) = catagories(count,1);
%                     compare1(count) = catagories(count,2);
%                     ranking(catagories(count,1)) = ranking(catagories(count,1)) + 0;
%                     ranking(catagories(count,2)) = ranking(catagories(count,2)) + 1;
%                 elseif distance_matrix(count,1) == distance_matrix(count,2);
%                     ranking(catagories(count,1)) = ranking(catagories(count,1)) + .5;
%                     ranking(catagories(count,2)) = ranking(catagories(count,2)) + .5;
%                 end
%             end
            
            %
            
            compare1(compare1==0) = [];
            compare2(compare2==0) = [];
            
            %biograph and graphisdag have been removed since R2022b, so check the version here to use the functions accordingly 
            verStr=version('-release');
            verYear=str2num(verStr(1:4));
            versionAB=verStr(5);
            
            if verYear < 2022
               oldVer=1;
            elseif verYear > 2022
               oldVer=0;
            elseif verYear == 2022
                if strcmp(versionAB,'a')
                   oldVer=1;
                else
                   oldVer=0;
                end
            end

            if oldVer==1
                DG = sparse(compare1,compare2,true,4,4);
                transitivity = graphisdag(DG);
            else
                DG_digraph = digraph(compare1, compare2);
                transitivity = isdag(DG_digraph);
            end
            
            if transitivity == 1;
                [~,ranking_out] = sort(ranking,'descend');
            elseif transitivity == 0;
                %view(biograph(DG))
                ranking_out(1:4) = NaN;
            end
            
        end
        