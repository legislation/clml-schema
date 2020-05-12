<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cm="http://macksol.co.uk" xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:xh="http://www.w3.org/1999/xhtml" version="1.0">
  
   <p:documentation>Validates a folder/subfolders XML files against he schema and writes any errors to log files</p:documentation>
  
   <p:option required="false" name="schemaUri" select="'file:/C:/Users/colin/unified-master-schema/schema/legislation.xsd'"/>
   <p:option required="true" name="xml-input-folder"/>
   <p:option required="false" name="logFolder" select="'file:/C:/Users/colin/Documents/newco/TSO/TNA/xprocValidate/logs'"/>
   <p:option required="false" name="cleanXsltFilename" select="'cleanLog.xsl'"/>
   <p:option required="false" name="preValidationXsltFilename" select="''"/>
  
  <p:input port="source" sequence="true" >
      <p:empty/>
  </p:input>
  <p:output port="output" sequence="true" >
      <p:empty/>
  </p:output>
  
   <p:import href="validate-content.xpl"/> 
   <p:import href="recursive-directory-list.xpl"/>
   <!--<p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>-->
   <p:import href="library-1.0.xpl"/>
  
    <p:variable name="startDateTime" select="current-dateTime()"/>
    <p:variable name="logInfoFilename" select="concat($logFolder,'/', replace(substring-before(xs:string($startDateTime),'.'),':','-'),'.log')"/>
    <!-- load the schema once rather than once per file -->
    <p:load>
        <p:with-option name="href" select="$schemaUri"/>
    </p:load>
    <p:identity name="xsdschema"/>
    <p:sink/>
  
    <!-- load the error cleaning XSLT once rather than once per file -->
    <p:load name="cleanXSLT">
        <p:with-option name="href" select="$cleanXsltFilename"/>
    </p:load>
    <p:sink/>
  
    <!-- load the pre validation XSLT once, if specified 
      This can be used to test changes to data and then we can compare the validation report with and without the change 
    -->
    <p:choose>
      <p:when test="$preValidationXsltFilename != ''">
        <p:load>
          <p:with-option name="href" select="$preValidationXsltFilename"/>
        </p:load>
      </p:when>
      <p:otherwise>
        <p:identity>
          <p:input port="source">
            <p:inline><null/></p:inline>
          </p:input>
        </p:identity>
      </p:otherwise>
    </p:choose>
    <p:identity name="preValidationXslt"/>
  
    <p:variable name="logFilename" select="concat($logFolder,'/',replace(substring-before(xs:string(current-dateTime()),'.'),':',''),'.xml')"/>
    <cm:recursive-directory-list depth="-1" name="getList">
      <p:with-option name="path" select="$xml-input-folder"/>
    </cm:recursive-directory-list>
    
    <p:identity name="directoryList"/>
  <p:group>
  
    <p:variable name="totalFileCount" select="count(//*:file[ends-with(@name,'.xml')])"/>
    <cx:message>
      <p:with-option name="message" select="concat('Number of files to process is ',$totalFileCount)"/>
    </cx:message>
    <cx:message>
        <p:with-option name="message" select="concat('Processing ',$xml-input-folder,'/',/*/@relname)"/>
    </cx:message>
       
    <!-- Colin: Add relative paths to relname attribute so we can keep subfolders in output if we transform data -->
    <p:xslt>
       <p:input port="parameters"><p:empty/></p:input>
       <p:input port="stylesheet">
         <p:inline>
                <xsl:transform version="2.0">
                  <xsl:variable name="vBasefolder" select="(//*:directory)[1]/@*[local-name()='base']"/>
                  <xsl:variable name="vSubfolder" select="tokenize($vBasefolder,'/')[last()-1]"/>
                    <xsl:template match="/">
                      <xsl:apply-templates/>
                    </xsl:template>
                    <xsl:template match="*:file">
                          <xsl:copy>
                            <xsl:attribute name="relname">
                              <xsl:choose>
                                <xsl:when test="count(ancestor::*:directory) gt 1">
                                  <xsl:value-of select="concat(substring-after(ancestor::*:directory[1]/@*[local-name()='base'],$vBasefolder),@name)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                  <xsl:value-of select="@name"/>
                                </xsl:otherwise>
                              </xsl:choose>
                            </xsl:attribute>
                            <xsl:apply-templates select="*|@*|text()"/>
                          </xsl:copy>
                    </xsl:template>
                    <xsl:template match="*|@*|text()">
                          <xsl:copy>
                            <xsl:apply-templates select="*|@*|text()"/>
                          </xsl:copy>
                    </xsl:template>
                </xsl:transform>
            </p:inline>
       </p:input>
     </p:xslt>
    <p:identity name="xsltFileListOut"/>
  
    <p:filter select="//*:file[ends-with(@name,'.xml')]"/>
    <p:identity name="fileList"/>
    <p:group>  
        <p:for-each name="iterate" >
          <cx:message>
              <p:with-option name="message" select="concat('Processing ',$xml-input-folder,'/',/*/@relname)"/>
          </cx:message>
          <p:try>
            <p:group>
              <p:variable name="name" select="concat($xml-input-folder,'/', /*/@relname)"/>
              <!--<p:sink/>
              <p:identity>
                <p:input port="source">
                    <p:pipe port="result" step="xsdschema"/>
                </p:input>
              </p:identity>--> 
               <cm:validate-content>
                <p:input port="source">
                    <p:pipe port="result" step="xsdschema"/>
                </p:input>
                 <p:input port="preValidationstylesheet">
                    <p:pipe port="result" step="preValidationXslt"/>
                </p:input>
                <p:input port="cleanerstylesheet">
                    <p:pipe port="result" step="cleanXSLT"/>
                </p:input>
                 <p:with-option name="logInfoFilename" select="$logInfoFilename"/>
                 <p:with-option name="xml-input-folder" select="$xml-input-folder"/>
                 <p:with-option name="logFolder" select="$logFolder"/>
                 <p:with-option name="initialFolderName" select="$xml-input-folder"/> 
                 <p:with-option name="totalFileCount" select="$totalFileCount"/>
                 <p:with-option name="inputFileUri" select="$name"/>
               </cm:validate-content>
            </p:group>
            <p:catch>
               <cx:message>
                   <p:with-option name="message" select="concat('Failure processing ',$xml-input-folder,'/',/*/@relname)"/>
               </cx:message>
            </p:catch>
         </p:try>
        </p:for-each>
      <p:sink/>
      <p:group>
        <!-- Write a summary out with times and total files processed -->
        <p:store omit-xml-declaration="false" indent="true">
            <p:input port="source">
              <p:inline exclude-inline-prefixes="#all"><logInfo/></p:inline>
            </p:input>
            <p:with-option name="href" select="$logInfoFilename"/>
        </p:store>
        <p:load>
            <p:with-option name="href" select="$logInfoFilename"/>
        </p:load>
        <p:add-attribute match="/logInfo" attribute-name="xmlInputFolder">
          <p:with-option name="attribute-value" select="$xml-input-folder"/>
        </p:add-attribute>
        <p:add-attribute match="/logInfo" attribute-name="totalFileCount">
          <p:with-option name="attribute-value" select="$totalFileCount"/>
        </p:add-attribute>
        <p:add-attribute match="/logInfo" attribute-name="startTime">
          <p:with-option name="attribute-value" select="$startDateTime"/>
        </p:add-attribute>
        <p:add-attribute match="/logInfo" attribute-name="endTime">
          <p:with-option name="attribute-value" select="current-dateTime()"/>
        </p:add-attribute>
        <p:store omit-xml-declaration="false" indent="true">
            <p:with-option name="href" select="$logInfoFilename"/>
        </p:store>
     </p:group>
      </p:group>
  </p:group>
</p:declare-step>
