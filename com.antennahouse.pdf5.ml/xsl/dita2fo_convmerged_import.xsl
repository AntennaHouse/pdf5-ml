<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet 
Module: Import layer shell stylesheet for preprocessing
Copyright © 2009-2014 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="2.0" 
 xmlns:fo="http://www.w3.org/1999/XSL/Format" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

   <xsl:include href="dita2fo_constants.xsl"/>
   <xsl:include href="dita2fo_param.xsl"/>
   <xsl:include href="dita2fo_flag_ditaval.xsl"/>
   <xsl:include href="dita2fo_message.xsl"/>
   <xsl:include href="dita2fo_util.xsl"/>
   <xsl:include href="dita2fo_convmerged.xsl"/>
</xsl:stylesheet>