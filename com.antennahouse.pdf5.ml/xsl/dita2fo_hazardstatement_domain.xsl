<!--
****************************************************************
DITA to XSL-FO Stylesheet 
Module: Hazard Statement Domain elements stylesheet
Copyright © 2009-2019 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="2.0" 
    xmlns:fo="http://www.w3.org/1999/XSL/Format" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf"
    >
    
    <!-- 
     function:  hazardstatement template
     param:	    
     return:    fo:table
     note:      Hazardstatement is specialized from note
                Only @type="caution/warning/danger" are supported.
     -->
    <xsl:template match="*[contains(@class, ' hazard-d/hazardstatement ')]" priority="4">
        <fo:table table-layout="fixed">
            <xsl:copy-of select="ahf:getAttributeSet('atshazardstatementOuterBlock')"/>
            <fo:table-column column-number="1">
                <xsl:copy-of select="ahf:getAttributeSet('atsHazardsymbolColumn')"/>
            </fo:table-column>
            <fo:table-column column-number="2"/>
            <fo:table-body>
                <fo:table-row>
                    <xsl:copy-of select="ahf:getAttributeSet('atsHazardstatementTitleRow')"/>
                    <fo:table-cell>
                        <xsl:copy-of select="ahf:getAttributeSet('atsHazardstatementTitleCell')"/>
                        <fo:block text-align="center">
                            <xsl:copy-of select="ahf:getAttributeSet('atsWarningTitleBlock')"/>
                            <fo:inline>
                                <fo:external-graphic>
                                    <xsl:copy-of select="ahf:getAttributeSet('atsNoteCautionIconImage')"/>
                                </fo:external-graphic>
                                <xsl:choose>
                                    <xsl:when test="@type eq 'danger'">
                                        <xsl:call-template name="getVarValueWithLangAsText">
                                            <xsl:with-param name="prmVarName" select="'Note_Danger'"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:when test="@type eq 'caution'">
                                        <xsl:call-template name="getVarValueWithLangAsText">
                                            <xsl:with-param name="prmVarName" select="'Note_Caution'"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:when test="@type eq 'warning'">
                                        <xsl:call-template name="getVarValueWithLangAsText">
                                            <xsl:with-param name="prmVarName" select="'Note_Warning'"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="getVarValueWithLangAsText">
                                            <xsl:with-param name="prmVarName" select="'Note_Warning'"/>
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </fo:inline>
                        </fo:block>
                    </fo:table-cell>
                </fo:table-row>
                <xsl:variable name="hsymbols" select="*[contains(@class,' hazard-d/hazardsymbol ')]" as="node()*"/>
                <xsl:variable name="hmespanel" select="*[contains(@class,' hazard-d/messagepanel ')]" as="node()*"/>
                <!-- Contens of hazardstatement -->
                <xsl:for-each select="$hmespanel">
                    <fo:table-row text-align="justify">
                        <!-- hazardsymbol -->
                        <fo:table-cell>
                            <xsl:copy-of select="ahf:getAttributeSet('atsHazardsymbolCell')"/>
                            <xsl:variable name="hpos" select="position()" as="xs:integer"/>
                            <xsl:choose>
                                <xsl:when test="$hsymbols[$hpos]">
                                    <xsl:apply-templates select="$hsymbols[$hpos]"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="$hsymbols[1]"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </fo:table-cell>
                        <!-- messagepanel -->
                        <fo:table-cell>
                            <xsl:copy-of select="ahf:getAttributeSet('atsMessagepanelCell')"/>
                            <xsl:apply-templates select="."/>
                        </fo:table-cell>
                    </fo:table-row>
                </xsl:for-each>
            </fo:table-body>
        </fo:table>
    </xsl:template>

    <!-- 
     function:  hazardsymbol template
     param:	    
     return:    fo:external-graphic with fo:block/fo:block-container
     note:	
     -->
    <xsl:template match="*[contains(@class, ' hazard-d/hazardsymbol ')]" priority="2">
        <xsl:choose>
            <xsl:when test="$pAutoScaleDownToFit">
                <fo:block-container>
                    <xsl:if test="string(@span) eq 'all'">
                        <xsl:copy-of select="ahf:getAttributeSet('atsImageBlockSpan')"/>
                    </xsl:if>
                    <fo:block start-indent="0mm">
                        <xsl:choose>
                            <xsl:when test="@placement eq  'break' and not(string(@scale))">
                                <xsl:copy-of select="ahf:getAttributeSet('atsImageAutoScallDownToFitBlock')"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:copy-of select="ahf:getImageBlockAttr(.)"/>
                        <!-- Image processing -->
                        <xsl:call-template name="ahf:processImage">
                            <xsl:with-param name="prmImage" select="."/>
                        </xsl:call-template>
                    </fo:block>
                </fo:block-container>                    
            </xsl:when>
            <xsl:otherwise>
                <fo:block>
                    <xsl:copy-of select="ahf:getImageBlockAttr(.)"/>
                    <xsl:if test="string(@span) eq 'all'">
                        <xsl:copy-of select="ahf:getAttributeSet('atsImageBlockSpan')"/>
                    </xsl:if>
                    <!-- Image processing -->
                    <xsl:call-template name="ahf:processImage">
                        <xsl:with-param name="prmImage" select="."/>
                    </xsl:call-template>
                </fo:block>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>