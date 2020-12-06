<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output encoding="UTF-8" indent="yes" method="xml"/>
    
    <!-- support modes are 'groupErrors' that outputs group of the same errors type across files
    mode 'fileErrors' will produce a list of files sorted by number of errors 
    otherwise it does both modes -->
    <xsl:param name="mode" as="xs:string" select="''"/>
    
    <!--<xsl:param name="filterText" as="xs:string?">
        <xsl:text>Invalid content was found starting with element 'CommentaryRef'.</xsl:text>
    </xsl:param>-->
    
    <xsl:param name="filterText" as="xs:string?">
        <xsl:text></xsl:text>
    </xsl:param>
    
    <xsl:variable name="gvFilterText" select="normalize-space($filterText)"/>
    <xsl:variable name="gvTotalFiles" select="/log/@totalFileCount"/>
    
    <xsl:template match="/log">
        <report>
            <xsl:copy-of select="@* except @totalFileCount"/>
            <xsl:attribute name="totalFiles" select="$gvTotalFiles"/>
            <xsl:attribute name="totalInvalidFiles" select="count(distinct-values(error/@xmlFilename))"/>
            <!-- add in duration calculation -->
            <xsl:call-template name="processErrors"/>
        </report>
    </xsl:template>
    
    <xsl:template name="processErrors">
        <xsl:choose>
            <xsl:when test="$mode='groupErrors'">
                <xsl:call-template name="groupErrors"/>
            </xsl:when>
            <xsl:when test="$mode='fileErrors'">
                <xsl:call-template name="fileErrors"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="groupErrors"/>
                <xsl:call-template name="fileErrors"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="groupErrors">
        <xsl:variable name="vGroupErrors" as="element()*">
           <xsl:for-each-group select="error/cleanedText[if ($gvFilterText) then contains(.,$gvFilterText) else true()]" group-by="." >
               <xsl:sort select="count(current-group())" order="descending"/>
               <error>
                   <xsl:copy-of select="@*"/>
                   <xsl:attribute name="count" select="count(current-group())"/>
                   <xsl:value-of select="."/>
               </error>
           </xsl:for-each-group>
        </xsl:variable>
       <errorsByErrorType differentErrors="{count($vGroupErrors)}" allErrors="{sum($vGroupErrors/@count)}">
           <xsl:copy-of select="$vGroupErrors"/>
       </errorsByErrorType>
    </xsl:template>
    
    <xsl:template name="fileErrors">
        <xsl:variable name="vGroupErrors" as="element()*">
           <xsl:for-each-group select="error[if ($gvFilterText) then contains(cleanedText,$gvFilterText) else true()]/@xmlFilename" group-by="." >
               <xsl:sort select="count(current-group())" order="descending"/>
               <error>
                   <xsl:attribute name="count" select="count(current-group())"/>
                   <xsl:value-of select="."/>
               </error> 
           </xsl:for-each-group>
        </xsl:variable>
       <errorsByFile filesWithErrors="{count($vGroupErrors)}" allErrors="{sum($vGroupErrors/@count)}"
           totalFilesProcessed="{$gvTotalFiles}" percentageValidFiles="{round((($gvTotalFiles - count($vGroupErrors)) div $gvTotalFiles) * 100)}%" >
           <xsl:copy-of select="$vGroupErrors"/>
       </errorsByFile>
    </xsl:template>
</xsl:stylesheet>