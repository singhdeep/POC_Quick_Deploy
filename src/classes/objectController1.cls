public class objectController1
{
    //Devops change1
private Map <String, Schema.SObjectType> schemaMap =Schema.getGlobalDescribe();
public List <SelectOption> objectNames{public get; private set;}
public String selectedObject {get; set;}
public String selectedField {get; set;}
public List<SelectOption> fieldNames {public get; private set;}
    public objectController1() {
        objectNames = initObjNames();
    }
// Populate SelectOption list -

// find all sObjects available in the organization

private List<SelectOption> initObjNames() {
List<SelectOption> objNames =
new List<SelectOption>();
List<String> entities =
new List<String>(schemaMap.keySet());
entities.sort();
    for(String name : entities){
objNames.add(new SelectOption(name,name));
    }
return objNames;
}

// Find the fields for the selected object

public void  showFields() {
    fieldNames = new List<SelectOption>();
Map <String, Schema.SObjectField> fieldMap = schemaMap.get(selectedObject).getDescribe().fields.getMap();
/*
for(Schema.SObjectField sfield : fieldMap.Values()){
schema.describefieldresult dfield = sfield.getDescribe();
Pair field = new Pair();
field.key = dfield.getname();
fields.add(field);
}*/
    for (String fieldName: fieldMap.keySet()) 
    {  
        fieldNames.add(new SelectOption(fieldName,fieldName));
    }
    
}
}