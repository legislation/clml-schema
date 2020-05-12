<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" xmlns:c="http://www.w3.org/ns/xproc-step"
    version="2.0">
    <xsl:param name="pInputFilename" as="xs:string"/>
    <xsl:param name="pIsValid" as="xs:string"/>
    
    <xsl:template match="/">
        <xsl:element name="file">
            <xsl:attribute name="name" select="$pInputFilename"/>
            <xsl:if test="$pIsValid='no'">
                <xsl:apply-templates select="c:errors/c:error"/>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    
    <!-- we seem to get duplicate errors for same result so try to drop them -->
    <xsl:template match="c:error">
        <xsl:variable name="vLine" select="@line" as="xs:string?"/>
        <xsl:variable name="vColumn" select="@column" as="xs:string?"/>
        <xsl:variable name="vText" select="." as="xs:string?"/>
        <xsl:if test="not(preceding-sibling::c:error[(@line=$vLine) and (@column=$vColumn) and (.=$vText)])">
            <xsl:element name="error">
                <xsl:copy-of select="@*"/>
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>