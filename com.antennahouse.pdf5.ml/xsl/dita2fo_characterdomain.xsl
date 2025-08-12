<?xml version="1.0" encoding="UTF-8"?>
<!--
    ****************************************************************
    DITA to XSL-FO Stylesheet
    Module: Character domain elements stylesheet
    Copyright © 2009-2014 Antenna House, Inc. All rights reserved.
    Antenna House is a trademark of Antenna House, Inc.
    URL    : http://www.antennahouse.com/
    E-mail : info@antennahouse.com
    ****************************************************************
-->
<xsl:stylesheet version="3.0" 
    xmlns:fo="http://www.w3.org/1999/XSL/Format" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf"
>

    <!-- 
        function:	cm (check mark) template
        param:	    none
        return:	    fo:inline
        note:		cm is empty element.
                    There is no needs to make mode="MODE_GET_STYLE" template.
    -->
    <xsl:template match="*[contains(@class, ' ch-d/cm ')]" priority="2">
        <xsl:variable name="check" as="element()" select="." />
        <xsl:choose>
            <xsl:when test="string($check/@value) eq 'yes'">
                <fo:inline>
                    <xsl:call-template name="getAttributeSetWithLang">
                        <xsl:with-param name="prmAttrSetName" select="'atsCmYes'"/>
                    </xsl:call-template>
                    <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
                    <xsl:call-template name="getVarValueWithLang">
                        <xsl:with-param name="prmVarName" select="'cCheckYes'"/>
                    </xsl:call-template>
                </fo:inline>
            </xsl:when>
            <xsl:when test="string($check/@value) eq 'no'">
                <fo:inline>
                    <xsl:call-template name="getAttributeSetWithLang">
                        <xsl:with-param name="prmAttrSetName" select="'atsCmNo'"/>
                    </xsl:call-template>
                    <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
                    <xsl:call-template name="getVarValueWithLang">
                        <xsl:with-param name="prmVarName" select="'cCheckNo'"/>
                    </xsl:call-template>
                </fo:inline>
            </xsl:when>
            <xsl:when test="string($check/@value) eq 'dc'">
                <fo:inline>
                    <xsl:call-template name="getAttributeSetWithLang">
                        <xsl:with-param name="prmAttrSetName" select="'atsCmDc'"/>
                    </xsl:call-template>
                    <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
                    <xsl:call-template name="getVarValueWithLang">
                        <xsl:with-param name="prmVarName" select="'cCheckDc'"/>
                    </xsl:call-template>
                </fo:inline>
            </xsl:when>
            <xsl:otherwise>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    

    <!-- 
        function:	br template
        param:	    none
        return:	    fo:block
        note:		none
    -->
    <xsl:template match="*[contains(@class, ' ch-d/br ')]" priority="2">
        <xsl:variable name="br" as="element()" select="." />
        <xsl:choose>
            <xsl:when test="exists($br/preceding-sibling::node()[1][contains(@class,' ch-d/br ')])">
                <!-- Continiuous br -->
                <fo:block>
                    <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
                    <xsl:text>&#xA0;</xsl:text>
                </fo:block>
            </xsl:when>
            <xsl:otherwise>
                <!-- Single br -->
                <fo:block>
                    <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
                </fo:block>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>