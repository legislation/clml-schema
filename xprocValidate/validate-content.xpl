<?xml version="1.0"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cm="http://macksol.co.uk" xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:c="http://www.w3.org/ns/xproc-step"
    version="1.0" 
    type="cm:validate-content" name="validate-content">
    
    <p:documentation>Validates a single file against the schema and writes any errors to a log file.
    The schema is supplied as the input source with XSLTs on other ports (to save loading for every file)</p:documentation>
    
    <!--<p:serialization port="result" method="xml" omit-xml-declaration="false" indent="false"/>-->
    
    <p:option required="true" name="logInfoFilename"/>
    <p:option required="true" name="xml-input-folder"/>
    <p:option required="true" name="logFolder"/>
    <p:option required="false" name="initialFolderName" select="''"/>
    <p:option required="false" name="totalFileCount" select="'1'"/>
    <p:option required="true" name="inputFileUri"/>
    
    <p:input port="source" primary="true"/>
    <!-- may or may not be present -->
    <p:input port="preValidationstylesheet" kind="document" sequence="true"/>
    <p:input port="cleanerstylesheet" kind="document" />
    
    <p:output port="output" sequence="true" >
        <p:empty/>
    </p:output>
    
    <p:import href="library-1.0.xpl"/>
    <p:import href="add-logEntry.xpl"/>
    <p:variable name="vInputFilename" select="if (contains($inputFileUri,'/')) then tokenize($inputFileUri,'/')[last()] else tokenize($inputFileUri,'\\')[last()]"/>
    <p:variable name="vStartDateTime" select="current-dateTime()"/>
    
    <p:identity name="xsdschema"/>
    
    <p:load>
        <p:with-option name="href" select="$inputFileUri"/>
    </p:load>
    <p:identity name="originalDocument"/>
    
    <p:identity>
        <p:input port="source">
            <p:pipe port="preValidationstylesheet" step="validate-content"/>
        </p:input>
    </p:identity>
    <p:choose>
        <p:when test="/xsl:stylesheet">
            <p:sink/>
            <p:xslt>
                <p:input port="source">
                    <p:pipe port="result" step="originalDocument"/>
                </p:input>
                <p:input port="stylesheet">
                    <p:pipe port="preValidationstylesheet" step="validate-content"/>
                </p:input>
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
             </p:xslt>
        </p:when>
        <p:otherwise>
            <p:sink/>
            <p:identity>
                <p:input port="source">
                    <p:pipe port="result" step="originalDocument"/>
                </p:input>
            </p:identity>
        </p:otherwise>
    </p:choose>
    <p:identity name="finalDocument"/>
    
    <p:try name="final">
        <p:group>
            <p:validate-with-xml-schema name="validate">
                <p:input port="source">
                  <p:pipe step="finalDocument" port="result"/>
                </p:input>
                <p:input port="schema">
                  <p:pipe port="result" step="xsdschema"/>
                </p:input>
                <p:with-option name="assert-valid" select="'true'"/>
            </p:validate-with-xml-schema>
            <cx:message>
                <p:with-option name="message" select="concat($vInputFilename,' is valid')"/>
            </cx:message>
            <p:sink/>
        </p:group>
        <p:catch name="xsderror">
            <p:identity>
                <p:input port="source">
                    <p:pipe step="xsderror" port="error"/>
                </p:input>
            </p:identity>
            <!-- see https://github.com/ndw/xmlcalabash1/issues/297 
            workaround if all errors are the calabash issues then it is not a XML schema error -->
            <p:choose>
                <p:when test="/c:errors/c:error[ends-with(@href,'.xpl')] and not(/c:errors/c:error[not(ends-with(@href,'.xpl'))])">
                    <!-- <c:error xmlns:err="http://www.w3.org/ns/xproc-error"
               code="err:XD0023"
               href="file:/C:/Users/colin/Documents/newco/TSO/TNA/xprocValidate/validate-content.xpl"
               line="6"
               column="32">The supplied node has been schema-validated, but the XPath expression was compiled without schema-awareness</c:error> -->
                    <cx:message>
                        <p:with-option name="message" select="concat($vInputFilename,' is valid (Xproc error ignored)')"/>
                    </cx:message>
                    <p:sink/>
                </p:when>
                <p:otherwise>
                    <cx:message>
                        <p:with-option name="message" select="concat($vInputFilename,' is invalid')"/>
                    </cx:message>
                    <cm:addLogEntry>
                        <p:input port="cleanerstylesheet">
                          <p:pipe port="cleanerstylesheet" step="validate-content"/>
                        </p:input>
                         <p:with-option name="logInfoFilename" select="$logInfoFilename"/>
                         <p:with-option name="xml-input-folder" select="$xml-input-folder"/>
                         <p:with-option name="logFolder" select="$logFolder"/>
                         <p:with-option name="initialFolderName" select="$initialFolderName"/> 
                         <p:with-option name="totalFileCount" select="$totalFileCount"/>
                         <p:with-option name="inputFileUri" select="$vInputFilename"/>
                    </cm:addLogEntry>
                    <p:sink/>
                </p:otherwise>
            </p:choose>
        </p:catch>
    </p:try>
    
    
</p:declare-step>
