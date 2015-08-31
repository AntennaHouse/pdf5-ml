<?xml version="1.0" encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet
Module: Index shell template
Copyright © 2009-2009 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="2.0" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 xmlns:fo="http://www.w3.org/1999/XSL/Format" 
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 xmlns:psmi="http://www.CraneSoftwrights.com/resources/psmi"
 xmlns:i18n_index_saxon9="java:jp.co.antenna.ah_i18n_index.IndexSortSaxon9"
 extension-element-prefixes="i18n_index_saxon9"
 exclude-result-prefixes="xs ahf i18n_index_saxon9"
>
    <!-- Use I18n Index Library -->
    <xsl:include href="dita2fo_indexi18n.xsl" use-when="system-property('use.i18n.index.lib')='yes'"/>
    
    <!-- Does not use I18n Index Library. Use xsl:sort for index sorting. -->
    <xsl:include href="dita2fo_index.xsl"     use-when="not(system-property('use.i18n.index.lib')='yes')"/>
    <xsl:include href="dita2fo_indexsort.xsl" use-when="not(system-property('use.i18n.index.lib')='yes')"/>
     
    <!-- Common template -->
    <xsl:include href="dita2fo_indexcommon.xsl" />

</xsl:stylesheet>
