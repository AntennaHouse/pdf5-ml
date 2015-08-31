<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet
Module: Stylesheet customization layer
Copyright © 2009-2015 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="2.0" xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="ahf">
    
    <!-- Mandartory overriding stylesheet module. -->
    <xsl:include href="dita2fo_style_set.xsl"/>
    
    <!-- Add your customization here-->
    <xsl:include href="dita2fo_param.xsl"/>
    <xsl:include href="dita2fo_global.xsl"/>
    
</xsl:stylesheet>
