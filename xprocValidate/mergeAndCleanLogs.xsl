<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsd="http://www.w3.org/2001/XMLSchema"
     xmlns:c="http://www.w3.org/ns/xproc-step"
    version="2.0" exclude-result-prefixes="xs c">
    
    <!-- merge log files (one per source XML) into one XML file
    IF the xml error file has not already gone through a cleaning process (e.g. dropping the particular id value of id not found to enable better reporting)
    then do that cleaning -->
    
    <xsl:param name="gpInputPath" select="'file:/C:/Users/colin/Documents/newco/TSO/TNA/xprocValidate/logs'" as="xs:string"/>
    
    <xsl:import href="cleanLog.xsl"/>
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="/">
        <xsl:message>Creating merged log</xsl:message>
        <xsl:variable name="vLogInfo" as="element()*">
            <xsl:for-each select="uri-collection(concat($gpInputPath,'?select=*.log;recurse=yes'))">
                <xsl:variable name="vDoc" select="document(.)" as="document-node()"/>
                <xsl:copy-of select="document(.)/logInfo"/>
            </xsl:for-each>
        </xsl:variable>
        <log>
            <!-- get list of URIS
                Note: we do not use collection as it loads all files into memory -->
            <xsl:for-each select="uri-collection(concat($gpInputPath,'?select=*.xml;recurse=yes'))">
                <xsl:variable name="vDoc" select="document(.)" as="document-node()"/>
                <xsl:apply-templates select="$vDoc/*">
                    <xsl:with-param name="pPos" select="position()"/>
                    <xsl:with-param name="pLogInfo" select="$vLogInfo"/>
                </xsl:apply-templates>
            </xsl:for-each>
        </log>
    </xsl:template>
    
    <xsl:template match="fileLog">
        <xsl:param name="pPos" as="xs:integer"/>
        <xsl:param name="pLogInfo" as="element()+"/>
        <xsl:if test="$pPos=1">
            <!-- there may be multiple runs being processed so need to cope with multiple info elements -->
            <xsl:attribute name="totalFileCount" select="sum($pLogInfo/@totalFileCount)"/>
            <xsl:for-each select="$pLogInfo">
                <xsl:variable name="vPos" select="position()" as="xs:integer"/>
                <xsl:for-each select="@*">
                    <xsl:attribute name="{concat(local-name(),'-',$vPos)}" select="."/>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>
    
</xsl:stylesheet>