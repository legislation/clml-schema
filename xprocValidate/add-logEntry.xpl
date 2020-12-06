<?xml version="1.0"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cm="http://macksol.co.uk" xmlns:sch="http://purl.oclc.org/dsdl/schematron"  xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    version="2.0" type="cm:addLogEntry" name="addLogEntry">

    <p:option required="true" name="logInfoFilename"/>
    <p:option required="true" name="xml-input-folder"/>
    <p:option required="true" name="logFolder"/>
    <p:option required="false" name="initialFolderName"/>
    <p:option required="false" name="totalFileCount"/>
    <p:option required="false" name="inputFileUri" select="''"/>
    <p:option required="false" name="isValid" select="'no'"/>
    
    <p:input port="source" primary="true"/>
    <p:input port="cleanerstylesheet" kind="document" />
    <p:output port="output" sequence="true">
        <p:empty/>
    </p:output>
    
    <p:import href="library-1.0.xpl"/>
    
    <p:variable name="vInputFilename" select="if (contains($inputFileUri,'/')) then tokenize($inputFileUri,'/')[last()] else tokenize($inputFileUri,'\\')[last()]"/>
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:pipe port="cleanerstylesheet" step="addLogEntry"/>
        </p:input>
        <p:with-param name="gpLogInfoFilename" select="$logInfoFilename"/>
        <p:with-param name="gpDataBasePath" select="$xml-input-folder"/>
     </p:xslt>
    
    <!-- Store the updated log file -->
    <p:store omit-xml-declaration="false" indent="true">
        <p:with-option name="href" select="concat($logFolder,'/',$vInputFilename)"/>
    </p:store>
        
    
</p:declare-step>
