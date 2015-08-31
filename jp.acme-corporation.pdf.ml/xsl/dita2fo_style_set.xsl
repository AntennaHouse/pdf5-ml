<?xml version="1.0" encoding="UTF-8" ?>
<!--
**************************************************************
DITA to XSL-FO Stylesheet
Read attributeset,variable and instream-object from external
style definition file into temporary tree.
**************************************************************
File Name : dita2fo_styleset.xsl
**************************************************************
Copyright © 2009-2015 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.co.jp/
**************************************************************
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    xmlns:svg="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:l="http://www.antennahouse.com/names/XSLT/Document/Layout"
    exclude-result-prefixes="xs ahf">
    
    <!-- Plug-in URI: upper hierarchy of this stylesheet.
         Change it to this plug-in folder layer.
     -->
    <xsl:variable name="basePluginUri" as="xs:string" select="string(resolve-uri('../', static-base-uri()))"/>
    
</xsl:stylesheet>
