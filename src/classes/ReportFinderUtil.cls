public with sharing class ReportFinderUtil {
//Devops change1
  public ReportFinderUtil(){}
  
  public String findReportId(String reportName){
    
    Sobject myReport = [select Id,Name From Report Where Name=:reportName];
    return myReport.Id;
    
  }
  
  
}