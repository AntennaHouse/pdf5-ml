<?xml version='1.0' encoding="UTF-8" ?>
<!--
    ****************************************************************
    DITA to XSL-FO Stylesheet
    Module: Generate merged-middle file from sigle topic
    Copyright © 2009-2023 Antenna House, Inc. All rights reserved.
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
 xmlns:ahd="http://www.antennahouse.com/names/XSLT/Debugging"
 exclude-result-prefixes="ahf" 
>

    <!-- Important notice
         This styleshhet is intended to use XSLT 3.0 rather than XSLT 2.0.
         Use appropriate DITA-OT versions that support XSLT 3.0 XSLT stylesheet.
     -->
    <xsl:include href="dita2fo_util.xsl"/>
    <xsl:include href="dita2fo_error_util.xsl"/>
    <xsl:include href="dita2fo_constants.xsl"/>
    <xsl:include href="dita2fo_message.xsl"/>
    
    <xsl:include href="dita2fo_gen_merged_main.xsl"/>
    <xsl:include href="dita2fo_gen_merged_param.xsl"/>
    
    
</xsl:stylesheet>
