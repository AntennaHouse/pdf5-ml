<?xml version="1.0" encoding="UTF-8" ?>
<!--
    **************************************************************
    DITA to XSL-FO Stylesheet
    DITA-OT Utility Templates
    **************************************************************
    File Name : dita2fo_ot_util.xsl
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
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:xlink="http://www.w3.org/1999/xlink"
 	xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf" >

    <!--
    ===============================================
     Utility Templates For DITA-OT or ANT
    ===============================================
    -->

    <!--
        function:   DITA-OT parameter value
        param:      prmBool
        note:       Return true() if $prmBool eq 'true'
    -->
    <xsl:function name="ahf:isDitaotTrue" as="xs:boolean">
        <xsl:param name="prmBool" as="xs:string"/>
        <xsl:sequence select="$prmBool eq 'true'"/>
    </xsl:function>
    
    <!--
        function:   ANT property value
        param:      prmBool
        note:       Return true() if $prmBool = ('true','yes')
    -->
    <xsl:function name="ahf:isAntTrue" as="xs:boolean">
        <xsl:param name="prmBool" as="xs:string"/>
        <xsl:sequence select="$prmBool = ('true','yes')"/>
    </xsl:function>
    
    <!-- end of stylesheet -->
</xsl:stylesheet>
