<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet
Module: Stylesheet parameter and global variables.
Copyright © 2009-2009 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="2.0" xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf">

    <!-- Map directory
         2012-11-11 t.makita
     -->
    <xsl:param name="PRM_MAP_DIR_URL" required="yes" as="xs:string"/>
    <xsl:variable name="pMapDirUrl" as="xs:string" select="$PRM_MAP_DIR_URL"/>
    
    <!-- FO property name now defined as parameter!
         2019-12-21 t.makita
     -->
    <xsl:param name="PRM_FO_PROP_NAME" required="no" as="xs:string" select="'fo:prop'"/>
    <xsl:variable name="pFoPropName" as="xs:string" select="$PRM_FO_PROP_NAME"/>

    <xsl:param name="PRM_FO_STYLE_NAME" required="no" as="xs:string" select="'fo:style'"/>
    <xsl:variable name="pFoStyleName" as="xs:string" select="$PRM_FO_STYLE_NAME"/>
    
    <!-- Output draft-comment -->
    <xsl:param name="PRM_OUTPUT_DRAFT_COMMENT" required="no" as="xs:string" select="$cNo"/>
    <xsl:variable name="pOutputDraftComment" select="boolean($PRM_OUTPUT_DRAFT_COMMENT eq $cYes)"
        as="xs:boolean"/>
    
    <!-- Output required-cleanup -->
    <xsl:param name="PRM_OUTPUT_REQUIRED_CLEANUP" required="no" as="xs:string" select="$cNo"/>
    <xsl:variable name="pOutputRequiredCleanup" select="boolean($PRM_OUTPUT_REQUIRED_CLEANUP eq $cYes)"
        as="xs:boolean"/>

</xsl:stylesheet>
