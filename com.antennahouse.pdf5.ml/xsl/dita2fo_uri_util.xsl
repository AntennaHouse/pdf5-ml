<?xml version="1.0" encoding="UTF-8" ?>
<!--
    **************************************************************
    DITA to XSL-FO Stylesheet
    URI Utility Templates
    **************************************************************
    File Name : dita2fo_uri_util.xsl
    **************************************************************
    Copyright © 2009 2026 Antenna House, Inc. All rights reserved.
    Antenna House is a trademark of Antenna House, Inc.
    URL : http://www.antennahouse.com/
    **************************************************************
-->

<xsl:stylesheet version="3.0" 
    xmlns:fo="http://www.w3.org/1999/XSL/Format" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf" >

    <!-- 
     function:  Judge absolute URI
     param:     prmUri
     return:	xs:boolean
     note:      If $prmUri starts with protocol defined in RFC3986, it's absolute URI.
                Also remove Windows local drive path such as 'C:\'. 
     -->
    <xsl:function name="ahf:isAbsoluteUri" as="xs:boolean">
        <xsl:param name="prmUri" as="xs:string"/>
        <xsl:variable name="hasScheme" as="xs:boolean" 
            select="matches($prmUri, '^[a-zA-Z][a-zA-Z0-9+.\-]*:')
            and not(matches($prmUri, '^[a-zA-Z]:[/\\]'))"/>
        <xsl:sequence select="$hasScheme"/>
    </xsl:function>

</xsl:stylesheet>