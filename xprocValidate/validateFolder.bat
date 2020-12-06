set JAVA_HOME=C:\Program Files (x86)\Common Files\Oracle\Java\javapath\jre
set SAXON_HOME=C:\Program Files\Oxygen XML Editor 19\lib
set CBASH_HOME=..\xmlcalabash-1.1.24-98\lib"
set PATH=%PATH%;%SAXON_HOME%;%CBASH_HOME%;%JAVA_HOME%;


java -Xmx10G -jar ..\schemaDoc\processors\xmlcalabash-1.1.24-98\xmlcalabash-1.1.24-98.jar C:\Users\colin\unified-master-schema\xprocValidate\validate-folder.xpl xml-input-folder=file:/C:/Users/colin/Documents/newco/TSO/TNA/data27-02-2020/enacted logFolder=file:/C:/Users/colin/Documents/newco/TSO/TNA/xprocValidate/logs/enacted

java -Xmx10G -jar ..\schemaDoc\processors\xmlcalabash-1.1.24-98\xmlcalabash-1.1.24-98.jar C:\Users\colin\unified-master-schema\xprocValidate\validate-folder.xpl xml-input-folder=file:/C:/Users/colin/Documents/newco/TSO/TNA/data27-02-2020/revised logFolder=file:/C:/Users/colin/Documents/newco/TSO/TNA/xprocValidate/logs/revised



pause
