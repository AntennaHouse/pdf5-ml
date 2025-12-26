<?xml version="1.0" encoding="UTF-8"?>
<!--
 psmi.xsl

 Interpret the Page Sequence Master Interleave formatting semantic described
 at http://www.CraneSoftwrights.com/resources/psmi for interleaving page
 geometries in XSLFO flows.

 $Id: psmi.xsl,v 1.6 2002/11/01 18:11:28 G. Ken Holman Exp $

This semantic, its stylesheet file, and the information contained herein is
provided on an "AS IS" basis and CRANE SOFTWRIGHTS LTD. DISCLAIMS
ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO 
ANY WARRANTY THAT THE USE OF THE INFORMATION HEREIN WILL NOT INFRINGE
ANY RIGHTS OR ANY IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS 
FOR A PARTICULAR PURPOSE.

-->
<xsl:stylesheet xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <xsl:import href="psmi_impl.xsl"/>
  <dita:extension id="com.antennahouse.pdf5.ml.psmi.xsl" behavior="org.dita.dost.platform.ImportXSLAction" xmlns:dita="http://dita-ot.sourceforge.net"/>
  <xsl:import href="../customization/psmi_custom.xsl"/>
</xsl:stylesheet>