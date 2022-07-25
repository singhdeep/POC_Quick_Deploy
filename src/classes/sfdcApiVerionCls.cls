public class sfdcApiVerionCls {
    //Devops change1
    public sfdcApiVerionCls(){
        getApiVersionCount('ApexClass');
        getApiVersionCount('ApexTrigger');
        getApiVersionCount('ApexPage');//VF Page
        getApiVersionCount('ApexComponent'); // VF Components
        getApiVersionCount('AuraDefinitionBundle');// Lightning
    }
    
    public void getApiVersionCount(string ObjectName){
        
        Integer int_01_10=0;
        Integer int_11_20=0;
        Integer int_21_30=0;
        Integer int_31_40=0;
        Integer int_41_50=0;
        Integer apiVersion;
        List<sObject> sobjList = Database.query('SELECT Id,ApiVersion,NamespacePrefix FROM '+ ObjectName +' where NamespacePrefix=null');
                
        for(sObject cls : sobjList){
            apiVersion = Integer.valueOf(cls.get('ApiVersion'));

            if(apiVersion >0 && apiVersion <= 10){
                int_01_10++;
            }            
            else if(apiVersion >10 && apiVersion <= 20){
                int_11_20++;
            }
            else if(apiVersion >20 && apiVersion <= 30){
                int_21_30++;
            }
            else if(apiVersion >30 && apiVersion <= 40){
                int_31_40++;
            }
            else{
                int_41_50++;
            }
        }
        
        System.debug(ObjectName+' ApiVersion (01-10) # '+int_01_10);
        System.debug(ObjectName+' ApiVersion (11-20) # '+int_11_20);
        System.debug(ObjectName+' ApiVersion (21-30) # '+int_21_30);
        System.debug(ObjectName+' ApiVersion (31-40) # '+int_31_40);
        System.debug(ObjectName+' ApiVersion (41-50) # '+int_41_50);
    }
}