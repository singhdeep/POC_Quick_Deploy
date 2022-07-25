public class objectLists{
    public String SeletedObject {get; set;}
    public  String childObj {get;set;}
    List<SelectOption> options;

    public List<SelectOption> getObjectOptions() 
    {
        //Devops change1
         options = new List<SelectOption>();
         Map<String, Schema.SObjectType> AllObjmap   = New Map<String, Schema.SObjectType>();
         AllObjmap = Schema.getGlobalDescribe();

         System.debug('******All object Names******* :'+ AllObjmap.keyset());

         for(String ObjectName: AllObjmap.keySet())
         {
            List<string> objlist = new List<string>();
            objlist.add(ObjectName);
            options.add(new SelectOption(ObjectName,ObjectName));

        }
        return options;        
    }
    public List<ChildRelationship> getrelatedchild()
    {
         Map<string,string> childMap = new Map<String, String>();
         List<Schema.Childrelationship> childList = Schema.getGlobalDescribe().get(SeletedObject).getdescribe().getChildRelationships();
        return childList;
    }
    public List<ChildRelationship> getRelationships()
    {
        return SObjectType.Individual.getChildRelationships();
    }
    
}