<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata" version="3.0"
    exclude-result-prefixes="xs" >
    <xsl:output method="xml" indent="false"/>
    <!-- auto identity template -->
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:template match="ukm:DocumentCategory/@Value">
        <xsl:attribute name="Value" select="concat(.,'BROKEN')"/>
    </xsl:template>

</xsl:stylesheet>