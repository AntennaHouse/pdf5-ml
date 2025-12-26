<?xml version='1.0' encoding="UTF-8" ?>
<!--
    ****************************************************************
    DITA to XSL-FO Stylesheet
    Module: Stylesheet parameter and global variables (2).
    Copyright © 2009-2009 Antenna House, Inc. All rights reserved.
    Antenna House is a trademark of Antenna House, Inc.
    URL    : http://www.antennahouse.com/
    E-mail : info@antennahouse.com
    ****************************************************************
-->
<xsl:stylesheet version="3.0" xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf">

    <!-- Paper size
         2015-04-23 t.makita
     -->
    <xsl:param name="PRM_PAPER_SIZE" required="no" as="xs:string" select="'Letter'"/>
    <xsl:variable name="pPaperSize" as="xs:string" select="$PRM_PAPER_SIZE"/>
    
    <xsl:param name="cPaperInfo" as="xs:string+">
        <xsl:call-template name="getVarValueAsStringSequence">
            <xsl:with-param name="prmVarName" select="'Paper_Info'"/>
            <xsl:with-param name="prmPaperSize" select="()"/>
        </xsl:call-template>
    </xsl:param>
    
    <xsl:variable name="paperIndex" as="xs:integer" >
        <xsl:variable name="tempPaperIndex" as="xs:integer?" select="index-of($cPaperInfo,$pPaperSize)[1]"/>
        <xsl:choose>
            <xsl:when test="empty($tempPaperIndex)">
                <xsl:call-template name="errorExit">
                    <xsl:with-param name="prmMes" select="ahf:replace($stMes1500,('%param','%sptval'),($pPaperSize,string-join($cPaperInfo[(position() mod 5) eq 1],',')))"/>
                </xsl:call-template>
                <xsl:sequence select="1"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$tempPaperIndex"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!-- paper related variables used here -->
    <xsl:variable name="pPaperWidth" as="xs:string" select="$cPaperInfo[$paperIndex + 1]"/>
    <xsl:variable name="pPaperHeight" as="xs:string" select="$cPaperInfo[$paperIndex + 2]"/>
    <xsl:variable name="pCropSizeH" as="xs:string" select="$cPaperInfo[$paperIndex + 3]"/>
    <xsl:variable name="pCropSizeV" as="xs:string" select="$cPaperInfo[$paperIndex + 4]"/>
    <xsl:variable name="pBleedSize" as="xs:string" select="ahf:getVarValue('Bleed_Size')"/>

</xsl:stylesheet>
