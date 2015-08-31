<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet 
Module: Shell Stylesheet.
Copyright © 2009-2009 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="2.0" 
 xmlns:fo="http://www.w3.org/1999/XSL/Format" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

   <xsl:import href="dita2fo_import.xsl"/>
   <xsl:import href="../customization/dita2fo_custom.xsl"/>
   <xsl:strip-space elements="menucascade uicontrol abstract"/>

</xsl:stylesheet>