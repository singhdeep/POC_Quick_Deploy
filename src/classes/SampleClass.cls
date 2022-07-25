/***********************************************************************************
Class Name          : SampleClass
Description         : This is a sample class created by Visual Studio Code extension.
Author              : Author Name
Created Date        : 05/06/2020
**************************************************************************************/
public with sharing class SampleClass
{
    public void bar(){
    string s = 'first.second';
    string[] part = s.split('.'); 
    string[] part1;
    part1 = s.split('&');
    
    String input = 'valueOne valueTwo valueThree';
    String[] values = input.split(' ');
    String result = String.join( values, ' AND ' );
    String result1;
    result1 = String.join( values, ' AND ' );
    
    String str='Anu',str1='test';
    String msg, msg1, msg3, msg4;
    msg = str != null ? str : 'str1';
    msg1 = str != null ? '' : '';
    msg4 = str != null ? '' : str;
    
    String msg5 = str != null ? str : 'str1';
    String msg6 = str != null ? '' : '';
    String msg7 = str != null ? 'str' : '';
    String msg8 = str != null ? '' : str;
}
}