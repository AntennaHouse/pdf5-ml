<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet 
Module: Preprocessing shell Stylesheet.
Copyright © 2009-2014 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="2.0" xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <!-- Import PDF5 shell stylesheet -->
    <xsl:import href="../../com.antennahouse.pdf5.ml/xsl/dita2fo_convmerged_shell.xsl"/>
    <!-- Import own customization stylesheet -->
    <xsl:import href="dita2fo_convmerged.xsl"/>
    
</xsl:stylesheet>
