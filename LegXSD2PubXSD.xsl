<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    version="2.0" exclude-result-prefixes="xs">
    
    <!-- XSLT to convert the legalisation namespace schema into
        a) a version that works in the TSO namespace; and/or
        b) a version without atom.xsd (for MSXML compliance but not suitable for web data which will contain atom metadata elements)
        
        Now we have global parameters to control this behaviour.
    -->
    
    <xsl:param name="gpInputPath" select="'file:/C:/Users/colin/unified-master-schema'" as="xs:string"/>
    <xsl:param name="gpOutputPath" select="concat($gpInputPath,'/../newMergedSchemaPubNS-Auto')" as="xs:string"/>
    <xsl:param name="gpConvertToTsoNS" select="'true'" as="xs:string"/>
    <xsl:param name="gpDropAtom" select="'true'" as="xs:string"/>
    
    <xsl:variable name="gvConvertToTsoNS" select="$gpConvertToTsoNS='true'" as="xs:boolean"/>
    <xsl:variable name="gvDropAtom" select="$gpDropAtom='true'" as="xs:boolean"/>
    
    <xsl:template match="/">
        <xsl:message>Converting schema: Publication Namespace is <xsl:value-of select="$gvConvertToTsoNS"/> Drop atom is <xsl:value-of select="$gvDropAtom"/></xsl:message>
        <!-- get list of URIS
            Note: we do not use collection as it loads all xsds into memory -->
<!--        <xsl:for-each select="uri-collection(concat($vInputPath,'/schema?select=*.xsd')),uri-collection(concat($vInputPath,'/schemaModules?select=*.xsd'))">-->
        <xsl:for-each select="uri-collection(concat($gpInputPath,'?select=*.xsd;recurse=yes')),uri-collection(concat($gpInputPath,'?select=*.xs;recurse=yes'))">
            <xsl:apply-templates select="document(.)/*" mode="xsd">
                <xsl:with-param name="pFileURI" select="."/>
            </xsl:apply-templates>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="/*" priority="+2" mode="xsd">
        <xsl:param name="pFileURI" as="xs:string"/>
        <xsl:variable name="vPathAfterBaseFolder" select="substring-after($pFileURI, $gpInputPath)" as="xs:string"/>
        <xsl:variable name="vOutFilename" select="concat($gpOutputPath,$vPathAfterBaseFolder)" as="xs:string"/>
        <xsl:message>input = <xsl:value-of select="$pFileURI"/> output = <xsl:value-of select="$vOutFilename"/></xsl:message>
        <!-- process the file -->
        <xsl:result-document encoding="UTF-8" href="{$vOutFilename}">
<xsl:text>
</xsl:text>
            <xsl:apply-templates select="."/>
        </xsl:result-document>
        <!-- auto generate old file name -->
        <xsl:if test="(@id='SchemaENbase') and ends-with($vOutFilename,'/en.xsd')">
            <xsl:message>input = <xsl:value-of select="$pFileURI"/> output = <xsl:value-of select="replace($vOutFilename,'/en.xsd','/schemaENbase-v0-1.xsd')"/></xsl:message>
            <xsl:result-document encoding="UTF-8" href="{replace($vOutFilename,'/en.xsd','/schemaENbase-v0-1.xsd')}">
<xsl:text>
</xsl:text>
                <xsl:apply-templates select="."/>
            </xsl:result-document>
        </xsl:if>
    </xsl:template>
    
    <!-- swap schema element default and target namespaces only where required -->
    <xsl:template match="xsd:schema[(@targetNamespace='http://www.legislation.gov.uk/namespaces/legislation') and $gvConvertToTsoNS]" priority="+1">
        <xsd:schema targetNamespace="http://www.tso.co.uk/assets/namespace/legislation"
	       xmlns:ukm="http://www.tso.co.uk/assets/namespace/metadata" xmlns:leg="http://www.tso.co.uk/assets/namespace/legislation"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"  xmlns:atom="http://www.w3.org/2005/Atom"
	xmlns="http://www.tso.co.uk/assets/namespace/legislation" xmlns:math="http://www.w3.org/1998/Math/MathML"  xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:ukl="http://www.tso.co.uk/assets/namespace/legislation" xmlns:dcq="http://purl.org/dc/terms/"  xmlns:dct="http://purl.org/dc/terms/" xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:err="http://www.tso.co.uk/assets/namespace/error" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:errl="http://www.legislation.gov.uk/namespaces/error"
	elementFormDefault="qualified" attributeFormDefault="unqualified" >
            <xsl:apply-templates select="@version|@id"/>
            <xsl:apply-templates/>
        </xsd:schema>
    </xsl:template>
    
    <xsl:template match="xsd:schema[(@targetNamespace='http://www.legislation.gov.uk/namespaces/metadata') and $gvConvertToTsoNS]" priority="+1">
        <xsd:schema targetNamespace="http://www.tso.co.uk/assets/namespace/metadata"
	       xmlns:ukm="http://www.tso.co.uk/assets/namespace/metadata" xmlns:leg="http://www.tso.co.uk/assets/namespace/legislation"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"  xmlns:atom="http://www.w3.org/2005/Atom"
	xmlns="http://www.tso.co.uk/assets/namespace/metadata" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:ukl="http://www.tso.co.uk/assets/namespace/legislation" xmlns:dcq="http://purl.org/dc/terms/"  xmlns:dct="http://purl.org/dc/terms/" xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:err="http://www.tso.co.uk/assets/namespace/error" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:errl="http://www.legislation.gov.uk/namespaces/error"
	elementFormDefault="qualified" attributeFormDefault="unqualified" >
            <xsl:apply-templates select="@version|@id"/>
            <xsl:apply-templates/>
        </xsd:schema>
    </xsl:template>
        
    <!-- error should still be in TSO namespace until data is changed? see #161880322  -->
    <xsl:template match="xsd:schema[(@targetNamespace='http://www.legislation.gov.uk/namespaces/error') and (@id='ukGovErrors') and $gvConvertToTsoNS]" priority="+1">
        <xsd:schema  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    targetNamespace="http://www.legislation.gov.uk/namespaces/error"
    xmlns="http://www.legislation.gov.uk/namespaces/error" xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns:errl="http://www.legislation.gov.uk/namespaces/error"
    elementFormDefault="qualified"  attributeFormDefault="unqualified" >
            <xsl:apply-templates select="@version|@id"/>
            <xsl:apply-templates/>
        </xsd:schema>
    </xsl:template>
    
    <xsl:template match="xsd:schema[(@targetNamespace='http://www.tso.co.uk/assets/namespace/error') and $gvConvertToTsoNS]" priority="+1">
        <xsd:schema  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	targetNamespace="http://www.tso.co.uk/assets/namespace/error"
	xmlns="http://www.tso.co.uk/assets/namespace/error" xmlns:atom="http://www.w3.org/2005/Atom"
	xmlns:err="http://www.tso.co.uk/assets/namespace/error" elementFormDefault="qualified">
            <xsl:apply-templates select="@version|@id"/>
            <xsl:apply-templates/>
        </xsd:schema>
    </xsl:template>
    
    <xsl:template match="xsd:schema[(@targetNamespace='http://www.legislation.gov.uk/namespaces/error') and not(@id='ukGovErrors') and $gvConvertToTsoNS]" priority="+1">
        <xsd:schema  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    targetNamespace="http://www.tso.co.uk/assets/namespace/error" xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns="http://www.tso.co.uk/assets/namespace/error"
    xmlns:errl="http://www.tso.co.uk/assets/namespace/error"
    elementFormDefault="qualified"  attributeFormDefault="unqualified" >
            <xsl:apply-templates select="@version|@id"/>
            <xsl:apply-templates/>
        </xsd:schema>
    </xsl:template>
    
    <xsl:template match="xsd:schema[(@targetNamespace='http://www.w3.org/1999/xhtml') and $gvConvertToTsoNS]" priority="+1">
        <xsd:schema targetNamespace="http://www.w3.org/1999/xhtml"
	       xmlns:ukm="http://www.tso.co.uk/assets/namespace/metadata"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"  xmlns:atom="http://www.w3.org/2005/Atom"
	xmlns="http://www.w3.org/1999/xhtml" xmlns:leg="http://www.tso.co.uk/assets/namespace/legislation"
	xmlns:ukl="http://www.tso.co.uk/assets/namespace/legislation" xmlns:dcq="http://purl.org/dc/terms/"  xmlns:dct="http://purl.org/dc/terms/" xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:err="http://www.tso.co.uk/assets/namespace/error" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:errl="http://www.legislation.gov.uk/namespaces/error"
	elementFormDefault="qualified" attributeFormDefault="unqualified" >
            <xsl:apply-templates select="@version|@id"/>
            <xsl:apply-templates/>
        </xsd:schema>
    </xsl:template>
    
    <!-- Bizarrely XMetaL (v12 for example) errors with "The schema document does not contain a schema element"
         IF the schema has multiple ns preix deinitions for schema
         <xsd:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsd="http://www.w3.org/2001/XMLSchema"
         That should not be an error but the matches below are in place to cope with it
    -->
        
    <xsl:template match="xsd:schema[@targetNamespace='http://purl.org/dc/terms/']" priority="+1">
        <xsd:schema
           xmlns:dc="http://purl.org/dc/elements/1.1/"
           xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:atom="http://www.w3.org/2005/Atom"
           targetNamespace="http://purl.org/dc/terms/"
           xmlns="http://purl.org/dc/terms/"
           elementFormDefault="qualified"
           attributeFormDefault="unqualified">
            <xsl:apply-templates select="@version|@id"/>
            <xsl:apply-templates/>
        </xsd:schema>
    </xsl:template>
    
    <xsl:template match="xsd:schema[@targetNamespace='http://purl.org/dc/elements/1.1/']" priority="+1">
        <xsd:schema xmlns="http://purl.org/dc/elements/1.1/" targetNamespace="http://purl.org/dc/elements/1.1/" xmlns:atom="http://www.w3.org/2005/Atom" elementFormDefault="qualified" attributeFormDefault="unqualified">
            <xsl:apply-templates select="@version|@id"/>
            <xsl:apply-templates/>
        </xsd:schema>
    </xsl:template>
    
    <xsl:template match="xsd:schema[@targetNamespace='http://purl.org/dc/dcmitype/']" priority="+1">
        <xsd:schema  xmlns="http://purl.org/dc/dcmitype/"  xmlns:atom="http://www.w3.org/2005/Atom" targetNamespace="http://purl.org/dc/dcmitype/" elementFormDefault="qualified" attributeFormDefault="unqualified">
            <xsl:apply-templates select="@version|@id"/>
            <xsl:apply-templates/>
        </xsd:schema>
    </xsl:template>
    
    <xsl:template match="xsd:schema[@targetNamespace='http://www.w3.org/1998/Math/MathML']" priority="+1">
        <xsd:schema  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	targetNamespace="http://www.w3.org/1998/Math/MathML" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns="http://www.w3.org/1998/Math/MathML" xmlns:atom="http://www.w3.org/2005/Atom" elementFormDefault="qualified">
            <xsl:apply-templates select="@version|@id"/>
            <xsl:apply-templates/>
        </xsd:schema>
    </xsl:template>
    
    <xsl:template match="xsd:schema[@targetNamespace='http://www.w3.org/1999/xlink']" priority="+1">
        <xsd:schema  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	targetNamespace="http://www.w3.org/1999/xlink" xmlns:atom="http://www.w3.org/2005/Atom"
	xmlns="http://www.w3.org/1999/xlink" elementFormDefault="qualified">
            <xsl:apply-templates select="@version|@id"/>
            <xsl:apply-templates/>
        </xsd:schema>
    </xsl:template>
    
    <xsl:template match="xsd:schema[@targetNamespace='http://www.w3.org/1999/XSL/Format']" priority="+1">
        <xsd:schema  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	targetNamespace="http://www.w3.org/1999/XSL/Format" xmlns:atom="http://www.w3.org/2005/Atom"
	xmlns="http://www.w3.org/1999/XSL/Format" elementFormDefault="qualified" attributeFormDefault="qualified">
            <xsl:apply-templates select="@version|@id"/>
            <xsl:apply-templates/>
        </xsd:schema>
    </xsl:template>

    <xsl:template match="xsd:schema[(@targetNamespace='http://www.w3.org/2005/Atom') and not($gvDropAtom)]" priority="+1">
        <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsd="http://www.w3.org/2001/XMLSchema" elementFormDefault="qualified"
	targetNamespace="http://www.w3.org/2005/Atom" xmlns:atom="http://www.w3.org/2005/Atom"
	xmlns:xhtml="http://www.w3.org/1999/xhtml">
            <xsl:apply-templates select="@version|@id"/>
            <xsl:apply-templates/>
        </xs:schema>
    </xsl:template>
    
    <!-- swap imports where required -->
    <xsl:template match="@namespace[(. = 'http://www.legislation.gov.uk/namespaces/legislation') and $gvConvertToTsoNS]">
        <xsl:attribute name="namespace" select="'http://www.tso.co.uk/assets/namespace/legislation'"/>
    </xsl:template>
    
    <xsl:template match="@namespace[(. = 'http://www.legislation.gov.uk/namespaces/metadata') and $gvConvertToTsoNS]">
        <xsl:attribute name="namespace" select="'http://www.tso.co.uk/assets/namespace/metadata'"/>
    </xsl:template>
    
    <!-- drop the import for atom as not needed for publication and causes error in MSXML which is used in Pub pipeline -->
    <xsl:template match="xsd:import[(@namespace = 'http://www.w3.org/2005/Atom') and $gvDropAtom]" priority="+1"/>
    <xsl:template match="xsd:element[(@ref = 'atom:link') and $gvDropAtom]" priority="+1"/>
    
    <xsl:template match="xsd:*[$gvConvertToTsoNS]">
        <xsl:element name="xsd:{local-name()}"  inherit-namespaces="no">
            <xsl:apply-templates select="*|@*|processing-instruction()|text()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="@base[$gvConvertToTsoNS]|@type[$gvConvertToTsoNS]">
        <xsl:attribute name="{name()}">
            <xsl:choose>
                <xsl:when test="contains(.,'xs:')">
                    <xsl:value-of select="concat('xsd:',substring-after(.,':'))"/>
                </xsl:when>
                <xsl:when test="local-name(.)='type' and . ='anyURI'">
                    <xsl:text>xsd:anyURI</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@memberTypes[contains(concat(' ',.),' xs:') and $gvConvertToTsoNS]">
        <xsl:attribute name="memberTypes">
            <xsl:variable name="vMembers" select="tokenize(normalize-space(.),' ')" as="xs:string*"/>
            <xsl:for-each select="$vMembers">
                <xsl:choose>
                    <xsl:when test="starts-with(.,'xs:')">
                        <xsl:text>xsd:</xsl:text>
                        <xsl:value-of select="substring-after(.,'xs:')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="not(position()=last())">
                    <xsl:text> </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:attribute>
    </xsl:template>
    
    <!-- pass through everything else 
    CM: added comments which were missing 25/02/20-->
    <xsl:template match="*|@*|processing-instruction()|text()|comment()" priority="-1">
        <xsl:copy>
            <xsl:apply-templates select="*|@*|processing-instruction()|text()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>