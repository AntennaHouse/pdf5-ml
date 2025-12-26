<?xml version='1.0' encoding="UTF-8" ?>
<!--
    ****************************************************************
    DITA to XSL-FO Stylesheet 
    Module: Reference elements stylesheet
    Copyright © 2009-2009 Antenna House, Inc. All rights reserved.
    Antenna House is a trademark of Antenna House, Inc.
    URL    : http://www.antennahouse.com/
    E-mail : info@antennahouse.com
    ****************************************************************
-->
<xsl:stylesheet version="3.0" 
 xmlns:fo="http://www.w3.org/1999/XSL/Format" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 exclude-result-prefixes="xs ahf"
>
    <!-- NOTE: reference/reference is implemented in dita2fo_topicelements.xsl as topic/title.
               reference/refbody is implemented in dita2fo_topicelements.xsl as topic/body.
               reference/refsyn is implemented in dita2fo_topicelements.xsl as topic/section. 
     -->
    
    <!-- 
     function:	properties template
     param:	    
     return:	fo:table
     note:		MODE_GET_STYLE is defined only for properties in this version.
     -->
    <xsl:template match="*[contains-token(@class, 'reference/properties')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsPropertyTable'"/>
    </xsl:template>    

    <xsl:template match="*[contains-token(@class, 'reference/properties')]" priority="2">
        <xsl:variable name="keyCol" select="ahf:getKeyCol(.)" as="xs:integer"/>
        <xsl:variable name="propertiesAttr" as="attribute()*">
            <xsl:call-template name="getAttributeSetWithLang"/>
        </xsl:variable>
        <fo:table>
            <xsl:copy-of select="$propertiesAttr"/>
            <xsl:copy-of select="ahf:getDisplayAtts(.,$propertiesAttr)"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:if test="exists(@relcolwidth)">
                <xsl:copy-of select="ahf:getAttributeSet('atsPropertyTableFixed')"/>
                <xsl:call-template name="processRelColWidth">
                    <xsl:with-param name="prmRelColWidth" select="string(@relcolwidth)"/>
                    <xsl:with-param name="prmTable" select="."/>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates select="*[contains-token(@class, 'reference/prophead')]">
                <xsl:with-param name="prmKeyCol" tunnel="yes" select="$keyCol"/>
            </xsl:apply-templates>
            <fo:table-body>
                <xsl:copy-of select="ahf:getAttributeSet('atsPropertyTableBody')"/>
                <xsl:apply-templates select="*[contains-token(@class, 'reference/property')]">
                    <xsl:with-param name="prmKeyCol" tunnel="yes" select="$keyCol"/>
                </xsl:apply-templates>
            </fo:table-body>
        </fo:table>
    </xsl:template>
    
    <!-- 
     function:	prophead template
     param:	    prmKeyCol
     return:	fo:table-header
     note:		prophead is optional.
                proptypehd, propvaluehd, propvaluehd are all optional.
                This stylesheet apply bold for prophead if properties/@keycol is not defined.
     -->
    <xsl:template match="*[contains-token(@class, 'reference/prophead')]" priority="2">
        <xsl:param name="prmKeyCol"   required="yes" tunnel="yes" as="xs:integer"/>
        
        <fo:table-header>
            <xsl:copy-of select="ahf:getAttributeSet('atsPropertyTableHeader')"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <fo:table-row>
                <xsl:copy-of select="ahf:getAttributeSet('atsPropertyTableRow')"/>
                <!-- proptypehd -->
                <xsl:if test="exists(*[contains-token(@class, 'reference/proptypehd')])">
                    <fo:table-cell>
                        <xsl:copy-of select="ahf:getAttributeSet('atsPropertyTableHeaderCell')"/>
                        <xsl:choose>
                            <xsl:when test="$prmKeyCol eq 1">
                                <xsl:copy-of select="ahf:getAttributeSet('atsPropertyTableKeyCol')"/>
                            </xsl:when>
                            <xsl:when test="$prmKeyCol ne 0">
                                <xsl:copy-of select="ahf:getAttributeSet('atsPropertyTableNoKeyCol')"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:apply-templates select="*[contains-token(@class, 'reference/proptypehd')]"/>
                    </fo:table-cell>
                </xsl:if>
                <!-- propvaluehd -->
                <xsl:if test="exists(*[contains-token(@class, 'reference/propvaluehd')])">
                    <fo:table-cell>
                        <xsl:copy-of select="ahf:getAttributeSet('atsPropertyTableHeaderCell')"/>
                        <xsl:choose>
                            <xsl:when test="$prmKeyCol eq 2">
                                <xsl:copy-of select="ahf:getAttributeSet('atsPropertyTableKeyCol')"/>
                            </xsl:when>
                            <xsl:when test="$prmKeyCol ne 0">
                                <xsl:copy-of select="ahf:getAttributeSet('atsPropertyTableNoKeyCol')"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:apply-templates select="*[contains-token(@class, 'reference/propvaluehd')]"/>
                    </fo:table-cell>
                </xsl:if>
                <!-- propvaluehd -->
                <xsl:if test="exists(*[contains-token(@class, 'reference/propdeschd')])">
                    <fo:table-cell>
                        <xsl:copy-of select="ahf:getAttributeSet('atsPropertyTableHeaderCell')"/>
                        <xsl:choose>
                            <xsl:when test="$prmKeyCol eq 3">
                                <xsl:copy-of select="ahf:getAttributeSet('atsPropertyTableKeyCol')"/>
                            </xsl:when>
                            <xsl:when test="$prmKeyCol ne 0">
                                <xsl:copy-of select="ahf:getAttributeSet('atsPropertyTableNoKeyCol')"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:apply-templates select="*[contains-token(@class, 'reference/propdeschd')]"/>
                    </fo:table-cell>
                </xsl:if>
            </fo:table-row>
        </fo:table-header>
    </xsl:template>
    
    <!-- 
     function:	proptypehd template
     param:	    
     return:	proptypehd contents (fo:block)
     note:		none
     -->
    <xsl:template match="*[contains-token(@class, 'reference/proptypehd')]" priority="2">
        <fo:block>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <!-- 
     function:	propvaluehd template
     param:	    
     return:	propvaluehd contents (fo:block)
     note:		none
     -->
    <xsl:template match="*[contains-token(@class, 'reference/propvaluehd')]" priority="2">
        <fo:block>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <!-- 
     function:	propdeschd template
     param:	    
     return:	propdeschd contents (fo:block)
     note:		none
     -->
    <xsl:template match="*[contains-token(@class, 'reference/propdeschd')]" priority="2">
        <fo:block>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <!-- 
     function:	property template
     param:	    prmKeyCol
     return:	fo:table-row
     note:		none
     -->
    <xsl:template match="*[contains-token(@class, 'reference/property')]" priority="2">
        <xsl:param name="prmKeyCol"   required="yes" tunnel="yes" as="xs:integer"/>
        
        <fo:table-row>
            <xsl:copy-of select="ahf:getAttributeSet('atsPropertyTableRow')"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <!-- proptype -->
            <xsl:if test="exists(*[contains-token(@class, 'reference/proptype')])">
                <fo:table-cell>
                    <xsl:copy-of select="ahf:getAttributeSet('atsPropertyTableBodyCell')"/>
                    <xsl:choose>
                        <xsl:when test="$prmKeyCol eq 1">
                            <xsl:copy-of select="ahf:getAttributeSet('atsPropertyTableKeyCol')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="ahf:getAttributeSet('atsPropertyTableNoKeyCol')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:apply-templates select="*[contains-token(@class, 'reference/proptype')]"/>
                </fo:table-cell>
            </xsl:if>
            <!-- propvalue -->
            <xsl:if test="exists(*[contains-token(@class, 'reference/propvalue')])">
                <fo:table-cell>
                    <xsl:copy-of select="ahf:getAttributeSet('atsPropertyTableBodyCell')"/>
                    <xsl:choose>
                        <xsl:when test="$prmKeyCol eq 2">
                            <xsl:copy-of select="ahf:getAttributeSet('atsPropertyTableKeyCol')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="ahf:getAttributeSet('atsPropertyTableNoKeyCol')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:apply-templates select="*[contains-token(@class, 'reference/propvalue')]"/>
                </fo:table-cell>
            </xsl:if>
            <!-- propdesc -->
            <xsl:if test="exists(*[contains-token(@class, 'reference/propdesc')])">
                <fo:table-cell>
                    <xsl:copy-of select="ahf:getAttributeSet('atsPropertyTableBodyCell')"/>
                    <xsl:choose>
                        <xsl:when test="$prmKeyCol eq 3">
                            <xsl:copy-of select="ahf:getAttributeSet('atsPropertyTableKeyCol')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="ahf:getAttributeSet('atsPropertyTableNoKeyCol')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:apply-templates select="*[contains-token(@class, 'reference/propdesc')]"/>
                </fo:table-cell>
            </xsl:if>
        </fo:table-row>
    </xsl:template>
    
    <!-- 
     function:	proptype template
     param:	    
     return:	proptype contents (fo:block)
     note:		none
     -->
    <xsl:template match="*[contains-token(@class, 'reference/proptype')]" priority="2">
        <fo:block>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <!-- 
     function:	propvalue template
     param:	    
     return:	propvalue contents (fo:block)
     note:		none
     -->
    <xsl:template match="*[contains-token(@class, 'reference/propvalue')]" priority="2">
        <fo:block>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <!-- 
     function:	propdesc template
     param:	    
     return:	propdesc contents (fo:block)
     note:		none
     -->
    <xsl:template match="*[contains-token(@class, 'reference/propdesc')]" priority="2">
        <fo:block>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

</xsl:stylesheet>