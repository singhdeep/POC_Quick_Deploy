/*
* @author  Esteve Graells (esteve.graells at gmail.com)
* @version 1.0
* @since   17-11-2016
* @version: 1.0
*
* Salesforce does not send notification when File or Data Storage hits the ORG limit, thats very incovenient for an admin.
* The Limits values are only exposed through REST API, no via standard object, to query it through SOQL 
* No Packages found in App Exchange that are reliable and customizable, so I wrote mine, based on idea of 
* bob_buzzard in https://developer.salesforce.com/forums/?id=906F000000092EjIAI (Screen Scraper, what is scaring and challenging at the same time)
* 
* Please used it only if you know what you are doing.
*  
* Data and File Storage are the first values that we find following the Pattern \\d+%</td></tr> in the html source code of page: 
* https://yourdomain.salesforce.com/setup/org/orgstorageusage.jsp?id=your_ORG_Id&setupid=CompanyResourceDisk
* (dont worry to build the URL, the apex code builds it, indepently of your org)
*
* You need to do 2 things: 
* 1st. To schedule the Apex Class as a job, run the following in your Developer Console:
*
* StorageNotification storageNotification= new StorageNotification();
* String frequency = '0 0 * * * ?'; //run every hour o'clock, customize it on your needs
* System.schedule('Storage Alarms Notification', frequency, storageNotification);
*

* 2nd. Customize the literals for mail messagea - mine are in spanish 
* (Remember body is Html so be fancy!!)
*
* After all:
* Check you Deliverabililty settings under Setup > Email Administration > Deliverability. Issue appears wehn that setting is set to No Access.  
* It must be set to All Email.
* Check the Apex Job got scheduled on Setup->Jobs->Scheduled Jobs
* After first run check results on Setup->Jobs->Apex Jobs
* 
*/

//Devops change1
global class StorageNotification implements Schedulable {
	
   global void execute(SchedulableContext SC) {
      EnviarAlarmas();      
   }
   
    @future (callout=true)	
    static void EnviarAlarmas(){
    	
    	String[] recipientsMail = 	new String[] {'s.a.ranjan.mahapatra@gmail.com'};
    	String[] adminsMail 	=	new String[] {'s.a.ranjan.mahapatra@gmail.com'}; //Sent when error occurs
		
		Integer limiteDataStorageInfo 	= 75; // Enviar correo de informacion al llegar a este %
	    Integer limiteDataStorageAlerta = 90; // Enviar correo de informacion al llegar a este %
	    Integer limiteFileStorageInfo	= 75; // Enviar correo de informacion al llegar a este %
	    Integer limiteFileStorageAlerta = 90; // Enviar correo de informacion al llegar a este %
	    
	    String requestUrl = '/setup/org/orgstorageusage.jsp?id=' + UserInfo.getOrganizationId() + '&setupid=CompanyResourceDisk';
    	                
    	//Get the Storage Page, prepare to scrape
    	PageReference pg = new PageReference( requestUrl );
    	String htmlCode = pg.getContent().toString();
    	
    	//Find the pattern 
    	Pattern patternToSearch = Pattern.compile('\\d+%</td></tr>'); 
        Matcher matcherPattern = patternToSearch.matcher(htmlCode);

        String  dataStorageString, fileStorageString, dataStorageUsedPercentage, fileStorageUsedPercentage;
                
        //Find the first Occurrence which is Data Storage       
        if ( matcherPattern.find() ) {
        	
            dataStorageString = htmlCode.substring(matcherPattern.start(), matcherPattern.end());
            //System.debug('**************************** dataStorageString: ' + dataStorageString);
            
            //Find the Subpattern
            Pattern subpatternToSearch = Pattern.compile('\\d+'); //Indica valores de la tabla de porcentages
        	Matcher matcherPatternPercentage = subpatternToSearch.matcher(dataStorageString);
            
            if ( matcherPatternPercentage.find() ) { 
            	
            	dataStorageUsedPercentage = dataStorageString.substring(matcherPatternPercentage.start(), matcherPatternPercentage.end());
            	
            }else{
                dataStorageString =  null;
            }
        }
         
		//Find the first Occurrence; which is File Storage
        if ( matcherPattern.find() ) {
            
            fileStorageString = htmlCode.substring(matcherPattern.start(), matcherPattern.end());
            
            Pattern subpatternToSearch = Pattern.compile('\\d+'); //Indica valores de la tabla de percentages
        	Matcher matcherPatternPercentage = subpatternToSearch.matcher(fileStorageString);            
            
            if ( matcherPatternPercentage.find() ) { 
            	fileStorageUsedPercentage = fileStorageString.substring(matcherPatternPercentage.start(), matcherPatternPercentage.end());
            }else{
                fileStorageString = null;
            }
        }        
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    	String bodyMessage = '';
    	Boolean sendMessage = false;
    	
        //Check we've got values, otherwise notify the Admins
        if ( (!String.isBlank(dataStorageUsedPercentage)) && (!String.isBlank(fileStorageUsedPercentage) ) ){
        	
        	if ( ( limiteDataStorageAlerta <= integer.valueof(dataStorageUsedPercentage) ) || ( limiteFileStorageAlerta <= integer.valueof(fileStorageUsedPercentage) ) ) {
        		
                sendMessage = true;
                mail.setSubject('Aviso ALERTA almacenamiento: ' + UserInfo.getOrganizationName() + ' - ID: '+ UserInfo.getOrganizationId());
                   	
		   	}else if ( ( limiteDataStorageInfo <= integer.valueof(dataStorageUsedPercentage) ) || ( limiteFileStorageInfo <= integer.valueof(fileStorageUsedPercentage) ) ) {
		   		
		   		sendMessage = true;
                mail.setSubject('Aviso INFO almacenamiento: ' + UserInfo.getOrganizationName() + ' - ID: '+ UserInfo.getOrganizationId());
                
			}            
        	
        	if ( sendMessage ){
        		//Send Mail Notifications
	    		mail.setToAddresses(recipientsMail);
		        mail.setSenderDisplayName('Aviso almacenamiento');
	        	bodyMessage  = 'Se ha generado una alarma de almacenamiento debido a que uno de los valores siguientes ha superado el límite:';
		        bodyMessage += '<ul><li>Almacenamiento Data: <b>' +  dataStorageUsedPercentage + '%</b>';
		        bodyMessage += '<li>Almacenamiento Files: <b>' + fileStorageUsedPercentage + '%</b></ul>';
		        bodyMessage += 'Los límites establecidos son:';
		        bodyMessage += '<ul><li>Info y Alerta para Data Storage : ' + limiteDataStorageInfo + '% y ' + limiteDataStorageAlerta + '%';
		        bodyMessage += '<li>Info y Alerta para File Storage: ' + limiteFileStorageInfo + '% y ' + limiteFileStorageAlerta + '%';
		        bodyMessage += '<p><a href="' + System.URL.getSalesforceBaseUrl().toExternalForm() + requestUrl + '" target="_blank">Acceder a la página de almacenamiento</a>';
		        mail.setHtmlBody(bodyMessage);
	        	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        	}
        	//else No Alerts must be sent, storage usages are between limits
        	
        	
        	
        }else{
        	//Things went Wrong, notify the admins
        	
        	//System.debug('Pattern finding failed miserayble - Esteve\'s Fault');
        	
        	//Send Mail Notifications
    		mail.setToAddresses(adminsMail);
	        mail.setSenderDisplayName('Error en generación de Alertas');
	        mail.setSubject('Error Generación Alertas Almacenamiento en: ' + UserInfo.getOrganizationName() + ' - ID: '+ UserInfo.getOrganizationId());
	        
	        bodyMessage  = 'Error en la generación de alertas, los valores son dataStorageUsedPercentage:' +  dataStorageUsedPercentage + ' fileStorageUsedPercentage:' + fileStorageUsedPercentage;
	        
	        mail.setHtmlBody(bodyMessage);
	        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
       
}