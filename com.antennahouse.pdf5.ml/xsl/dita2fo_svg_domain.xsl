<?xml version="1.0" encoding="UTF-8"?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet
Module: SVG domain templates
Copyright © 2009-2016 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="2.0" 
    xmlns:fo="http://www.w3.org/1999/XSL/Format" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    xmlns:svg="http://www.w3.org/2000/svg"
    exclude-result-prefixes="xs ahf"
    >

    <!-- 
     function:	svg-container template
     param:	    
     return:	fo:wrapper
     note:		svg-container is only a container of SVG itself or svgref
     -->
    <xsl:template match="*[contains(@class, ' svg-d/svg-container ')]" priority="2">
        <fo:wrapper>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:apply-templates/>
        </fo:wrapper>
    </xsl:template>
    
    <!-- 
     function:	SVG contained in svg-container template
     param:	    
     return:	fo:instream-foreign-object
     note:		SVG may be stored as only one child of svg-container.
                So ahf:getFoStyleAndProperty() is applied here.
     -->
    <xsl:template match="svg:svg">
        <fo:instream-foreign-object>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(parent::*[1])"/>
            <xsl:copy-of select="."/>
        </fo:instream-foreign-object>
    </xsl:template>

    <xsl:template match="svg:svg" mode="TEXT_ONLY"/>

    <!-- 
     function:	svgref template
     param:	    
     return:	fo:external-graphic
     note:		svg-ref may only exits as the child of svg-container.
                So ahf:getFoStyleAndProperty() is applied here.
     -->
    <xsl:template match="*[contains(@class, ' svg-d/svgref ')]" priority="2">
        <fo:external-graphic>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:attribute name="src" select="ahf:getImageUrl(.)"/>
            <xsl:attribute name="content-type" select="'content-type:xml/svg'"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(parent::*[1])"/>
        </fo:external-graphic>
    </xsl:template>
    
</xsl:stylesheet>