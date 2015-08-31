<?xml version="1.0" encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet
Module: Stylesheet constants.
Copyright © 2009-2009 Antenna House, Inc. All rights reserved.
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
>
    <!-- *************************************** 
            Constants
         ***************************************-->
    
    <!-- External Parameter yes/no value -->
    <xsl:variable name="cYes" select="'yes'" as="xs:string"/>
    <xsl:variable name="cNo" select="'no'" as="xs:string"/>
    
    <!-- Inner flag/attribute value: true/false -->
    <xsl:variable name="true" select="'true'" as="xs:string"/>
    <xsl:variable name="false" select="'false'" as="xs:string"/>
    
    <xsl:variable name="NaN" select="'NaN'" as="xs:string"/>
    <xsl:variable name="lf" select="'&#x0A;'" as="xs:string"/>
    <xsl:variable name="doubleApos" as="xs:string">
    	<xsl:text>''</xsl:text>
    </xsl:variable>
    
    <!-- units -->
    <xsl:variable name="cUnitPc" select="'pc'" as="xs:string"/>
    <xsl:variable name="cUnitPt" select="'pt'" as="xs:string"/>
    <xsl:variable name="cUnitPx" select="'px'" as="xs:string"/>
    <xsl:variable name="cUnitIn" select="'in'" as="xs:string"/>
    <xsl:variable name="cUnitCm" select="'cm'" as="xs:string"/>
    <xsl:variable name="cUnitMm" select="'mm'" as="xs:string"/>
    <xsl:variable name="cUnitEm" select="'em'" as="xs:string"/>

</xsl:stylesheet>
