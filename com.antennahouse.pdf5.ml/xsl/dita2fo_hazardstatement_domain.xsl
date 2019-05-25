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
    <xsl:template match="*[contains(@class, ' hazard-d/hazardstatement ')]" priority="2">
        <fo:table>
            <xsl:copy-of select="ahf:getAttributeSet('atsHazardStatementTable')"/>
            <fo:table-column column-number="1">
                <xsl:copy-of select="ahf:getAttributeSet('atsHazardSymbolColumn')"/>
            </fo:table-column>
            <fo:table-column column-number="2">
                <xsl:copy-of select="ahf:getAttributeSet('atsHazardStatementDesc')"/>
            </fo:table-column>
            <fo:table-header>
                <fo:table-row>
                    <xsl:copy-of select="ahf:getAttributeSet('atsHazardStatementTitleRow')"/>
                    <fo:table-cell>
                        <xsl:copy-of select="ahf:getAttributeSet('atsHazardStatementTitleCell')"/>
                        <fo:block>
                            <xsl:copy-of select="ahf:getAttributeSet('atsHazardStatementTitleBlock')"/>
                            <fo:inline>
                                <fo:external-graphic>
                                    <xsl:copy-of select="ahf:getAttributeSet('atsHazardStatementIconImage')"/>
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
            </fo:table-header>
            <fo:table-body>
                <xsl:variable name="hazardSymbols" select="*[contains(@class,' hazard-d/hazardsymbol ')]" as="element()*"/>
                <xsl:variable name="hazardMessagePanel" select="*[contains(@class,' hazard-d/messagepanel ')]" as="element()*"/>
                <!-- Contens of hazardstatement -->
                <xsl:for-each select="$hazardMessagePanel">
                    <fo:table-row>
                        <!-- hazardsymbol -->
                        <fo:table-cell>
                            <xsl:copy-of select="ahf:getAttributeSet('atsHazardSymbolCell')"/>
                            <xsl:variable name="hpos" select="position()" as="xs:integer"/>
                            <xsl:apply-templates select="$hazardSymbols[$hpos]"/>
                        </fo:table-cell>
                        <!-- messagepanel -->
                        <fo:table-cell>
                            <xsl:copy-of select="ahf:getAttributeSet('atsMessagePanelCell')"/>
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
                    <fo:block start-indent="0mm">
                        <xsl:choose>
                            <xsl:when test="(string(@placement) eq 'break') and empty(string(@scale))">
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
                    <!-- Image processing -->
                    <xsl:call-template name="ahf:processImage">
                        <xsl:with-param name="prmImage" select="."/>
                    </xsl:call-template>
                </fo:block>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>